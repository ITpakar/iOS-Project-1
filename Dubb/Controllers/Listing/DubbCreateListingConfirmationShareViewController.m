//
//  DubbCreateListingConfirmationShareViewController.m
//  Dubb
//
//  Created by andikabijaya on 9/14/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "DubbActivityProvider.h"
#import "DubbCreateListingConfirmationShareViewController.h"
#define commonShareText(listingTitle)  [NSString stringWithFormat:@"I just bought this cool service '%@' on - Dubb Mobile Marketplace for Creative Freelancers - http://www.dubb.com/app", listingTitle]
@interface DubbCreateListingConfirmationShareViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *onIndicatorView;
@property (strong, nonatomic) IBOutlet UILabel *emailTabLabel;
@property (strong, nonatomic) IBOutlet UILabel *smsTabLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *onIndicatorViewCenterConstraint;
@property (strong, nonatomic) IBOutlet UIView *emailContainerView;
@property (strong, nonatomic) IBOutlet UIView *smsContainerView;
@property (strong, nonatomic) IBOutlet UILabel *listingTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *listingImageView;
@property (strong, nonatomic) IBOutlet UIView *previewContainerView;
@property (strong, nonatomic) IBOutlet UILabel *orderAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *slugLabel;
@property (strong, nonatomic) IBOutlet UITableView *smsTableView;
@property (strong, nonatomic) IBOutlet UITableView *emailTableView;
@property (strong, nonatomic) IBOutlet UILabel *contactsNumberLabel;

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property (nonatomic, strong) NSMutableArray *arrContactsData;
@property (nonatomic, strong) NSMutableArray *arrContactPhoneNumbers;
@property (nonatomic, strong) NSMutableArray *arrContactEmails;
@end

enum DubbEmailCellTag {
    kDubbEmailCellProfileImageViewTag = 100,
    kDubbEmailCellNameLabelTag,
    kDubbEmailCellEmailLabelTag,
    kDubbEmailCellSendButtonTag
};

enum DubbSmsCellTag {
    kDubbSmsCellProfileImageViewTag = 104,
    kDubbSmsCellNameLabelTag,
    kDubbSmsCellPhoneNumberLabelTag,
    kDubbSmsCellSendButtonTag
};
@implementation DubbCreateListingConfirmationShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listingTitleLabel.text = self.listingTitle;
    self.locationLabel.text = self.listingLocation.address;
    self.listingImageView.image = self.mainImage;
    self.orderAmountLabel.text = [NSString stringWithFormat:@"$%ld", (long)self.baseServicePrice];
    self.slugLabel.text = self.slugUrlString;
    self.previewContainerView.layer.borderWidth = 1.0f;
    self.previewContainerView.layer.borderColor = [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f].CGColor;
    
    _arrContactPhoneNumbers = [[NSMutableArray alloc] init];
    _arrContactEmails = [[NSMutableArray alloc] init];
    [self obtainContactsInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)addContact:(ABRecordRef)person{
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", [UIImage imageNamed:@"placeholder_image.png"]]
                                            forKeys:@[@"firstName", @"lastName", @"phoneNumber", @"email", @"address", @"zipCode", @"city", @"image"]];
    
    
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    
    
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        if (currentPhoneValue) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"phoneNumber"];
        }
        
        CFRelease(currentPhoneValue);
    }
    CFRelease(phonesRef);
    
    
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
        
        if (currentEmailValue) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"email"];
            break;
        }
    }
    CFRelease(emailsRef);
    
    if (ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        [contactInfoDict setObject:contactImageData forKey:@"image"];
    }
    
    if (![contactInfoDict[@"phoneNumber"] isEqualToString:@""]) {
        [_arrContactPhoneNumbers addObject:contactInfoDict];
    }
    
    if (![contactInfoDict[@"email"] isEqualToString:@""]) {
        [_arrContactEmails addObject:contactInfoDict];
    }
    
    return NO;
}
- (IBAction)emailTabButtonTapped:(id)sender {
    self.emailTabLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    self.smsTabLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    self.onIndicatorView.center = CGPointMake(self.emailContainerView.center.x, self.onIndicatorView.center.y);
    self.emailTableView.hidden = NO;
    self.smsTableView.hidden = YES;
    self.contactsNumberLabel.text = [NSString stringWithFormat:@"%ld CONTACTS", _arrContactEmails.count];
}
- (IBAction)smsTabButtonTapped:(id)sender {
    self.smsTabLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    self.emailTabLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    self.onIndicatorView.center = CGPointMake(self.smsContainerView.center.x, self.onIndicatorView.center.y);
    self.emailTableView.hidden = YES;
    self.smsTableView.hidden = NO;
    self.contactsNumberLabel.text = [NSString stringWithFormat:@"%ld CONTACTS", _arrContactPhoneNumbers.count];
}
- (IBAction)sendButtonTapped:(id)sender {
    [self.navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"]] animated:NO];
    
}
- (IBAction)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)copyToClipboardButtonTapped:(id)sender {
    NSString *listingTitle = self.listingTitle;
    DubbActivityProvider *activityProvider = [[DubbActivityProvider alloc] initWithListingTitle:listingTitle];
    NSURL *url = [NSURL URLWithString:self.slugLabel.text];
    NSArray *objectsToShare = @[activityProvider, listingTitle, url];
    
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    
    [activityVC setCompletionWithItemsHandler:^(NSString *act, BOOL done, NSArray *returnedItems, NSError *activity)
     {
         if (done) {
             NSString *ServiceMsg = @"Message Has Been Shared!";
             [self showMessage:ServiceMsg];
         }
         
         
     }];

}

-(void)obtainContactsInfo{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                [self addContactsToAddressBook];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self addContactsToAddressBook];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    }

- (void)addContactsToAddressBook {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        [self addContact:ref];
    }
    [self.emailTableView reloadData];
    [self.smsTableView reloadData];
    NSLog(@"%@", allPeople);

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (tableView == self.emailTableView) {
        return _arrContactEmails.count;
    } else {
        return _arrContactPhoneNumbers.count;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView == self.emailTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EmailCell"];
        
        UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kDubbEmailCellProfileImageViewTag];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:kDubbEmailCellNameLabelTag];
        UILabel *emailLabel = (UILabel *)[cell viewWithTag:kDubbEmailCellEmailLabelTag];
        UIButton *sendButton = (UIButton *)[cell viewWithTag:kDubbEmailCellSendButtonTag];
        
        NSMutableDictionary *contactEmail = _arrContactEmails[indexPath.row];
        profileImageView.image = contactEmail[@"image"];
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", contactEmail[@"firstName"], contactEmail[@"lastName"]];
        emailLabel.text = contactEmail[@"email"];
        
        sendButton.tag = indexPath.row;
        [sendButton addTarget:self action:@selector(sendEmail:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SMSCell"];
        UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kDubbSmsCellProfileImageViewTag];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:kDubbSmsCellNameLabelTag];
        UILabel *phoneNumberLabel = (UILabel *)[cell viewWithTag:kDubbSmsCellPhoneNumberLabelTag];
        UIButton *sendButton = (UIButton *)[cell viewWithTag:kDubbSmsCellSendButtonTag];
        
        NSMutableDictionary *contactEmail = _arrContactPhoneNumbers[indexPath.row];
        profileImageView.image = contactEmail[@"image"];
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", contactEmail[@"firstName"], contactEmail[@"lastName"]];
        phoneNumberLabel.text = contactEmail[@"phoneNumber"];
        
        sendButton.tag = indexPath.row;
        [sendButton addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)sendEmail:(UIButton *)sender {
    NSLog(@"Sending Email...");
    
    NSMutableDictionary *contactEmail = _arrContactEmails[sender.tag];
    NSString *emailTitle = @"I just made my services available on @dubbapp";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"Hi,  Check out my listing %@. You can download dubb app at http://www.dubb.com/app", self.slugUrlString];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:contactEmail[@"email"]];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)sendSMS:(UIButton *)sender {
    NSLog(@"Sending SMS...");
    
    NSMutableDictionary *contactPhoneNumber = _arrContactPhoneNumbers[sender.tag];
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[contactPhoneNumber[@"phoneNumber"]];
    NSString *message = [NSString stringWithFormat:@"Hi,  Check out my listing %@. You can download dubb app at http://www.dubb.com/app", self.slugUrlString];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
#pragma mark - MFMessageComposeViewController Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewController Delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
