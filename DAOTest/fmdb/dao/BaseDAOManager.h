//
//  BaseDAOManager.h
//  BESTKEEP
//
//  Created by dcj on 15/9/29.
//  Copyright © 2015年 YISHANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "BaseDAO.h"

@interface BaseDAOManager : NSObject


+(instancetype)cruuentManager;

-(void)openDataBase;

-(void)closeDataBase;

-(void)releaseManager;

-(BOOL)createTableWithDao:(Class)dao;

-(BOOL)insertModelWithDao:(BaseDAO *)dao;

-(void)insertModelWithDao:(BaseDAO *)dao andCompeletion:(CompeletionBool) compeletion;

-(id)searchModelWihtDao:(BaseDAO *)dao;

-(void)searchModelWithDao:(BaseDAO *)dao andCompeletion:(CompeletionId) compeletion;

@end
