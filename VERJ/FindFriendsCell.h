//
//  FindFriendsCell.h
//  VERJ
//
//  Created by Daniel Ho on 11/22/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol FindFriendsCellDelegate;

@interface FindFriendsCell : UITableViewCell

@property (nonatomic, strong) id<FindFriendsCellDelegate> delegate;


@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIButton *addFriendButton;


- (void)setUser:(PFUser *)user;

- (void)didTapUserButtonAction:(id)sender;
- (void)didTapAddFriendButtonAction:(id)sender;

+ (CGFloat)heightForCell;

@end

@protocol FindFriendsCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(FindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser;
- (void)cell:(FindFriendsCell *)cellView didTapAddFriendButton:(PFUser *)aUser;


@end
