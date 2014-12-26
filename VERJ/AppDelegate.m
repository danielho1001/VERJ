//
//  AppDelegate.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "LoginViewController.h"
#import "ParseLoginViewControllers.h"
#import "SignUpViewController.h"
#import "ProjectsTableViewController.h"
#import "VerjCache.h"
#import "VerjUtility.h"
#import "Constants.h"
#import "Reachability.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface AppDelegate () {
    BOOL firstLaunch;
}

@property (nonatomic, strong) RootViewController *rootViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    [Parse setApplicationId:@"pGwk7zjK1drm2txjG5dBAGyf9WrMaR5o0DNa3ULy"
                  clientKey:@"PXUeZivhlRLP1IRtMveW87BodxezKV4tqk7PwElc"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
    
    [self monitorReachability];
    
    self.rootViewController = [[RootViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    //    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

#pragma mark - ()

// Set up appearance parameters to achieve Anypic's custom look and feel
- (void)setupAppearance {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
}


- (void)monitorReachability
{
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    
    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser]) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewController {
    [self presentLoginViewControllerAnimated:YES];
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    ParseLoginViewControllers *loginViewController = [[ParseLoginViewControllers alloc] init];
    [loginViewController setDelegate:self];
    
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
    signUpViewController.fields = PFSignUpFieldsDefault;
    [loginViewController setSignUpController:signUpViewController];
    
    loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsLogInButton;
    loginViewController.facebookPermissions = @[ @"user_about_me", @"user_relationships", @"email", @"user_friends", @"user_location" ];
    
    [self.rootViewController presentViewController:loginViewController animated:NO completion:NULL];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        NSLog(@"Proceed");
    }
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)loginViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:@"proceed", nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {

    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [self facebookRequestDidLoad:result];
        } else {
            [self facebookRequestDidFailWithError:error];
        }
    }];
    [self.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    if ([VerjUtility userHasValidFacebookData:[PFUser currentUser]]) {
        [self presentLoginViewController];
        
        [self.navController dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    
    return NO;
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navController popToRootViewControllerAnimated:NO];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (void)logOut {
    // clear cache
    [[VerjCache sharedCache] clear];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
}

- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        // we have friends data
        
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[VerjCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if ([user objectForKey:UserFacebookFriendsKey]) {
                [user removeObjectForKey:UserFacebookFriendsKey];
            }
            
            NSError *error = nil;
            
            // find common Facebook friends already using Anypic
            PFQuery *facebookFriendsQuery = [PFUser query];
            [facebookFriendsQuery whereKey:UserFacebookIDKey containedIn:facebookIds];
            
            NSArray *fbFriends = [facebookFriendsQuery findObjects:&error];
            
            if (!error) {
                [fbFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                    PFObject *joinActivity = [PFObject objectWithClassName:ActivityClassKey];
                    [joinActivity setObject:user forKey:ActivityFromUserKey];
                    //                    [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                    [joinActivity setObject:ActivityTypeJoined forKey:ActivityTypeKey];
                    
                    PFACL *joinACL = [PFACL ACL];
                    [joinACL setPublicReadAccess:YES];
                    joinActivity.ACL = joinACL;
                    
                    // make sure our join activity is always earlier than a follow
                    [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        //                        [PAPUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                        //                            // This block will be executed once for each friend that is followed.
                        //                            // We need to refresh the timeline when we are following at least a few friends
                        //                            // Use a timer to avoid refreshing innecessarily
                        //                            if (self.autoFollowTimer) {
                        //                                [self.autoFollowTimer invalidate];
                        //                            }
                        //
                        //                            self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                        //                        }];
                    }];
                }];
            }
            
            //            if (![self shouldProceedToMainInterface:user]) {
            //                [self logOut];
            //                return;
            //            }
            
            //            if (!error) {
            //                [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
            //                if (anypicFriends.count > 0) {
            //                    self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
            //                    self.hud.dimBackground = YES;
            //                    self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
            //                } else {
            //                    [self.homeViewController loadObjects];
            //                }
            //            }
            
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        //        self.hud.labelText = NSLocalizedString(@"Creating Profile", nil);
        
        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:UserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:UserDisplayNameKey];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:UserFacebookIDKey];
            }
            
            NSString *facebookEmail = result[@"email"];
            if (facebookEmail && [facebookEmail length] != 0) {
                [user setObject:facebookEmail forKey:UserEmailKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}


@end
