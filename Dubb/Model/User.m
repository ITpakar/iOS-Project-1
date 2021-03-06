//
//  User.m
//  Dubb
//
//  Created by Oleg Koshkin on 13/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "User.h"

@implementation User

+(User*) currentUser{
    static User* user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[self alloc] init];
        user.timeZone = 8;
        user.longitude = @0;
        user.latitude = @0;
        user.quickbloxID = @"";
        [user initialize];
    });
    
    return user;
}

-(void) initialize{
    _usersAsDictionary = [NSMutableDictionary dictionary];
    _avatarsAsDictionary = [NSMutableDictionary dictionary];
    _username = [NSString stringWithFormat:@"%@", @""];
    _userID = [NSString stringWithFormat:@"%@", @""];
    _firstName = [NSString stringWithFormat:@"%@", @""];
    _lastName = [NSString stringWithFormat:@"%@", @""];
    _fbID = [NSString stringWithFormat:@"%@", @""];
    _gpID = [NSString stringWithFormat:@"%@", @""];
    _zipCode = [NSString stringWithFormat:@"%@", @""];
    _countryCode = [NSString stringWithFormat:@"%@", @""];
    _profileImageURL = @"";
    _chatUser = nil;
    _profileImage = nil;
    _quickbloxID = @"";
}


+(User*) initialize:(NSDictionary*) dic
{
    User *user = [User currentUser];
    
    if(dic[@"id"] && ![dic[@"id"] isKindOfClass:[NSNull class]] )
        user.userID = dic[@"id"];

    if( dic[@"quickblox_id"] && ![dic[@"quickblox_id"] isKindOfClass:[NSNull class]] )
        user.quickbloxID = dic[@"quickblox_id"];
    
    if( dic[@"email"] && ![dic[@"email"] isKindOfClass:[NSNull class]] )
        user.email = dic[@"email"];
    
    if( dic[@"username"] && ![dic[@"username"] isKindOfClass:[NSNull class]] ){
        user.username = dic[@"username"];
    }
    
    if( dic[@"first"] && ![dic[@"first"] isKindOfClass:[NSNull class]] ){
        user.firstName = dic[@"first"];
    }
    
    if( dic[@"last"] && ![dic[@"last"] isKindOfClass:[NSNull class]] ){
        user.lastName = dic[@"last"];
    }
    
    return user;
}

- (void)setChatUsers:(NSArray *)chatUsers
{
    _chatUsers = chatUsers;
    
    //NSMutableDictionary *__usersAsDictionary = [NSMutableDictionary dictionary];
    for(QBUUser *user in chatUsers){
        //if( ![_usersAsDictionary objectForKey:@(user.ID)] )
            [_usersAsDictionary setObject:user forKey:@(user.ID)];
    }
    
    //_usersAsDictionary = [__usersAsDictionary copy];
    //[_usersAsDictionary addEntriesFromDictionary:__usersAsDictionary];
}

@end
