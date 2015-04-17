//
//  MUPObject1.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPObject.h"

@interface MUPObject (mapProperty)

/**
 *  映射对象的每个属性
 */
+ (void)mapRelation;
/**
 *  判断类的属性是否已映射
 *
 *  @return BOOL
 */
+ (BOOL)isRelationMapped;

/**
 *  获取属性列表,key是model的属性名，value是封装model属性详情的字典
 *
 *  @return 属性的字典形式
 */
+ (NSDictionary *)properties;

@end
