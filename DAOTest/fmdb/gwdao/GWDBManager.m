//
//  GWDBManager.m
//  GWMovie
//
//  Created by wushengtao on 14-12-2.
//  Copyright (c) 2014年 gewara. All rights reserved.
//

#import "GWDBManager.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "GWBaseDAO.h"
#import "GWDBProperty.h"
#import "GWDBCondition.h"
//#import "msgdefine.h"

NSString* const KDBManagerOpenedNotification = @"DB_Manager_Opened";
NSString* const KDBManagerClosedNotification = @"DB_Manager_Closed";

static NSString* const GWSQL_Attribute_NotNull     =   @"NOT NULL";
static NSString* const GWSQL_Attribute_PrimaryKey  =   @"PRIMARY KEY";
static NSString* const GWSQL_Attribute_Default     =   @"DEFAULT";
static NSString* const GWSQL_Attribute_Unique      =   @"UNIQUE";
static NSString* const GWSQL_Attribute_Check       =   @"CHECK";

static GWDBManager* shareInstance = nil;

@interface GWDBManager()
@property(nonatomic, strong) FMDatabaseQueue* dbQueue;
@end

@implementation GWDBManager

+ (id)shareDBManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!shareInstance)
        {
            shareInstance = [[GWDBManager alloc] init];
        }
    });
    
    return shareInstance;
}

- (void)dealloc
{
    [self closeDB];
}

- (BOOL)openDBWithName:(NSString *)dbName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [NSString stringWithFormat:@"%@/%@.db", [paths firstObject], dbName];
    
    if([_dbQueue openFlags] && [_dbQueue.path isEqualToString:path])
    {
//        D_Log(@"openDBWithName error, this db is being open");
        return NO;
    }
    
    [self closeDB];
    
//    D_Log(@"openDBWithName: %@", path);
    self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KDBManagerOpenedNotification object:nil];
    
    return YES;
}

- (BOOL)dbIsOpen
{
    return [_dbQueue openFlags];
}

- (void)closeDB
{
    if([_dbQueue openFlags])
    {
        [_dbQueue close];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KDBManagerClosedNotification object:nil];
}

-(void)executeDB:(void (^)(FMDatabase* db))block
{
    [_dbQueue inDatabase:^(FMDatabase *db){
#ifdef DEBUG
         //debug 模式下  打印错误日志
         db.logsErrors = YES;
#endif
        block(db);
     }];
}

-(BOOL)executeSQL:(NSString *)sql withArgumentsInArray:(NSArray *)arguments
{
    __block BOOL execute = NO;
    [self executeDB:^(FMDatabase *db) {
        if([arguments count])
        {
            execute = [db executeUpdate:sql withArgumentsInArray:arguments];
        }
        else
        {
            execute = [db executeUpdate:sql];
        }
    }];
    return execute;
}

#pragma mark create table
- (BOOL)createTableWithClass:(Class)daoClass
{
    if(![daoClass isSubclassOfClass:[GWBaseDAO class]])
    {
//        D_Log(@"is not a vaild DAO class");
        return NO;
    }
    
    NSArray* propertyList = [daoClass propertyListFromObject];
    NSMutableArray* columns = [[NSMutableArray alloc] init];
    NSMutableArray* primaryKeys = [[NSMutableArray alloc] init];
    NSMutableArray* alertColumns = [[NSMutableArray alloc] init];
    
    NSString* sqlToAlertTable;
    for(GWDBProperty* property in propertyList)
    {
        if(![property propertyCanUpdate])
        {
            continue;
        }
        
        NSMutableString* tmpColumns = [[NSMutableString alloc] init];
        [tmpColumns appendFormat:@"%@ %@",property.columnName, property.columnType];
        
        if(property.isNotNull)
        {
            [tmpColumns appendFormat:@" %@", GWSQL_Attribute_NotNull];
        }
        if(property.isUnique)
        {
            [tmpColumns appendFormat:@" %@", GWSQL_Attribute_Unique];
        }
        if(property.checkValue)
        {
            [tmpColumns appendFormat:@" %@(%@)", GWSQL_Attribute_Check, property.checkValue];
        }
        if(property.defaultValue)
        {
            [tmpColumns appendFormat:@" %@ %@", GWSQL_Attribute_Default, property.defaultValue];
        }
        
        if(EGWDBColumnStatusAddition == property.columnStatus)
        {
            sqlToAlertTable = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@", [daoClass tableName], tmpColumns];
            [alertColumns addObject:sqlToAlertTable];
            continue;
        }
        else if(EGWDBColumnStatusRemove == property.columnStatus)
        {
            sqlToAlertTable = [NSString stringWithFormat:@"ALTER TABLE %@ DROP COLUMN %@", [daoClass tableName], property.columnName];
            [alertColumns addObject:sqlToAlertTable];
            continue;
        }else{
           
        }
        
        [columns addObject:tmpColumns];
        
        if(property.isPrimary)
        {
            [primaryKeys addObject:property.columnName];
        }
    }
    
    NSMutableString* columnStr = [[NSMutableString alloc] initWithString:[columns componentsJoinedByString:@", "]];
    NSMutableString* primaryKeyStr = [[NSMutableString alloc] initWithString:[primaryKeys componentsJoinedByString:@", "]];
    if([primaryKeyStr length])
    {
        [primaryKeyStr insertString:@", primary key(" atIndex:0];
        [primaryKeyStr appendString:@")"];
    }
    
    NSString* createSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@%@)", [daoClass tableName], columnStr, primaryKeyStr];
    BOOL success = [self executeSQL:createSql withArgumentsInArray:nil];
    if(!success)
    {
//        D_Log(@"create table fail:%@", createSql);
        return NO;
    }
    for(NSString* alertSql in alertColumns)
    {
        success = [self executeSQL:alertSql withArgumentsInArray:nil];
        if(!success)
        {
//            D_Log(@"alert table fail:%@", alertSql);
        }
    };
    
    return YES;
}

- (NSMutableArray*)explainSet:(FMResultSet*)set withClass:(Class)daoClass
{
    if(![daoClass isSubclassOfClass:[GWBaseDAO class]])
    {
//        D_Log(@"is not a vaild DAO class");
        return nil;
    }
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSDictionary* propertyDictionary = [[daoClass class] propertyDictionaryFromObject];
    NSInteger columnCount = [set columnCount];
    while ([set next])
    {
        GWBaseDAO* dao = [[daoClass alloc] init];
        
        for(int i = 0; i < columnCount; i++)
        {
            NSString* columnName = [set columnNameForIndex:i];
            GWDBProperty* property = [propertyDictionary objectForKey:columnName];
            if(!property)
            {
                if([[columnName lowercaseString] isEqualToString:@"rowid"])
                {
                    dao.rowid = [set longForColumnIndex:i];
                }
                
                continue;
            }
            
            if([property.columnType isEqualToString:GWDB_Type_Blob])
            {
                [dao modelWithProperty:property value:[set dataForColumnIndex:i]];
            }
            else
            {
                [dao modelWithProperty:property value:[set stringForColumnIndex:i]];
            }
        }
        [results addObject:dao];
    }
    
    return results;
}

- (void)asyncTask:(void(^)(GWDBManager*))task
{
//    WeakObjectDef(self);
    __weak typeof(self)weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        StrongObjectDef(weakself);
        __strong typeof(self)strongweakself = weakself;
        if(strongweakself)
        {
            task(strongweakself);
        }
    });
}

#pragma mark search

- (void)searchWithClass:(Class)daoClass
                  condition:(GWDBSearchCondition*)condition
             completion:(void(^)(NSArray*))completion
{
    [self asyncTask:^(id strongself) {
        NSArray* results = [strongself searchWithClass:daoClass
                                             condition:condition];
        completion(results);
    }];
}

- (NSArray*)searchWithClass:(Class)daoClass
                  condition:(GWDBSearchCondition*)condition
{
    if(![daoClass isSubclassOfClass:[GWBaseDAO class]])
    {
//        D_Log(@"is not a vaild DAO class");
        return nil;
    }
    
    NSMutableArray* arguments = [[NSMutableArray alloc] init];
    
    NSString* columnString = [condition cloumString];
    NSString* conditionString = [condition conditionStringAddValues:arguments];
    columnString = [columnString length] ? columnString : @"*";
    conditionString = [conditionString length] ? conditionString : @"";
    NSMutableString* searchSql = [NSMutableString stringWithFormat:@"select %@,rowid from %@ %@", columnString, [daoClass tableName], conditionString];
    __block NSMutableArray* results = nil;
    [self executeDB:^(FMDatabase *db) {
        FMResultSet* set = nil;
        if(![arguments count])
        {
            set = [db executeQuery:searchSql];
        }
        else
        {
            set = [db executeQuery:searchSql withArgumentsInArray:arguments];
        }
        
        results = [self explainSet:set withClass:daoClass];
        
        [set close];
    }];
    
    return results;
}

#pragma mark insert
- (void)insertWithDAO:(GWBaseDAO*)dao
             completion:(void(^)(BOOL))completion
{
    [self asyncTask:^(GWDBManager* strongself) {
        BOOL success = [strongself insertWithDAO:dao];
        completion(success);
    }];
}

- (BOOL)insertWithDAO:(GWBaseDAO*)dao
{
    if(![dao isKindOfClass:[GWBaseDAO class]])
    {
//        D_Log(@"is not a vaild DAO class");
        return NO;
    }
    
    NSArray* propertyList = [[dao class] propertyListFromObject];
    NSMutableArray* columns = [[NSMutableArray alloc] init];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    NSMutableArray* arguments = [[NSMutableArray alloc] init];
    id value = nil;
    for(GWDBProperty* property in propertyList)
    {
        if(![property propertyCanUpdate])
        {
            continue;
        }
        value = [dao valueForProperty:property];
        if(value)
        {
            [columns addObject:property.columnName];
            [values addObject:@"?"];
            [arguments addObject:value];
        }
    }
    
    NSMutableString* columnStr = [[NSMutableString alloc] initWithString:[columns componentsJoinedByString:@","]];
    NSMutableString* valueStr = [[NSMutableString alloc] initWithString:[values componentsJoinedByString:@","]];
    NSString* insertSql = [NSString stringWithFormat:@"replace into %@(%@) values(%@)", [[dao class] tableName], columnStr, valueStr];

//    BOOL success = [self executeSQL:insertSql withArgumentsInArray:arguments];
    __block BOOL success = NO;
    __block sqlite_int64 lastInsertRowId = 0;
    
    [self executeDB:^(FMDatabase *db) {
        success = [db executeUpdate:insertSql
               withArgumentsInArray:arguments];
        lastInsertRowId = db.lastInsertRowId;
    }];
    
    dao.rowid = (NSInteger)lastInsertRowId;
    
    if(!success)
    {
//        D_Log(@"replace table fail:%@, %@", insertSql, arguments);
    }
    
    return success;
}

#pragma mark update
- (void)updateWithDAO:(GWBaseDAO*)dao
        withCondition:(GWDBCondition*)condition
           completion:(void(^)(BOOL))completion
{
    [self asyncTask:^(GWDBManager* strongself) {
        BOOL success = [strongself updateWithDAO:dao
                                   withCondition:condition];
        completion(success);
    }];
}

- (BOOL)updateWithDAO:(GWBaseDAO*)dao
        withCondition:(GWDBCondition*)condition
{
    if(![[dao class] isSubclassOfClass:[GWBaseDAO class]])
    {
//        D_Log(@"is not a vaild DAO class");
        return NO;
    }
    
    NSMutableString* updateSql = [NSMutableString stringWithFormat:@"update %@ set ", [[dao class] tableName]];
    
    NSArray* propertyList = [[dao class] propertyListFromObject];
    id value = nil;
    NSMutableArray* values = [[NSMutableArray alloc] init];
    NSMutableArray* arguments = [[NSMutableArray alloc] init];
    for(GWDBProperty* property in propertyList)
    {
        if(![property propertyCanUpdate])
        {
            continue;
        }
        value = [dao valueForProperty:property];
        if(value)
        {
            [values addObject:[NSString stringWithFormat:@"%@=?", property.columnName]];
            [arguments addObject:value];
        }
    }
    
    NSString* valueString = [values componentsJoinedByString:@","];
    [updateSql appendString:valueString];
    
    NSString* conditionStr = [condition conditionStringAddValues:arguments];
    //有条件优先条件
    if([conditionStr length])
    {
//        [updateSql appendString:conditionStr];
    }
    //无条件查dao的rowid
    else if(dao.rowid > 0)
    {
        conditionStr = [NSString stringWithFormat:@" where rowid=%ld", (long)dao.rowid];
    }
    //都没有报错
    else
    {
//        D_Log(@"update fail:no primary key(%@)", [dao class]);
        return NO;
    }
    [updateSql appendString:conditionStr];
    
    BOOL success = [self executeSQL:updateSql withArgumentsInArray:arguments];
    if(!success)
    {
//        D_Log(@"update table fail:%@", updateSql);
    }
    
    return success;
}

#pragma mark delete
- (void)deleteWithDAO:(GWBaseDAO*)dao
           completion:(void(^)(BOOL))completion
{
    [self asyncTask:^(GWDBManager* strongself) {
        BOOL success = [strongself deleteWithDAO:dao];
        completion(success);
    }];
}

- (BOOL)deleteWithDAO:(GWBaseDAO*)dao
{
    if(![[dao class] isSubclassOfClass:[GWBaseDAO class]])
    {
//        D_Log(@"is not a vaild DAO class");
        return NO;
    }
    
    NSMutableString* deleteSql = [NSMutableString stringWithFormat:@"delete from %@", [[dao class] tableName]];
    NSMutableArray* arguments = [[NSMutableArray alloc] init];
    //由于没有传入condition model，这里只有and的条件，后续增加
    NSMutableString* conditionStr = [[NSMutableString alloc] init];
    //如果dao的rowid存在
    if(dao.rowid > 0)
    {
        [conditionStr appendFormat:@"rowid=%ld", (long)dao.rowid];
    }
    else
    {
        NSArray* propertyList = [[dao class] propertyListFromObject];
        id value = nil;
        NSString* joinedStr = nil;
        
        NSMutableArray* conditions = [[NSMutableArray alloc] init];
        for(GWDBProperty* property in propertyList)
        {
            if(![property propertyCanUpdate])
            {
                continue;
            }
            value = [dao valueForProperty:property];
            if(value)
            {
                joinedStr = [dao joinedDeleteConditionColume:property.columnName];
                if([joinedStr length])
                {
                    [arguments addObject:value];
                    [conditions addObject:joinedStr];
                }
            }
        }
        [conditionStr appendString:[conditions componentsJoinedByString:@" and "]];
    }
    //有条件优先条件
    if([conditionStr length])
    {
        [conditionStr insertString:@" where " atIndex:0];
    }
    //都没有报错
    else
    {
//        D_Log(@"delete fail:no primary key(%@)", [self class]);
//        return NO;
    }
    
    [deleteSql appendString:conditionStr];

    BOOL success = [self executeSQL:deleteSql withArgumentsInArray:arguments];
    if(!success)
    {
//        D_Log(@"delete table fail:%@", deleteSql);
    }
    else
    {
        dao.rowid = 0;
    }
    
    return success;
}

- (BOOL)deleteAllWithClass:(Class)daoClass
{
    if(![daoClass isSubclassOfClass:[GWBaseDAO class]])
    {
//        D_Log(@"is not a vaild DAO class");
        return NO;
    }
    
    NSMutableString* deleteSql = [NSMutableString stringWithFormat:@"delete from %@", [daoClass tableName]];
    
    BOOL success = [self executeSQL:deleteSql withArgumentsInArray:nil];
    if(!success)
    {
//        D_Log(@"delete table fail:%@", deleteSql);
    }
    
    return success;
}
@end
