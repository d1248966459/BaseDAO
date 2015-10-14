//
//  GWDBCondition.h
//  GWMovie
//
//  Created by wushengtao on 14-12-3.
//  Copyright (c) 2014年 gewara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GWDBConditionPair : NSObject
@property (nonatomic, strong) NSArray* conditionArray;
@property (nonatomic, strong) NSDictionary* equlPair;
@property (nonatomic, strong) NSDictionary* likePair;
@end

@interface GWDBCondition : NSObject
@property (nonatomic, strong) GWDBConditionPair* andPairs;
@property (nonatomic, strong) GWDBConditionPair* orPairs;

- (NSString*)conditionStringAddValues:(NSMutableArray*)values;
@end

@interface GWDBSearchCondition : GWDBCondition
@property (nonatomic, strong) NSArray* columnList;
@property (nonatomic, strong) NSArray* groupByList;
@property (nonatomic, strong) NSArray* orderByList;
@property (nonatomic, assign) BOOL ascSort;

@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;

- (NSString*)cloumString;
@end
