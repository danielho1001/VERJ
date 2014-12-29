//
//  IdeasTableViewController.h
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "MCSwipeTableViewCell.h"
#import "MTStatusBarOverlay.h"

@interface IdeasTableViewController : PFQueryTableViewController <MCSwipeTableViewCellDelegate, MTStatusBarOverlayDelegate>

@property (nonatomic, strong) PFObject *project;

- (id)initWithProject:(PFObject*)aProject;


@end
