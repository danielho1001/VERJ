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
#import "IdeaCell.h"
#import "CreateIdeaButtonItem.h"
#import "BackButton.h"
#import "NewIdeaViewController.h"
#import "MCSwipeTableViewCell.h"
#import "VerjUtility.h"
#import "VerjCache.h"
#import <Parse/Parse.h>

@interface IdeasTableViewController()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@end

@implementation IdeasTableViewController

@synthesize project;

- (id)initWithProject:(PFObject *)aProject {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
    self.navigationItem.title = [self.project objectForKey:ProjectNameKey];
    self.navigationItem.rightBarButtonItem = [[CreateIdeaButtonItem alloc] initWithTarget:self action:@selector(createIdeaButtonAction:)];
    self.navigationItem.leftBarButtonItem = [[BackButton alloc] initWithTarget:self action:@selector(backButtonAction:) withImageName:@"menu.png"];
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
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withIdea:object];
    }
    
    //Add swipe gesture selectors and update information from cache
    [self configCell:cell];

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
    // Check if there are any ideas. If none, then auto trigger to generation page
//    [self checkForIdeas];
}

#pragma mark - ()

-(void)configCell:(MCSwipeTableViewCell *)cell{
    //Check if there's existing info on this cell in cache
    //If yes, update it
    //
    //If no, query Parse then update
    
    [cell setSwipeGestureWithView:cell.upImgView color:cell.upColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self voteOnCell:cell up:YES];
    }];
    
    [cell setSwipeGestureWithView:cell.downImgView color:cell.downColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self voteOnCell:cell up:NO];
    }];
}

- (void)voteOnCell:(MCSwipeTableViewCell *)cell up:(BOOL)votedUp {
    NSNumber *voteCount = cell.count;
    if (votedUp) {
        voteCount = [NSNumber numberWithInt:[voteCount intValue] + 1];
        [[VerjCache sharedCache] incrementScoreCountForIdea:cell.idea];
    } else {
        voteCount = [NSNumber numberWithInt:[voteCount intValue] - 1];
        [[VerjCache sharedCache] decrementScoreCountForIdea:cell.idea];
    }
    [[VerjCache sharedCache] setIdeaIsVotedByCurrentUser:cell.idea up:votedUp];
    cell.count = voteCount;
    
    [VerjUtility voteIdeaInBackground:cell.idea up:votedUp block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"%@", cell.count);
        }
        else {
            // Do some recovery
        }
    }];
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
