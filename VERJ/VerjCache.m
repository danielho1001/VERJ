//
//  VerjCache.m
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "VerjCache.h"
#import "Constants.h"

@interface VerjCache()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation VerjCache
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PAPCache

- (void)clear {
    [self.cache removeAllObjects];
}

- (void)setAttributesForIdea:(PFObject *)idea voters:(NSArray *)voters score:(NSNumber *)score votedByCurrentUser:(BOOL)votedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:votedByCurrentUser],IdeaAttributesIsVotedByCurrentUserKey,
                                @([voters count]),IdeaAttributesVoterCountKey,
                                score, IdeaAttributesScoreCountKey,
                                voters,IdeaAttributesVotersKey,nil];
    [self setAttributes:attributes forIdea:idea];
}

- (NSDictionary *)attributesForIdea:(PFObject *)idea {
    NSString *key = [self keyForIdea:idea];
    return [self.cache objectForKey:key];
}

- (NSDictionary *)attributesForProject:(PFObject *)project {
    NSString *key = [self keyForProject:project];
    return [self.cache objectForKey:key];
}

- (NSNumber *)scoreCountForIdea:(PFObject *)idea {
    NSDictionary *attributes = [self attributesForIdea:idea];
    if (attributes) {
        return [attributes objectForKey:IdeaAttributesScoreCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)voterCountForIdea:(PFObject *)idea {
    NSDictionary *attributes = [self attributesForIdea:idea];
    if (attributes) {
        return [attributes objectForKey:IdeaAttributesVoterCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)ideaCountForProject:(PFObject *)project {
    NSDictionary *attributes = [self attributesForProject:project];
    if (attributes) {
        return [attributes objectForKey:ProjectAttributesIdeaCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSArray *)votersForIdea:(PFObject *)idea {
    NSDictionary *attributes = [self attributesForIdea:idea];
    if (attributes) {
        return [attributes objectForKey:IdeaAttributesVotersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)contributorsForProject:(PFObject *)project {
    NSDictionary *attributes = [self attributesForProject:project];
    if (attributes) {
        return [attributes objectForKey:ProjectAttributesContributorsKey];
    }
    
    return [NSArray array];
}

- (void)setIdeaIsVotedByCurrentUser:(PFObject *)idea up:(BOOL)voted {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForIdea:idea]];
    [attributes setObject:[NSNumber numberWithBool:voted] forKey:IdeaAttributesIsVotedByCurrentUserKey];
    [self setAttributes:attributes forIdea:idea];
}

- (BOOL)isIdeaVotedByCurrentUser:(PFObject *)idea {
    NSDictionary *attributes = [self attributesForIdea:idea];
    if (attributes) {
        return [[attributes objectForKey:IdeaAttributesIsVotedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementScoreCountForIdea:(PFObject *)idea {
    NSNumber *scoreCount = [NSNumber numberWithInt:[[self scoreCountForIdea:idea] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForIdea:idea]];
    [attributes setObject:scoreCount forKey:IdeaAttributesScoreCountKey];
    [self setAttributes:attributes forIdea:idea];
}

- (void)decrementScoreCountForIdea:(PFObject *)idea {
    NSNumber *scoreCount = [NSNumber numberWithInt:[[self scoreCountForIdea:idea] intValue] - 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForIdea:idea]];
    [attributes setObject:scoreCount forKey:IdeaAttributesScoreCountKey];
    [self setAttributes:attributes forIdea:idea];
}

- (void)incrementIdeaCountForProject:(PFObject *)project {
    NSNumber *ideaCount = [NSNumber numberWithInt:[[self ideaCountForProject:project] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForProject:project]];
    [attributes setObject:ideaCount forKey:ProjectAttributesIdeaCountKey];
    [self setAttributes:attributes forIdea:project];
}

- (void)decrementIdeaCountForProject:(PFObject *)project {
    NSNumber *ideaCount = [NSNumber numberWithInt:[[self ideaCountForProject:project] intValue] - 1];
    if ([ideaCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForProject:project]];
    [attributes setObject:ideaCount forKey:ProjectAttributesIdeaCountKey];
    [self setAttributes:attributes forIdea:project];
}

- (void)setAttributesForUser:(PFUser *)user projectCount:(NSNumber *)count {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,UserAttributesProjectCountKey,nil];
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (BOOL)projectStatusForUser:(PFUser *)user andProject:(PFObject *)project{
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSMutableArray *projectsThatIncludeUser = [attributes objectForKey:UserAttributesIsAddedByCurrentUserKey];
        if ([projectsThatIncludeUser containsObject:project]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setProjectStatus:(BOOL)add forUser:(PFUser *)user andProject:(PFObject *)project{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    NSMutableArray *projectsThatIncludeUser = [attributes objectForKey:UserAttributesIsAddedByCurrentUserKey];
    if (add) {
        [projectsThatIncludeUser addObject:project];
    } else {
        [projectsThatIncludeUser removeObject:project];
    }
    [attributes setObject:projectsThatIncludeUser forKey:UserAttributesIsAddedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (NSNumber *)projectCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *projectCount = [attributes objectForKey:UserAttributesProjectCountKey];
        if (projectCount) {
            return projectCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (void)setProjectCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:UserAttributesProjectCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = UserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = UserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }
    
    return friends;
}


#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forIdea:(PFObject *)idea {
    NSString *key = [self keyForIdea:idea];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forProject:(PFUser *)project {
    NSString *key = [self keyForProject:project];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForIdea:(PFObject *)idea {
    return [NSString stringWithFormat:@"idea_%@", [idea objectId]];
}

- (NSString *)keyForProject:(PFObject *)project {
    return [NSString stringWithFormat:@"project_%@", [project objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}


@end
