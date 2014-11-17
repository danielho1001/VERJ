//
//  CreateIdeaButtonItem.m
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "CreateIdeaButtonItem.h"

@implementation CreateIdeaButtonItem

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *createIdeaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self = [super initWithCustomView:createIdeaButton];
    if (self) {
//        [createIdeaButton setBackgroundImage:[UIImage imageNamed:@"CreateIdeaButton.png"] forState:UIControlStateNormal];
        [createIdeaButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [createIdeaButton setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 32.0f)];
        [createIdeaButton setImage:[UIImage imageNamed:@"CreateIdeaButton.png"] forState:UIControlStateNormal];
//        [createIdeaButton setImage:[UIImage imageNamed:@"ButtonImageSettingsSelected.png"] forState:UIControlStateHighlighted];
    }
    
    return self;
}

@end
