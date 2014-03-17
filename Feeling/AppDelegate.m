//
//  AppDelegate.m
//  Feeling
//
//  Created by Kristian Freeman on 2/23/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "AppDelegate.h"
#import <HockeySDK.h>

// Controllers
#import "FeelingsBaseNavigationController.h"
#import "FeelingsChartViewController.h"
#import "EventsListController.h"

#import "Event.h"

#import <CRToast.h>

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Launch

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    
    self.navigationController = [[FeelingsBaseNavigationController alloc] initWithRootViewController:[[FeelingsChartViewController alloc] init]];
    
    [self.pageViewController setViewControllers:@[self.navigationController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.pageViewController.dataSource = self.navigationController;
    
    self.window.rootViewController = self.pageViewController;
    [self.window makeKeyAndVisible];
    
    
    if (application.scheduledLocalNotifications.count > 1) {
        // For testing notification settings
        [application cancelAllLocalNotifications];
    }

    if (application.scheduledLocalNotifications.count == 0) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.repeatInterval = NSDayCalendarUnit;
        [notification setAlertBody:@"How are you feeling?"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [notification setSoundName:@"Jingle.aif"];
        [notification setApplicationIconBadgeNumber:1];
        [application scheduleLocalNotification:notification];
    }
    
    if (self.getAllEvents.count == 1) {
        [self showSingleEntryAlert];
    }
//    [self insertTestData];
    return YES;
}

- (void)showSingleEntryAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Single entry"
                                                    message:@"You've only added one entry, so your graph is empty. Come back tomorrow!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Events.sqlite"]];
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(NSArray*)getAllEvents 
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if( [[BITHockeyManager sharedHockeyManager].authenticator handleOpenURL:url
                                                          sourceApplication:sourceApplication
                                                                 annotation:annotation]) {
        return YES;
    }
    
    /* Your own custom URL handlers */
    return NO;
}

- (void)insertTestData {
    int i;
    for (i=0; i < 10; i = i + 1) {
        Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                        inManagedObjectContext:self.managedObjectContext];
        int max = 5;
        int min = 0;
        int randomNumber = min + arc4random() % (max-min);
        newEvent.timestamp = [NSDate dateWithTimeIntervalSinceNow:-1209600.0 + (randomNumber * 100)];
        newEvent.rating = [NSNumber numberWithInt:randomNumber];
        NSError *error;
        NSLog(@"new event");
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
}

@end
