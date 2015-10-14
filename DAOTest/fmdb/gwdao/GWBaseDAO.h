//
//  GWBaseDAO.h
//  GWMovie
//
//  Created by wushengtao on 14-12-3.
//  Copyright (c) 2014年 gewara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWDBProperty.h"


/**
 表示主键
 
 @property(nonatomic, strong) NSString<GWDBKeyPrimary>* propertyName
 */
@protocol GWDBKeyPrimary
@end

/**
 表示忽略字段
 
 @property(nonatomic, strong) NSString<GWDBKeyIgnore>* propertyName
 */
@protocol GWDBKeyIgnore
@end


@protocol GWDBKeyUnique
@end

@protocol GWDBKeyNotNull
@end

/**
 表示新增字段，需要ALTER TABLE xxx ADD
 
 @property(nonatomic, strong) NSString<GWDBKeyAddition>* propertyName
 */
@protocol GWDBKeyAddition
@end

/**
 表示删除字段，需要ALTER TABLE xxx DROP，该字段查改增删均无效<sqlite不支持，等同ignore>
 
 @property(nonatomic, strong) NSString<GWDBKeyRemove>* propertyName
 */
@protocol GWDBKeyRemove
@end


@class GWDBSearchCondition;
@class GWDBCondition;
@class GWDBManager;
@interface GWBaseDAO : NSObject

@property NSInteger rowid;

+ (NSMutableArray*)propertyListFromObject;
+ (NSMutableDictionary*)propertyDictionaryFromObject;

/**
 *  使用的dbmanager
 *
 *  @return <#return value description#>
 */
+ (GWDBManager*)dbManager;

/**
 *  表名，子类需实现之
 *
 *  @return 表明
 */
+ (NSString*)tableName;

/**
 *  创建表
 *
 *  @return YES:成功, NO:失败
 */
+ (BOOL)createTable;

/**
 *  增加对应属性的约束，主要是defaultValue和checkValue，默认无
 *
 *  @param property <#property description#>
 */
+ (void)addConstraintWithProperty:(GWDBProperty*)property;

/**
 *  db对应字段值转模型
 *
 *  @param property <#property description#>
 *  @param value    <#value description#>
 */
- (void)modelWithProperty:(GWDBProperty*)property value:(id)value;

/**
 *  模型转db对应字段值
 *
 *  @param property <#property description#>
 *
 *  @return <#return value description#>
 */
- (id)valueForProperty:(GWDBProperty*)property;

/**
 *  <#Description#>
 *
 *  @param column <#column description#>
 *
 *  @return <#return value description#>
 */
- (NSString*)joinedDeleteConditionColume:(NSString*)column;

/**
 *  异步执行查询
 *
 *  @param condition  查询条件模型，可为空
 *  @param completion 完成回调block
 */
+ (void)searchWithCondition:(GWDBSearchCondition*)condition
                 completion:(void(^)(NSArray*))completion;
/**
 *  同步执行查询
 *
 *  @param condition 查询条件模型，可为空
 *
 *  @return 查询结果
 */
+ (NSArray*)searchWithCondition:(GWDBSearchCondition*)condition;

/**
 *  异步执行更新
 *
 *  @param condition  更新条件模型，可为空
 *  @param completion 完成回调block
 */
- (void)updateModelWithCondition:(GWDBCondition*)condition
                      completion:(void(^)(BOOL))completion;
/**
 *  同步执行更新
 *
 *  @param condition 更新条件模型，可为空
 *
 *  @return YES:成功, NO:失败
 */
- (BOOL)updateModelWithCondition:(GWDBCondition*)condition;

/**
 *  异步执行插入
 *
 *  @param completion 完成回调block
 */
- (void)insertModelCompletion:(void(^)(BOOL))completion;
/**
 *  同步执行插入
 *
 *  @return YES:成功, NO:失败
 */
- (BOOL)insertModel;

/**
 *  异步执行删除
 *
 *  @param completion 完成回调block
 */
- (void)deleteModelCompletion:(void(^)(BOOL))completion;
/**
 *  同步执行删除
 *
 *  @return YES:成功, NO:失败
 */
- (BOOL)deleteModel;

/**
 *  用户手动清除缓存所调用方法，默认为空实现
 */
+ (void)clearCacheByUser;
@end
