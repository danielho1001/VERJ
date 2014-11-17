//
//  createProjectViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "CreateProjectViewController.h"
#import "Constants.h"


@implementation CreateProjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setUpView];

}

- (void)setUpView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    self.projectNameField = [[UITextField alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 300.0f, 30.0f)];
    self.projectNameField.delegate = self;
    self.projectNameField.backgroundColor = [UIColor whiteColor];
    self.projectNameField.placeholder = @"Name the project";
    [self.view addSubview:self.projectNameField];
    
    UIButton *inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteFriendsButton.frame = CGRectMake(30.0f, 300.0f, 300.0f, 30.0f);
    inviteFriendsButton.backgroundColor = [UIColor orangeColor];
    inviteFriendsButton.titleLabel.text = @"Invite Friends";
    inviteFriendsButton.titleLabel.textColor = [UIColor whiteColor];
    [inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inviteFriendsButton];
    
    UIButton *createProjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createProjectButton.backgroundColor = [UIColor orangeColor];
    createProjectButton.frame = CGRectMake( 30.0f, 500.0f, 300.0f, 30.0f);
    createProjectButton.titleLabel.text = @"Create Project";
    createProjectButton.titleLabel.textColor = [UIColor whiteColor];
    [createProjectButton addTarget:self action:@selector(createProjectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createProjectButton];
}

#pragma mark - Selector methods

-(void)inviteFriendsButtonAction:(id)sender {
    
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
        
//        [project setObject: forKey:ProjectParticipantsKey];
        
        // projects are public, but may only be modified by the user who uploaded them
        PFACL *projectACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [projectACL setPublicReadAccess:YES];
        project.ACL = projectACL;
        
        // Save the Project PFObject
        [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFObject *projectCreated = [PFObject objectWithClassName:ActivityClassKey];
                [projectCreated setObject:ActivityTypeProjectCreated forKey:ActivityTypeKey];
                [projectCreated setObject:project forKey:ActivityProjectKey];
                [projectCreated setObject:[PFUser currentUser] forKey:ActivityFromUserKey];
                
//                PFRelation *invitedUsers = [projectCreated relationForKey:ActivityToUserKey];
//                [invitedUsers addObject:[PFUser currentUser]];
//                [projectCreated setObject:invitedUsers forKey:ActivityToUserKey];
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

@end
