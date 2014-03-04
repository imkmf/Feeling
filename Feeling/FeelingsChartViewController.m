//
//  FeelingsChartViewController.m
//  Feeling
//
//  Created by Kristian Freeman on 2/23/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "FeelingsChartViewController.h"
#import "JBChartInformationView.h"
#import "JBChartHeaderView.h"
#import "JBLineChartFooterView.h"
#import "AddEventViewController.h"

#import "AppDelegate.h"
#import "Event.h"

#import <JBLineChartView.h>
#import <CRToast.h>

#define ARC4RANDOM_MAX 0x100000000
#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

// Numerics
CGFloat const kJBLineChartViewControllerChartHeight = 250.0f;
CGFloat const kJBLineChartViewControllerChartHeaderHeight = 60.0f;
CGFloat const kJBLineChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;

// Strings
NSString * const kJBLineChartViewControllerNavButtonViewKey = @"view";

@interface FeelingsChartViewController () <JBLineChartViewDelegate, JBLineChartViewDataSource>

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) UIButton *addView;
@property (nonatomic, strong) JBChartInformationView *informationView;

@property (nonatomic,strong) NSArray *fetchedEventsArray;

@end

@implementation FeelingsChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self getNewData];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    NSArray *colorScheme = [[UIColor robinEggColor] colorSchemeOfType:ColorSchemeAnalagous];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.view.backgroundColor = [UIColor robinEggColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    if (self.fetchedEventsArray.count > 1) {
        
        self.lineChartView = [[JBLineChartView alloc] initWithFrame:CGRectMake(kJBNumericDefaultPadding, kJBNumericDefaultPadding + 20, self.view.bounds.size.width - (kJBNumericDefaultPadding * 2), kJBLineChartViewControllerChartHeight)];
        self.lineChartView.delegate = self;
        self.lineChartView.dataSource = self;
        self.lineChartView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
        self.lineChartView.backgroundColor = [UIColor clearColor];
        
        JBChartHeaderView *headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBNumericDefaultPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5), self.view.bounds.size.width - (kJBNumericDefaultPadding * 2), kJBLineChartViewControllerChartHeaderHeight)];
        headerView.titleLabel.text = [kJBStringLabelHowAreYouFeeling uppercaseString];
        headerView.titleLabel.textColor = [UIColor whiteColor];
        headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
        headerView.titleLabel.shadowOffset = CGSizeMake(0, 1);
        headerView.separatorColor = [UIColor clearColor];
        self.lineChartView.headerView = headerView;
        
        [self.view addSubview:self.lineChartView];
        
        JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(kJBNumericDefaultPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBNumericDefaultPadding * 2), kJBLineChartViewControllerChartFooterHeight)];
        footerView.backgroundColor = [UIColor clearColor];
        footerView.alpha = 0.5;
        self.lineChartView.footerView = footerView;
        
        self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.lineChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.lineChartView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame)) layout:JBChartInformationViewLayoutVertical];
        [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:1]];
        [self.informationView setTitleTextColor:kJBColorLineChartHeader];
        [self.informationView setTextShadowColor:nil];
        [self.informationView setSeparatorColor:kJBColorLineChartHeaderSeparatorColor];
        [self.view addSubview:self.informationView];
        
        [self.lineChartView reloadData];
        
        self.addView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.addView setFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.lineChartView.frame) + 40, self.view.bounds.size.width, CGRectGetMaxY(self.lineChartView.frame) / 3)];
        [self.addView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        [self.addView.titleLabel setFont:[UIFont systemFontOfSize:60]];
        [self.addView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.addView setBackgroundColor:[colorScheme objectAtIndex:1]];
        [self.addView setTitle:@"+" forState:UIControlStateNormal];
        [self.addView.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [self.addView setAlpha:1.0];
        [self.addView addTarget:self action:@selector(addEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.addView];
        
        UIButton *arrow = [[UIButton alloc] initWithFrame:CGRectMake(135, CGRectGetMaxY(self.lineChartView.frame) + 180, 50, 50)];
        [arrow setImage:[UIImage imageNamed:@"arrow-down.png"] forState:UIControlStateNormal];
        arrow.alpha = 0.5;
        [arrow addTarget:appDelegate action:@selector(toTable) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:arrow];
    } else {
        UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 80)];
        introLabel.textAlignment = NSTextAlignmentCenter;
        introLabel.text = @"How are you feeling?";
        introLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
        introLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:introLabel];
        
        self.addView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.addView setFrame:CGRectMake(self.view.bounds.origin.x, 400, self.view.bounds.size.width, 80)];
        [self.addView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        [self.addView.titleLabel setFont:[UIFont systemFontOfSize:60]];
        [self.addView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.addView setBackgroundColor:[colorScheme objectAtIndex:1]];
        [self.addView setTitle:@"+" forState:UIControlStateNormal];
        [self.addView.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [self.addView setAlpha:1.0];
        [self.addView addTarget:self action:@selector(addEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.addView];
    }

    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;

}

- (void)getNewData {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.fetchedEventsArray = [appDelegate getAllEvents];
}

- (void)addEvent:(id)sender
{
    bool alreadyExists = false;
    if (self.fetchedEventsArray.count >= 1) {
        for (Event *event in self.fetchedEventsArray) {
            
            // Terrible way to check if there's an entry for today.
            // Messy to accommodate testing, which has multiple day entries
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSInteger comps = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
            
            NSDateComponents *date1Components = [calendar components:comps
                                                            fromDate:[NSDate date]];
            NSDateComponents *date2Components = [calendar components:comps
                                                            fromDate:event.timestamp];
            NSDate *today = [calendar dateFromComponents:date1Components];
            NSDate *stamp = [calendar dateFromComponents:date2Components];
            NSComparisonResult result = [today compare:stamp];
            
            if (result == NSOrderedSame) { alreadyExists = true; }
        }
    }
    
    if (alreadyExists) {
        NSDictionary *options = @{
                                  kCRToastTextKey : @"You've already added an event for today.",
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [UIColor goldenrodColor],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight),
                                  kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar)
                                  };
        [CRToastManager showNotificationWithOptions:options completionBlock:nil];
    } else {
        AddEventViewController *addEvent = [[AddEventViewController alloc] init];
        [self.navigationController presentViewController:addEvent animated:YES completion:nil];
    }
}

- (void)reloadGraph {
    [self getNewData];
    [self.lineChartView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getNewData];
    [super viewDidAppear:animated];
    [self.lineChartView setState:JBChartViewStateExpanded animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView heightForIndex:(NSInteger)index
{
    Event *event = [self.fetchedEventsArray objectAtIndex:index];
    float rating = event.rating.floatValue;
    return rating;
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectChartAtIndex:(NSInteger)index
{
    Event *event = [self.fetchedEventsArray objectAtIndex:index];

    [self.informationView setValueText:[NSString stringWithFormat:@"%@", event.rating] unitText:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    NSString *textDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:event.timestamp]];
    [self.informationView setTitleText:textDate];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.addView setAlpha:0];
    [self.addView setHidden:YES];
    [UIView commitAnimations];
    [self.informationView setHidden:NO animated:YES];
}

- (void)lineChartView:(JBLineChartView *)lineChartView didUnselectChartAtIndex:(NSInteger)index
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.addView setAlpha:1];
    [self.addView setHidden:NO];
    [UIView commitAnimations];
    [self.informationView setHidden:YES animated:YES];
}

#pragma mark - JBLineChartViewDataSource

- (NSInteger)numberOfPointsInLineChartView:(JBLineChartView *)lineChartView
{
    NSInteger count = self.fetchedEventsArray.count;
    return count;
}

- (UIColor *)lineColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

- (UIColor *)selectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor limeColor];
}

@end