//
//  createProjectViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "CreateProjectViewController.h"
#import "Constants.h"
#import "FindFriendsViewController.h"
#import "AddFriendsToNewProjectViewController.h"

@implementation CreateProjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    
    self.friendsToBeInvited = nil;

}

- (void)setUpView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    self.projectNameField = [[UITextField alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 300.0f, 30.0f)];
    self.projectNameField.delegate = self;
    self.projectNameField.backgroundColor = [UIColor whiteColor];
    self.projectNameField.placeholder = @"Name the project";
    [self.view addSubview:self.projectNameField];
    
    UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendsButton.frame = CGRectMake(30.0f, 300.0f, 300.0f, 30.0f);
    addFriendsButton.backgroundColor = [UIColor orangeColor];
    [addFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    [addFriendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addFriendsButton addTarget:self action:@selector(addFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addFriendsButton];
    
    UIButton *createProjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createProjectButton.backgroundColor = [UIColor orangeColor];
    createProjectButton.frame = CGRectMake( 30.0f, 500.0f, 300.0f, 30.0f);
    [createProjectButton setTitle:@"Create Project" forState:UIControlStateNormal];
    [createProjectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createProjectButton addTarget:self action:@selector(createProjectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createProjectButton];
}

#pragma mark - Selector methods

-(void)addFriendsButtonAction:(id)sender {
    AddFriendsToNewProjectViewController *addFriendsVC = [[AddFriendsToNewProjectViewController alloc] initWithFriends:self.friendsToBeInvited];
    addFriendsVC.delegate = self;
    [self.navigationController pushViewController:addFriendsVC animated:YES];
}

-(void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createProjectButtonAction:(id)sender {
    if ([self.projectNameField.text length] != 0) {
        NSString *trimmedComment = [self.projectNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // create a photo object
        PFObject *project = [PFObject objectWithClassName:ProjectClassKey];
        [project setObject:[PFUser currentUser] forKey:ProjectUserKey];
        [project setObject:trimmedComment forKey:ProjectNameKey];
        PFRelation *participantsRelation = [project relationForKey:ProjectParticipantsKey];
        for (PFObject *friend in self.friendsToBeInvited) {
            [participantsRelation addObject:friend];
        }
        // projects are public, but may only be modified by the user who uploaded them
        PFACL *projectACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [projectACL setPublicReadAccess:YES];
        project.ACL = projectACL;
        
        // Save the Project PFObject
        [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFObject *projectCreated = [PFObject objectWithClassName:ActivityClassKey];
                [projectCreated setObject:ActivityTypeProjectCreated forKey:ActivityTypeKey];
                [projectCreated setObject:project forKey:ActivityToProjectKey];
                [projectCreated setObject:[PFUser currentUser] forKey:ActivityFromUserKey];

                PFRelation *invitedUsersRelation = [projectCreated relationForKey:ActivityToUserKey];
                for (PFObject *friend in self.friendsToBeInvited) {
                    [invitedUsersRelation addObject:friend];
                }
                [projectCreated setObject:trimmedComment forKey:ActivityContentKey];
                
                PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [ACL setPublicReadAccess:YES];
                projectCreated.ACL = ACL;
                
                [projectCreated saveEventually];

                [self dismissViewControllerAnimated:YES completion:nil];
                [self.delegate sendNewProjectToProjectsTablePage:project];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't create your project" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }];

    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Delegate Methods

-(void)sendFriendsToCreateProjectPage:(NSMutableArray *)friends {
    self.friendsToBeInvited = friends;
}


@end
