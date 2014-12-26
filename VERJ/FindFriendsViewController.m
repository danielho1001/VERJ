//
//  FindFriendsViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/22/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "FindFriendsViewController.h"
#import "VerjCache.h"
#import "Constants.h"
#import "VerjUtility.h"

@interface FindFriendsViewController ()

@property (nonatomic, strong) NSMutableDictionary *outstandingAddFriendQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;

@end

@implementation FindFriendsViewController

@synthesize outstandingAddFriendQueries;
@synthesize outstandingCountQueries;

- (id)initWithProject:(PFObject *)aProject {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.outstandingAddFriendQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
//        self.objectsPerPage = 15;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        return [FindFriendsCell heightForCell];
    } else {
        return 44.0f;
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    // Use cached facebook friend ids
    NSArray *facebookFriends = [[VerjCache sharedCache] facebookFriends];
    
    // Query for all friends you have on facebook and who are using the app
    PFQuery *friendsQuery = [PFUser query];
    [friendsQuery whereKey:UserFacebookIDKey containedIn:facebookFriends];
    
    friendsQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (self.objects.count == 0) {
        friendsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [friendsQuery orderByAscending:UserDisplayNameKey];
    
    return friendsQuery;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

//    PFQuery *friendHasBeenAddedQuery = [PFQuery queryWithClassName:ActivityClassKey];
//    [friendHasBeenAddedQuery whereKey:ActivityFromUserKey equalTo:[PFUser currentUser]];
//    [friendHasBeenAddedQuery whereKey:ActivityTypeKey equalTo:ActivityTypeAddFriendToProject];
//    [friendHasBeenAddedQuery whereKey:ActivityToUserKey containedIn:self.objects];
//    [friendHasBeenAddedQuery setCachePolicy:kPFCachePolicyNetworkOnly];
//    
//    [friendHasBeenAddedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        if (!error) {
//            if (number == self.objects.count) {
//                for (PFUser *user in self.objects) {
//                    [[VerjCache sharedCache] setProjectStatus:YES forUser:user andProject:self.project];
//                }
//            } else if (number == 0) {
//                for (PFUser *user in self.objects) {
//                    [[VerjCache sharedCache] setProjectStatus:NO forUser:user andProject:self.project];
//                }
//            }
//        }
//    }];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    FindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[FindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
//    [cell setUser:(PFUser*)object];
//
//    NSDictionary *attributes = [[VerjCache sharedCache] attributesForUser:(PFUser *)object];
//    
//    cell.addFriendButton.selected = NO;
//    cell.tag = indexPath.row;
//    if (attributes) {
//        [cell.addFriendButton setSelected:[[VerjCache sharedCache] projectStatusForUser:(PFUser *)object andProject:self.project]];
//    } else {
//        @synchronized(self) {
//            NSNumber *outstandingQuery = [self.outstandingAddFriendQueries objectForKey:indexPath];
//            if (!outstandingQuery) {
//                [self.outstandingAddFriendQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
//                PFQuery *friendHasBeenAddedQuery = [PFQuery queryWithClassName:ActivityClassKey];
//                [friendHasBeenAddedQuery whereKey:ActivityFromUserKey equalTo:[PFUser currentUser]];
//                [friendHasBeenAddedQuery whereKey:ActivityTypeKey equalTo:ActivityTypeAddFriendToProject];
//                [friendHasBeenAddedQuery whereKey:ActivityToUserKey equalTo:object];
//                [friendHasBeenAddedQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
//                
//                [friendHasBeenAddedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//                    @synchronized(self) {
//                        [self.outstandingAddFriendQueries removeObjectForKey:indexPath];
//                        [[VerjCache sharedCache] setProjectStatus:(!error && number > 0) forUser:(PFUser *)object andProject:self.project];
//                    }
//                    if (cell.tag == indexPath.row) {
//                        [cell.addFriendButton setSelected:(!error && number > 0)];
//                    }
//                }];
//            }
//        }
//    }

    return cell;
}

#pragma mark - FindFriendsCellDelegate

- (void)cell:(FindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
//    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
//    [accountViewController setUser:aUser];
//    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(FindFriendsCell *)cellView didTapAddFriendButton:(PFUser *)aUser {
    [self shouldToggleAddFriendForCell:cellView];
}

- (void)shouldToggleAddFriendForCell:(FindFriendsCell*)cell {
//    PFUser *cellUser = cell.user;
//    if ([cell.addFriendButton isSelected]) {
//        // Unfollow
//        cell.addFriendButton.selected = NO;
//        [VerjUtility removeUserEventually:cellUser fromProject:self.project];
////        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
//    } else {
//        // Follow
//        cell.addFriendButton.selected = YES;
//        [VerjUtility addUserEventually:cellUser toProject:self.project block:^(BOOL succeeded, NSError *error) {
//            if (!error) {
////                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
//            } else {
//                cell.addFriendButton.selected = NO;
//            }
//        }];
//    }
}


@end
