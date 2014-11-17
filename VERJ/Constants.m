//
//  Constants.m
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "Constants.h"

#pragma mark - NSUserDefaults

NSString *const UserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Anypic.userDefaults.activityFeedViewController.lastRefresh";
NSString *const UserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Anypic.userDefaults.cache.facebookFriends";

#pragma mark - Activity
// Class Key
NSString *const ActivityClassKey = @"Activity";
// Field Keys
NSString *const ActivityToUserKey = @"toUser";
NSString *const ActivityFromUserKey = @"fromUser";
NSString *const ActivityTypeKey = @"type";
NSString *const ActivityContentKey = @"content";
NSString *const ActivityProjectKey = @"Project";
NSString *const ActivityIdeaKey = @"Idea";
// Type Values
NSString *const ActivityTypeProjectAccepted = @"projectAccepted";
NSString *const ActivityTypeProjectCreated = @"projectCreated";
NSString *const ActivityTypeIdeaCreated = @"ideaCreated";
NSString *const ActivityTypeJoined = @"joined";



#pragma mark - Project
// Class Key
NSString *const ProjectClassKey = @"Project";
// Field Keys
NSString *const ProjectUserKey = @"creator";
NSString *const ProjectNameKey = @"name";
NSString *const ProjectParticipantsKey = @"participants";


#pragma mark - Idea
// Class Key
NSString *const IdeaClassKey = @"Idea";
// Field Keys
NSString *const IdeaProjectKey = @"Project";
NSString *const IdeaFromUserKey = @"fromUser";
NSString *const IdeaToUserKey = @"toUser";
NSString *const IdeaContentKey = @"content";
NSString *const IdeaTypeKey = @"type";
// Type Values
NSString *const IdeaTypeString = @"string";
NSString *const IdeaTypePhoto = @"photo";

#pragma mark - User Class
// Field keys
NSString *const UserDisplayNameKey = @"displayName";
NSString *const UserFacebookIDKey = @"facebookId";
NSString *const UserPhotoIDKey = @"photoId";
NSString *const UserFacebookFriendsKey = @"facebookFriends";

#pragma mark - Cached Project Attributes
// keys
NSString *const ProjectAttributesIdeaCountKey = @"projectCount";
NSString *const ProjectAttributesContributorsKey = @"contributors";

#pragma mark - Cached Idea Attributes
// keys
NSString *const IdeaAttributesIsVotedByCurrentUserKey = @"isVotedByCurrentUser";
NSString *const IdeaAttributesIsVotedUpByCurrentUserKey = @"isVotedUpByCurrentUser";
NSString *const IdeaAttributesIsVotedDownByCurrentUserKey = @"isVotedDownByCurrentUser";
NSString *const IdeaAttributesVoterCountKey = @"voterCount";
NSString *const IdeaAttributesVotersKey = @"voters";
NSString *const IdeaAttributesScoreCountKey = @"scoreCount";

#pragma mark - Cached User Attributes
// keys
NSString *const UserAttributesIdeaCountKey                 = @"userIdeaCount";
NSString *const UserAttributesProjectCountKey                 = @"userProjectCount";


