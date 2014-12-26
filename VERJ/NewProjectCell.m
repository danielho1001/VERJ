//
//  NewProjectCell.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "NewProjectCell.h"
#import "VerjUtility.h"

@interface NewProjectCell ()

@property (nonatomic, strong) UIImageView *plusImage;

@end

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
        self.textLabel.textColor = [UIColor whiteColor];
        
        self.backgroundColor = [VerjUtility getVerjOrangeColor];
        
        self.plusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus.png"]];
        [self addSubview:self.plusImage];
        
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
    
    
    [self.plusImage setFrame:CGRectMake( self.frame.size.width - 60, (self.frame.size.height - 40)/2, 40.0f, 40.0f)];
}


@end
