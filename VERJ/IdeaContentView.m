//
//  IdeaContentView.m
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "IdeaContentView.h"

@implementation IdeaContentView

@synthesize ideaContentTextView;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:225.0/255.0f green:102.0/255.0f blue:0.0/255.0f alpha:1.0f];
        
        ideaContentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, self.frame.size.width, 300.0f)];
        ideaContentTextView.font = [UIFont systemFontOfSize:14.0f];
//        ideaContentTextView.returnKeyType = UIReturnKeySend;
        ideaContentTextView.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        [self addSubview:ideaContentTextView];
    }
    return self;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

}


#pragma mark - PAPPhotoDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 50.0f, [UIScreen mainScreen].bounds.size.width, 500.0f);
}


@end
