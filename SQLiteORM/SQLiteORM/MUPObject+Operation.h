//
//  MUPObject+Operation.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPObject.h"

@class MUPResultSet;

@interface MUPObject (Operation)
/**
 *  返回默认orm中存储的所有数据
 *
 *  @return 查询到的结果
 */
+(MUPResultSet*)allObjects;

/**
 *  返回默认orm中存储的所有数据
 *
 *  @param tableName 查询数据所在的表
 *
 *  @return 查询结果
 */
+(MUPResultSet*)allObjectsInTable:(NSString*)tableName;

/**
 *  根据nspredicate格式的String查询数据库中的数据
 *
 *  @param predicate 查询的谓词
 *
 *  @return 查询结果
 */
+(MUPResultSet*)allObjectsWhere:(NSString*)predicate;

+(MUPResultSet*)allObjectsWithPredicate:(NSPredicate*)predicate;
/*
*  根据nspredicate格式的String查询数据库中的数据
* 
*  @param tableName 查询数据所在的表
*  @param predicate 查询的谓词
*
*  @return 查询结果
*/
+(MUPResultSet*)allObjectsInTable:(NSString*)tableName Where:(NSString*)predicate;


+(MUPResultSet*)allObjectsInTable:(NSString*)tableName WithPredicate:(NSPredicate*)predicate;

/**
 *  查询所在orm该对象的所有数据
 *
 *  @param orm 查询的orm
 *
 *  @return 查询结果
 */
+(MUPResultSet*)allObjectsInORM:(MUPSQLiteORM*)orm;

/**
 *  查询所在orm该对象的所有数据
 *
 *  @param orm       查询的orm
 *  @param tableName 查询的表
 *
 *  @return 查询结果
 */
+(MUPResultSet*)allObjectsInORM:(MUPSQLiteORM*)orm InTable:(NSString*)tableName;

/**
 *  保存对象
 *
 *  @return 成功与否
 */
-(BOOL)save;

/**
 *  删除对象
 *
 *  @return 成功与否
 */
-(BOOL)remove;

/**
 *  修改对象
 *
 *  @param patchProperties 修改对象的键值，嵌套对象采用点格式  embedobj.property 目前不支持数组的更新，数组更新请删除后保存
 *
 *  @return 修改成功与否
 */
-(BOOL)patch:(NSDictionary*)patchProperties;

-(id)objectForKeyedSubscript:(NSString*)property;

@end
