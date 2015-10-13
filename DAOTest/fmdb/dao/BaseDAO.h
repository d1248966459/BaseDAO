//
//  BaseDAO.h
//  BESTKEEP
//
//  Created by dcj on 15/9/29.
//  Copyright © 2015年 YISHANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseDaoProperty;


typedef void(^CompeletionBool)(BOOL result);
typedef void(^CompeletionId)(id result, NSError * error);

/**
 *  非空
 */
@protocol DataBaseIsNotNull <NSObject>
@end
/**
 *  主键
 */
@protocol DatabaseIsPrimary <NSObject>
@end
/**
 *  无效
 */
@protocol DataBaseIsIgnore <NSObject>
@end
/**
 *  唯一
 */
@protocol DataBaseIsUnique <NSObject>
@end
/**
 *  添加
 */
@protocol DataBaseIsAddition <NSObject>
@end
/**
 *  移除
 */
@protocol DataBaseIsRemove <NSObject>
@end


@interface BaseDAO : NSObject

@property (nonatomic,assign) NSInteger rowID;



+(BOOL)createTable;

-(BOOL)deleteTable;

-(void)insertModelWithCompeletion:(CompeletionBool)compeletion;

-(void)searchModelWithCompeletion:(CompeletionId)commpeletion;




/**
 *  表名 子类需实现
 *
 *  @return 表名
 */
+(NSString *)tableName;

+(NSMutableArray *)getPropertyArray;
-(id)valueForProperty:(BaseDaoProperty *)property;

@end
