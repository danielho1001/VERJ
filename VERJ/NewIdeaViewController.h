//
//  NewIdeaViewController.h
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NewIdeaViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) PFObject *project;

- (id)initWithProject:(PFObject*)aProject;


@end
