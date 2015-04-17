//
//  MUPObject.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUPObjectConfig.h"

@class MUPSQLiteORM;

@interface MUPObject : NSObject <MUPObjectConfig>


/**
 *  表明该object已从数据库删除，不可在访问
 */
@property (nonatomic, readonly, getter = isInvalidated) BOOL invalidated;

/**
 *  该对象存储对应的orm数据库，默认存储在default ORM
 */
@property(nonatomic,weak)MUPSQLiteORM *MUPORM;

/**
 *  返回该对象对应的类名
 *
 *  @return 类名
 */
-(NSString *)className;

/**
 *  设置该模型对应的表名，实现分表，同一个模型放置在不同的表中，不设置取默认值
 */
@property(nonatomic,copy)NSString *tableName;

//+(MUPSQLiteORM*)getMUPSQLiteORM;

/**
 *  解锁
 */
+(void)unlockProgress;

/**
 *  加锁
 */
+(void)lockProgress;

@end
