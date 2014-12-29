//
//  CreateProjectPanelView.h
//  VERJ
//
//  Created by Daniel Ho on 12/26/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateProjectPanelView : UIView

@property (nonatomic, strong) UITextField *name;

@property (nonatomic, strong) UIButton *addCollaborators;

-(id) initWithFrame:(CGRect)frame;

+ (CGRect)rectForView;


@end
