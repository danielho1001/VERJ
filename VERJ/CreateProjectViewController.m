//
//  createProjectViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "CreateProjectViewController.h"
#import "Constants.h"
#import "AddFriendsToNewProjectViewController.h"
#import "CreateProjectPanelView.h"
#import "VerjUtility.h"

@interface CreateProjectViewController ()

//@property (nonatomic, strong) CreateProjectPanelView *panelView;

@end

@implementation CreateProjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self) {
        [self setUpView];
//        self.panelView = [[CreateProjectPanelView alloc] initWithFrame:[CreateProjectPanelView rectForView]];
//        [self.view addSubview:self.panelView];
    }
    self.friendsToBeInvited = nil;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

}

- (void)setUpView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    self.projectNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 85.0f, self.view.frame.size.width, 44.0f)];
    self.projectNameField.delegate = self;
    self.projectNameField.backgroundColor = [VerjUtility getVerjOrangeColor];
    self.projectNameField.textColor = [UIColor whiteColor];
    self.projectNameField.placeholder = @"Project Name";
    self.projectNameField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.projectNameField];
    
    UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendsButton.frame = CGRectMake(0.0f, 153.0f, self.view.frame.size.width, 44.0f);
    addFriendsButton.backgroundColor = [VerjUtility getVerjOrangeColor];
    [addFriendsButton setTitle:@"Add Collaborators" forState:UIControlStateNormal];
    [addFriendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addFriendsButton addTarget:self action:@selector(addFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addFriendsButton];
    
    UIButton *createProjectButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 69, self.view.frame.size.width, 69.0f)];
    [createProjectButton setBackgroundImage:[UIImage imageNamed:@"startProject.png"] forState:UIControlStateNormal];
    createProjectButton.titleLabel.text = @"";
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
                
                [projectCreated saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Something went wrong");
                    }
                }];

                [self dismissViewControllerAnimated:YES completion:nil];
                [self.delegate sendNewProjectToProjectsTablePage:project];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't create your project" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }];

    } else {
        
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

-(void)dismissKeyboard {
    [self.projectNameField resignFirstResponder];
}


@end
