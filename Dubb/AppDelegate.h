//
//  AppDelegate.h
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NotificationView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NotificationDelegate, QBActionStatusDelegate, CLLocationManagerDelegate>

-(void)registerForRemoteNotifications;

-(void)didReceiveMessage: (QBChatMessage*) message;
-(void)updateUserLocation;@property (strong, nonatomic) UIWindow *window;
-(void)startLocationTimer;

@property (strong) NotificationView *notificationView;



@end

