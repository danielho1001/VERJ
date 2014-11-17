//
//  ProjectCell.m
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "ProjectCell.h"

@implementation ProjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        //        self.createProjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        self.createProjectButton.frame = CGRectMake(20.0f, 0.0f, 280.0f, 280.0f);
        //        self.createProjectButton.backgroundColor = [UIColor clearColor];
        //        UIImage *buttonImage = [UIImage imageNamed:@"CreateProjectButton.png"];
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
