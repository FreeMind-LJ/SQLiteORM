//
//  NSPredicate+SQL.m
//  MUPSQLiteORM
//
//  Created by lujb on 15/4/22.
//  Copyright (c) 2015年 ND. All rights reserved.
//

#import "NSPredicate+SQL.h"

@implementation NSPredicate (SQL)

-(NSString*)translateToSQLWithValues:(out NSArray **)queryValues
                         shouldBreak:(out BOOL *)shouldBreak
{
    NSString *sql;
    if ([self isKindOfClass:[NSComparisonPredicate class]]) {
        
        sql = [self translateToSQLFromComparisonPredicate:(NSComparisonPredicate*)self
                                                    values:queryValues
                                               shouldBreak:shouldBreak];
        if ([sql containsString:@"."]) {
        //*subQueries =self;//*queryValues forKey:sql];
            sql = @"1";
        }
        return sql;
    }
    
    else if ([self isKindOfClass:[NSCompoundPredicate class]]) {
        sql = [self translateToSQLFromCompoundPredicate:(NSCompoundPredicate*)self
                                                  values:queryValues
                                             shouldBreak:shouldBreak];
        
//        NSCompoundPredicate *predicate = (NSCompoundPredicate*)self;
//        NSCompoundPredicate *subPredicate;
//        if (predicate.compoundPredicateType == NSOrPredicateType) {
//            
//            subPredicate = [NSCompoundPredicate orPredicateWithSubpredicates: @[*subQueries]];
//        }else if (predicate.compoundPredicateType == NSAndPredicateType) {
//            
//            subPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[*subQueries]];
//        }else if (predicate.compoundPredicateType == NSNotPredicateType) {
//            
//            subPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:*subQueries];
//        }
//        *subQueries = subPredicate;
        return sql;
    }
    
    NSLog(0, @"<ERROR> didn't understand predicate: %@",self);
    return nil;

}

-(NSString*)translateToSQLFromComparisonPredicate:(NSComparisonPredicate*)predicate
                                           values:(out NSArray **)queryValues
                                      shouldBreak:(out BOOL *)shouldBreak
{
    NSString *operatorString = nil;
    NSString *operatorStringForNULL = nil;
    
    switch (predicate.predicateOperatorType) {
            
        case NSLessThanPredicateOperatorType:
            operatorString = @" < ";
            operatorStringForNULL = @" IS NOT ";
            break;
            
        case NSLessThanOrEqualToPredicateOperatorType:
            operatorString = @" <= ";
            operatorStringForNULL = @" IS NOT ";
            break;
            
        case NSGreaterThanPredicateOperatorType:
            operatorString = @" > ";
            operatorStringForNULL = @" IS NOT ";
            break;
            
        case NSGreaterThanOrEqualToPredicateOperatorType:
            operatorString = @" >= ";
            operatorStringForNULL = @" IS NOT ";
            break;
            
        case NSEqualToPredicateOperatorType:
            operatorString = @" = ";
            operatorStringForNULL = @" IS ";
            break;
            
        case NSNotEqualToPredicateOperatorType:
            operatorString = @" != ";
            operatorStringForNULL = @" IS NOT ";
            break;
            
        case NSInPredicateOperatorType:
            operatorString = @" IN ";
            operatorStringForNULL = @" IS ";
            break;
            
        default:
             break;
            /*
             暂不支持一下类型:
             
             NSMatchesPredicateOperatorType,
             NSLikePredicateOperatorType,
             NSBeginsWithPredicateOperatorType,
             NSEndsWithPredicateOperatorType,
             NSInPredicateOperatorType,
             NSContainsPredicateOperatorType,
             NSBetweenPredicateOperatorType
             
             */
    }
    
    if (!operatorString) {
        NSLog(0, @"<ERROR> NSPredicate not supported operation type. Type: %i Predicate: %@",predicate.predicateOperatorType,predicate);
        return nil;
    }
    NSString *resultOperation = operatorString;
    NSMutableArray *expressionsValues = [NSMutableArray array];
    
    //左表达式
    BOOL shouldBreakLeftExpression = NO;
    NSString *leftExpressionStr = [self expStringFromExpression:predicate.leftExpression
                                                      putValues:expressionsValues
                                                    shouldBreak:&shouldBreakLeftExpression];
    
    if ([leftExpressionStr isEqualToString:@"NULL"]) {
        resultOperation = operatorStringForNULL;
    }
    
    //右表达式
    BOOL shouldBreakRightExpression = NO;
    NSString *rightExpressionStr = [self expStringFromExpression:predicate.rightExpression
                                                       putValues:expressionsValues
                                                     shouldBreak:&shouldBreakRightExpression];
    
    if ([rightExpressionStr isEqualToString:@"NULL"]) {
        resultOperation = operatorStringForNULL;
    }
    
    *shouldBreak = shouldBreakLeftExpression || shouldBreakRightExpression;
    
    if (!*shouldBreak && (!leftExpressionStr || !rightExpressionStr))
        NSLog(@"<ERROR> didn't understand predicate: %@",predicate);
    
    *queryValues = expressionsValues.count ? expressionsValues : nil;
    if ([resultOperation isEqualToString:@" IN "]) {
        NSMutableString *string = [NSMutableString string];
        [string appendString:@"("];
        for (int i=0; i<expressionsValues.count; i++) {
            if (i!=0) {
                [string appendString:@", ? "];
            }else{
                [string appendString:@"?"];
            }
        }
        [string appendString:@")"];
        rightExpressionStr = string;
    }

    return [NSString stringWithFormat:@"%@ %@ %@",leftExpressionStr,resultOperation,rightExpressionStr];

}


-(NSString*)translateToSQLFromCompoundPredicate:(NSCompoundPredicate *)predicate
                                         values:(out NSArray **)queryValues
                                    shouldBreak:(out BOOL *)shouldBreak
{
    // NOT predicate
    if (predicate.compoundPredicateType == NSNotPredicateType) {
        NSString* subpredicateString = [self translateToSQLWithValues:queryValues
                                                        shouldBreak:shouldBreak];
        
        return [NSString stringWithFormat:@"NOT (%@)", subpredicateString];
    }
    
    // AND OR predicate
    NSString *predicateTypeString = nil;
    switch (predicate.compoundPredicateType) {
        case NSAndPredicateType:
            
            if (predicate.subpredicates.count == 0) {
                return @"(TRUE)";
            }
            predicateTypeString = @" AND ";
            break;
            
        case NSOrPredicateType:
            
            if (predicate.subpredicates.count == 0) {
                return @"(FALSE)";
            }
            predicateTypeString = @" OR ";
            break;
            
        default:
            break;
    }
    
    
    NSMutableArray *compoundPredicateQueryValues = [NSMutableArray array];
    NSMutableArray *subpredicateStrings = [NSMutableArray arrayWithCapacity:predicate.subpredicates.count];
    
    for (NSPredicate *subpredicate in predicate.subpredicates) {
        
        NSArray *subpredicateQueryValues = nil;
        NSString* subpredicateString = [NSString stringWithFormat:@"(%@)", [subpredicate translateToSQLWithValues:&subpredicateQueryValues
                                                                                            shouldBreak:shouldBreak]];
        
        if (subpredicateQueryValues)
            [compoundPredicateQueryValues addObjectsFromArray:subpredicateQueryValues];
        
        [subpredicateStrings addObject:subpredicateString];
    }
    
    *queryValues = compoundPredicateQueryValues.count > 0 ? compoundPredicateQueryValues : nil;
    
    return [subpredicateStrings componentsJoinedByString:predicateTypeString];

}

#pragma mark --  help

- (NSString *) expStringFromExpression:(NSExpression *)expression
                             putValues:(in NSMutableArray *)expressionsValues
                           shouldBreak:(out BOOL *)shouldBreak {
    
    NSString *expressionStr = nil;
    
    switch (expression.expressionType) {
        
        case NSConstantValueExpressionType: {
        //表达式的右值
            id expConstantValue = expression.constantValue;
            
            [self transformConstantValue:expConstantValue
                             toExpValues:expressionsValues
                      andExpFormatString:&expressionStr
                             shouldBreak:shouldBreak];
        }
            break;
        
        case NSKeyPathExpressionType:
             //keypath 属性，表达式的左值
            expressionStr = expression.keyPath;
            break;
            
        case NSEvaluatedObjectExpressionType:
            
            //expressionStr = [entity.userInfo valueForKey:kMIStoreRowIdField] ?: @"rowId";
            
            break;
        
        default:
            break;
    }
    
    return expressionStr;
}

/**
 *  转换比较的右值
 *
 *  @param expConstantValue 需要转换的右值
 *  @param expressionValues 输出表达式对应的值
 *  @param expressionStr    输出的表达式
 *  @param shouldBreak      是否中断
 */
- (void) transformConstantValue:(in id)expConstantValue
                    toExpValues:(out NSMutableArray *)expressionValues
             andExpFormatString:(out NSString **)expressionStr
                    shouldBreak:(out BOOL *)shouldBreak
{
    //右值非空
    if(expConstantValue)
    {
        if (expressionStr != NULL)
            *expressionStr = @"?";
    
        if ([expConstantValue isKindOfClass:[NSDate class]]){
            //如果右值是nsdate
            NSDate *dateToCompare =  (NSDate *)expConstantValue;
            expConstantValue = @((int)[dateToCompare timeIntervalSince1970]);
            [expressionValues addObject:expConstantValue];
        }else if ([expConstantValue isKindOfClass:[NSArray class]]){
            //如果右值是array
            NSArray *expArray = (NSArray *)expConstantValue;
            [expressionValues addObjectsFromArray:expArray];
        }else{
            //直接将右值加到输出数组中
            [expressionValues addObject:expConstantValue];
        }
        
    }
    else
    {
        if (expressionStr != NULL)
            *expressionStr = @"NULL";
    }
}

@end
