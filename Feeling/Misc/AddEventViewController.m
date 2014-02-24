//
//  AddEventViewController.m
//  Feeling
//
//  Created by Kristian Freeman on 2/24/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "AddEventViewController.h"
#import <EFCircularSlider.h>
#import "Event.h"
#import "AppDelegate.h"

@interface AddEventViewController ()
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) EFCircularSlider *slider;

@end

@implementation AddEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        self.changed = NO;
    }
    return self;
}
                                      
- (void)willSave {
    NSNumber *rounded = [NSNumber numberWithInt:(int)self.slider.currentValue];
    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                      inManagedObjectContext:self.managedObjectContext];
    newEvent.timestamp = [NSDate date];
    newEvent.rating = rounded;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    [self dismissNow];
}

- (void)willCancel {
    [self dismissNow];
}

- (void)dismissNow {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    CGRect sliderFrame = CGRectMake(10, 40, 300, 300);
    self.slider = [[EFCircularSlider alloc] initWithFrame:sliderFrame];
    [self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider setLineWidth:20];
    [self.slider setFilledColor:UIColorFromHex(0x999999)];
    [self.view addSubview:self.slider];
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    [super viewDidLoad];
}

-(void)valueChanged:(EFCircularSlider*)slider {
    if (!self.changed) {
        self.changed = YES;
        [self showButtons];
    }
}

- (void)showButtons {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setFrame:CGRectMake(0, 360, 160, 120)];
    [cancelButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:60]];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:UIColorFromHex(0x222222)];
    [cancelButton setTitle:@"x" forState:UIControlStateNormal];
    [cancelButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [cancelButton setAlpha:0.0];
    [cancelButton addTarget:self action:@selector(willCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addButton setFrame:CGRectMake(160, 360, 160, 120)];
    [addButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [addButton.titleLabel setFont:[UIFont systemFontOfSize:60]];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton setBackgroundColor:UIColorFromHex(0x222222)];
    [addButton setTitle:@"+" forState:UIControlStateNormal];
    [addButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [addButton setAlpha:0.0];
    [addButton addTarget:self action:@selector(willSave) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [cancelButton setAlpha:1.0];
    [addButton setAlpha:1.0];
    [self.view addSubview:cancelButton];
    [self.view addSubview:addButton];
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
