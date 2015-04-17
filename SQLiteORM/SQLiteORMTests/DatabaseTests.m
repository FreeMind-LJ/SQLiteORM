//
//  DatabaseTests.m
//  MUPSQLiteORM
//
//  Created by lujb on 15/4/15.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


#import "SQLiteORM.h"

#import "Message.h"
#import "User.h"

@interface DatabaseTests : XCTestCase
@end

@implementation DatabaseTests

/**
 *  添加数据
 */
    -(void)testAddItems
    {
        BOOL reselut = NO;
        
        Message *message = [Message new];
        message.messageID = 9;
        message.messageContent = @"this is test message 9";
        reselut = [message save];

        
        Message *message1 = [Message new];
        message1.messageID = 10;
        message1.messageContent = @"this is test message 10";
        reselut = [message1 save];
        
        Message *message2 = [Message new];
        message2.messageID = 11;
        message2.messageContent = @"this is test message 11";
        reselut = [message2 save];
        
        //分表
        Message *message3 = [Message new];
        message3.messageID = 12;
        message3.messageContent = @"this is test message 12";
        message3.tableName = @"message12";
        reselut = [message3 save];
    }

/**
 *  添加嵌套对象
 */
-(void)testAddEmbedObj
{
    BOOL reselut = NO;
    Message *message1 = [Message new];
    message1.messageID = 13;
    message1.messageContent = @"this is test message 13";
    
    Message *message2 = [Message new];
    message2.messageID = 14;
    message2.messageContent = @"this is test message 14";
    
    //分表
    Message *message3 = [Message new];
    message3.messageID = 15;
    message3.messageContent = @"this is test message 15";
    message3.tableName = @"message15";
    
    NSArray *array = [NSArray arrayWithObjects:message2,message3, nil];
    
    User *user1 = [User new];
    user1.userID = 1;
    user1.userName = @"user1";
    user1.firstMessage = message1;
    user1.userDictionary = @{@"father":@"jhon peter",@"mother":@"taylor swift"};
    user1.recentMessages = array;
    
    reselut = [[MUPSQLiteORM defaultORM] addOrUpdateObject:user1];
    
    MUPResultSet *resultSet = [User allObjects];
    
    User *userFind = [resultSet firstObject];
}

/**
 *  测试删除对象
 */
-(void)testDeleteObj
{
    BOOL ret = NO;
    MUPResultSet *resultSet = [User allObjects];
    
    User *user1= [resultSet firstObject];
    
     ret =  [user1 remove];
}

/**
 *  测试查找对象
 */
-(void)testFindObj
{
    MUPResultSet *messageSet = [Message allObjects];
    NSArray *allMessage = messageSet.dataArray;
    
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"messageID > %@",@(10)];
    MUPResultSet *filterSet =  (MUPResultSet*)[messageSet objectsWithPredicate:pred];
    NSArray *filterArray = filterSet.dataArray;
    
}

/**
 *  测试更新数据
 */
    -(void)testUpdateObj
    {
        BOOL ret = NO;
        MUPResultSet *userSet = [User allObjects];
        User *user = [userSet firstObject];
        
        NSDictionary *updateDic = @{@"userName":@"userNameUpdate",@"firstMessage.messageContent":@"firstMessageContent Changed",@"userDictionary.father":@"lujb"};
        ret = [user patch:updateDic];
        
        userSet = [User allObjects];
        User *userUpdate = [userSet firstObject];

    }

/**
 *  测试orm切换
 */
-(void)testOrmChanged
{
    BOOL ret = NO;
    MUPSQLiteORM *defaultOrm = [MUPSQLiteORM defaultORM];
    NSString *path = [MUPSQLiteORM defaultORMPath];
    
    path = defaultOrm.ormPath;
    
    NSString *newPath = @"/Users/houxh/Library/Developer/CoreSimulator/Devices/07C486D5-01FD-4F25-9A69-6FE720C29A2E/data/Documents/newORM.sqlite";
    
    MUPSQLiteORM *newOrm = [MUPSQLiteORM ormWithPath:newPath];
    
    Message *message1 = [Message new];
    message1.messageID = 23;
    message1.messageContent = @"this is test message 23";
    ret = [newOrm addOrUpdateObject:message1];
    
    Message *message2 = [Message new];
    message2.messageID = 24;
    message2.messageContent = @"this is test message 24";
    message2.MUPORM = newOrm;
    ret = [message2 save];

}

/**
 *  测试resultSet操作
 */
-(void)testResultOperation
{
    MUPResultSet *messageSet = [Message allObjects];
    
    NSNumber *total = [messageSet sumOfProperty:@"messageID"];
    
    NSNumber *average = [messageSet averageOfProperty:@"messageID"];
}


@end