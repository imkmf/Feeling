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
@property (nonatomic, retain) UILabel *ratingLabel;

@property (nonatomic, retain) EFCircularSlider *slider;

@property (nonatomic, retain) NSArray *colorScheme;

@end

@implementation AddEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.colorScheme = [[UIColor robinEggColor] colorSchemeOfType:ColorSchemeTriad];
        [self.view setBackgroundColor:[UIColor robinEggColor]];
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
    CGRect sliderFrame = CGRectMake(10, 100, 300, 300);
    self.slider = [[EFCircularSlider alloc] initWithFrame:sliderFrame];
    [self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider setLineWidth:20];
    [self.slider setFilledColor:[UIColor whiteColor]];
    [self.view addSubview:self.slider];
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    UILabel *introText = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 60)];
    introText.text = @"How are you?";
    [introText setFont:[UIFont boldSystemFontOfSize:30]];
    [introText setTextColor:[UIColor whiteColor]];
    [introText setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:introText];
    
    self.ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 190, 120, 120)];
    self.ratingLabel.text = @"0";
    [self.ratingLabel setFont:[UIFont boldSystemFontOfSize:40]];
    [self.ratingLabel setTextColor:[UIColor whiteColor]];
    [self.ratingLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.ratingLabel];
    [super viewDidLoad];
}

-(void)valueChanged:(EFCircularSlider*)slider {
    if (!self.changed) {
        self.changed = YES;
        [self showButtons];
    }
    NSNumber *rounded = [NSNumber numberWithInt:(int)self.slider.currentValue];
    [self setBar:rounded];
    self.ratingLabel.text = [NSString stringWithFormat:@"%@", rounded];
}

-(void)setBar:(NSNumber*)rounded {
    int num = [rounded intValue];
    if (0 < num && num < 50) {
        self.slider.filledColor = [UIColor salmonColor];
    } else if (51 < num && num < 100) {
        self.slider.filledColor = [UIColor pastelGreenColor];
    }
}

- (void)showButtons {
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setFrame:CGRectMake(0, 420, 160, 120)];
    [cancelButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:60]];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor salmonColor]];
    [cancelButton setTitle:@"x" forState:UIControlStateNormal];
    [cancelButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [cancelButton setAlpha:0.0];
    [cancelButton addTarget:self action:@selector(willCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addButton setFrame:CGRectMake(160, 420, 160, 120)];
    [addButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [addButton.titleLabel setFont:[UIFont systemFontOfSize:60]];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton setBackgroundColor:[UIColor pastelGreenColor]];
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
