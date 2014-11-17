//
//  IdeasTableViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "IdeasTableViewController.h"
#import "Constants.h"
#import "IdeaCell.h"
#import "CreateIdeaButtonItem.h"
#import "NewIdeaViewController.h"
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
        //        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = IdeaClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
//        self.objectsPerPage = 10;
        
        //        // Improve scrolling performance by reusing UITableView section headers
        //        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        //
//        self.shouldReloadOnAppear = YES;
    }
    return self;
}

#pragma mark - UIViewController
-(void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];

//    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
//    UIBarButtonItem* createIdeaButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CreateIdeaButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(createIdeaButtonAction:)];
//    self.navigationItem.rightBarButtonItem = createIdeaButton;
    self.navigationItem.title = @"Project";
    self.navigationItem.rightBarButtonItem = [[CreateIdeaButtonItem alloc] initWithTarget:self action:@selector(createIdeaButtonAction:)];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSString *CellIdentifier = @"Cell";

    IdeaCell *cell = (IdeaCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[IdeaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [object objectForKey:IdeaContentKey];
    return cell;
}

#pragma mark - Data Source

- (PFQuery *) queryForTable {
    // Query for the ideas the current project contains
    PFQuery *ideasQuery = [PFQuery queryWithClassName:IdeaClassKey];
    [ideasQuery whereKey:IdeaProjectKey equalTo:self.project];
    [ideasQuery includeKey:IdeaProjectKey];
    [ideasQuery orderByDescending:@"updatedAt"];
    return ideasQuery;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self checkForIdeas];
}

#pragma mark - Delegate Methods

-(void)checkForIdeas {
    if ([self.objects count] == 0) {
        [self createIdeaButtonAction:self];
    }
}

-(void)createIdeaButtonAction:(id)sender {
    NewIdeaViewController *newIdeaVC = [[NewIdeaViewController alloc] initWithProject:self.project];
    [self.navigationController pushViewController:newIdeaVC animated:YES];
}


@end
