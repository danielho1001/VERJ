//
//  NewIdeaViewController.m
//  VERJ
//
//  Created by Daniel Ho on 11/16/14.
//  Copyright (c) 2014 Verj Technologies. All rights reserved.
//

#import "NewIdeaViewController.h"
#import "IdeaContentView.h"
#import "BackButton.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "VerjUtility.h"

@interface NewIdeaViewController()
@property (nonatomic, strong) UITextView *ideaContentTextView;

@property (nonatomic, assign) UIBackgroundTaskIdentifier ideaPostBackgroundTaskId;
@property (nonatomic, strong) MTStatusBarOverlay *statusBar;

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
    self.ideaContentTextView = ideaContentView.textView;
    self.ideaContentTextView.delegate = self;
    [self.view addSubview:ideaContentView];
    [self.ideaContentTextView becomeFirstResponder];
    
    self.statusBar = [MTStatusBarOverlay sharedInstance];
    self.statusBar.delegate = self;
    self.statusBar.hidesActivity = YES;
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(newIdea:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.ideaContentTextView addGestureRecognizer:swipe];
    
    self.navigationItem.title = [self.project objectForKey:ProjectNameKey];
    
    self.navigationItem.leftBarButtonItem = [[BackButton alloc] initWithTarget:self action:@selector(backButtonAction:) withImageName:@"converge.png"];
    
    [self.navigationController.navigationBar setBarTintColor:[VerjUtility getVerjOrangeColor]];
}

#pragma mark - Selector Methods

-(void)newIdea:(id)sender {
    if (![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [self.statusBar postMessage:@"Need Internet connection to post idea" duration:2 animated:YES];
        return;
    }
    NSString *trimmedComment = [self.ideaContentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([trimmedComment length] != 0) {
        //Check if project was created correctly
        if (!self.project) {
            [self.statusBar postMessage:@"Couldn't post your idea" duration:2 animated:YES];
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
                [ideaCreated setObject:self.project forKey:ActivityToProjectKey];
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
                [self.statusBar postMessage:@"Couldn't post your idea" duration:2 animated:YES];
            }
            [[UIApplication sharedApplication] endBackgroundTask:self.ideaPostBackgroundTaskId];
        }];
    }
}

#pragma marks - ()

-(void) backButtonAction:(id)sender {
    [self.navigationController.navigationBar setBarTintColor:[VerjUtility getDefaultNavBarColor]];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
