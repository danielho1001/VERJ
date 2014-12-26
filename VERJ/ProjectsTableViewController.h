//
//  ProjectsTableViewController.h
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "MTStatusBarOverlay.h"
#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "CreateProjectViewController.h"

@interface ProjectsTableViewController : PFQueryTableViewController <CreateProjectDelegate, MTStatusBarOverlayDelegate>

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;

@end
