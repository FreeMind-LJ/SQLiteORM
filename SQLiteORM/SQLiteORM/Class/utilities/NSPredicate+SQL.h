//
//  NSPredicate+SQL.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/4/22.
//  Copyright (c) 2015年 ND. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (SQL)

/**
 *  转换nspredicate为SQL语句
 *
 *  @param queryValues 输出查询的值
 *  @param shouldBreak 是否中断
 *
 *  @return sql语句
 */
-(NSString*)translateToSQLWithValues:(out NSArray **)queryValues
                         shouldBreak:(out BOOL *)shouldBreak;

@end
