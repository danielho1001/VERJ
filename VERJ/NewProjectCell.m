//
//  NewProjectCell.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "NewProjectCell.h"

@implementation NewProjectCell
@synthesize createProjectButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.textLabel.text = @"New Project";
        
        self.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:102.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        
//        self.createProjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.createProjectButton.frame = CGRectMake(20.0f, 0.0f, 280.0f, 280.0f);
//        self.createProjectButton.backgroundColor = [UIColor clearColor];
//        UIImage *buttonImage = [UIImage imageNamed:@"createProjectButton.png"];
//        [self.createProjectButton setImage:buttonImage forState:UIControlStateNormal];
//        [self.contentView addSubview:self.createProjectButton];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.createProjectButton.frame = CGRectMake( 20.0f, 0.0f, 280.0f, 280.0f);
}


@end
