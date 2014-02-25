//
//  FeelingsBaseNavigationController.m
//  Feeling
//
//  Created by Kristian Freeman on 2/23/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "FeelingsBaseNavigationController.h"

@implementation FeelingsBaseNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.translucent = YES;
        [[UINavigationBar appearance] setBarTintColor:[UIColor robinEggColor]];
    }
    return self;
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
