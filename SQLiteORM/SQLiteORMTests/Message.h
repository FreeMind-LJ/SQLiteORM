//
//  Message.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/4/15.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPObject.h"

@interface Message : MUPObject

@property(nonatomic,assign) UInt64 messageID;

@property(nonatomic,copy) NSString *messageContent;

@end
