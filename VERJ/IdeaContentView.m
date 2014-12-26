//
//  IdeaContentView.m
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "IdeaContentView.h"
#import "VerjUtility.h"

@interface IdeaContentView ()

@property (nonatomic, strong) UIView *mainView;

@end

@implementation IdeaContentView

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [VerjUtility getVerjOrangeColor];
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 250.0f)];
//        mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]];
        [self addSubview:self.mainView];
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 300.0f)];
        self.textView.font = [UIFont systemFontOfSize:14.0f];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.textColor = [UIColor blackColor];
        self.textView.font = [UIFont systemFontOfSize:35];
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textView.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        [self.mainView addSubview:self.textView];
    }
    return self;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

}

#pragma mark - IdeaContentView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 50.0f, [UIScreen mainScreen].bounds.size.width, 500.0f);
}


@end
