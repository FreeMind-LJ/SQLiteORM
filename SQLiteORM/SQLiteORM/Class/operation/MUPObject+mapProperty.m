//
//  MUPObject1.m
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//
#import <objc/runtime.h>
#import "MUPObject+mapProperty.h"
#import "MUPPorperty.h"

@implementation MUPObject (mapProperty)

static NSMutableDictionary * __Properties = nil;
static NSMutableDictionary * __PropertyMapped = nil;

+(void)mapRelation
{
    if ([self isRelationMapped]) {
        return;
    }

    NSArray *ignoredProperties = [self ignoredProperties];
    for ( Class clazzType = self; clazzType != [MUPObject class]; )
    {
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList( clazzType, &propertyCount );
        for ( NSUInteger i = 0; i < propertyCount; i++ )
        {
            const char *	name = property_getName(properties[i]);
            NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            
            if ( [propertyName hasSuffix:@"_"] )
                continue;
            if (ignoredProperties && [ignoredProperties containsObject:propertyName]){
                continue;
            }
            const char *attr = property_getAttributes(properties[i]);
            MUPPorpertyType propertyType = [MUPPorperty typeOfProperty:attr];
            if (propertyType == MUPPorpertyTypeInt || propertyType ==MUPPorpertyTypeBool || propertyType == MUPPorpertyTypeShort || propertyType == MUPPorpertyTypeLong || propertyType == MUPPorpertyTypeLongLong)
            {
                [self mapProperty:propertyName type:MUPPorpertyTypeInterger defaultValue:@(0)];
            }
            else if( propertyType == MUPPorpertyTypeNumber)
            {
                [self mapProperty:propertyName type:MUPPorpertyTypeNumber defaultValue:@(0)];
            }
            else if( propertyType == MUPPorpertyTypeFloat ||  propertyType == MUPPorpertyTypeDouble)
            {
                [self mapProperty:propertyName type:MUPPorpertyTypeReal defaultValue:@(0)];
            }
            else if ( MUPPorpertyTypeString == propertyType )
            {
                [self mapProperty:propertyName type:MUPPorpertyTypeText defaultValue:@""];
            }
            else if ( MUPPorpertyTypeDate == propertyType )
            {
                [self mapProperty:propertyName type:MUPPorpertyTypeDate defaultValue:[NSDate dateWithTimeIntervalSince1970:0]];
            }
            else if ( MUPPorpertyTypeDictionary == propertyType )
            {
                [self mapProperty:propertyName type:MUPPorpertyTypeDictionary defaultValue:[NSMutableDictionary dictionary]];
            }
            else if ( MUPPorpertyTypeArray == propertyType )
            {
                [self mapProperty:propertyName type:MUPPorpertyTypeArray defaultValue:[NSMutableArray array]];
            }
            else if ( MUPPorpertyTypeObject == propertyType )
            {
                NSString * attrClassName = [MUPPorperty classNameOfProperty:attr];
                if ( attrClassName )
                {
                    Class class = NSClassFromString( attrClassName );
                    if ( class )
                    {
                        [self mapProperty:propertyName forClass:attrClassName defaultValue:nil];
                    }
                }
            }
        }
        free( properties );
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
    [self lockProgress];
    [__PropertyMapped setObject:@(YES) forKey:[self description]];
    [self unlockProgress];
}

+(NSDictionary*)properties
{
    [self lockProgress];
    NSDictionary *dic = [[__Properties objectForKey:[self description]] mutableCopy];
     [self unlockProgress];
    return dic;
}

+(BOOL)isRelationMapped
{
    BOOL mapped = FALSE;
    [self lockProgress];
    if (!__PropertyMapped) {
        __PropertyMapped = [NSMutableDictionary new];
        [__PropertyMapped setObject:@(FALSE) forKey:[self description]];
        mapped = FALSE;
    }else{
        mapped = [[__PropertyMapped objectForKey:[self description]] boolValue];
    }
    [self unlockProgress];
    return mapped;
}

#pragma mark -- map property

+ (void)mapProperty:(NSString *)name type:(MUPPorpertyType)type defaultValue:(id)value
{
    [self mapProperty:name type:type forClass:nil defaultValue:value];
}
+ (void)mapProperty:(NSString *)name forClass:(NSString *)className defaultValue:(id)value
{
    [self mapProperty:name type:MUPPorpertyTypeObject forClass:className defaultValue:value];
}

+ (void)mapProperty:(NSString *)name type:(MUPPorpertyType)type  forClass:(NSString *)className defaultValue:(id)value
{
    [self lockProgress];
    if (!__Properties) {
        __Properties = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary * propertySet = [__Properties objectForKey:[self description]];
    if (!propertySet ){
        propertySet = [NSMutableDictionary dictionary];
        [__Properties setObject:propertySet forKey:[self description]];
    }
    
    NSMutableDictionary * property = [propertySet objectForKey:name];
    if (!property) {
        property = [NSMutableDictionary dictionary];
        [property setObject:name forKey:@"propertyName"];
        //    [property setObject:(key ? @"YES" : @"NO") forKey:@"key"];
        if ( className )
        {
            [property setObject:className forKey:@"propertyClassName"];
        }
        [property setObject:value?value:[NSNull null] forKey:@"propertyDefaultvalue"];
        [property setObject:@(type) forKey:@"propertyType"];
        [propertySet setObject:property forKey:name];
    }
    
    [self unlockProgress];
}





@end
