//
//  MUPObject+Operation.m
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 ND. All rights reserved.
//

#import "MUPObject+Operation.h"
#import "MUPResultSet.h"
#import "MUPObject+mapProperty.h"
#import "MUPPorperty.h"
#import "MUPSQLiteORM.h"
#import "NSPredicate+SQL.h"

@implementation MUPObject (Operation)

+(MUPResultSet*)allObjects
{
    NSString *tableName = [[self class] tableName];
    tableName = tableName?tableName:NSStringFromClass([self class]);
    return [self allObjectsInTable:tableName];
}

+(MUPResultSet*)allObjectsInTable:(NSString *)tableName
{
    MUPResultSet *result = [self findAllObjectsIntable:tableName];
    return result;
}

+(MUPResultSet*)allObjectsWithPredicate:(NSPredicate *)predicate
{
    NSString *tableName = [[self class] tableName];
    tableName = tableName?tableName:NSStringFromClass([self class]);
    return [self findAllObjectsIntable:tableName orm:[MUPSQLiteORM defaultORM] predicate:predicate];
}

+(MUPResultSet*)allObjectsInTable:(NSString *)tableName WithPredicate:(NSPredicate *)predicate
{
    return [self findAllObjectsIntable:tableName orm:[MUPSQLiteORM defaultORM] predicate:predicate];
}

+(MUPResultSet*)allObjectsInORM:(MUPSQLiteORM *)orm
{
    MUPResultSet *result = [self allObjectsInORM:orm InTable:[[self class] tableName]];
    return result;
}

+(MUPResultSet*)allObjectsInORM:(MUPSQLiteORM *)orm InTable:(NSString *)tableName
{
    MUPResultSet *result = [self findAllObjectsInOrm:orm Intable:tableName];
    return result;
}

+(MUPResultSet*)allObjectsWhere:(NSString *)predicate
{
    NSPredicate *queryPredicate = [NSPredicate predicateWithFormat:predicate];
    NSString *tableName = [[self class] tableName];
    tableName = tableName?tableName:NSStringFromClass([self class]);
    return [self findAllObjectsIntable:tableName orm:[MUPSQLiteORM defaultORM] predicate:queryPredicate];
}

+(MUPResultSet*)allObjectsInTable:(NSString *)tableName Where:(NSString *)predicate
{
    NSPredicate *queryPredicate = [NSPredicate predicateWithFormat:predicate];
    return [self findAllObjectsIntable:tableName orm:[MUPSQLiteORM defaultORM] predicate:queryPredicate];
}

-(BOOL)save
{
    BOOL result = NO;
    result = [self.MUPORM addOrUpdateObject:self];
    return result;
}

-(BOOL)remove
{
    BOOL result = NO;
    result = [self.MUPORM deleteObject:self];
    return result;
}

-(BOOL)patch:(NSDictionary *)patchProperties
{
    BOOL result = NO;
    
    NSMutableDictionary *dictonary = [NSMutableDictionary dictionary];
    NSMutableDictionary *embedObjDic = [NSMutableDictionary dictionary];
    for (NSString *key in patchProperties.allKeys)
    {
        NSRange range = [key rangeOfString:@"."];
        id value = [patchProperties valueForKey:key];
        if (range.location == NSNotFound) {
            [dictonary setObject:value forKey:key];
        }
        else
        {
            NSString *embedObjName= [key substringToIndex:range.location];
            if([[self valueForKey:embedObjName] isKindOfClass:[NSDictionary class]]){
                //更新的为字典对象
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self valueForKey:embedObjName]];
                [dic setValue:value forKey:[key substringFromIndex:range.location+1]];
                NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [dictonary setValue:jsonStr?jsonStr:[NSNull null] forKey:embedObjName];
                continue;
            }
            
            int i = 0;
            for (NSString *objName in embedObjDic.allKeys )
            {
                if ([objName isEqualToString:embedObjName]) {
                    NSMutableDictionary *embedDic = [embedObjDic valueForKey:objName];
                    [embedDic setValue:value forKey:[key substringFromIndex:range.location+1]];
                    break;
                }
                i++;
                
            }
            if (i == embedObjDic.allKeys.count) {
                NSMutableDictionary *embedDic = [NSMutableDictionary dictionary];
                [embedDic setValue:value forKey:[key substringFromIndex:range.location+1]];
                [embedObjDic setObject:embedDic forKey:[key substringToIndex:range.location]];
            }
        }
    }
    
    for (NSString *embedObjName in embedObjDic.allKeys) {
        id embedObj = [self valueForKey:embedObjName];
        
        if ([embedObj isKindOfClass:[MUPObject class]]) {
            //更新的为obj对象
            [embedObj patch:[embedObjDic valueForKey:embedObjName]];
        }
        
    }
    
    result = [self pacthObjectFromDictionary:dictonary];
    return result;
}

-(id)objectForKeyedSubscript:(NSString *)property
{
    id value;
    if (property) {
        value = [self valueForKey:property];
    }
    return value;
}

#pragma mark -- operation internal

+(MUPResultSet*)findAllObjectsIntable:(NSString*)tableName orm:(MUPSQLiteORM*)orm predicate:(NSPredicate*)predicate
{
    NSArray *queryArguments = nil;
    BOOL shouldBreakRequest = NO;
    NSString *whereSQL = [predicate translateToSQLWithValues:&queryArguments  shouldBreak:&shouldBreakRequest];
    NSMutableString *sql = [NSMutableString stringWithString:[self assembleSelectSqlFromTable:tableName condition:nil allValues:nil]];
    
    [sql appendFormat:@" where %@",whereSQL];
    NSMutableArray *resultArray = [NSMutableArray array];
    FMResultSet *rs = [orm executeQuery:sql withArgumentsInArray:queryArguments];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        if (dict) {
            MUPObject *mupObject = [self objectFromDictionary:dict];
            [resultArray addObject:mupObject];
            
        }
    }
    [rs close];
    
    if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
        //满足过滤条件，添加到数组中
        NSArray *filter = [resultArray filteredArrayUsingPredicate:predicate];
        resultArray = [NSMutableArray arrayWithArray:filter];
    }
    
    MUPResultSet *resultSet = [MUPResultSet new];
    resultSet.dataArray = resultArray;
    return resultSet;
}

+(MUPResultSet*)findAllObjectsIntable:(NSString*)tableName
{
    return [self findAllObjectsInOrm:[MUPSQLiteORM defaultORM] Intable:tableName];
}

+(MUPResultSet*)findAllObjectsInOrm:(MUPSQLiteORM*)orm Intable:(NSString*)tableName
{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSString *sql = [self assembleSelectSqlFromTable:tableName condition:nil allValues:nil];
    FMResultSet *rs = [orm executeQuery:sql];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        if (dict) {
            MUPObject *mupObject = [self objectFromDictionary:dict];
            [resultArray addObject:mupObject];
        }
    }
    [rs close];
    MUPResultSet *resultSet = [MUPResultSet new];
    resultSet.dataArray = resultArray;
    return resultSet;
}

+(MUPResultSet*)findAllObjectsIntable:(NSString*)tableName condition:(NSDictionary*)condition
{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSMutableArray *allValues = [NSMutableArray array];
    NSString *sql = [self assembleSelectSqlFromTable:tableName condition:condition allValues:allValues];
    FMResultSet *rs = [[MUPSQLiteORM defaultORM] executeQuery:sql withArgumentsInArray:allValues];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        if (dict) {
            MUPObject *mupObject = [self objectFromDictionary:dict];
            mupObject.tableName = tableName;
            [resultArray addObject:mupObject];
        }
    }
    [rs close];
    MUPResultSet *resultSet = [MUPResultSet new];
    resultSet.dataArray = resultArray;
    return resultSet;
}

/**
 *  根据dictionary生成对应的object对象
 *
 *  @param dictionary 传入的dictionary
 *
 *  @return object对象
 */
+(MUPObject*)objectFromDictionary:(NSDictionary*)dictionary
{
    MUPObject *mupObject = [self new];
    NSDictionary *propertySet = [self properties];
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary * property = [propertySet objectForKey:key];
        MUPPorpertyType type = [[property objectForKey:@"propertyType"] intValue];
        
        if (type == MUPPorpertyTypeDictionary ){
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[dictionary valueForKey:key] dataUsingEncoding:NSASCIIStringEncoding]
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
            [mupObject setValue:dic forKey:key];
            
        }else if (type == MUPPorpertyTypeObject ) {
            
            id embedDicString = [dictionary valueForKey:key];
            if (embedDicString && !(embedDicString == [NSNull null])) {
                NSDictionary *embedDic = [NSJSONSerialization JSONObjectWithData:[embedDicString dataUsingEncoding:NSASCIIStringEncoding]
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:nil];
                
                NSString *className = [embedDic valueForKey:MUP_OBJ_CLASS_NAME];
                Class embedClass = NSClassFromString(className);
                
                NSString *tableName = [embedDic objectForKey:MUP_OBJ_TABLE_NAME];
                NSMutableDictionary *conditionDic = [NSMutableDictionary dictionary];
                for (NSString *embedDicKey in embedDic) {
                    if (!([embedDicKey isEqualToString:MUP_OBJ_CLASS_NAME] || [embedDicKey isEqualToString:MUP_OBJ_TABLE_NAME])) {
                        [conditionDic setObject:[embedDic valueForKey:embedDicKey] forKey:embedDicKey];
                    }
                }
                MUPResultSet *resultSet = [embedClass findAllObjectsIntable:tableName condition:conditionDic];
                MUPObject *objectEmbed = resultSet.dataArray[0];
                [mupObject setValue:objectEmbed forKey:key];
            }
            
        }else if (type == MUPPorpertyTypeArray ){
            
            id embedArrayString = [dictionary valueForKey:key];
            if (embedArrayString && !(embedArrayString == [NSNull null])) {
                NSError *error;
                NSDictionary *embedArrayDic = [NSJSONSerialization JSONObjectWithData:[embedArrayString dataUsingEncoding:NSASCIIStringEncoding]
                                                                              options:NSJSONReadingAllowFragments
                                                                                error:&error];
                id arrayDataString = [embedArrayDic objectForKey:MUP_OBJ_TYPE_DATA];
                if ([[embedArrayDic objectForKey:MUP_OBJ_TYPE_NAME] isEqualToString:@"NON_MUPObject_Array"]) {
                    
                    if (arrayDataString && arrayDataString != [NSNull null]) {
                        NSArray *ArrayData = [NSJSONSerialization JSONObjectWithData:[arrayDataString dataUsingEncoding:NSASCIIStringEncoding]
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:nil];
                        
                        [mupObject setValue:ArrayData forKey:key];
                    }
                }else{
                    
                    
                    if (arrayDataString && arrayDataString != [NSNull null]) {
                        NSArray *ArrayData = [NSJSONSerialization JSONObjectWithData:[arrayDataString dataUsingEncoding:NSASCIIStringEncoding]
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:nil];
                        NSMutableArray *objectArray = [NSMutableArray array];
                        for (NSDictionary *objItemDic in ArrayData) {
                            NSString *className = [objItemDic valueForKey:MUP_OBJ_CLASS_NAME];
                            Class embedClass = NSClassFromString(className);
                            
                            NSString *tableName = [objItemDic objectForKey:MUP_OBJ_TABLE_NAME];
                            NSMutableDictionary *conditionDic = [NSMutableDictionary dictionary];
                            for (NSString *embedDicKey in objItemDic) {
                                if (!([embedDicKey isEqualToString:MUP_OBJ_CLASS_NAME] || [embedDicKey isEqualToString:MUP_OBJ_TABLE_NAME])) {
                                    [conditionDic setObject:[objItemDic valueForKey:embedDicKey] forKey:embedDicKey];
                                }
                            }
                            MUPResultSet *resultSet = [embedClass findAllObjectsIntable:tableName condition:conditionDic];
                            
                            [objectArray addObjectsFromArray:resultSet.dataArray];
                        }
                        
                        [mupObject setValue:objectArray forKey:key];
                    }
                }
                
                
            }
            
            
        }else{
            [mupObject setValue:[dictionary valueForKey:key] forKey:key];
        }
    }
    return mupObject;
}

/**
 *  根据传入的dictionary修改object对象
 *
 *  @param dictonary 传入的dictionary
 *
 *  @return 修改是否成功
 */
-(BOOL)pacthObjectFromDictionary:(NSDictionary*)dictonary
{
    BOOL result = NO;
    NSMutableArray *allValues = [NSMutableArray array];
    NSMutableDictionary *conditon = [NSMutableDictionary dictionary];
    
    NSArray *keyProperties = [[self class] primaryKeys];
    for (NSString *key in keyProperties) {
        [conditon setValue:[self valueForKey:key] forKey:key];
    }
    
    NSString *sql = [[self class] assembleUpdateSqlForTable:self.tableName dictonary:dictonary condition:conditon allValues:allValues];
    
    result = [self.MUPORM executeUpdate:sql withArgumentsInArray:allValues ];
    return result;
}

#pragma mark -- assemble Sql

+(NSString*)assembleSelectSqlFromTable:(NSString*)tableName condition:(NSDictionary*)condition allValues:(NSMutableArray*)allValues
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendFormat:@"select * from %@",tableName];
    NSString *key;
    NSObject *value;
    if (condition) {
        [sql appendString:@" where \n"];
        for ( NSInteger i = 0; i < condition.count; ++i )
        {
            if ( 0 != i )
            {
                [sql appendString:@" AND "];
            }
            key = [condition.allKeys objectAtIndex:i];
            value = [condition objectForKey:key];
            
            [sql appendString:key];
            [allValues addObject:value];
            [sql appendString:@" = (?)"];
        }
    }
    return sql;
}

+(NSString*)assembleUpdateSqlForTable:(NSString*)tableName dictonary:(NSDictionary*)keyValues condition:(NSDictionary*)condition allValues:(NSMutableArray*)allValues
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendFormat:@"update %@ set \n",tableName];
    NSString *key;
    NSObject *value;
    
    for ( NSInteger i = 0; i < keyValues.allKeys.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        key = [keyValues.allKeys objectAtIndex:i];
        value = [keyValues objectForKey:key];
        
        [sql appendString:key];
        [allValues addObject:value];
        [sql appendString:@" = (?)"];
    }
    
    if (condition) {
        [sql appendString:@" where \n"];
        for ( NSInteger i = 0; i < condition.count; ++i )
        {
            if ( 0 != i )
            {
                [sql appendString:@" AND "];
            }
            key = [condition.allKeys objectAtIndex:i];
            value = [condition objectForKey:key];
            
            [sql appendString:key];
            [allValues addObject:value];
            [sql appendString:@" = (?)"];
        }
    }
    
    
    return sql;
}

@end
