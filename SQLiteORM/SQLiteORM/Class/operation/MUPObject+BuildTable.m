//
//  MUPObject+BuildTable.m
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPObject+BuildTable.h"
#import "MUPSQLiteORM.h"
#import "MUPPorperty.h"
#import "MUPObject+mapProperty.h"

@implementation MUPObject (BuildTable)

/**
 *  对象的表是否已经生成，key:tableName  value: YES or NO
 */
static NSMutableDictionary *tableBuilt;

+(BOOL)isTableBuiltForTableName:(NSString *)tableName
{
    return [self isTableBuiltForTableName:tableName orm:[MUPSQLiteORM defaultORM]];
}

+(BOOL)isTableBuiltForTableName:(NSString *)tableName orm:(MUPSQLiteORM *)orm
{
    BOOL isBulit = NO;
    [self lockProgress];
    NSArray *ormPathArray = [tableBuilt objectForKey:tableName];
    if ([ormPathArray containsObject:orm.ormPath]) {
        isBulit = YES;
    }
    [self unlockProgress];
    return isBulit;

}

+(void)buildTableForTableName:(NSString *)tableName
{
    return [self buildTableForTableName:tableName orm:[MUPSQLiteORM defaultORM]];
}

+(void)buildTableForTableName:(NSString *)tableName orm:(MUPSQLiteORM *)orm
{
    if ([self isTableBuiltForTableName:tableName orm:orm]){
        return;
    }
    [self mapRelation];
    
    NSString * CreateSql = [self assembleCreateTable:tableName];
    BOOL ret = [orm executeUpdate:CreateSql];
    if (ret) {
        [self lockProgress];
        if (!tableBuilt) {
            tableBuilt = [NSMutableDictionary dictionary];
        }
        NSArray *array = [tableBuilt objectForKey:tableName];
        if (!array) {
            array = @[orm.ormPath];
        }else{
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
            [mutableArray addObject:orm.ormPath];
            array = mutableArray;
        }
        [tableBuilt setObject:array forKey:tableName];//标记表是否已建立
        [self unlockProgress];

        //    创建索引
        NSArray *index = [self indices];
        if (index) {
            NSString *indexSql = [self assembleCreateIndex:tableName index:index];
            [orm executeUpdate:indexSql];
        }
    }
}


+(NSString*)assembleCreateTable:(NSString*)tableName
{
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] initWithDictionary:[self properties]];
    NSArray *primaryKey = [self primaryKeys];
    if (!(primaryKey )){
        NSAssert(FALSE, @"需要设置主键或联合主键");
    }
    
    NSMutableString * sql = [NSMutableString string];
    [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ ( ", tableName];
    for ( NSInteger i = 0; i < properties.allKeys.count; ++i )
    {
        if ( 0 != i ) {
            [sql appendString:@", "];
        }
        [sql appendString:@"\n"];
        NSDictionary *property = [properties objectForKey:properties.allKeys[i]];
        NSString * propertyName = (NSString *)[property objectForKey:@"propertyName"];
        NSObject * propertyDefaultvalue = (NSNumber *)[property objectForKey:@"propertyDefaultvalue"];
        MUPPorpertyType propertyType = [[property objectForKey:@"propertyType"] intValue];
        
        [sql appendFormat:@"%@", propertyName];
        
        if ( propertyType == MUPPorpertyTypeReal) {
            [sql appendFormat:@" %@", @"REAL"];
        } else if(propertyType == MUPPorpertyTypeDictionary || propertyType == MUPPorpertyTypeString || propertyType == MUPPorpertyTypeArray || propertyType == MUPPorpertyTypeDate || propertyType == MUPPorpertyTypeText|| propertyType == MUPPorpertyTypeObject){
              [sql appendFormat:@" %@", @"TEXT"];
        }else{
            [sql appendFormat:@" %@", @"INTEGER"];
           
        }
        
        if(primaryKey.count ==1){
            NSString *primaryKeyString = primaryKey[0];
            if ([primaryKeyString isEqualToString:propertyName]) {
                [sql appendString:@" PRIMARY KEY"];
            }
            if ([self AutoIncrement]) {
                [sql appendString:@" AUTOINCREMENT"];
            }
        }
        
        if ( propertyDefaultvalue )
        {
            if ( [propertyDefaultvalue isKindOfClass:[NSNull class]] )
            {
                [sql appendString:@" DEFAULT NULL"];
            }
            else if ( [propertyDefaultvalue isKindOfClass:[NSNumber class]] )
            {
                [sql appendFormat:@" DEFAULT %@", propertyDefaultvalue];
            }
            else if ( [propertyDefaultvalue isKindOfClass:[NSString class]] )
            {
                [sql appendFormat:@" DEFAULT '%@'", propertyDefaultvalue];
            }
            else
            {
                [sql appendFormat:@" DEFAULT '%@'", propertyDefaultvalue];
            }
        }
    }
    if (primaryKey.count > 1)
    {
        [sql appendFormat:@" ,primary key("];
        for (int i=0; i < primaryKey.count; i++)
        {
            if (i==0)
            {
                [sql appendFormat:@"%@",primaryKey[i]];
            }
            else
            {
                [sql appendFormat:@",%@",primaryKey[i]];
            }
        }
        [sql appendString:@")"];
    }
    [sql appendString:@")"];
    return sql;
}

+(NSString*)assembleCreateIndex:(NSString*)tableName index:(NSArray*)indices
{
    NSMutableString * sql = [NSMutableString string];
    
    [sql appendFormat:@"CREATE INDEX IF NOT EXISTS idx_%@ ON %@ ( ",tableName, tableName];
    
    for ( NSInteger i = 0; i < indices.count; ++i )
    {
        NSString * field = [indices objectAtIndex:i];
        
        if ( 0 == i )
        {
            [sql appendFormat:@"%@", field];
        }
        else
        {
            [sql appendFormat:@", %@", field];
        }
    }
    
    [sql appendString:@" )"];
    
    return sql;

}

#pragma mark -- config 
+(MUPSQLiteORM *)MUPORM{
    
    return [MUPSQLiteORM defaultORM];
}

+ (NSArray *)indices{
    
    return nil;
}

@end
