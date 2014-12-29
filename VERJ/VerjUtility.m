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

+ (UIColor *)getColorForIdea:(PFObject *)idea {
    NSNumber *score = [[VerjCache sharedCache] scoreForIdea:idea];
    NSNumber *votersCount = [[VerjCache sharedCache] voterCountForIdea:idea];
    float red = 255.0/255.0;
    float green = 255.0/255.0;
    float blue = 255.0/255.0;
    float alpha = 1.0;
    
    if ([score floatValue] > 0) {
        green = 102.0/255.0;
        blue = 0.0/255.0;
        if ([score floatValue] >= 10) {
            alpha = 1.0;
        } else {
            alpha = [score floatValue]/[votersCount floatValue];
        }
    } else if ([score floatValue]< 0) {
        red = 0.0/255.0;
        green = 204.0/255.0;
        blue = 204.0/255.0;
        if ([score floatValue] <= -10) {
            alpha = 1.0;
        } else {
            alpha = (abs([score floatValue]))/[votersCount floatValue];
        }
    }  else if ([score floatValue] == 0){ // Need to account for if note has been voted
        red = 0.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
        alpha = 0.1;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
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
        [voteActivity setObject:[VerjUtility getStringForVote:vote] forKey:ActivityContentKey];
        
        PFACL *voteACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [voteACL setPublicReadAccess:YES];
        [voteACL setWriteAccess:YES forUser:[PFUser currentUser]];
        voteActivity.ACL = voteACL;
        
        [voteActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            
            // refresh cache
            PFQuery *query = [VerjUtility queryForActivitiesOnIdea:idea cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *voters = [NSMutableArray array];
                    NSNumber *score = [NSNumber numberWithInt:0];
                    
                    BOOL isVotedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        [voters addObject:[activity objectForKey:ActivityFromUserKey]];
                        if ([[activity objectForKey:ActivityContentKey] isEqualToString:@"YES"]) {
                            score = [NSNumber numberWithInt:[score intValue] + 1];
                        } else {
                            score = [NSNumber numberWithInt:[score intValue] - 1];
                        }
                        
                        if ([[[activity objectForKey:ActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            isVotedByCurrentUser = YES;
                        }
                    }
                    
                    [[VerjCache sharedCache] setAttributesForIdea:idea voters:voters withScore:score votedByCurrentUser:isVotedByCurrentUser];
                }
                
            }];
            
        }];
    }];


}

+ (PFQuery *)queryForActivitiesOnIdea:(PFObject *)idea cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryVotes = [PFQuery queryWithClassName:ActivityClassKey];
    [queryVotes whereKey:ActivityToIdeaKey equalTo:idea];
    [queryVotes whereKey:ActivityTypeKey equalTo:ActivityTypeIdeaVote];
    
    [queryVotes setCachePolicy:cachePolicy];
    [queryVotes includeKey:ActivityFromUserKey];
    [queryVotes includeKey:ActivityToIdeaKey];
    
    return queryVotes;
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
