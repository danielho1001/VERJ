//
//  NewIdeaViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "NewIdeaViewController.h"
#import "IdeaContentView.h"
#import "Constants.h"

@interface NewIdeaViewController()
@property (nonatomic, strong) UITextView *ideaContentTextView;

@property (nonatomic, assign) UIBackgroundTaskIdentifier ideaPostBackgroundTaskId;


@end

@implementation NewIdeaViewController

@synthesize ideaContentTextView;

@synthesize ideaPostBackgroundTaskId;



- (id)initWithProject:(PFObject*)aProject {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.project = aProject;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect ideaContentRect = [IdeaContentView rectForView];
    
    IdeaContentView *ideaContentView = [[IdeaContentView alloc] initWithFrame:ideaContentRect];
    self.ideaContentTextView = ideaContentView.ideaContentTextView;
    self.ideaContentTextView.delegate = self;
    [self.ideaContentTextView becomeFirstResponder];
    [self.view addSubview:ideaContentTextView];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(newIdea:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.ideaContentTextView addGestureRecognizer:swipe];
    
}

#pragma mark - UITextViewDelegate


#pragma mark - Selector Methods

-(void)newIdea:(id)sender {
    NSString *trimmedComment = [self.ideaContentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([trimmedComment length] != 0) {
        //Check if project was created correctly
        if (!self.project) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your idea" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            return;
        }
        
        // create an idea object
        PFObject *idea = [PFObject objectWithClassName:IdeaClassKey];
        [idea setObject:[PFUser currentUser] forKey:IdeaFromUserKey];
        [idea setObject:self.project forKey:IdeaProjectKey];
        [idea setObject:trimmedComment forKey:IdeaContentKey];
        [idea setObject:IdeaTypeString forKey:IdeaTypeKey];
        
        // ideas are public, but may only be modified by the user who uploaded them
        PFACL *ideaACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ideaACL setPublicReadAccess:YES];
        idea.ACL = ideaACL;
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.ideaPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.ideaPostBackgroundTaskId];
        }];
        
        // Save the Photo PFObject
        [idea saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // create and save photo caption
                PFObject *ideaCreated = [PFObject objectWithClassName:ActivityClassKey];
                [ideaCreated setObject:ActivityTypeIdeaCreated forKey:ActivityTypeKey];
                [ideaCreated setObject:self.project forKey:ActivityProjectKey];
                [ideaCreated setObject:[PFUser currentUser] forKey:ActivityFromUserKey];
                
                //                PFRelation *invitedUsers = [projectCreated relationForKey:ActivityToUserKey];
                //                [invitedUsers addObject:[PFUser currentUser]];
                //                [projectCreated setObject:invitedUsers forKey:ActivityToUserKey];
                [ideaCreated setObject:trimmedComment forKey:ActivityContentKey];
                
                PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [ACL setPublicReadAccess:YES];
                ideaCreated.ACL = ACL;
                
                [ideaCreated saveEventually];
                
                self.ideaContentTextView.text = @"";
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your idea" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            [[UIApplication sharedApplication] endBackgroundTask:self.ideaPostBackgroundTaskId];
        }];

    }
}


@end
