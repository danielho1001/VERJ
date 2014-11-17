//
//  IdeasTableViewController.h
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface IdeasTableViewController : PFQueryTableViewController

@property (nonatomic, strong) PFObject *project;

- (id)initWithProject:(PFObject*)aProject;


@end
