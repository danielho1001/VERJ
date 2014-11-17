//
//  ProjectsTableViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "ProjectsTableViewController.h"
#import "Constants.h"
#import "NewProjectCell.h"
#import "IdeasTableViewController.h"
#import "CreateProjectViewController.h"
#import "ProjectCell.h"
#import "NewIdeaViewController.h"
#import <Parse/Parse.h>


@interface ProjectsTableViewController ()

@property (nonatomic,strong) UINavigationController *navController;

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@end

@implementation ProjectsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
//        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = ProjectClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
//        self.objectsPerPage = 10;
        
//        // Improve scrolling performance by reusing UITableView section headers
//        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
//        
        self.shouldReloadOnAppear = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
//    self.navigationItem.rightBarButtonItem = [[NewProjectButtonItem alloc] initWithTarget:self action:@selector(newProjectButtonAction:)];
    self.navigationItem.title = @"VERJ";
    self.navController = [[UINavigationController alloc] init];
    
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonAction:)];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data methods

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.row == 0) {
        return nil;
        
    } else {
        NSInteger decrementedRowNum = indexPath.row - 1;
        return [self.objects objectAtIndex:decrementedRowNum];
    }
    
    return nil;
}

- (PFQuery *) queryForTable {
    // Query for the projects the current user is participating in
    PFQuery *projectsQuery = [PFQuery queryWithClassName:ActivityClassKey];
    [projectsQuery whereKey:ActivityTypeKey equalTo:ActivityTypeProjectCreated];
    [projectsQuery whereKey:ActivityFromUserKey equalTo:[PFUser currentUser]];

    // We create a final compound query that will find all of the photos that were
    // taken by the user's friends or by the user
    [projectsQuery includeKey:ActivityProjectKey];
    [projectsQuery orderByDescending:@"updatedAt"];
    return projectsQuery;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.objects count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    NSString *CellIdentifier = @"Cell";
    if (indexPath.row == 0) {
        NewProjectCell *cell = (NewProjectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[NewProjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        return cell;
    } else {
        ProjectCell *cell = (ProjectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ProjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
//        NSInteger decrementedRowNum = indexPath.row - 1;
        PFObject *project = [object objectForKey:ActivityProjectKey];
        cell.textLabel.text = [project objectForKey:ProjectNameKey];
        return cell;
    }

}

#pragma mark - delegate methods

-(void)logoutButtonAction:(id)sender {
    [PFUser logOut];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self presentCreateNewProjectViewController];
    } else {
        NSInteger decrementedRowNum = indexPath.row - 1;
        PFObject *project = [[self.objects objectAtIndex:decrementedRowNum] objectForKey:ActivityProjectKey];
        [self presentIdeasTableViewControllerWithProject:project animated:YES];
    }
}

-(void)presentCreateNewProjectViewController {
    CreateProjectViewController *createProjectVC = [[CreateProjectViewController alloc] init];
    createProjectVC.delegate = self;
    [createProjectVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navController pushViewController:createProjectVC animated:NO];

    [self presentViewController:self.navController animated:YES completion:nil];

}

-(void)presentIdeasTableViewControllerWithProject:(PFObject *)project animated:(BOOL)animated {
    IdeasTableViewController *ideaVC = [[IdeasTableViewController alloc] initWithProject:project];
    [self.navigationController pushViewController:ideaVC animated:animated];
}

-(void)sendNewProjectToProjectsTablePage:(PFObject *)project {
    [self presentIdeasTableViewControllerWithProject:project animated:YES];
}


@end
