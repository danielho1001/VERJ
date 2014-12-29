//
//  IdeasTableViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "IdeasTableViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "CreateIdeaButtonItem.h"
#import "BackButton.h"
#import "NewIdeaViewController.h"
#import "VerjUtility.h"
#import "VerjCache.h"
#import <Parse/Parse.h>

@interface IdeasTableViewController()

@property (nonatomic, strong) NSMutableDictionary *outstandingCellQueries;

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@property (nonatomic, strong) MTStatusBarOverlay *statusBar;
@end

@implementation IdeasTableViewController

@synthesize project;

- (id)initWithProject:(PFObject *)aProject {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.outstandingCellQueries = [NSMutableDictionary dictionary];
        
        self.project = aProject;
        
        // The className to query on
        self.parseClassName = IdeaClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        self.shouldReloadOnAppear = YES;
    }
    return self;
}

#pragma mark - UIViewController
-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    /** still a slight delay in animating this */
    
    self.navigationItem.title = [self.project objectForKey:ProjectNameKey];
    self.navigationItem.rightBarButtonItem = [[CreateIdeaButtonItem alloc] initWithTarget:self action:@selector(createIdeaButtonAction:)];
    self.navigationItem.leftBarButtonItem = [[BackButton alloc] initWithTarget:self action:@selector(backButtonAction:) withImageName:@"menu.png"];
    
    self.statusBar = [MTStatusBarOverlay sharedInstance];
    self.statusBar.delegate = self;
    self.statusBar.hidesActivity = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldReloadOnAppear) {
        [self loadObjects];
    }
}

#pragma mark - Data Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.objects count] == 0) {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        /** still has a slight delay in removing the separator */
    } else {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    return [self.objects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSString *CellIdentifier = @"Cell";
    MCSwipeTableViewCell *cell = (MCSwipeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone; // Disallow select highlighting
    cell.idea = object;
    //Add swipe gesture selectors and update information from cache
    
    NSDictionary *attributesForIdea = [[VerjCache sharedCache] attributesForIdea:cell.idea];
    if (attributesForIdea) {
        [self configCell:cell];
    } else {
        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingCellQueryStatus = [self.outstandingCellQueries objectForKey:@(indexPath.row)];
            if (!outstandingCellQueryStatus) {
                PFQuery *query = [VerjUtility queryForActivitiesOnIdea:cell.idea cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingCellQueries removeObjectForKey:@(indexPath.row)];
                        
                        if (error) {
                            NSLog(@"Error in outstandingCellQuery");
                            return;
                        }
                        
                        NSMutableArray *voters = [NSMutableArray array];
                        NSNumber *score = [NSNumber numberWithInt:0];
                        
                        BOOL isVotedByCurrentUser = NO;
                        
                        for (PFObject *activity in objects) {
                         
                            [voters addObject:[activity objectForKey:ActivityFromUserKey]];
                            if ([[activity objectForKey:ActivityContentKey] isEqualToString:@"YES"]) {
                                score = [NSNumber numberWithInt:[score intValue] + 1];
                            } else {
                                score = [NSNumber numberWithInt:[score intValue] - 1];
                            }

                            if ([[[activity objectForKey:ActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                isVotedByCurrentUser = YES;
                            }
                        }
                        
                        [[VerjCache sharedCache] setAttributesForIdea:cell.idea voters:voters withScore:score votedByCurrentUser:isVotedByCurrentUser];
                        
                        [self configCell:cell];
                    }
                }];
            }
        }
    }
    return cell;
}

#pragma mark - Data Source

- (PFQuery *) queryForTable {
    // Query for the ideas the current project contains
    PFQuery *ideasQuery = [PFQuery queryWithClassName:IdeaClassKey];
    [ideasQuery whereKey:IdeaProjectKey equalTo:self.project];
    [ideasQuery includeKey:IdeaProjectKey];
    [ideasQuery orderByDescending:@"updatedAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [ideasQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        
        [ideasQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return ideasQuery;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

}

#pragma mark - ()

-(void)configCell:(MCSwipeTableViewCell *)cell{
    cell.textLabel.text = [cell.idea objectForKey:IdeaContentKey];
    [self updateCell:cell];
    
    [cell setSwipeGestureWithView:cell.upImgView color:cell.upColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self voteOnCell:cell up:YES];
    }];
    
    [cell setSwipeGestureWithView:cell.downImgView color:cell.downColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self voteOnCell:cell up:NO];
    }];
}

- (void)updateCell:(MCSwipeTableViewCell *) cell{
    cell.voteStatus = [[VerjCache sharedCache] isIdeaVotedByCurrentUser:cell.idea];
    cell.score = [[VerjCache sharedCache] scoreForIdea:cell.idea];
    cell.voterCount = [[VerjCache sharedCache] voterCountForIdea:cell.idea];
    /** currently don't store info on who has voted on this idea */
    
    [UIView animateWithDuration:0 animations:^{
        //        [cell setBackgroundColor:[VerjUtility getColorForIdea:cell.idea]];
        [cell.scorePalette setBackgroundColor:[VerjUtility getColorForIdea:cell.idea]];
    }];
}


- (void)voteOnCell:(MCSwipeTableViewCell *)cell up:(BOOL)votedUp {
    if (![[VerjCache sharedCache] isIdeaVotedByCurrentUser:cell.idea]) {
        NSNumber *voteCount = cell.score;
        if (votedUp) {
            voteCount = [NSNumber numberWithInt:[voteCount intValue] + 1];
            [[VerjCache sharedCache] incrementScoreCountForIdea:cell.idea];
        } else {
            voteCount = [NSNumber numberWithInt:[voteCount intValue] - 1];
            [[VerjCache sharedCache] decrementScoreCountForIdea:cell.idea];
        }
        [[VerjCache sharedCache] setIdeaIsVotedByCurrentUser:cell.idea up:votedUp];
        [self updateCell:cell];
        
        [VerjUtility voteIdeaInBackground:cell.idea up:votedUp block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
            }
            else {
                [self.statusBar postMessage:@"Could not save vote in database. Will keep trying" duration:2 animated:YES];
            }
        }];
    } else {
        [self.statusBar postMessage:@"Already voted on this idea" duration:2 animated:YES];
    }
}



-(void)checkForIdeas {
    if ([self.objects count] == 0) {
        [self createIdeaButtonAction:self];
    }
}

-(void)createIdeaButtonAction:(id)sender {
    NewIdeaViewController *newIdeaVC = [[NewIdeaViewController alloc] initWithProject:self.project];
    [self.navigationController pushViewController:newIdeaVC animated:YES];
}

-(void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
