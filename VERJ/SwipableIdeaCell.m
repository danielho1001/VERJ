//
//  SwipableIdeaCell.m
//  VERJ
//
//  Created by Daniel Ho on 12/20/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "SwipableIdeaCell.h"
#import "VerjUtility.h"
#import "Constants.h"

@implementation SwipableIdeaCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withIdea:(PFObject *)idea{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.upImgView = [self viewWithImageName:@"up.png"];
        self.upColor = [VerjUtility getVerjGreenColor];
        
        self.downImgView = [self viewWithImageName:@"down.png"];
        self.downColor = [VerjUtility getVerjRedColor];
        
        self.textLabel.text = [idea objectForKey:IdeaContentKey];
    }
    
    return self;
}

- (UIImageView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

@end
