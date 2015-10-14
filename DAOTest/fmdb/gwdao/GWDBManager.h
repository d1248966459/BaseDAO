//
//  GWDBManager.h
//  GWMovie
//
//  Created by wushengtao on 14-12-2.
//  Copyright (c) 2014年 gewara. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const KDBManagerOpenedNotification;
extern NSString* const KDBManagerClosedNotification;

@class GWBaseDAO;
@class GWDBCondition;
@class GWDBSearchCondition;
@interface GWDBManager : NSObject
+ (id)shareDBManager;

- (BOOL)openDBWithName:(NSString *)dbName;
- (void)closeDB;
- (BOOL)dbIsOpen;

- (BOOL)createTableWithClass:(Class)daoClass;


- (void)searchWithClass:(Class)daoClass
              condition:(GWDBSearchCondition*)condition
             completion:(void(^)(NSArray*))completion;
- (NSArray*)searchWithClass:(Class)daoClass
                  condition:(GWDBSearchCondition*)condition;

- (void)insertWithDAO:(GWBaseDAO*)dao
           completion:(void(^)(BOOL))completion;
- (BOOL)insertWithDAO:(GWBaseDAO*)dao;


- (void)updateWithDAO:(GWBaseDAO*)dao
        withCondition:(GWDBCondition*)condition
           completion:(void(^)(BOOL))completion;
- (BOOL)updateWithDAO:(GWBaseDAO*)dao withCondition:(GWDBCondition*)condition;

- (void)deleteWithDAO:(GWBaseDAO*)dao
           completion:(void(^)(BOOL))completion;
- (BOOL)deleteWithDAO:(GWBaseDAO*)dao;
- (BOOL)deleteAllWithClass:(Class)daoClass;
@end
