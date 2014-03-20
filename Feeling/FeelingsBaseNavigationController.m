//
//  FeelingsBaseNavigationController.m
//  Feeling
//
//  Created by Kristian Freeman on 2/23/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "FeelingsBaseNavigationController.h"
#import "FeelingsChartViewController.h"
#import "EventsListController.h"

#import "AppDelegate.h"

@implementation FeelingsBaseNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.translucent = YES;
        [[UINavigationBar appearance] setBarTintColor:[UIColor robinEggColor]];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //Create the introduction view and set its delegate
            MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            introductionView.backgroundColor = [UIColor robinEggColor];
            introductionView.delegate = self;
            
            //Feel free to customize your introduction view here
            
            MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Welcome to Feeling." description:@"Feeling helps you look back. Every day, Feeling will remind you to rate your feelings for the day. As you continue to rate your days, Feeling will create a beautiful graph that shows the up and downs of life."];
            [panel1.PanelTitleLabel setTextAlignment:NSTextAlignmentCenter];
            panel1.PanelDescriptionLabel.frame = CGRectMake(panel1.PanelDescriptionLabel.frame.origin.x,
                                                            panel1.PanelDescriptionLabel.frame.origin.y,
                                                            panel1.PanelDescriptionLabel.frame.size.width,
                                                            panel1.PanelDescriptionLabel.frame.size.height * 2);
            panel1.PanelDescriptionLabel.font = [UIFont systemFontOfSize:18];
            
            MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Tips" description:@"Using Feeling is easy. Tap the \"+\" icon to add a rating. If you've already added a rating today, Feeling will gently remind you to wait until tomorrow. Tap the arrow button to see your ratings over time. If you drag your finger across the graph, you'll see all your ratings along the bottom part of the screen."];
            [panel2.PanelTitleLabel setTextAlignment:NSTextAlignmentCenter];
            panel2.PanelDescriptionLabel.frame = CGRectMake(panel2.PanelDescriptionLabel.frame.origin.x,
                                                            panel2.PanelDescriptionLabel.frame.origin.y,
                                                            panel2.PanelDescriptionLabel.frame.size.width,
                                                            panel2.PanelDescriptionLabel.frame.size.height * 2);
            panel2.PanelDescriptionLabel.font = [UIFont systemFontOfSize:18];
            
            MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Your first day" description:@"Because this is your first day with Feeling, we've disabled the graph until you have more than one data point (one day) on the graph. When you add your second rating, the graph will begin to populate, and we'll allow you to access your previous data points."];
            [panel3.PanelTitleLabel setTextAlignment:NSTextAlignmentCenter];
            panel3.PanelDescriptionLabel.frame = CGRectMake(panel3.PanelDescriptionLabel.frame.origin.x,
                                                            panel3.PanelDescriptionLabel.frame.origin.y,
                                                            panel3.PanelDescriptionLabel.frame.size.width,
                                                            panel3.PanelDescriptionLabel.frame.size.height * 2);
            panel3.PanelDescriptionLabel.font = [UIFont systemFontOfSize:18];
            
            NSArray *panels = @[panel1, panel2, panel3];
            
            [introductionView buildIntroductionWithPanels:panels];
            
            [self.view addSubview:introductionView];
            
        }
        
    }
    return self;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[FeelingsBaseNavigationController class]])
        return nil;
    
    FeelingsBaseNavigationController *navigationController = [[FeelingsBaseNavigationController alloc] initWithRootViewController:[[FeelingsChartViewController alloc] init]];
    
    return navigationController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UITableViewController class]])
        return nil;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    NSArray *fetchedEventsArray = [appDelegate getAllEvents];
    
    if (fetchedEventsArray.count > 1) {
        EventsListController *listController = [[EventsListController alloc] initWithStyle:UITableViewStylePlain];
        return listController;
    } else {
        return nil;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
