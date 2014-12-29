//
//  createProjectViewController.h
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AddFriendsToNewProjectViewController.h"
#import "MTStatusBarOverlay.h"

@protocol CreateProjectDelegate <NSObject>

-(void)sendNewProjectToProjectsTablePage:(PFObject *)project;

@end

@interface CreateProjectViewController : UIViewController <UITextFieldDelegate, AddFriendsToNewProjectDelegate>

@property (nonatomic, strong) UITextField *projectNameField;

@property (nonatomic, strong) NSMutableArray *friendsToBeInvited;

@property (nonatomic, weak) id<CreateProjectDelegate> delegate;

@end
