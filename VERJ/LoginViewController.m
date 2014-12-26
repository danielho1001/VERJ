//
//  LoginViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "LoginViewController.h"
#import "ProjectsTableViewController.h"
#import "VerjCache.h"
#import "Constants.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addButton];
}

#pragma mark - UI Set up

- (void) addButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(loginButtonTouchHandler:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(50.0, 100.0, 160.0, 40.0);
    [self.view addSubview:button];
}

- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"email", @"user_friends", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        [self facebookRequestDidLoad:result];
                    } else {
                        [self facebookRequestDidFailWithError:error];
                    }
                }];
            } else {
                NSLog(@"User with facebook logged in!");
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        [self facebookRequestDidLoad:result];
                    } else {
                        [self facebookRequestDidFailWithError:error];
                    }
                }];
            }
            
            [self presentProjectsTableViewControllerAnimated:YES];
        }
    }];
    
}

- (void)presentProjectsTableViewControllerAnimated:(BOOL)animated {
    ProjectsTableViewController *projectsTableViewController = [[ProjectsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:projectsTableViewController animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)logOut {
    // clear cache
    [[VerjCache sharedCache] clear];
    
    //    // clear NSUserDefaults
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    //    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    //    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //    [self presentLoginViewController];
    
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
