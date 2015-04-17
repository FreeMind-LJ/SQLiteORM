//
//  MUPResultSet.m
//  MUPSQLiteORM
//
//  Created by devp on 15-3-2.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPResultSet.h"
#import "MUPObject.h"

typedef NS_ENUM(int32_t, OBJC_TYPE) {
    
    OBJC_TYPE_Int    ,
    OBJC_TYPE_UnsignedInt    ,
    OBJC_TYPE_Short ,
    OBJC_TYPE_UnsignedShort ,
    OBJC_TYPE_Long ,
    OBJC_TYPE_Unsigned_Long,
    OBJC_TYPE_LongLong ,
    OBJC_TYPE_UnsignedLongLong,
    OBJC_TYPE_Float  ,
    OBJC_TYPE_Double ,
    OBJC_TYPE_Other
    
    
};

@interface MUPResultSet ()

@end

@implementation MUPResultSet

-(NSUInteger)count{
    return [self.dataArray count];
}

-(NSString *)objectClassName{
    return NSStringFromClass([self.dataArray[0] class]);
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.dataArray objectAtIndex:index];
}

- (id)firstObject
{
    return [self.dataArray firstObject];
}

- (id)lastObject
{
    return [self.dataArray lastObject];
}

- (NSUInteger)indexOfObject:(id)object
{
    return [self.dataArray indexOfObject:object];
}

- (NSUInteger)indexOfObjectWhere:(NSString *)predicateFormat, ...
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    NSArray *array = [self.dataArray filteredArrayUsingPredicate:predicate];
    return [self indexOfObject:array[0]];
}

- (NSUInteger)indexOfObjectWithPredicate:(NSPredicate *)predicate{
    NSArray *array = [self.dataArray filteredArrayUsingPredicate:predicate];
    return [self indexOfObject:array[0]];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    if(index >= [_dataArray count])
        return nil;
    return [_dataArray objectAtIndex:index];
}

- (id<MUPCollection>)sortedResultsUsingProperty:(NSString *)property ascending:(BOOL)ascending
{
    NSComparator cmptr = ^(id obj1, id obj2){
        MUPObject *mupObj1 = (MUPObject*)obj1;
        MUPObject *mupObj2 = (MUPObject*)obj2;
        
        if ([mupObj1 valueForKey:property] < [mupObj2 valueForKey:property]) {
            return ascending?(NSComparisonResult)NSOrderedAscending:(NSComparisonResult)NSOrderedDescending;
        }else if ([mupObj1 valueForKey:property] > [mupObj2 valueForKey:property]) {
            return ascending?(NSComparisonResult)NSOrderedDescending:(NSComparisonResult)NSOrderedAscending;
        }else{
            return (NSComparisonResult)NSOrderedSame;
        }
    };
    
    NSArray *array = [self.dataArray sortedArrayUsingComparator:cmptr];
    MUPResultSet *mupResult = [MUPResultSet new];
    mupResult.dataArray = array;
    return mupResult;
}
- (id<MUPCollection>)sortedResultsUsingDescriptors:(NSArray *)properties
{
    NSArray  *sortedArray = [_dataArray sortedArrayUsingDescriptors:properties];
    MUPResultSet *mupResult = [MUPResultSet new];
    mupResult.dataArray = sortedArray;
    return mupResult;
}


- (id<MUPCollection>)objectsWhere:(NSString *)predicateFormat, ...
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    NSArray *array = [self.dataArray filteredArrayUsingPredicate:predicate];
    MUPResultSet *mupResult = [MUPResultSet new];
    mupResult.dataArray = array;
    return mupResult;
}


- (id<MUPCollection>)objectsWithPredicate:(NSPredicate *)predicate
{
    NSArray *array = [self.dataArray filteredArrayUsingPredicate:predicate];
    MUPResultSet *mupResult = [MUPResultSet new];
    mupResult.dataArray = array;
    return mupResult;
}

-(id)minOfProperty:(NSString *)property
{
    MUPObject *resultObj = self.dataArray[0];
    for (int i=1; i<self.dataArray.count; i++) {
        MUPObject *currentObj = self.dataArray[i];
        if ([currentObj valueForKey:property] < [resultObj valueForKey:property]) {
            resultObj = currentObj;
        }
    }
    return resultObj;
}
-(id)maxOfProperty:(NSString *)property
{
    MUPObject *resultObj = self.dataArray[0];
    for (int i=1; i<self.dataArray.count; i++) {
        MUPObject *currentObj = self.dataArray[i];
        if ([currentObj valueForKey:property] > [resultObj valueForKey:property]) {
            resultObj = currentObj;
        }
    }
    return resultObj;
}
-(NSNumber *)sumOfProperty:(NSString *)property
{
    unsigned long long unlonglongSumValue = 0;
    long long longlongSumValue = 0;
    float floatSumValue = 0.0;
    double doubleSumValue = 0.0;
    
    OBJC_TYPE objcType = [self objcTypeOfObject:_dataArray[0] property:property];
    if (objcType == OBJC_TYPE_Other) {
        return nil;
    }
    for (MUPObject *object in _dataArray) {
        NSNumber *number = [object valueForKey:property];
        switch (objcType)
        {
            case OBJC_TYPE_Int:
            case OBJC_TYPE_Short:
            case OBJC_TYPE_Long:
            case OBJC_TYPE_LongLong:
                longlongSumValue += [number longLongValue];
                break;
            case OBJC_TYPE_UnsignedInt:
            case OBJC_TYPE_UnsignedShort:
            case OBJC_TYPE_Unsigned_Long:
            case OBJC_TYPE_UnsignedLongLong:
                unlonglongSumValue += [number unsignedLongLongValue];
                break;
            case OBJC_TYPE_Float:
                floatSumValue += [number floatValue];
                break;
            case OBJC_TYPE_Double:
                doubleSumValue += [number doubleValue];
                break;
            default:
                break;
        }
    }
    
    switch (objcType)
    {
        case OBJC_TYPE_Int:
        case OBJC_TYPE_Short:
        case OBJC_TYPE_Long:
        case OBJC_TYPE_LongLong:
            return [NSNumber numberWithLongLong:longlongSumValue];
        case OBJC_TYPE_UnsignedInt:
        case OBJC_TYPE_UnsignedShort:
        case OBJC_TYPE_Unsigned_Long:
        case OBJC_TYPE_UnsignedLongLong:
            return [NSNumber numberWithUnsignedLongLong :unlonglongSumValue];
        case OBJC_TYPE_Float:
            return [NSNumber numberWithFloat:floatSumValue];
        case OBJC_TYPE_Double:
            return [NSNumber numberWithDouble:doubleSumValue];
        default:
            return nil;
    }
}

-(NSNumber *)averageOfProperty:(NSString *)property
{
    OBJC_TYPE objcType = [self objcTypeOfObject:_dataArray[0] property:property];
    NSNumber *total = [self sumOfProperty:property];
    switch (objcType)
    {
        case OBJC_TYPE_Int:
        case OBJC_TYPE_Short:
        case OBJC_TYPE_Long:
        case OBJC_TYPE_LongLong:
            return [NSNumber numberWithLongLong:[total longLongValue]/_dataArray.count];
        case OBJC_TYPE_UnsignedInt:
        case OBJC_TYPE_UnsignedShort:
        case OBJC_TYPE_Unsigned_Long:
        case OBJC_TYPE_UnsignedLongLong:
            return [NSNumber numberWithLongLong:[total unsignedLongLongValue]/_dataArray.count];
        case OBJC_TYPE_Float:
            return [NSNumber numberWithLongLong:[total floatValue]/_dataArray.count];
        case OBJC_TYPE_Double:
            return [NSNumber numberWithLongLong:[total doubleValue]/_dataArray.count];
        default:
            return nil;
    }
}

-(OBJC_TYPE)objcTypeOfObject:(MUPObject*)obj property:(NSString*)property
{
    OBJC_TYPE objc_type = OBJC_TYPE_Other;
    NSNumber * number = [obj valueForKey:property];
    if (![number isKindOfClass:[NSNumber class]]) {
        //非nsnumber,返回
        return OBJC_TYPE_Other;
    }else{
        if (strcmp([number objCType], @encode(int)) == 0){
            objc_type = OBJC_TYPE_Int;
        }else if(strcmp([number objCType], @encode(unsigned long long)) == 0){
            objc_type = OBJC_TYPE_Unsigned_Long;
        }else if (strcmp([number objCType], @encode(long long)) == 0) {
            objc_type = OBJC_TYPE_LongLong;
        } else if(strcmp([number objCType], @encode(unsigned int)) == 0){
            objc_type = OBJC_TYPE_UnsignedInt;
        } else if (strcmp([number objCType], @encode( long)) == 0) {
            objc_type = OBJC_TYPE_Long;
        }else if (strcmp([number objCType], @encode(unsigned short)) == 0){
            objc_type = OBJC_TYPE_UnsignedShort;
        } else if(strcmp([number objCType], @encode(unsigned long)) == 0) {
            objc_type = OBJC_TYPE_Unsigned_Long;
        }else if (strcmp([number objCType], @encode(short)) == 0){
            objc_type = OBJC_TYPE_Short;
        }else if(strcmp([number objCType], @encode(float)) == 0){
            objc_type = OBJC_TYPE_Float;
        }else if (strcmp([number objCType], @encode(double)) == 0){
            objc_type = OBJC_TYPE_Double;
        }
    }
    return objc_type;
}
@end
