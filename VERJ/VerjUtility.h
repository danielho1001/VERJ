//
//  VerjUtility.h
//  VERJ
//
//  Created by Daniel Ho on 11/22/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface VerjUtility : NSObject

+ (UIColor *)getVerjOrangeColor;
+ (UIColor *)getDefaultNavBarColor;
+ (UIColor *)getVerjGreenColor;
+ (UIColor *)getVerjRedColor;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;

+ (void)voteIdeaInBackground:(PFObject *)idea up:(BOOL)vote block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (NSString *)getStringForVote:(BOOL)vote;

+ (void)addUserInBackground:(PFUser *)user toProject:(PFObject *)project block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)addUserEventually:(PFUser *)user toProject:(PFObject *)project block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)addUsersEventually:(NSArray *)users toProject:(PFObject *)project block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)removeUserEventually:(PFUser *)user fromProject:(PFObject *)project;
+ (void)removeUsersEventually:(NSArray *)users fromProject:(PFObject *)project;

+ (PFQuery *)queryForActivitiesOnIdea:(PFObject *)idea cachePolicy:(PFCachePolicy)cachePolicy;



@end
