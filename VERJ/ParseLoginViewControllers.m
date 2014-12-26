//
//  ParseLoginViewControllers.m
//  VERJ
//
//  Created by Daniel Ho on 12/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "ParseLoginViewControllers.h"

@implementation ParseLoginViewControllers

- (void) viewDidLoad {
    [super viewDidLoad];

    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
}

- (void)viewDidLayoutSubviews {
    
    UIImageView *bottomBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBottomBackground.png"]];
    [bottomBackground setFrame:CGRectMake(0, 400, self.view.frame.size.width, self.view.frame.size.height - 400)];
    [self.logInView addSubview:bottomBackground];
    
    [self.logInView.logo setFrame:CGRectMake((self.view.frame.size.width - 200.0f)/2, 60.0f, 200.0f, 40.0f)];
    
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"login.png"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup.png"] forState:UIControlStateNormal];
    
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    
    float widthOfFields = 247.0f;
    float centeredTopLeftCorner = (self.view.frame.size.width - widthOfFields)/2;
    float centeredTopRightCorner = self.view.frame.size.width - (self.view.frame.size.width - 250.0f)/2;
    
    [self.logInView.usernameField setFrame:CGRectMake(centeredTopLeftCorner, 129.0f, widthOfFields, 45.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(centeredTopLeftCorner, 182.0f, widthOfFields, 45.0f)];
    
    float widthOfButtons = 114.0f;
    [self.logInView.logInButton setFrame:CGRectMake(centeredTopLeftCorner, 269.0f, widthOfButtons, 37.0f)];
    [self.logInView.signUpButton setFrame:CGRectMake(centeredTopRightCorner - widthOfButtons, 269.0f, widthOfButtons, 37.0f)];

    [self.logInView.facebookButton setFrame:CGRectMake(centeredTopLeftCorner, 350.0f, widthOfFields, 40.0f)];
}

@end
