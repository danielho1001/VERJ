//
//  createProjectViewController.h
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol CreateProjectDelegate <NSObject>

-(void)sendNewProjectToProjectsTablePage:(PFObject *)project;

@end

@interface CreateProjectViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *projectNameField;

@property (nonatomic, weak) id<CreateProjectDelegate> delegate;

@end
