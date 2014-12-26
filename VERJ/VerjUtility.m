//
//  VerjUtility.m
//  VERJ
//
//  Created by Daniel Ho on 11/22/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "VerjUtility.h"
#import "Constants.h"
#import "VerjCache.h"

@implementation VerjUtility

+ (UIColor *)getVerjOrangeColor {
    return [UIColor colorWithRed:255.0/255.0f green:102.0/255.0f blue:0.0/255.0f alpha:1.0f];
}

+ (UIColor *)getDefaultNavBarColor {
    return [UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1.0f];
}

+ (UIColor *)getVerjGreenColor {
    return [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
}

+ (UIColor *)getVerjRedColor {
    return [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:UserFacebookIDKey];
    return (facebookId && facebookId.length > 0);
}

+ (void)voteIdeaInBackground:(PFObject *)idea up:(BOOL)vote block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingVotes = [PFQuery queryWithClassName:ActivityClassKey];
    [queryExistingVotes whereKey:ActivityToIdeaKey equalTo:idea];
    [queryExistingVotes whereKey:ActivityTypeKey equalTo:ActivityTypeIdeaVote];
    [queryExistingVotes whereKey:ActivityFromUserKey equalTo:[PFUser currentUser]];
    
    [queryExistingVotes setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [queryExistingVotes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *voteActivity = [PFObject objectWithClassName:ActivityClassKey];
        [voteActivity setObject:ActivityTypeIdeaVote forKey:ActivityTypeKey];
        [voteActivity setObject:[PFUser currentUser] forKey:ActivityFromUserKey];
        PFRelation *toUserRelation = [voteActivity relationForKey:ActivityToUserKey];
        [toUserRelation addObject:[idea objectForKey:IdeaFromUserKey]];
        [voteActivity setObject:idea forKey:ActivityToIdeaKey];
//        [voteActivity setObject:[VerjUtility getStringForVote:vote] forKey:ActivityContentKey];
        
        PFACL *voteACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [voteACL setPublicReadAccess:YES];
//        [voteACL setWriteAccess:YES forUser:[PFUser currentUser]];
        voteActivity.ACL = voteACL;
        
        [voteActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
//            // refresh cache
//            PFQuery *query = [VerjUtility queryForActivitiesOnIdea:idea cachePolicy:kPFCachePolicyNetworkOnly];
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                if (!error) {
//                    
//                    NSMutableArray *likers = [NSMutableArray array];
//                    NSMutableArray *commenters = [NSMutableArray array];
//                    
//                    BOOL isLikedByCurrentUser = NO;
//                    
//                    for (PFObject *activity in objects) {
//                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
//                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
//                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
//                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
//                        }
//                        
//                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
//                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
//                                isLikedByCurrentUser = YES;
//                            }
//                        }
//                    }
//                    
//                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
//                }
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
//            }];
            
        }];
    }];


}

+ (NSString *)getStringForVote:(BOOL)votedUp {
    if (votedUp) {
        return @"YES";
    } else {
        return @"NO";
    }
}

+ (void)addUserInBackground:(PFUser *)user toProject:(PFObject *)project block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:ActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:ActivityFromUserKey];
    [followActivity setObject:user forKey:ActivityToUserKey];
    [followActivity setObject:ActivityTypeAddFriendToProject forKey:ActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[VerjCache sharedCache] setProjectStatus:YES forUser:user andProject:project];
}

+ (void)addUserEventually:(PFUser *)user toProject:(PFObject *)project block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *addFriendToProjectActivity = [PFObject objectWithClassName:ActivityClassKey];
    [addFriendToProjectActivity setObject:[PFUser currentUser] forKey:ActivityFromUserKey];
    PFRelation *toUserRelation = [addFriendToProjectActivity relationForKey:ActivityToUserKey];
    [toUserRelation addObject:user];
    [addFriendToProjectActivity setObject:ActivityTypeAddFriendToProject forKey:ActivityTypeKey];
    [addFriendToProjectActivity setObject:project forKey:ActivityToProjectKey];
    PFACL *addFriendToProjectACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [addFriendToProjectACL setPublicReadAccess:YES];
    addFriendToProjectActivity.ACL = addFriendToProjectACL;
    
    [addFriendToProjectActivity saveEventually:completionBlock];
    [[VerjCache sharedCache] setProjectStatus:YES forUser:user andProject:project];
}

+ (void)addUsersEventually:(NSArray *)users toProjects:(PFObject *)project block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [VerjUtility addUserEventually:user toProject:project block:completionBlock];
        [[VerjCache sharedCache] setProjectStatus:YES forUser:user andProject:project];
    }
}

+ (void)removeUserEventually:(PFUser *)user toProject:(PFObject *)project {
    PFQuery *query = [PFQuery queryWithClassName:ActivityClassKey];
    [query whereKey:ActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:ActivityToProjectKey equalTo:project];
    [query whereKey:ActivityToUserKey equalTo:user];
    [query whereKey:ActivityTypeKey equalTo:ActivityTypeAddFriendToProject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *addFriendToProjectActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *addFriendToProjectActivity in addFriendToProjectActivities) {
                [addFriendToProjectActivity deleteEventually];
            }
        }
    }];
    [[VerjCache sharedCache] setProjectStatus:NO forUser:user andProject:nil];
}

+ (void)removeUsersEventually:(NSArray *)users toProject:(PFObject *)project {
    PFQuery *query = [PFQuery queryWithClassName:ActivityClassKey];
    [query whereKey:ActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:ActivityToUserKey containedIn:users];
    [query whereKey:ActivityToProjectKey equalTo:project];
    [query whereKey:ActivityTypeKey equalTo:ActivityTypeAddFriendToProject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[VerjCache sharedCache] setProjectStatus:NO forUser:user andProject:nil];
    }
}


@end
