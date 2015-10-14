//
//  GWDBProperty.h
//  GWMovie
//
//  Created by wushengtao on 14-12-2.
//  Copyright (c) 2014年 gewara. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

extern NSString* const GWDB_Type_Text;
extern NSString* const GWDB_Type_Int;
extern NSString* const GWDB_Type_Double;
extern NSString* const GWDB_Type_Blob;

typedef enum : NSUInteger {
    EGWDBColumnStatusNormal,
    EGWDBColumnStatusAddition,
    EGWDBColumnStatusRemove,
} EGWDBColumnStatus;

@interface GWDBProperty : NSObject
/**
 *  是否是主键字段
 */
@property (nonatomic, readonly) BOOL isPrimary;
/**
 *  是否无效字段
 */
@property (nonatomic, readonly) BOOL isIgnore;
/**
 *  是否唯一性字段
 */
@property (nonatomic, readonly) BOOL isUnique;
/**
 *  是否非空字段
 */
@property (nonatomic, readonly) BOOL isNotNull;
/**
 *  字段状态(初始、增加、删除)
 */
@property (nonatomic, readonly) EGWDBColumnStatus columnStatus;

@property(strong,nonatomic) NSString* defaultValue;
@property(strong,nonatomic) NSString* checkValue;

@property(nonatomic, readonly) NSString* propertyType;
@property(nonatomic, readonly) NSString* columnName;
@property(nonatomic, readonly) NSString* columnType;

/**
 *  该属性是否可以改增删（!isIgnore && != EGWDBColumnStatusRemove）
 *
 *  @return <#return value description#>
 */
- (BOOL)propertyCanUpdate;

- (id)initWithProperty:(objc_property_t*)property;
@end
