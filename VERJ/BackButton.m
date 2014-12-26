//
//  BackButton.m
//  VERJ
//
//  Created by Daniel Ho on 12/20/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "BackButton.h"

@implementation BackButton

- (id)initWithTarget:(id)target action:(SEL)action withImageName:(NSString *)imgName {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self = [super initWithCustomView:backButton];
    if (self) {
        [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 25.0f)];
        [backButton setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    }
    
    return self;
}


@end
