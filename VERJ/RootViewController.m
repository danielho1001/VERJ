//
//  RootViewController.m
//  VERJ
//
//  Created by Daniel Ho on 12/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "ProjectsTableViewController.h"
#import <Parse/Parse.h>

@interface RootViewController ()

@property (nonatomic, strong) ProjectsTableViewController *homeViewController;

@end

@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // If not logged in, present login view controller
    if (![PFUser currentUser]) {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    // Present Anypic UI
    [self presentNavController];
    
    // Refresh current user with server side data -- checks if user is still valid and so on
//    [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}

#pragma mark - ()

- (void) presentNavController {
    self.homeViewController = [[ProjectsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
//    [self.homeViewController setFirstLaunch:firstLaunch];
    
    [self.navigationController pushViewController:self.homeViewController animated:NO];
    
    
}

//- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
//    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
//    if (error && error.code == kPFErrorObjectNotFound) {
//        NSLog(@"User does not exist.");
//        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
//        return;
//    }
//    
//    // Check if user is missing a Facebook ID
//    if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
//        // User has Facebook ID.
//        
//        // refresh Facebook friends on each launch
//        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//            if (!error) {
//                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
//                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
//                }
//            } else {
//                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
//                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
//                }
//            }
//        }];
//    } else {
//        NSLog(@"Current user is missing their Facebook ID");
//        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//            if (!error) {
//                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
//                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
//                }
//            } else {
//                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
//                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
//                }
//            }
//        }];
//    }
//}


@end
