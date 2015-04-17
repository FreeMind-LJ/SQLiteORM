//
//  MUPCollection.h
//  MUPSQLiteORM
//
//  Created by lujb on 15-3-2.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MUPCollection

@required

@property (nonatomic, readonly, assign) NSUInteger count;
@property (nonatomic, readonly, copy) NSString *objectClassName;

- (id)objectAtIndex:(NSUInteger)index;
- (id)firstObject;
- (id)lastObject;

/**
 *    获取指定对象位于结果集中的索引
 *
 *    @param object 需要获取索引的对象
 *
 *    @return 返回该对象在结果集中的索引，不存在与结果集中则返回NSNotFound
 */
- (NSUInteger)indexOfObject:(id)object;
/**
 *    使用指定谓词条件获取对象结果集
 *
 *    @param predicateFormat 谓词条件格式
 *
 *    @return 返回匹配指定谓词条件格式的对象结果集
 */
- (NSUInteger)indexOfObjectWhere:(NSString *)predicateFormat, ...;

/**
 *    @see indexOfObjectWhere:
 */
- (NSUInteger)indexOfObjectWithPredicate:(NSPredicate *)predicate;


- (id<MUPCollection>)objectsWhere:(NSString *)predicateFormat, ...;



- (id<MUPCollection>)objectsWithPredicate:(NSPredicate *)predicate;

/**
 *    @see sortedResultsUsingDescriptors:
 */

- (id<MUPCollection>)sortedResultsUsingProperty:(NSString *)property ascending:(BOOL)ascending;
/**
 *    从当前`MUPResultSet`对象使用指定的排序描述列表获取进行排序后的新`MUPResultSet`结果集
 *
 *    @param properties 包含`MUPSortDescriptor`对象的排序描述列表
 *
 *    @return 返回经过排序后的新结果集
 */
- (id<MUPCollection>)sortedResultsUsingDescriptors:(NSArray *)properties;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
@end
