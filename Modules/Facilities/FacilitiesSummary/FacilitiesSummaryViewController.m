#import <QuartzCore/QuartzCore.h>

#import "FacilitiesSummaryViewController.h"
#import "FacilitiesCategory.h"
#import "FacilitiesLocation.h"
#import "FacilitiesRoom.h"
#import "FacilitiesRepairType.h"
#import "FacilitiesConstants.h"
#import "FacilitiesSubmitViewController.h"
#import "UIImage+Resize.h"

enum {
    FacilitiesFocusDescription = 1,
    FacilitiesFocusEmail
};

@interface FacilitiesSummaryViewController ()
- (UIView*)firstResponderInView:(UIView*)view;
@end

@implementation FacilitiesSummaryViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize imageButton = _imageButton;
@synthesize problemLabel = _problemLabel;
@synthesize descriptionView = _descriptionView;
@synthesize emailField = _emailField;
@synthesize reportData = _reportData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Detail";
    }
    return self;
}

- (void)dealloc
{
    self.imageView = nil;
    self.problemLabel = nil;
    self.descriptionView = nil;
    self.emailField = nil;
    self.reportData = nil;
    self.scrollView = nil;
    self.imageButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
    self.imageView.layer.cornerRadius = 5.0;
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageButton.layer.cornerRadius = 5.0;
    self.imageButton.backgroundColor = [UIColor colorWithWhite:1
                                                         alpha:0.25];
    
    self.descriptionView.layer.cornerRadius = 5.0f;
    self.descriptionView.layer.borderWidth = 2.0f;
    self.descriptionView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descriptionView.delegate = self;
    
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                              style:UIBarButtonItemStyleDone
                                                             target:self
                                                             action:@selector(submitReport:)] autorelease];
    item.title = @"Submit";
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.backBarButtonItem.title = @"Cancel";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    FacilitiesLocation *location = [self.reportData objectForKey:FacilitiesRequestLocationBuildingKey];
    FacilitiesRoom *room = [self.reportData objectForKey:FacilitiesRequestLocationRoomKey];
    FacilitiesRepairType *type = [self.reportData objectForKey:FacilitiesRequestRepairTypeKey];
    NSString *customLocation = [self.reportData objectForKey:FacilitiesRequestLocationUserBuildingKey];
    NSString *customRoom = [self.reportData objectForKey:FacilitiesRequestLocationUserRoomKey];
    NSString *typeString = [type.name lowercaseString];

    NSString *text = nil;
    
    if (location && room) {
        text = [NSString stringWithFormat:@"I'm reporting a problem with a %@ at %@ near room %@.",typeString,location.name,[room displayString]];
    } else if (location) {
        if ([customRoom hasSuffix:@"side"]) {
            text = [NSString stringWithFormat:@"I'm reporting a problem with a %@ %@ %@.",typeString,[customRoom lowercaseString],location.name];
        } else {
            text = [NSString stringWithFormat:@"I'm reporting a problem with a %@ at %@ near %@.",typeString,location.name,[customRoom lowercaseString]];
        }
    } else {
        text = [NSString stringWithFormat:@"I'm reporting a problem with a %@ in %@",typeString,customLocation];
    }
    
    self.problemLabel.text = text;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.imageView = nil;
    self.problemLabel = nil;
    self.descriptionView = nil;
    self.emailField = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction Methods
- (IBAction)selectPicture:(id)sender {
    if (_keyboardIsVisible) {
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                otherButtonTitles:@"Take Photo",@"Choose Existing", nil] autorelease];
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [sheet showInView:self.view];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *controller = [[[UIImagePickerController alloc] init] autorelease];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        [self presentModalViewController:controller
                                animated:YES];
    }
}

- (IBAction)submitReport:(id)sender {
    if (_keyboardIsVisible) {
        return;
    }
    
    if ([self.descriptionView.text length] == 0) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Information Missing"
                                                         message:@"Please enter a description before continuing"
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil] autorelease];
        alert.tag = FacilitiesFocusDescription;
        [alert show];
        return;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.reportData];
    [dictionary setObject:self.emailField.text
                   forKey:FacilitiesRequestUserEmailKey];
    [dictionary setObject:self.descriptionView.text
                   forKey:FacilitiesRequestUserDescriptionKey];
    self.reportData = dictionary;
    [self.navigationController pushViewController:[[[FacilitiesSubmitViewController alloc] initWithReportData:dictionary] autorelease]
                                                                           animated:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    if (_keyboardIsVisible) {
        UIView *firstResponder = [self firstResponderInView:self.view];
        
        if (firstResponder) {
            [firstResponder resignFirstResponder];
        }
    }
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *controller = [[[UIImagePickerController alloc] init] autorelease];
    if (buttonIndex == 0) {
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.showsCameraControls = YES;
    } else if (buttonIndex == 1) {
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (buttonIndex == 2) {
        return;
    }
    
    controller.delegate = self;
    [self presentModalViewController:controller
                            animated:YES];
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (image) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.reportData];
        [dictionary setObject:image
                       forKey:FacilitiesRequestImageKey];
        self.reportData = dictionary;
        self.imageView.image = image;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageButton.hidden = YES;
    } else {
        self.imageView.image = nil;
        self.imageButton.hidden = NO;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Notification Methods
- (UIView*)firstResponderInView:(UIView*)view {
    if ([view isFirstResponder]) {
        return view;
    }
    
    for (UIView *subview in view.subviews) {
        UIView *fr = [self firstResponderInView:subview];
        if (fr) {
            return fr;
        }
    }
    
    return nil;
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSValue *keyboard = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[keyboard CGRectValue]
                                        fromView:nil];
    CGSize keyboardSize = keyboardRect.size;

    NSValue *durationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [durationValue getValue:&duration];

    NSValue *curveValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions options = 0;
    [curveValue getValue:&options];
    options |= UIViewAnimationOptionBeginFromCurrentState;
    options |= UIViewAnimationOptionAllowAnimatedContent;

    UIView *responder = [self firstResponderInView:self.view];
    CGRect responderRect = CGRectZero;
    if (responder) {
        responderRect = responder.frame;
        CGFloat minFrame = responderRect.origin.y + responderRect.size.height;
        if (minFrame > keyboardSize.height) {
    	    responderRect.origin.y += 10;
        }
    }

	CGRect viewFrame = self.scrollView.frame;
	viewFrame.size.height -= keyboardSize.height;

    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^ {
                         [self.scrollView setFrame:viewFrame];
                         [self.scrollView scrollRectToVisible:responderRect
                                                     animated:NO];
                     }
                     completion:nil];
    _keyboardIsVisible = YES;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSValue *keyboardValue = [[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [keyboardValue CGRectValue];

    NSValue *durationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [durationValue getValue:&duration];

    NSValue *curveValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions options = 0;
    [curveValue getValue:&options];
    options |= UIViewAnimationOptionBeginFromCurrentState;
    
    CGRect visibleRect = self.scrollView.frame;
    visibleRect.size.height += keyboardRect.size.height;

    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^ {
                         [self.scrollView setFrame:visibleRect];
                     }
                     completion:^ (BOOL finished) {
                         if (finished) {
                             [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1)
                                                         animated:YES];
                         }
                     }];
    _keyboardIsVisible = NO;
}
@end
