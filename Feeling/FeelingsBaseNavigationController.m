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
        self.navigationBar.translucent = NO;
        [[UINavigationBar appearance] setBarTintColor:kJBColorNavigationTint];
        [[UINavigationBar appearance] setTintColor:kJBColorNavigationBarTint];
        self.navigationController.navigationBar.titleTextAttributes =
        @{
          NSForegroundColorAttributeName : [UIColor whiteColor],
        };
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
