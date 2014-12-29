//
//  AddFriendsToNewProjectViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/22/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "AddFriendsToNewProjectViewController.h"
#import "Constants.h"
#import "VerjCache.h"

@interface AddFriendsToNewProjectViewController ()

@property (nonatomic, strong) NSDictionary *friendsDictionary;

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *friendsIdArray;

@end

@implementation AddFriendsToNewProjectViewController
@synthesize friendsDictionary;

- (id)initWithFriends:(NSMutableArray *)aFriends {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        if (aFriends) {
            self.friends = aFriends;
            self.friendsIdArray = [[NSMutableArray alloc] init];
            for (PFUser *friend in self.friends) {
                [self.friendsIdArray addObject:friend.objectId];
            }
        } else {
            self.friends = [[NSMutableArray alloc] init];
        }
        
//        self.outstandingAddFriendQueries = [NSMutableDictionary dictionary];
//        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
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
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row < self.objects.count) {
//        return [FindFriendsCell heightForCell];
//    } else {
//        return 44.0f;
//    }
    return [FindFriendsCell heightForCell];
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    FindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[FindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    [cell setUser:(PFUser*)object];
    
    cell.addFriendButton.selected = NO;
    cell.tag = indexPath.row;
    [cell.addFriendButton setSelected:[self statusForFriend:cell.user]];
    
    return cell;
}

#pragma mark - Delegate Methods

- (void)cell:(FindFriendsCell *)cellView didTapAddFriendButton:(PFUser *)aUser {
    [self shouldToggleAddFriendForCell:cellView];
}

- (void)shouldToggleAddFriendForCell:(FindFriendsCell*)cell {
    PFUser *cellUser = cell.user;
    if ([cell.addFriendButton isSelected]) {
        // Remove
        cell.addFriendButton.selected = NO;
        [self removeFriend:cellUser];
    } else {
        // Add
        cell.addFriendButton.selected = YES;
        [self addFriend:cellUser];
    }
}

-(void)addFriend:(PFUser *)aFriend {
    if ([self.friendsIdArray containsObject:aFriend.objectId]) {
        
    } else {
        [self.friends addObject:aFriend];
        [self.friendsIdArray addObject:aFriend.objectId];
    }
}

-(void)removeFriend:(PFUser *)aFriend {
    if ([self.friendsIdArray containsObject:aFriend.objectId]) {
        [self.friends removeObject:aFriend];
        [self.friendsIdArray removeObject:aFriend.objectId];
    }
}

-(BOOL)statusForFriend:(PFUser *)aFriend {
    if ([self.friendsIdArray containsObject:aFriend.objectId]) {
        return YES;
    } else return NO;
}

-(void)doneButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate sendFriendsToCreateProjectPage:self.friends];
}


@end
