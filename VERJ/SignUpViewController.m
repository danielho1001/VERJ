//
//  SignUpViewController.m
//  VERJ
//
//  Created by Daniel Ho on 12/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "SignUpViewController.h"

@implementation SignUpViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];

}

- (void)viewDidLayoutSubviews {
    
    UIImageView *bottomBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBottomBackground.png"]];
    [bottomBackground setFrame:CGRectMake(0, 400, self.view.frame.size.width, self.view.frame.size.height - 400)];
    [self.signUpView addSubview:bottomBackground];
    
    [self.signUpView.logo setFrame:CGRectMake((self.view.frame.size.width - 200.0f)/2, 60.0f, 200.0f, 40.0f)];
    
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup.png"] forState:UIControlStateNormal];
    
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.signUpView.dismissButton setTitle:@"" forState:UIControlStateNormal];
    
    float widthOfFields = 247.0f;
    float centeredTopLeftCorner = (self.view.frame.size.width - widthOfFields)/2;
    float centeredTopRightCorner = self.view.frame.size.width - (self.view.frame.size.width - 250.0f)/2;
    
    [self.signUpView.usernameField setFrame:CGRectMake(centeredTopLeftCorner, 129.0f, widthOfFields, 45.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(centeredTopLeftCorner, 182.0f, widthOfFields, 45.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(centeredTopLeftCorner, 235.0f, widthOfFields, 45.0f)];
    
    float widthOfButtons = 114.0f;
    [self.signUpView.dismissButton setFrame:CGRectMake(centeredTopLeftCorner, 290.0f, widthOfButtons, 37.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(centeredTopRightCorner - widthOfButtons, 290.0f, widthOfButtons, 37.0f)];
    
}


@end
