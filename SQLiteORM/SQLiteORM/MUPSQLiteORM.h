//
//  MUPSQLiteORM.h
//  MUPSQLiteORM
//
//  Created by lujb on 15-2-5.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

#define MUP_OBJ_TABLE_NAME @"mup_Obj_Table_Name"
#define MUP_OBJ_CLASS_NAME @"mup_Obj_Class_Name"
#define MUP_OBJ_TYPE_NAME @"mup_Obj_Type_Name"
#define MUP_OBJ_TYPE_DATA @"mup_Obj_Type_Date"

@class MUPObject;

@interface MUPSQLiteORM : NSObject
/**
 *  返回默认的orm
 *
 *  @return orm
 */
+(instancetype)defaultORM;

/**
 *  根据路径获取对应的orm路径,传入绝对路径
 *
 *  @param path orm路径
 *
 *  @return orm
 */
+(instancetype)ormWithPath:(NSString*)path;

/**
 *  默认orm对应的绝对路径
 *
 *  @return 路径名
 */
+(NSString*)defaultORMPath;

/**
 *  设置默认orm的路径,传入绝对路径
 *
 *  @param path 新的路径名
 */
+(void)setDefaultORMPath:(NSString*)path;

/**
 *  orm路径,绝对路径
 */
@property (nonatomic, readonly) NSString *ormPath;

/**
 *  该orm是否只读
 */
@property (nonatomic, readonly, getter = isReadOnly) BOOL readOnly;

#pragma mark -- operation

/**
 *  添加对象到orm
 *
 *  @param object 添加的对象
 *
 *  @return 添加结果
 */
-(BOOL)addOrUpdateObject:(MUPObject*)object;

/**
 *  添加对象数组到orm
 *
 *  @param objectArray 对象数组
 *
 *  @return 成功与否
 */
-(BOOL)addOrUpdateObjects:(NSArray*)objectArray;

/**
 *  删除orm里的对象
 *
 *  @param object 删除的对象
 *
 *  @return 成功与否
 */
-(BOOL)deleteObject:(MUPObject*)object;

/**
 *  删除orm中的数组对象
 *
 *  @param objectArray 删除的数组对象
 *
 *  @return 成功与否
 */
-(BOOL)deleteObjects:(NSArray *)objectArray;

/**
 *  对象是否存在
 *
 *  @param object 查询的对象
 *
 *  @return 存在与否
 */
-(BOOL)existObject:(MUPObject*)object;

#pragma mark -- use with sql

/**
 *  开放对外的查询接口
 *
 *  @param sql sql语句
 *
 *  @return 执行结果
 */

-(FMResultSet*)executeQuery:(NSString*)sql ;

/**
 *  开放对外的查询接口
 *
 *  @param sql       sql语句
 *  @param arguments 查询参数
 *
 *  @return 执行结果
 */
- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;

/**
 *  开放对外的更新接口
 *
 *  @param sql 更新sql语句
 *
 *  @return 更新结果
 */
-(BOOL)executeUpdate:(NSString*)sql ;

/**
 *  开放对外的更新接口
 *
 *  @param sql 更新sql语句
 *  @param arguments 查询参数
 *
 *  @return 更新结果
 */
-(BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;

@end
