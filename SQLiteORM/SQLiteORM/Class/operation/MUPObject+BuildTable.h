//
//  MUPObject+BuildTable.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPObject.h"

@interface MUPObject (BuildTable)

/**
 *  在默认的orm中生成obj类型的表
 *
 *  @param tableName 表名
 */
+ (void)buildTableForTableName:(NSString*)tableName;

/**
 *  在指定的orm中生成obj类型的表
 *
 *  @param tableName 表名
 *  @param orm       orm名
 */
+ (void)buildTableForTableName:(NSString*)tableName orm:(MUPSQLiteORM*)orm;

/**
 *  判断表是否已经在默认的orm中建立
 *
 *  @param tableName 表的名字
 *
 *  @return YES:已建立   NO:未建立
 */
+ (BOOL)isTableBuiltForTableName:(NSString*)tableName;

/**
 *  判断表是否已经在指定的orm中建立
 *
 *  @param tableName 表名
 *  @param orm       orm名字
 *
 *  @return YES:已建立   NO:未建立
 */
+ (BOOL)isTableBuiltForTableName:(NSString*)tableName orm:(MUPSQLiteORM*)orm;

@end
