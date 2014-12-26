//
//  SwipableIdeaCell.h
//  VERJ
//
//  Created by Daniel Ho on 12/20/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#import <Parse/Parse.h>

@interface SwipableIdeaCell : MCSwipeTableViewCell

@property (nonatomic, strong) UIView *upImgView;
@property (nonatomic, strong) UIView *downImgView;

@property (nonatomic, strong) UIColor *upColor;
@property (nonatomic, strong) UIColor *downColor;

@property (nonatomic ,strong) PFObject *idea;
@property (nonatomic, assign) BOOL voteStatus;

@property (nonatomic, strong) NSNumber *count;

- (void)setLikeStatus:(BOOL)liked;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withIdea:(PFObject *)idea;

@end
