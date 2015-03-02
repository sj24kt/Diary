//
//  EntryViewController.m
//  Diary
//
//  Created by Sherrie Jones on 2/26/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import "EntryViewController.h"
#import "DiaryEntry.h"
#import "CoreDataStack.h"
#import <CoreLocation/CoreLocation.h>

@interface EntryViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIImage *pickedImage;
@property (assign, nonatomic) enum DiaryEntryMood pickedMood;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *location;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *badButton;
@property (weak, nonatomic) IBOutlet UIButton *averageButton;
@property (weak, nonatomic) IBOutlet UIButton *goodButton;
@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@end

@implementation EntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Don't forget to add NSLocationWhenInUseUsageDescription & NSLocationAlwaysUsageDescription in info.plist as a string
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    NSDate *date;

    // configure viewController IF we have an entry
    if (self.entry != nil) {
        self.textView.text = self.entry.body;
        self.pickedMood = self.entry.mood;
        date = [NSDate dateWithTimeIntervalSince1970:self.entry.date];

        // add a check for no images else the "noimage" placeholder will disappear
        if (self.entry.imageData != nil) {
            [self setPickedImage:[UIImage imageWithData:self.entry.imageData]];
        }
    } else {
        self.pickedMood = DiaryEntryMoodGood;
        date = [NSDate date];
        [self locationManager];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d, yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];

    self.textView.inputAccessoryView = self.accessoryView;
    self.imageButton.layer.cornerRadius = CGRectGetWidth(self.imageButton.frame) / 2.0f;

    if (self.entry.imageData != nil) {
        UIImage *image = [UIImage imageWithData:self.entry.imageData];
        [self.imageButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // makes the keyboard appear automatically on the textView
    [self.textView becomeFirstResponder];

}

# pragma mark - IBAction Methods

- (IBAction)doneWasPressed:(UIBarButtonItem *)sender {

    // update when entry disappears otherwise insert a new entry
    if (self.entry != nil) {
        [self updateDiaryEntry];
    } else {
        // save the diaryEntry when done button was pressed
        [self insertDiaryEntry];
    }
    [self dismissSelf];
}

- (IBAction)cancelWasPressed:(UIBarButtonItem *)sender {
    [self dismissSelf];
}

- (IBAction)badWasPressed:(UIButton *)sender {
    self.pickedMood = DiaryEntryMoodBad;
}

- (IBAction)averageWasPressed:(UIButton *)sender {
    self.pickedMood = DiaryEntryMoodAverage;
}

- (IBAction)goodWasPressed:(UIButton *)sender {
    self.pickedMood = DiaryEntryMoodGood;
}

- (IBAction)imageButtonWasPressed:(UIButton *)sender {

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self promptForSource];
    } else {
        [self promptForPhotoRoll];
    }
}

# pragma mark - UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    // user did not cancel
    if (buttonIndex != actionSheet.cancelButtonIndex) {

        // user tapped on the camera
        if (buttonIndex != actionSheet.firstOtherButtonIndex) {
            [self promptForPhotoRoll];
        } else {
            [self promptForCamera];
        }
    }
}

- (void)promptForSource {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Roll", nil];

    [actionSheet showInView:self.view];
}

# pragma mark - UIImagePickerController methods

- (void)promptForCamera {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)promptForPhotoRoll {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)setPickedImage:(UIImage *)pickedImage {
    _pickedImage = pickedImage;

    if (pickedImage == nil) {
        [self.imageButton setImage:[UIImage imageNamed:@"icn_noimage"] forState:UIControlStateNormal];
    } else {
        [self.imageButton setImage:pickedImage forState:UIControlStateNormal];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // grab image that user selected
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.pickedImage = image;
//    [picker dismissViewControllerAnimated:YES completion:nil];  //Added this line
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPickedMood:(enum DiaryEntryMood)pickedMood {
    _pickedMood = pickedMood;

    self.badButton.alpha = 0.5f;
    self.averageButton.alpha = 0.5f;
    self.goodButton.alpha = 0.5f;

    switch (pickedMood) {
        case DiaryEntryMoodGood:
            self.goodButton.alpha = 1.0f;
            break;

        case DiaryEntryMoodAverage:
            self.averageButton.alpha = 1.0f;
            break;

        case DiaryEntryMoodBad:
            self.badButton.alpha = 1.0f;
            break;

        default:
            break;
    }
}

# pragma mark - Helper Methods

- (void)dismissSelf {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// insert new diary entry instance and insert into managed object context
- (void)insertDiaryEntry {

    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    // inserts an new entry into the core data stack environment
    DiaryEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"DiaryEntry" inManagedObjectContext:coreDataStack.managedObjectContext];

    // configure entities with the value entered in textField
    entry.body = self.textView.text;
    entry.date = [[NSDate date] timeIntervalSince1970];
    entry.imageData = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    entry.mood = self.pickedMood;
    entry.location = self.location; // geocoder location name
    
    // save the coreDataStack to persistent store
    [coreDataStack saveContext];
}

- (void)updateDiaryEntry {

    // update our diary entry based on whatever is in our user interface 
    self.entry.body = self.textView.text;
    self.entry.mood = self.pickedMood;

    if (self.pickedImage != nil) {
        self.entry.imageData = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    }
//     else {
//        self.entry.imageData = UIImageJPEGRepresentation(self.imageButton.imageView.image, 0.75);
//    }

    // update and save our context data
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    [coreDataStack saveContext];
}

// find approximate location
- (void)loadLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = 1000; // 1000 meters or 1 kilometer or 0.6 miles

    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation]; // already have location, conserve battery

    CLLocation *location = [locations firstObject]; // only pick first location in array

    // setup a Geocoder to turn location into name of a place
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject]; // save location name in placemark from array
        self.location = placemark.name;
    }];
}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}
@end






























