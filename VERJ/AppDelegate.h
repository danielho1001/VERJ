//
//  AppDelegate.h
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;

- (void)logOut;

- (void)presentLoginViewController;
- (void)presentLoginViewControllerAnimated:(BOOL)animated;

- (void)facebookRequestDidLoad:(id)result;
- (void)facebookRequestDidFailWithError:(NSError *)error;


@end

