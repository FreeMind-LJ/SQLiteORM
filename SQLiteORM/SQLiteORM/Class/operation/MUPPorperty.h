//
//  MUPPorperty.h
//  MUPSQLiteORM
//
//  Created by lujb on 15/3/19.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(int32_t, MUPPorpertyType) {
 
    MUPPorpertyTypeInt    ,
    MUPPorpertyTypeBool   ,
    MUPPorpertyTypeShort ,
    MUPPorpertyTypeLong ,
    MUPPorpertyTypeLongLong ,
   
    MUPPorpertyTypeFloat  ,
    MUPPorpertyTypeDouble ,
    
    MUPPorpertyTypeString ,
    MUPPorpertyTypeData   ,
    RLMPropertyTypeAny    ,
    MUPPorpertyTypeDate   ,
    
    MUPPorpertyTypeNumber  ,
    MUPPorpertyTypeObject ,
    MUPPorpertyTypeArray  ,
    MUPPorpertyTypeDictionary  ,
    
    MUPPorpertyTypeReal,
    MUPPorpertyTypeInterger,
    MUPPorpertyTypeText,
    MUPPorpertyTypeUnkonwn
};

@interface MUPPorperty : NSObject

/**
 *  获取属性对象的类型
 *
 *  @param attr 属性描述
 *
 *  @return 属性类型
 */
+(MUPPorpertyType)typeOfProperty:(const char *)attr;

/**
 *  获取属性对象的类名
 *
 *  @param attr 属性描述
 *
 *  @return 属性类名
 */
+(NSString*)classNameOfProperty:(const char *)attr;

@end
