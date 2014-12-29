//
//  CreateProjectPanelView.m
//  VERJ
//
//  Created by Daniel Ho on 12/26/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "CreateProjectPanelView.h"
#import "VerjUtility.h"

#define mainViewHeight 400.0f
#define fieldHeight 44.0f
#define startProjectBarHeight 69.0f

@interface CreateProjectPanelView ()

@property (nonatomic, strong) UIView *mainView;

@end

@implementation CreateProjectPanelView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, mainViewHeight)];
//        [self addSubview:self.mainView];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.name = [[UITextField alloc] initWithFrame:CGRectMake(0, 85, self.frame.size.width, fieldHeight)];
        self.name.placeholder = @"Project Name";
        [self.name setBackgroundColor:[VerjUtility getVerjOrangeColor]];
        self.name.textColor = [UIColor whiteColor];
        [self addSubview:self.name];
        
        self.addCollaborators = [[UIButton alloc] initWithFrame:CGRectMake(0, 153, self.frame.size.width, fieldHeight)];
        [self.addCollaborators setBackgroundColor:[VerjUtility getVerjOrangeColor]];
        [self.addCollaborators setTitle:@"Add Collaborators" forState:UIControlStateNormal];
        [self.addCollaborators setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:self.addCollaborators];
    }
    return self;
}

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 69);
}


@end
