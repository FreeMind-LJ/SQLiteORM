//
//  MUPPorperty.m
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/19.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "MUPPorperty.h"

@implementation MUPPorperty

+(MUPPorpertyType)typeOfProperty:(const char *)attr
{
    if ( attr[0] != 'T' )
        return MUPPorpertyTypeUnkonwn;
    
    const char * type = &attr[1];
    if ( type[0] == '@' )
    {
        if ( type[1] != '"' )
            return MUPPorpertyTypeUnkonwn;
        
        char typeClazz[128] = { 0 };
        
        const char * clazz = &type[2];
        const char * clazzEnd = strchr( clazz, '"' );
        
        if ( clazzEnd && clazz != clazzEnd )
        {
            unsigned int size = (unsigned int)(clazzEnd - clazz);
            strncpy( &typeClazz[0], clazz, size );
        }
        
        if ( 0 == strcmp((const char *)typeClazz, "NSNumber") )
        {
            return MUPPorpertyTypeNumber;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSString") )
        {
            return MUPPorpertyTypeString;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSDate") )
        {
            return MUPPorpertyTypeDate;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSArray") )
        {
            return MUPPorpertyTypeArray;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSDictionary") )
        {
            return MUPPorpertyTypeDictionary;
        }
        else
        {
            return MUPPorpertyTypeObject;
        }
    }
    else
    {
        if ( type[0] == 'i' || type[0] == 'I' )
        {
            return MUPPorpertyTypeInt;
        }
        else if ( type[0] == 'S' || type[0] == 's' )
        {
            return MUPPorpertyTypeShort;
        }
        else if ( type[0] == 'L' || type[0] == 'l' )
        {
            return MUPPorpertyTypeLong;
        }
        else if ( type[0] == 'Q' || type[0] == 'q' )
        {
            return MUPPorpertyTypeLong;
        }
        else if ( type[0] == 'f' )
        {
            return MUPPorpertyTypeFloat;
        }
        else if ( type[0] == 'd' )
        {
            return MUPPorpertyTypeDouble;
        }
 
    }
    
    return MUPPorpertyTypeUnkonwn;
}

+ (NSString *)classNameOfProperty:(const char *)attr
{
    if ( attr[0] != 'T' )
        return nil;
    
    const char * type = &attr[1];
    if ( type[0] == '@' )
    {
        if ( type[1] != '"' )
            return nil;
        
        char typeClazz[128] = { 0 };
        
        const char * clazz = &type[2];
        const char * clazzEnd = strchr( clazz, '"' );
        
        if ( clazzEnd && clazz != clazzEnd )
        {
            unsigned int size = (unsigned int)(clazzEnd - clazz);
            strncpy( &typeClazz[0], clazz, size );
        }
        
        return [NSString stringWithUTF8String:typeClazz];
    }
    
    return nil;
}

@end
