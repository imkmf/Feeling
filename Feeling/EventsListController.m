//
//  EventsListController.m
//  Feeling
//
//  Created by Kristian Freeman on 2/26/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "EventsListController.h"
#import "FeelingsChartViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import "AddEventViewController.h"

#import "UIImage+Color.h"
#import <MCSwipeTableViewCell.h>

@interface EventsListController () <MCSwipeTableViewCellDelegate, UIAlertViewDelegate>
@property (nonatomic,strong) NSArray *fetchedEventsArray;
@property (nonatomic,strong) Event *eventToDelete;

@end

@implementation EventsListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        self.tableView.tableHeaderView = header;
        [self getData];
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [background setBackgroundColor:[UIColor robinEggColor]];
        [self.tableView setBackgroundView:background];
//        [self.tableView setBackgroundColor:[UIColor robinEggColor]];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [self addTableHeader];
    }
    return self;
}

- (void)getData {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.fetchedEventsArray = [appDelegate getAllEvents];
}

- (void)viewDidLoad
{
    [self getData];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self getData];
    [self.tableView reloadData];
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addTableHeader {
    self.tableView.tableHeaderView = nil;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90)];
    UIButton *arrow = [[UIButton alloc] initWithFrame:CGRectMake(135, 30, 50, 50)];
    self.tableView.tableHeaderView = header;
    [arrow setImage:[UIImage imageNamed:@"arrow-up.png"] forState:UIControlStateNormal];
    [arrow addTarget:self action:@selector(arrowPressed) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:arrow];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedEventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor whiteColor]];

        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        Event *event = [self.fetchedEventsArray objectAtIndex:indexPath.row];
        
        // Setting the background color of the cell.
        UIColor *color = [UIColor colorWithRed:(1 - ([event.rating floatValue] / 5.0f)) green:([event.rating floatValue] / 5.0f) blue:0 alpha:.5];
        cell.contentView.backgroundColor = color;
        
        if (event.image) {
            [cell.imageView setImage:[UIImage imageNamed:@"photos.png" withColor:[UIColor whiteColor] drawAsOverlay:NO]];
        }

        
        if (event.note) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", event.note];
        } else {
            cell.textLabel.text = @"No note for this entry";
        }
        cell.detailTextLabel.text = [event formattedDate];
    }
    
    UIView *editView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit"]];
    UIView *crossView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trash"]];
    
    // Setting the default inactive state color to the tableView background color.
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    // Adding gestures per state basis.
    [cell setSwipeGestureWithView:editView color:[UIColor seafoamColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self didSwipeEdit:cell];
    }];
    
    [cell setSwipeGestureWithView:crossView color:[UIColor strawberryColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self didSwipeDelete:cell];
    }];
    
    return cell;
}

- (void)arrowPressed {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    FeelingsChartViewController *chart = [[FeelingsChartViewController alloc] init];
    FeelingsBaseNavigationController *base = [[FeelingsBaseNavigationController alloc] initWithRootViewController:chart];
    [appDelegate.pageViewController setViewControllers:@[base] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

- (void)didSwipeEdit:(UITableViewCell *)cell {
    Event *event = [self getEventForCell:cell];
    AddEventViewController *eventPage = [[AddEventViewController alloc] init];
    [eventPage setSliderValue:event];
    [eventPage setEvent:event];
    [eventPage editMode];
    [self presentViewController:eventPage animated:YES completion:nil];
}

- (void)didSwipeDelete:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.eventToDelete = [self.fetchedEventsArray objectAtIndex:indexPath.row];
    UIAlertView *reallyDelete = [[UIAlertView alloc] initWithTitle:@"Delete event?" message:@"Really delete this event?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [reallyDelete show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Delete"])
    {
        self.eventToDelete.userDeleted = [NSNumber numberWithInt:1];
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        NSError *error;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    self.eventToDelete = nil;

    [self getData];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self.fetchedEventsArray objectAtIndex:indexPath.row];
    [self performSelector:@selector(eventPage:) withObject:event];
}

- (Event *)getEventForCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    return [self.fetchedEventsArray objectAtIndex:indexPath.row];
}

- (void)eventPage:(Event *)event {
    AddEventViewController *eventPage = [[AddEventViewController alloc] init];
    [eventPage setSliderValue:event];
    [eventPage setReadOnly];
    if (event.image) {
        [eventPage addImage:event.image];
    }
    
    [self presentViewController:eventPage animated:YES completion:nil];
}

@end
