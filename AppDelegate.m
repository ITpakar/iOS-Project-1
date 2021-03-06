//
//  AppDelegate.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <AWSiOSSDKv2/S3.h>
#import "DubbRootViewController.h"
#import "ChatViewController.h"
#import "ChatHistoryController.h"
#import "MBProgressHUD.h"
#import "User.h"

@interface AppDelegate (){
    CLLocationManager *locationManager;
    CLGeocoder *geoCoder;
    CLPlacemark *placeMark;

}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [User currentUser];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self enableQuickBlox];
    
    #ifndef DEBUG
    [QBSettings useProductionEnvironmentForPushNotifications:YES];
    
    #endif

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if( remoteNotification )
        [self openMessageFromNotification:remoteNotification];
    
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:awsAccessKey secretKey:awsSecretKey];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    return YES;
}


#pragma mark - 
#pragma mark Google Analytics
-(void) enableGoogleAnalytics
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 30;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackId];
}


- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}


#pragma mark -
#pragma mark Facebook

 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark - 
#pragma mark QuickBlox

-(void) enableQuickBlox
{
    [QBApplication sharedApplication].applicationId = qbAppID;
    [QBConnection registerServiceKey:qbServiceKey];
    [QBConnection registerServiceSecret:qbServiceSecret];
    [QBSettings setAccountKey:qbAccountKey];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if( [User currentUser].chatUser )
        [[ChatService instance] logout];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if( [User currentUser].chatUser )
        [[ChatService instance] logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if( [User currentUser].chatUser ){
        [[ChatService instance] loginWithUser:[User currentUser].chatUser completionBlock:^{
            
        }];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}


#pragma mark -
#pragma mark GeoLocation

-(void) updateUserLocation
{
    if( locationManager == nil ){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    if( geoCoder == nil ) geoCoder = [[CLGeocoder alloc] init];
    
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        User *currentUser = [User currentUser];
        currentUser.longitude = [NSNumber numberWithFloat: currentLocation.coordinate.longitude];
        currentUser.latitude = [NSNumber numberWithFloat: currentLocation.coordinate.latitude];        
    }
    
    [locationManager stopUpdatingLocation];
    
    /*
     // Reverse Geocoding
     NSLog(@"Resolving the Address");
     [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
     NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
     if (error == nil && [placemarks count] > 0) {
     placeMark = [placemarks lastObject];
     
     if (placeMark.postalCode)
     [dicLocation setObject: placeMark.postalCode forKey: @"postalCode"];
     else
     [dicLocation setObject: @"" forKey: @"postalCode"];
     
     if (placeMark.locality)
     [dicLocation setObject: placeMark.locality forKey: @"city"];
     else
     [dicLocation setObject: @"" forKey: @"city"];
     
     if (placeMark.administrativeArea)
     [dicLocation setObject: placeMark.administrativeArea forKey: @"administrativeArea"];
     else
     [dicLocation setObject: @"" forKey: @"administrativeArea"];
     
     if (placeMark.country)
     [dicLocation setObject: placeMark.country forKey: @"country"];
     else
     [dicLocation setObject: @"" forKey: @"country"];
     
     if (placeMark.ISOcountryCode)
     [dicLocation setObject: placeMark.ISOcountryCode forKey: @"countryCode"];
     else
     [dicLocation setObject: @"" forKey: @"countryCode"];
     
     [User currentUser].location = dicLocation;
     } else {
     NSLog(@"%@", error.debugDescription);
     }
     }];*/
}


- (void)registerForRemoteNotifications{
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    #else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    #endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
    [self openMessageFromNotification:userInfo];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [QBRequest registerSubscriptionForDeviceToken:deviceToken successBlock:^(QBResponse *response, NSArray *subscriptions) {
        NSLog(@"Register for APNS");
    } errorBlock:nil];
}


#pragma mark Message Notification

//Message when App is foreground
-(void) didReceiveMessage:(QBChatMessage *)message {
    
    if( ![self.window.rootViewController isKindOfClass:[DubbRootViewController class]] ) return;
    
    DubbRootViewController *rootVC = (DubbRootViewController*)self.window.rootViewController;
    UINavigationController *navController = (UINavigationController *)rootVC.contentViewController;
    
    if( [[navController visibleViewController] isKindOfClass:[ChatViewController class]] ){  //ChatViewController is Opened now
        ChatViewController *chatVC = (ChatViewController*)[navController visibleViewController];
        if( chatVC.dialog.recipientID == message.senderID ) return;
    } else if ([[navController visibleViewController] isKindOfClass:[ChatHistoryController class]]){
        ChatHistoryController *chatHistoryVC = (ChatHistoryController*)[navController visibleViewController];
        [chatHistoryVC reloadChatHistory];
    }
    
    [self showNotification:message];
}

-(void) showNotification: (QBChatMessage*)message
{
    if( _notificationView == nil ){
        _notificationView = [[NotificationView alloc] init];
        _notificationView.delegate = self;
    }
    
    QBUUser *user = [User currentUser].usersAsDictionary[@(message.senderID)];
    if( user ){
        [self.window.rootViewController.view addSubview:_notificationView];
        [_notificationView hideNotification];
        NSString *notification = [NSString stringWithFormat:@"%@: %@", user.fullName, message.text];
        _notificationView.messageInfo = @{@"sender":@(message.senderID), @"receiver":@(message.recipientID)};
        [_notificationView showMessage:notification];
        return;
    }
    
    [QBRequest userWithID:message.senderID successBlock:^(QBResponse *response, QBUUser *user) {
        
        
        [self.window.rootViewController.view addSubview:_notificationView];
        NSString *notification = [NSString stringWithFormat:@"%@: %@", user.fullName, message.text];
        _notificationView.messageInfo = @{@"sender":@(message.senderID), @"receiver":@(message.recipientID)};
        [_notificationView showMessage:notification];
    } errorBlock:^(QBResponse *response) {
        
    }];
}

-(void) openMessage:(NSDictionary *)messageInfo
{
    [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
    
    QBChatDialog *chatDialog = [QBChatDialog new];
    chatDialog.occupantIDs = @[messageInfo[@"sender"]];
    chatDialog.type = QBChatDialogTypePrivate;
    [QBChat createDialog:chatDialog delegate:self];
}

//Message when app is background
-(void) openMessageFromNotification: (NSDictionary*) info
{
    if([User currentUser].chatUser){
        [QBChat updateDialogWithID:info[@"dialog_id"] extendedRequest:nil delegate:self];
    }
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(QBResult *)result{
    
    [MBProgressHUD hideAllHUDsForView:self.window.rootViewController.view animated:NO];
    
    if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
        // dialog created
        
        QBChatDialogResult *dialogRes = (QBChatDialogResult *)result;
        
        ChatViewController *chatController = (ChatViewController*)[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"chatController"];
        chatController.dialog = dialogRes.dialog;
        DubbRootViewController *rootVC = (DubbRootViewController*)self.window.rootViewController;
        UINavigationController *navController = (UINavigationController *)rootVC.contentViewController;
        [navController pushViewController:chatController animated:YES];
        
    }else{
    }
}

@end
