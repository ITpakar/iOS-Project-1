//
//  DubbCreateListingConfirmationViewController.m
//  Dubb
//
//  Created by andikabijaya on 4/25/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <Social/Social.h>

#import "DubbCreateListingConfirmationViewController.h"

#define commonShareText  @"Discover and Hire local creative freelancers on the Dubb Mobile Marketplace http://www.dubb.co/app"

@interface DubbCreateListingConfirmationViewController ()
@property (strong, nonatomic) IBOutlet UILabel *listingTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *listingImageView;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@end

@implementation DubbCreateListingConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listingTitleLabel.text = self.listingTitle;
    self.profileImageView.image = [User currentUser].profileImage;
    self.userNameLabel.text = [User currentUser].username;
    self.locationLabel.text = self.listingLocation.address;
    self.listingImageView.image = self.mainImage;
    self.categoryLabel.text = self.categoryDescription;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}



#pragma mark - IBActions
- (IBAction)shareOnTwitterButtonTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Discover and Hire local creative freelancers on @Dubbapp  Mobile Marketplace http://www.dubb.co/app"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Twitter is not installed on this device! Please install first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}
- (IBAction)shareOnSmsButtonTapped:(id)sender {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[@""];
    NSString *message = commonShareText;
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
- (IBAction)shareOnEmailButtonTapped:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Awesome News!";
    // Email Content
    NSString *messageBody = commonShareText;
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@""];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];

}
- (IBAction)shareOnWhatsAppButtonTapped:(id)sender {
    
    NSString *textToShare = commonShareText;
    NSString *textToSend = [NSString stringWithFormat:@"whatsapp://send?text=%@", [textToShare stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *whatsappURL = [NSURL URLWithString:textToSend];
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Whatsapp is not installed on this device! Please install first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}
- (IBAction)shareOnFacebookButtonTapped:(id)sender {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:commonShareText];
        [self presentViewController:controller animated:YES completion:Nil];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Facebook is not installed on this device! Please install first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
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