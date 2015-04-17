//
//  MUPResultSet.h
//  MUPSQLiteORM
//
//  Created by lujb on 15-3-2.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUPCollection.h"

@interface MUPResultSet : NSObject <MUPCollection>

/**
 *  存放查询到的具体数据
 */
@property(nonatomic,strong)NSArray *dataArray;

/**
 *    结果集数量
 */
@property (nonatomic, readonly, assign) NSUInteger count;

/**
 *    结果集中存放`MUPObject`对象的类名
 */
@property (nonatomic, readonly, copy) NSString *objectClassName;

/**
 *    返回给定属性在结果集中最小值对象，如NSNumber *min = [results minOfProperty:@"age"];
 *
 *    @param property 属性描述
 *
 *    @return 返回最小值对象
 */
-(id)minOfProperty:(NSString *)property;

/**
 *    返回给定属性在结果集中最大值对象，如NSNumber *max = [results maxOfProperty:@"age"];
 *
 *    @param property 属性描述
 *
 *    @return 返回最大值对象
 */
-(id)maxOfProperty:(NSString *)property;

/**
 *    返回给定属性在结果集中总和，如NSNumber *sum = [results sumOfProperty:@"age"];
 *
 *    @param property 属性描述
 *ç
 *    @return 返回总和
 */
-(NSNumber *)sumOfProperty:(NSString *)property;

/**
 *    返回给定属性在结果集中平均值对象，如NSNumber *average = [results averageOfProperty:@"age"];
 *
 *    @param property 属性描述
 *
 *    @return 返回平均值对象
 */
-(NSNumber *)averageOfProperty:(NSString *)property;


@end
