//
//  EventsListController.m
//  Feeling
//
//  Created by Kristian Freeman on 2/26/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "EventsListController.h"
#import "AppDelegate.h"
#import "Event.h"

@interface EventsListController ()
@property (nonatomic,strong) NSArray *fetchedEventsArray;

@end

@implementation EventsListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        self.tableView.tableHeaderView = header;
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        self.fetchedEventsArray = [appDelegate getAllEvents];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        Event *event = [self.fetchedEventsArray objectAtIndex:indexPath.row];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"mm/dd/yyyy"];
        NSString *stringFromDate = [formatter stringFromDate:event.timestamp];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", event.rating];
        cell.detailTextLabel.text = stringFromDate;
    }
    
    return cell;
}
@end
