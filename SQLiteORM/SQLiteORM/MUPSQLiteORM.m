//
//  MUPSQLiteORM.m
//  MUPSQLiteORM
//
//  Created by lujb on 15-2-5.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPSQLiteORM.h"
#import "FMDatabaseQueue.h"
#import "MUPObject+mapProperty.h"
#import "MUPObject+BuildTable.h"
#import "MUPObject.h"
#import "MUPPorperty.h"



static NSString *defaultORMFileName = @"default.db";

static NSMutableDictionary *MUPORMDatabase;//存放路径对应的fmdatabasequeue



@interface MUPSQLiteORM ()

/**
 *  每个orm数据库对应的queue
 */
@property(nonatomic,strong)FMDatabaseQueue *database;

@end

@implementation MUPSQLiteORM

+(NSString*)defaultORMPath
{
    @synchronized(self){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSMutableString *docDir = [NSMutableString stringWithString:[paths objectAtIndex:0]];
        [docDir appendString:@"/DataBase"];
        
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:docDir
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:NULL];
        }
        NSString *filePath = [docDir stringByAppendingPathComponent:defaultORMFileName];

        return filePath;
    }
}

+(void)setDefaultORMPath:(NSString*)path
{
    @synchronized(self){
        if (!path && ![defaultORMFileName isEqualToString:path]) {
            return;
        }
        defaultORMFileName = path;
    }
}

+(instancetype)defaultORM
{
    MUPSQLiteORM *orm;
    @synchronized(self){
        if (!MUPORMDatabase) {
            MUPORMDatabase = [NSMutableDictionary new];
        }
        NSString *dbFilePath = [[self class] defaultORMPath];
        orm = [MUPORMDatabase objectForKey:dbFilePath];
        if (!orm) {
            orm = [MUPSQLiteORM new];
            orm.database = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
            [MUPORMDatabase setObject:orm forKey:dbFilePath];
        }
    }
    return orm;
}

+(instancetype)ormWithPath:(NSString*)path
{
    if (!path) {
        return nil;
    }
    MUPSQLiteORM *orm;
    @synchronized(self){
        if (!MUPORMDatabase) {
            MUPORMDatabase = [NSMutableDictionary new];
        }
        orm = [MUPORMDatabase objectForKey:path];
        if (!orm) {
            orm = [MUPSQLiteORM new];
            orm.database = [FMDatabaseQueue databaseQueueWithPath:path];
            [MUPORMDatabase setObject:orm forKey:path];
        }
    }
    return orm;
}

-(NSString*)ormPath
{
    @synchronized(self){
        for (NSString *keyPath in MUPORMDatabase.allKeys) {
            if ([MUPORMDatabase valueForKey:keyPath] == self) {
                return keyPath;
            }
        }
    }
    return nil;

}

#pragma mark -- operation

-(BOOL)addOrUpdateObject:(MUPObject *)object
{
    if (!object || ![object  isKindOfClass:[MUPObject class]]) {
        return FALSE;
    }
    if ([self objectExist:object]) {
        return [self updateObject:object];
    }else{
        return [self insertObject:object];
    }
}

-(BOOL)addOrUpdateObjects:(NSArray *)objectArray
{
    BOOL result = FALSE;
    if (!objectArray || ![objectArray[0]  isKindOfClass:[MUPObject class]]) {
        return FALSE;
    }
    for (MUPObject *object in objectArray) {
        if ([self objectExist:object]) {
            result = [self updateObject:object];
        }else{
            result = [self insertObject:object];
        }
    }
    return result;
}

-(BOOL)deleteObject:(MUPObject *)object
{
    if (!object || ![object  isKindOfClass:[MUPObject class]]) {
        return FALSE;
    }
    return [self deleteWithObject:object];
}

-(BOOL)deleteObjects:(NSArray *)objectArray
{
        BOOL result = FALSE;
    for (MUPObject *object in objectArray) {
        result = [self deleteObject:object];
    }
    return result;
}

#pragma mark -- operation internal

-(BOOL)objectExist:(MUPObject*)object
{
    NSArray *primaryKeys = [[object class] primaryKeys];
    if (primaryKeys.count == 0) {
        NSAssert(NO, @"必须设置主键或联合主键");
        return NO;
    }
    NSMutableDictionary *primaryKeysAndValues = [NSMutableDictionary dictionary];
    for (NSString *keyProperty in primaryKeys) {
        [primaryKeysAndValues setObject:[object valueForKey:keyProperty] forKey:keyProperty];
    }
    
    
    NSMutableArray *allVaules =[NSMutableArray array];
    NSString * sql = [self assembleExistSqlWithDictionary:primaryKeysAndValues tableName:object.tableName allValues:allVaules];
    __block BOOL result = NO;
    __block NSString *errMsg;
    [self.database inDatabase:^(FMDatabase *db) {
        FMResultSet *queryResult = [db executeQuery:sql withArgumentsInArray:allVaules];
        //发生错误
        if (!queryResult) {
            NSError *err = [db lastError];
            errMsg = err.userInfo[@"NSLocalizedDescription"];
        }
        if ( queryResult ){
            BOOL bRet = [queryResult next];
            if ( bRet ){
                result = (NSUInteger)[queryResult unsignedLongLongIntForColumn:@"numrows"]>0?YES:NO;
            }
            [queryResult close];
        }

    }];
    
    if (errMsg) {
        //不存在表时，重新建
        if ([errMsg containsString:@"no such table"]) {
            [[object class] buildTableForTableName:object.tableName orm:self];
            [self.database inDatabase:^(FMDatabase *db) {
                FMResultSet *queryResult = [db executeQuery:sql withArgumentsInArray:allVaules];
                if ( queryResult ){
                    BOOL bRet = [queryResult next];
                    if ( bRet ){
                        result = (NSUInteger)[queryResult unsignedLongLongIntForColumn:@"numrows"]>0?YES:NO;
                    }
                }
                
            }];
        }

    }
    
    return result;
}

-(BOOL)updateObject:(MUPObject*)object
{
    BOOL result = [self deleteObject:object];
    if (result) {
        result = [self insertObject:object];
    }
    return result;
}

-(BOOL)insertObject:(MUPObject*)object
{
    NSDictionary *propertySet = [[object class] properties];
    NSMutableDictionary *propertyValue = [NSMutableDictionary new];
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary * property = [propertySet objectForKey:key];
        NSString *propertyName = [property objectForKey:@"propertyName"];
        NSString *propertyClassName = [property objectForKey:@"propertyClassName"];
        MUPPorpertyType type = [[property objectForKey:@"propertyType"] intValue];
        
        NSObject * value = [object valueForKey:propertyName];
        
        if (type == MUPPorpertyTypeDate && value){
            value = [value description];
        }
        //字典直接存储为json字符串
        if (type == MUPPorpertyTypeDictionary && value){
            NSString *jsonStr;
            NSDictionary *dicValue = (NSDictionary*)value;
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:dicValue options:NSJSONWritingPrettyPrinted error:nil];
            jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            value = jsonStr;
        }
        //type为对象,存储主键对应的值，对象具体内容存储到各对象对应的表中,存储为dictionary->{key_Property:keyValue MUP_OBJ_TABLE_NAME:@"tableName" MUP_OBJ_CLASS_NAME:@"className"}
        if (type == MUPPorpertyTypeObject && value) {
            
            MUPObject *mupObj = (MUPObject*)value;
            NSMutableDictionary *dicValue = [NSMutableDictionary new];
            NSArray *primaryArr = [[mupObj class] primaryKeys];
            
            if (primaryArr.count > 1) {
                for (NSString *keyProperty in primaryArr){
                     [dicValue setObject:[mupObj valueForKey:keyProperty] forKey:keyProperty];
                }
            }else {
                NSString *keyProperty = primaryArr[0];
                [dicValue setObject:[mupObj valueForKey:keyProperty] forKey:keyProperty];
            }
            [dicValue setObject:mupObj.tableName forKey:MUP_OBJ_TABLE_NAME];//对应的表
            [dicValue setObject:propertyClassName forKey:MUP_OBJ_CLASS_NAME];//对应的类名
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:dicValue options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            value = jsonStr;
            // 存储对象到各种的表中
            [self addOrUpdateObject:mupObj];
        }
        
        //type为Array,存储为array,array中的元素为各个对象需要存储的内容:
//        @{
//          MUP_OBJ_TYPE_NAME:@"Array" ,
//          MUP_OBJ_TYPE_DATA:@[item1,item2]
//          }
        
        if (type == MUPPorpertyTypeArray && value)
        {
            NSArray *mupObjArray = (NSArray*)value;
            NSMutableDictionary *dicValue = [NSMutableDictionary dictionary];
        
            if (![mupObjArray[0] isKindOfClass:[MUPObject class]])
            {
                [dicValue setObject:@"NON_MUPObject_Array" forKey:MUP_OBJ_TYPE_NAME];
                //数组内容非obj对象,直接转成json进行存储
                NSData *data = [NSJSONSerialization dataWithJSONObject:mupObjArray options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (jsonStr) {
                    [dicValue setObject:jsonStr forKey:MUP_OBJ_TYPE_DATA];
                }
            }
            else
            {
                 NSMutableArray *arrValue = [NSMutableArray array];
                [dicValue setObject:@"MUPObject_Array" forKey:MUP_OBJ_TYPE_NAME];
                for (int i =0;i<mupObjArray.count;i++)
                {
                    //数组内容为mupobj对象
                    MUPObject *mupObj = mupObjArray[i];
                  
                    NSMutableDictionary *objDicValue = [NSMutableDictionary new];
                    NSArray *primaryArr = [[mupObj class] primaryKeys];
                    
                    if (primaryArr.count > 1) {
                        for (NSString *keyProperty in primaryArr){
                            [objDicValue setObject:[mupObj valueForKey:keyProperty] forKey:keyProperty];
                        }
                    }else {
                        NSString *keyProperty = primaryArr[0];
                        [objDicValue setObject:[mupObj valueForKey:keyProperty] forKey:keyProperty];
                    }
                    [objDicValue setObject:mupObj.tableName forKey:MUP_OBJ_TABLE_NAME];//对应的表
                    [objDicValue setObject:[NSString stringWithUTF8String:object_getClassName(mupObj)] forKey:MUP_OBJ_CLASS_NAME];//对应的类名
                    [arrValue addObject:objDicValue];
                    
                    [self addOrUpdateObject:mupObj];
                }
                NSData *data = [NSJSONSerialization dataWithJSONObject:arrValue options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (jsonStr) {
                    [dicValue setObject:jsonStr forKey:MUP_OBJ_TYPE_DATA];
                }
            }
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:dicValue options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            value = jsonStr;
        }
        
        [propertyValue setObject:value?value:[NSNull null] forKey:key];
    }
    NSMutableArray *allVaules =[NSMutableArray array];
    NSString *insertSql = [self assembleInsertSql:propertyValue tableName:object.tableName values:allVaules];
    __block BOOL result = NO;
    [self.database inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:insertSql withArgumentsInArray:allVaules];
    }];
    return result;
}

-(BOOL)deleteWithObject:(MUPObject *)object
{
    NSDictionary *propertySet = [[object class] properties];
    NSMutableDictionary *propertyValue = [NSMutableDictionary new];
    NSArray *primaryKeys = [[object class] primaryKeys];
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary * property = [propertySet objectForKey:key];
        NSString *propertyName = [property objectForKey:@"propertyName"];
        MUPPorpertyType type = [[property objectForKey:@"propertyType"] intValue];
        
        for (NSString *keyString in primaryKeys) {
            NSObject * value = [object valueForKey:propertyName];
            if ([keyString isEqualToString: propertyName]) {
                [propertyValue setObject:value forKey:propertyName];
                break;
            }
        }
        
        if (type == MUPPorpertyTypeObject ) {
            NSObject * value = [object valueForKey:propertyName];
            MUPObject *mupObj = (MUPObject*)value;
            if (mupObj) {
                [self deleteWithObject:mupObj];
            }
        }else if (type == MUPPorpertyTypeArray ){
            NSObject * value = [object valueForKey:propertyName];
            NSArray *mupObjArray = (NSArray*)value;
            if (value && [mupObjArray[0] isKindOfClass:[MUPObject class]])
            {
                for (int i =0;i<mupObjArray.count;i++)
                {
                    //数组内容为mupobj对象
                    MUPObject *mupObj = mupObjArray[i];
                    [self deleteWithObject:mupObj];
                }
            }
        }
    }
   
    NSMutableArray *allVaules =[NSMutableArray array];
    NSString *deleteSql = [self assembelDeleteSqlWithDictionary:propertyValue tableName:object.tableName allValues:allVaules];
    __block BOOL result = NO;
    [self.database inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:deleteSql withArgumentsInArray:allVaules];
    }];
    return result;

}

#pragma mark -- assemble Sql

-(NSString*)assembleInsertSql:(NSDictionary*)propertyWithValue tableName:(NSString*)tableName values:(NSMutableArray *)allValues

{
    NSMutableString * sql = [NSMutableString string];
    [sql appendFormat:@"INSERT INTO %@ (", tableName];
    NSArray *propertyArr = propertyWithValue.allKeys;

    NSString *key;
    NSObject *value;
    for ( NSInteger i = 0; i < propertyArr.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        
        [sql appendString:@"\n"];
        
        key = [propertyArr objectAtIndex:i];
        value = [propertyWithValue objectForKey:key];
        
        [sql appendString:key];
        [allValues addObject:value];
    }
    
    [sql appendString:@") VALUES ("];
    
    for ( NSInteger i = 0; i < allValues.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        
        [sql appendString:@"\n"];
        [sql appendString:@"?"];
    }
    
    [sql appendString:@")"];
    
    return sql;
}

-(NSString*)assembleExistSqlWithDictionary:(NSDictionary*)dictionary tableName:(NSString*)tableName allValues:(NSMutableArray*)allValues
{
    NSMutableString * sql = [NSMutableString string];
    [sql appendFormat:@"SELECT COUNT(*) AS numrows From %@ WHERE  ",tableName];
    NSArray *KeyPropertyArr = dictionary.allKeys;
    NSString *key;
    NSObject *value;
    for ( NSInteger i = 0; i < KeyPropertyArr.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@" AND "];
        }
        
        [sql appendString:@"\n"];
        
        key = [KeyPropertyArr objectAtIndex:i];
        value = [dictionary objectForKey:key];
        
        [sql appendString:key];
        [allValues addObject:value];
        [sql appendString:@" = (?)"];
    }
    return sql;
    
}

-(NSString*)assembleUpdateSqlWithDictionary:(NSDictionary*)dictionary whereDictionary:(NSDictionary*)whereDictionary tableName:(NSString*)tableName allValues:(NSMutableArray*)allValues
{
    NSMutableString * sql = [NSMutableString string];
    [sql appendFormat:@"update %@  set",tableName];
    
    NSArray *KeyPropertyArr = dictionary.allKeys;
    NSString *key;
    NSObject *value;
    for ( NSInteger i = 0; i < KeyPropertyArr.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@" , "];
        }
        
        [sql appendString:@"\n"];
        
        key = [KeyPropertyArr objectAtIndex:i];
        value = [dictionary objectForKey:key];
        
        [sql appendString:key];
        [allValues addObject:value];
        [sql appendString:@" = (?)"];
    }
    [sql appendString:@"\n where"];
    
    KeyPropertyArr = whereDictionary.allKeys;
    for ( NSInteger i = 0; i < whereDictionary.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@" AND "];
        }
        
        [sql appendString:@"\n"];
        
        key = [KeyPropertyArr objectAtIndex:i];
        value = [whereDictionary objectForKey:key];
        
        [sql appendString:key];
        [allValues addObject:value];
        [sql appendString:@" = (?)"];
    }
    return sql;

}

-(NSString*)assembelDeleteSqlWithDictionary:(NSDictionary*)dictionary tableName:(NSString*)tableName allValues:(NSMutableArray*)allValues
{
    NSMutableString * sql = [NSMutableString string];
    [sql appendFormat:@"delete from %@ where",tableName];
    
    NSArray *KeyPropertyArr = dictionary.allKeys;
    NSString *key;
    NSObject *value;
    for ( NSInteger i = 0; i < KeyPropertyArr.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@" and "];
        }
        [sql appendString:@"\n"];
        
        key = [KeyPropertyArr objectAtIndex:i];
        value = [dictionary objectForKey:key];
        
        [sql appendString:key];
        [allValues addObject:value];
        [sql appendString:@" = (?)"];
    }
    return sql;

}


#pragma mark -- use with sql

-(FMResultSet *)executeQuery:(NSString *)sql
{
    __block FMResultSet *result ;
    [self.database  inDatabase:^(FMDatabase *db) {
        result = [db executeQuery:sql];
    }];
    return result;
}

-(BOOL)executeUpdate:(NSString *)sql 
{
    __block BOOL result =NO ;
    [self.database  inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments
{
    __block FMResultSet *result ;
    [self.database  inDatabase:^(FMDatabase *db) {
        result = [db executeQuery:sql withArgumentsInArray:arguments];
    }];
    
    return result;
}

-(BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments
{
    __block BOOL result =NO;
    [self.database  inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql withArgumentsInArray:arguments];
    }];
    return result;
}

@end
