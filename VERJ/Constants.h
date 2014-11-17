//
//  Constants.h
//  VERJ
//
//  Created by Daniel Ho on 11/15/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - NSUserDefaults

extern NSString *const UserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const UserDefaultsCacheFacebookFriendsKey;

#pragma mark - Activity
// Class Key
extern NSString *const ActivityClassKey;
// Field Keys
extern NSString *const ActivityTypeKey;
extern NSString *const ActivityFromUserKey;
extern NSString *const ActivityToUserKey;
extern NSString *const ActivityContentKey;
extern NSString *const ActivityProjectKey;
extern NSString *const ActivityIdeaKey;
// Type Values
extern NSString *const ActivityTypeProjectAccepted;
extern NSString *const ActivityTypeProjectCreated;
extern NSString *const ActivityTypeIdeaCreated;
extern NSString *const ActivityTypeJoined;


#pragma mark - Project
// Class Key
extern NSString *const ProjectClassKey;
// Field Keys
extern NSString *const ProjectUserKey;
extern NSString *const ProjectNameKey;
extern NSString *const ProjectParticipantsKey;



#pragma mark - Idea
// Class Key
extern NSString *const IdeaClassKey;
// Field Keys
extern NSString *const IdeaProjectKey;
extern NSString *const IdeaFromUserKey;
extern NSString *const IdeaToUserKey;
extern NSString *const IdeaContentKey;
extern NSString *const IdeaTypeKey;
// Type Values
extern NSString *const IdeaTypeString;
extern NSString *const IdeaTypePhoto;

#pragma mark - PFObject User Class
// Field keys
extern NSString *const UserDisplayNameKey;
extern NSString *const UserFacebookIDKey;
extern NSString *const UserPhotoIDKey;
extern NSString *const UserFacebookFriendsKey;

#pragma mark - Cached Project Attributes
// keys
extern NSString *const ProjectAttributesIdeaCountKey;
extern NSString *const ProjectAttributesContributorsKey;

#pragma mark - Cached Photo Attributes
// keys
extern NSString *const IdeaAttributesIsVotedByCurrentUserKey;
extern NSString *const IdeaAttributesIsVotedUpByCurrentUserKey;
extern NSString *const IdeaAttributesIsVotedDownByCurrentUserKey;
extern NSString *const IdeaAttributesVoterCountKey;
extern NSString *const IdeaAttributesVotersKey;
extern NSString *const IdeaAttributesScoreCountKey;

#pragma mark - Cached User Attributes
// keys
extern NSString *const UserAttributesIdeaCountKey;
extern NSString *const UserAttributesProjectCountKey;




