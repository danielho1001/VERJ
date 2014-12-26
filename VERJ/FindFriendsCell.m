//
//  FindFriendsCell.m
//  VERJ
//
//  Created by Daniel Ho on 11/22/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "FindFriendsCell.h"
#import "Constants.h"

@interface FindFriendsCell ()
@property (nonatomic, strong) UIButton *nameButton;

@end

@implementation FindFriendsCell

@synthesize user;
@synthesize nameButton;
@synthesize addFriendButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nameButton.backgroundColor = [UIColor clearColor];
        self.nameButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.nameButton setTitleColor:[UIColor colorWithRed:87.0f/255.0f green:72.0f/255.0f blue:49.0f/255.0f alpha:1.0f]
                              forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f]
                              forState:UIControlStateHighlighted];
        [self.nameButton setTitleShadowColor:[UIColor whiteColor]
                                    forState:UIControlStateNormal];
        [self.nameButton setTitleShadowColor:[UIColor whiteColor]
                                    forState:UIControlStateSelected];
        [self.nameButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nameButton];
        
        self.addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.addFriendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.addFriendButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f);
//        [self.addFriendButton setBackgroundImage:[UIImage imageNamed:@"ButtonAdd.png"]
//                                     forState:UIControlStateNormal];
//        [self.addFriendButton setBackgroundImage:[UIImage imageNamed:@"ButtonAdd.png"]
//                                     forState:UIControlStateSelected];
//        [self.addFriendButton setImage:[UIImage imageNamed:@"IconTick.png"]
//                           forState:UIControlStateSelected];
        [self.addFriendButton setTitle:NSLocalizedString(@"Add  ", @"Add string, with spaces added for centering")
                           forState:UIControlStateNormal];
        [self.addFriendButton setTitle:@"Added"
                           forState:UIControlStateSelected];
        [self.addFriendButton setTitleColor:[UIColor colorWithRed:84.0f/255.0f green:57.0f/255.0f blue:45.0f/255.0f alpha:1.0f]
                                forState:UIControlStateNormal];
        [self.addFriendButton setTitleColor:[UIColor colorWithRed:84.0f/255.0f green:57.0f/255.0f blue:45.0f/255.0f alpha:1.0f]
                                forState:UIControlStateSelected];
        [self.addFriendButton setTitleShadowColor:[UIColor colorWithRed:232.0f/255.0f green:203.0f/255.0f blue:168.0f/255.0f alpha:1.0f]
                                      forState:UIControlStateNormal];
        [self.addFriendButton setTitleShadowColor:[UIColor colorWithRed:232.0f/255.0f green:203.0f/255.0f blue:168.0f/255.0f alpha:1.0f]
                                      forState:UIControlStateSelected];
        self.addFriendButton.titleLabel.shadowOffset = CGSizeMake( 0.0f, -1.0f);
        [self.addFriendButton addTarget:self action:@selector(didTapAddFriendButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.addFriendButton];

    }
    
    return self;
}

#pragma mark - PAPFindFriendsCell

- (void)setUser:(PFUser *)aUser {
    user = aUser;

    // Set name
    NSString *nameString = [self.user objectForKey:UserDisplayNameKey];
    CGSize nameSize = [nameString boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX)
                                               options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]}
                                               context:nil].size;
    [nameButton setTitle:[self.user objectForKey:UserDisplayNameKey] forState:UIControlStateNormal];
    [nameButton setTitle:[self.user objectForKey:UserDisplayNameKey] forState:UIControlStateHighlighted];
    
    [nameButton setFrame:CGRectMake( 60.0f, 17.0f, nameSize.width, nameSize.height)];
    
    // Set follow button
    [addFriendButton setFrame:CGRectMake( 208.0f, 20.0f, 103.0f, 32.0f)];
}

#pragma mark - ()

+ (CGFloat)heightForCell {
    return 67.0f;
}

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}

/* Inform delegate that the follow button was tapped */
- (void)didTapAddFriendButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapAddFriendButton:)]) {
        [self.delegate cell:self didTapAddFriendButton:self.user];
    }
}


@end
