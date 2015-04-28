# SQLiteORM
基于fmdb构建的orm，支持自动建表，分表，支持属性增删改查自动操作等，同时支持模型的嵌套

# Requirements

* ARC
- FMDB

# Usages

###定义模型

#####定义消息模型
    #import "MUPObject.h"

    @interface Message : MUPObject
    @property(nonatomic,assign) UInt64 messageID;
    @property(nonatomic,copy) NSString *messageContent;
    @end
  
    
    @implementation Message
    //设置主键
    +(NSArray*)primaryKeys{
      return @[@"messageID"];
    }
    @end
    
#####定义user模型
    @interface User : MUPObject
    @property(nonatomic,assign) UInt64 userID;
    @property(nonatomic,copy) NSString *userName;
    @property(nonatomic,strong)Message *firstMessage;
    @property(nonatomic,strong)NSArray *recentMessages;
    @property(nonatomic,strong)NSDictionary *userDictionary;
    @end
    
    @implementation User

    +(NSArray*)primaryKeys{
        return @[@"userID"];
    }
    //建立索引,create indices
    +(NSArray*)indices
    {
        return @[@"userName"];
    }
    @end

###添加对象,add obj
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

###添加嵌套对象,add obj
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
    }
###删除对象,delete obj
    -(void)testDeleteObj
    {
        BOOL ret = NO;
        MUPResultSet *resultSet = [User allObjects];
        User *user1= [resultSet firstObject];
        ret =  [user1 remove];
    }
###查找对象,find object ,use nspredicate
    -(void)testFindObj
    {
        MUPResultSet *messageSet = [Message allObjects];
        NSArray *allMessage = messageSet.dataArray;
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"messageID > %@",@(10)];
        MUPResultSet *filterSet =  (MUPResultSet*)[messageSet objectsWithPredicate:pred];
        NSArray *filterArray = filterSet.dataArray;
        
    }
###更新对象,update object
    -(void)testUpdateObj
    {
        BOOL ret = NO;
        MUPResultSet *userSet = [User allObjects];
        User *user = [userSet firstObject];
        NSDictionary *updateDic = @{@"userName":@"userNameUpdate",@"firstMessage.messageContent":@"firstMessageContent Changed",@"userDictionary.father":@"lujb"};
        ret = [user patch:updateDic];
    }
###切换ORM,change orm
    -(void)testOrmChanged
    {
        BOOL ret = NO;
        MUPSQLiteORM *defaultOrm = [MUPSQLiteORM defaultORM];
        NSString *path = [MUPSQLiteORM defaultORMPath];
        
        path = defaultOrm.ormPath;
        
        NSString *newPath = @"test/newORM.db";
        
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
    
###对结果集进行操作,operaion on mupResultSet
    -(void)testResultOperation
    {
        MUPResultSet *messageSet = [Message allObjects];
        NSNumber *sum = [messageSet sumOfProperty:@"messageID"];
        NSNumber *average = [messageSet averageOfProperty:@"messageID"];
    }

###  支持keypath子查询

    -(void)testKeyPathPredicate
    {
    //    for (int i=20;i<35;i++)
    //    {
    //        Message *message = [Message new];
    //        message.messageID = i;
    //        message.messageContent =[NSString stringWithFormat: @"this is test message %d",i ];
    //        
    //        
    //        User *user = [User new];
    //        user.userID = i;
    //        user.userName = [NSString stringWithFormat: @"user %d",i ];
    //        user.firstMessage = message;
    //        user.userDictionary = @{@"father":@"jhon peter",@"mother":@"taylor swift"};
    //        [[MUPSQLiteORM defaultORM] addOrUpdateObject:user];
    //    }
    
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID > %@ ", @23];
         MUPResultSet *result = [User allObjectsWithPredicate:predicate];

         predicate = [NSPredicate predicateWithFormat:@"firstMessage.messageID in %@ and firstMessage.messageID IN%@", @[@22,@23,@25],@[@23,@29,@30]];
         result = [User allObjectsWithPredicate:predicate];
    
        predicate = [NSPredicate predicateWithFormat:@"firstMessage.messageID > %@ or userID IN %@",@30,@[@23,@29,@30]];
        result = [User allObjectsWithPredicate:predicate];
    }
