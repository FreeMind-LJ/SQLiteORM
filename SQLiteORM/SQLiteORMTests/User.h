//
//  User.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/4/15.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPObject.h"

@class Message;

@interface User : MUPObject

@property(nonatomic,assign) UInt64 userID;

@property(nonatomic,copy) NSString *userName;

@property(nonatomic,strong)Message *firstMessage;

@property(nonatomic,strong)NSArray *recentMessages;

@property(nonatomic,strong)NSDictionary *userDictionary;


@end
