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
    FeelingsBaseNavigationController *navigationController = [[FeelingsBaseNavigationController alloc] initWithRootViewController:[[FeelingsChartViewController alloc] init]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    if (!TARGET_IPHONE_SIMULATOR) {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"1649200acbc9eacb3becf09ca3a95d20" delegate:self];
        [[BITHockeyManager sharedHockeyManager].authenticator setIdentificationType:BITAuthenticatorIdentificationTypeDevice];
        [[BITHockeyManager sharedHockeyManager] startManager];
        [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    }
    
    // Set notification
    if (application.scheduledLocalNotifications.count == 0) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.repeatInterval = NSDayCalendarUnit;
        [notification setAlertBody:@"How are you feeling?"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [application scheduleLocalNotification:notification];
    }

    if (self.getAllEvents.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to Feeling"
                                                        message:@"Add your first entry with the add button below. Since you will only have one entry, the graph will appear blank until you come back tomorrow!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if (self.getAllEvents.count == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Single entry"
                                                        message:@"You've only added one entry, so your graph is empty. Come back tomorrow!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return YES;
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
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if( [[BITHockeyManager sharedHockeyManager].authenticator handleOpenURL:url
                                                          sourceApplication:sourceApplication
                                                                 annotation:annotation]) {
        return YES;
    }
    
    /* Your own custom URL handlers */
    
    return NO;
}

@end
