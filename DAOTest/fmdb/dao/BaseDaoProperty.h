//
//  BaseDaoProperty.h
//  BESTKEEP
//
//  Created by dcj on 15/10/8.
//  Copyright © 2015年 YISHANG. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface BaseDaoProperty : NSObject
@property (nonatomic,copy) NSString * propertyType;
@property (nonatomic,copy) NSString * columnName;
@property (nonatomic,copy) NSString * columnType;


-(instancetype)initWithPorety:(objc_property_t *)property;

@end
