//
//  AddFriendsToNewProjectViewController.h
//  VERJ
//
//  Created by Daniel Ho on 11/22/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "FindFriendsCell.h"

@protocol AddFriendsToNewProjectDelegate <NSObject>

-(void)sendFriendsToCreateProjectPage:(NSMutableArray *)friends;

@end

@interface AddFriendsToNewProjectViewController : PFQueryTableViewController <FindFriendsCellDelegate>

@property (nonatomic, weak) id<AddFriendsToNewProjectDelegate> delegate;

- (id)initWithFriends:(NSMutableArray *)alreadyAddedfriends;

@end
