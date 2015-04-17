//
//  User.m
//  MUPSQLiteORM
//
//  Created by lujb on 15/4/15.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "User.h"

@implementation User

+(NSArray*)primaryKeys{
    return @[@"userID"];
}

+(NSArray*)indices
{
    return @[@"userName"];
}

@end
