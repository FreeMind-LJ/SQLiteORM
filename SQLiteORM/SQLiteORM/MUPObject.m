//
//  MUPObject.m
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPObject.h"
#import "MUPObject+BuildTable.h"
#import "MUPObject+mapProperty.h"

@interface MUPObject ()

@end

@implementation MUPObject

static NSLock *__Lock = nil;

-(id)init
{
    self = [super init];
    if ( self )
    {
        NSString *tableName = [[self class] tableName];
        _tableName = tableName?tableName:NSStringFromClass([self class]);
        [[self class] buildTableForTableName:_tableName];
        self.MUPORM = [MUPSQLiteORM defaultORM];
    }
    return self;
}

-(void)setTableName:(NSString*)tableName
{
    if(tableName)
    {
        _tableName = tableName;
        [[self class] buildTableForTableName:_tableName];
    }
}

-(NSString*)className{
    return NSStringFromClass([self class]);
}

#pragma mark --  锁操作

+(void)lockProgress
{
    if (!__Lock) {
        __Lock = [[NSLock alloc] init];
    }
    [__Lock lock];
}

+(void)unlockProgress
{
    [__Lock unlock];
}

#pragma mark -- config 实现

+ (NSString *)tableName{
    return nil;
}

+ (NSString *)primaryKey{
    return nil;
}
+ (BOOL)AutoIncrement{
    return FALSE;
}
+ (NSArray *)ignoredProperties{
    return nil;
}

+ (NSArray *)primaryKeyUnion{
    return nil;
}

+ (NSArray *)indices{
    return nil;
}


@end
