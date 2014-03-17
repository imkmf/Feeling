//
//  AddEventViewController.m
//  Feeling
//
//  Created by Kristian Freeman on 2/24/14.
//  Copyright (c) 2014 Kristian Freeman. All rights reserved.
//

#import "AddEventViewController.h"
#import "Event.h"
#import "AppDelegate.h"

#import "SoundManager.h"
#import "EFCircularSlider.h"
#import <CRToast.h>
#import "UIImage+Color.h"

@interface AddEventViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UILabel *ratingLabel;

@property (nonatomic, retain) EFCircularSlider *slider;

@property (nonatomic, retain) NSString *eventNote;

@property (nonatomic, retain) NSArray *colorScheme;
@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) SoundManager *manager;

@property (nonatomic, retain) UIButton *addButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *cameraButton;

@property (nonatomic, retain) UILabel *noteHintLabel;
@property (nonatomic, assign) BOOL infoAdded;
@property (nonatomic, assign) BOOL chanceToAddInfo;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) BOOL didUserDismissCamera;

@end

@implementation AddEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.colorScheme = [[UIColor robinEggColor] colorSchemeOfType:ColorSchemeAnalagous];
        [self.view setBackgroundColor:[UIColor robinEggColor]];
        self.manager = [[SoundManager alloc] init];
        self.manager.allowsBackgroundMusic = YES;
    }
    return self;
}
                                      
- (void)willSave {
    [self.slider removeFromSuperview];
    [self.ratingLabel removeFromSuperview];

    if (!self.chanceToAddInfo) {
        if (!self.infoAdded) {
            [self.cancelButton setTitle:@"" forState:UIControlStateNormal];
            [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton.png"] forState:UIControlStateNormal];
            [self.cancelButton.imageView setTintColor:[UIColor whiteColor]];
            
            UITextView *noteView = [[UITextView alloc] initWithFrame:CGRectMake(20, 100, 280, 120)];
            [noteView setDelegate:self];
            [noteView setBackgroundColor:[UIColor clearColor]];
            [noteView setFont:[UIFont systemFontOfSize:18]];
            [noteView setTextColor:[UIColor whiteColor]];
            [self.view addSubview:noteView];
            
            self.noteHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 280, 40)];
            [self.noteHintLabel setText:@"Add a note?"];
            [self.noteHintLabel setFont:[UIFont systemFontOfSize:18]];
            [self.noteHintLabel setTextAlignment:NSTextAlignmentCenter];
            [self.noteHintLabel setTextColor:[UIColor whiteColor]];
            [self.view addSubview:self.noteHintLabel];
            
            self.infoAdded = YES;
            
            int y = (isiPhone5) ? 280 : 200;
            self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, y, 320, 120)];
            [self.cameraButton setTitle:@"Add a picture?" forState:UIControlStateNormal];
            [self.cameraButton setBackgroundColor:[self.colorScheme objectAtIndex:1]];
            [self.cameraButton addTarget:self action:@selector(loadCamera) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.cameraButton];
            
            self.chanceToAddInfo = YES;
        }
    } else {
        NSDate *date = [NSDate date];
        Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                          inManagedObjectContext:self.managedObjectContext];
        newEvent.timestamp = date;
        newEvent.rating = self.number;
        newEvent.note = self.eventNote;
        NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
        newEvent.image = imageData;
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        NSDictionary *options = @{
                                  kCRToastTextKey : @"Thanks for the report!",
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [self.colorScheme objectAtIndex:3],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight),
                                  kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar)
                                  };
        [CRToastManager showNotificationWithOptions:options completionBlock:nil];
            
        [self dismissNow];
    }
}

- (void)loadCamera {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Take a new photo",
                                  @"Choose from existing", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (buttonIndex == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    } else if (buttonIndex == 1) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:picker animated:YES completion:NULL];
    self.didUserDismissCamera = YES;
}

#pragma mark - UIImagePickerController Delegate Methods
    
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *imageForDisplay = [UIImage scaleImage:info[UIImagePickerControllerEditedImage] toResolution:400];
    [self.cameraButton setImage:imageForDisplay forState:UIControlStateNormal];
    self.cameraButton.imageView.contentMode = UIViewContentModeCenter;
    self.cameraButton.imageView.clipsToBounds = YES;
    self.imageView.image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)willCancel {
    [self dismissNow];
}

- (void)dismissNow {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    int y = (isiPhone5) ? 150 : 120;
    
    CGRect sliderFrame = CGRectMake(60, y, 200, 200);
    self.slider = [[EFCircularSlider alloc] initWithFrame:sliderFrame];
    self.slider.labelFont = [UIFont systemFontOfSize:28];
    [self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider setLineWidth:20];
    [self.view addSubview:self.slider];
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    UILabel *introText = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 60)];
    introText.text = @"How are you?";
    [introText setFont:[UIFont boldSystemFontOfSize:30]];
    [introText setTextColor:[UIColor whiteColor]];
    [introText setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:introText];
    
    self.ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, y + 40, 120, 120)];
    self.ratingLabel.text = @"?";
    [self.ratingLabel setFont:[UIFont boldSystemFontOfSize:40]];
    [self.ratingLabel setTextColor:[UIColor whiteColor]];
    [self.ratingLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.ratingLabel];
    [super viewDidLoad];
}

-(void)valueChanged:(EFCircularSlider *)slider {
    if (!self.changed) {
        self.changed = YES;
        [self showButtons];
    }
    NSNumber *rounded = [NSNumber numberWithInt:0];
    if (self.slider.currentValue < 20.0f) {
        rounded = [NSNumber numberWithInt:1];
    } else if (self.slider.currentValue < 40.0f) {
        rounded = [NSNumber numberWithInt:2];
    } else if (self.slider.currentValue < 60.0f) {
        rounded = [NSNumber numberWithInt:3];
    } else if (self.slider.currentValue < 80.0f) {
        rounded = [NSNumber numberWithInt:4];
    } else if (self.slider.currentValue < 100.0f) {
        rounded = [NSNumber numberWithInt:5];
    }
    [self setBar:rounded];
    [self setNumberAndPlaySound:rounded];
    self.ratingLabel.text = [NSString stringWithFormat:@"%@", rounded];
}

-(void)setBar:(NSNumber*)rounded {
    UIColor *color = [UIColor colorWithRed:(1 - (self.slider.currentValue / 100.0f)) green:(self.slider.currentValue / 100.0f) blue:0 alpha:1];
    self.slider.filledColor = color;
}

-(void)setNumberAndPlaySound:(NSNumber*)rounded {
    if (![self.number isEqualToNumber:rounded]) {
        self.number = rounded;
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"Play Sounds"]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i", [rounded intValue]] ofType:@"caf"];
            Sound *sound = [Sound soundNamed:path];
            
            [self.manager prepareToPlay];
            [self.manager playSound:sound];
        }
        
    }
}

- (void)showButtons {
    self.addButton = [self createButtonWithText:@"+" WithX:160 WithColor:[UIColor pastelGreenColor]];
    [self.addButton addTarget:self action:@selector(willSave) forControlEvents:UIControlEventTouchUpInside];

    self.cancelButton = [self createButtonWithText:@"x" WithX:0 WithColor:[UIColor salmonColor]];
    [self.cancelButton addTarget:self action:@selector(willCancel) forControlEvents:UIControlEventTouchUpInside];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.cancelButton setAlpha:1.0];
    [self.addButton setAlpha:1.0];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.addButton];
    [UIView commitAnimations];
}

- (UIButton *)createButtonWithText:(NSString *)text WithX:(int)x WithColor:(UIColor *)color {
    int y = (isiPhone5) ? 420 : 340;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(x, y, 160, 120)];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [button.titleLabel setFont:[UIFont systemFontOfSize:60]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:color];
    [button setTitle:text forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [button setAlpha:0.0];
    return button;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.noteHintLabel removeFromSuperview];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        [self.view addSubview:self.noteHintLabel];
    } else {
        self.eventNote = textView.text;
    }
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
