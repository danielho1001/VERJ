//
//  VerjCache.h
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface VerjCache : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setAttributesForIdea:(PFObject *)idea voters:(NSArray *)voters withScore:(NSNumber *)score votedByCurrentUser:(BOOL)votedByCurrentUser;
- (NSDictionary *)attributesForIdea:(PFObject *)idea;
- (NSDictionary *)attributesForProject:(PFObject *)project;

- (NSNumber *)voterCountForIdea:(PFObject *)idea;
- (NSNumber *)ideaCountForProject:(PFObject *)project;
- (NSNumber *)scoreForIdea:(PFObject *)idea;
- (NSArray *)votersForIdea:(PFObject *)idea;
- (void)setIdeaIsVotedByCurrentUser:(PFObject *)idea up:(BOOL)voted;
- (BOOL)isIdeaVotedByCurrentUser:(PFObject *)idea;
- (void)incrementScoreCountForIdea:(PFObject *)idea;
- (void)decrementScoreCountForIdea:(PFObject *)idea;

- (void)incrementIdeaCountForProject:(PFObject *)project;
- (void)decrementIdeaCountForProject:(PFObject *)project;
- (NSArray *)contributorsForProject:(PFObject *)project;

- (void)setAttributesForUser:(PFUser *)user projectCount:(NSNumber *)count;
- (NSDictionary *)attributesForUser:(PFUser *)user;
- (BOOL)projectStatusForUser:(PFUser *)user andProject:(PFObject *)project;
- (void)setProjectStatus:(BOOL)add forUser:(PFUser *)user andProject:(PFObject *)project;

- (NSNumber *)projectCountForUser:(PFUser *)user;
- (void)setProjectCount:(NSNumber *)count user:(PFUser *)user;


- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;

@end
