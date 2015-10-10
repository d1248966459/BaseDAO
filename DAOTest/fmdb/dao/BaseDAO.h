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

@interface BaseDAO : NSObject


-(BOOL)createTable;

-(BOOL)deleteTable;

-(void)insertModelWithCompeletion:(CompeletionBool)compeletion;

-(void)searchModelWithCompeletion:(CompeletionId)commpeletion;




/**
 *  表名 子类需实现
 *
 *  @return 表名
 */
-(NSString *)tableName;

-(NSMutableArray *)getPropertyArray;
-(id)valueForProperty:(BaseDaoProperty *)property;

@end
