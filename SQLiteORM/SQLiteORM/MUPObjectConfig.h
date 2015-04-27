//
//  MUPObjectConfig.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPSQLiteORM.h"

@protocol  MUPObjectConfig <NSObject>

@optional

/**
 *  设置表名，默认使用类名作为表名
 *
 *  @return 表名，返回空串或nil，则使用类名作为表名
 */
+ (NSString *)tableName;

/**
 *  设置主键，需要使用model的属性名,默认nil
 *
 *  @return 主键
 */
+ (NSArray *)primaryKeys;

/**
 *  设置主键是否自动增长，默认为非自动增长
 *
 */
+ (BOOL)autoIncrement;

/**
 *  设置忽略的属性，不存入数据库
 *
 *  @return 需要忽略的属性
 */
+ (NSArray *)ignoredProperties;

/**
 *  设置索引字段，默认nil
 *
 *  @return 索引数组
 */
+ (NSArray *)indices;


@end