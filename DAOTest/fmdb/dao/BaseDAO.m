//
//  BaseDAO.m
//  BESTKEEP
//
//  Created by dcj on 15/9/29.
//  Copyright © 2015年 YISHANG. All rights reserved.
//

#import "BaseDAO.h"
#import "FMDB.h"
#import "BaseDAOManager.h"
#import "BaseDaoProperty.h"
#import <objc/runtime.h>
#import <CoreData/CoreData.h>
#import "UserInfoModel.h"

static NSSet *foundationClasses_;

typedef BOOL (^DJClassesEnumeration)(Class c, BOOL *stop);

@implementation BaseDAO

+(BOOL)createTable{
    
    BaseDAOManager * manager = [BaseDAOManager cruuentManager];
    return [manager createTableWithDao:[self class]];
}

-(BOOL)deleteTable{

    return NO;
}


-(void)searchModelWithCompeletion:(CompeletionId)commpeletion{
    [[BaseDAOManager cruuentManager] searchModelWithDao:self andCompeletion:commpeletion];
}
-(void)insertModelWithCompeletion:(CompeletionBool)compeletion{
    [[BaseDAOManager cruuentManager] insertModelWithDao:self andCompeletion:compeletion];
}




#pragma mark -- private method
-(id)valueForProperty:(BaseDaoProperty *)property{
    id value = [self valueForKey:property.columnName];
    id returnValue = value;
    if (value == nil) {
        return nil;
    }
    if ([value isKindOfClass:[NSString class]]) {
        returnValue = value;
    }else if ([value isKindOfClass:[NSNumber class]]){
        returnValue = [value stringValue];
    }else if ([value isKindOfClass:[NSValue class]]){
        NSString * columnType = property.columnType;
        if ([columnType isEqualToString:@"CGRect"]) {
            
        }
    
    }
    
    return value;
}

+(NSMutableArray *)getPropertyArray{
    NSMutableArray * propertyarr = [[NSMutableArray alloc] init];
    
    [self enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        unsigned int outCount, i;
        
        objc_property_t * properties = class_copyPropertyList([c class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property =properties[i];
            BaseDaoProperty * daoProperty = [[BaseDaoProperty alloc] initWithPorety:&property];
            if (daoProperty) {
                [propertyarr addObject:daoProperty];
            }
        }
        free(properties);
        return NO;
    }];
    
    
    return propertyarr;
}
+(BOOL)enumerateClasses:(DJClassesEnumeration)enumeration{
    if (enumeration == nil) return NO;
    BOOL stop = NO;
    
    UserInfoModel * model = [[UserInfoModel alloc] init];
    NSString * str = @"";
    Class c = [self class];
    while (c && !stop) {
        BOOL exit = enumeration(c, &stop);
        if (exit) {
            return YES;
        }
        c = class_getSuperclass(c);
        if ([self isClassFromFoundation:c]) {
            stop = YES;
            break;
        };
    }
    return NO;
}

+ (NSSet *)foundationClasses
{
    if (foundationClasses_ == nil) {
        foundationClasses_ = [NSSet setWithObjects:
                              [NSURL class],
                              [NSDate class],
                              [NSValue class],
                              [NSData class],
                              [NSError class],
                              [NSArray class],
                              [NSDictionary class],
                              [NSString class],
                              [NSAttributedString class],
                              [NSObject class],nil];
    }
    return foundationClasses_;
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    if (c == [NSObject class] || c == [NSManagedObject class]) return YES;
    
    __block BOOL result = NO;
    [[self foundationClasses] enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if (c == foundationClass || [c isSubclassOfClass:foundationClass]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

+(NSString *)tableName{
return @"BaseDao";
}

@end
