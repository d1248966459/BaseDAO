//
//  GWBaseDAO.m
//  GWMovie
//
//  Created by wushengtao on 14-12-3.
//  Copyright (c) 2014年 gewara. All rights reserved.
//

#import "GWBaseDAO.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "GWDBProperty.h"
//#import "JSONKit.h"
//#import "GWObject.h"
#import "GWDBManager.h"

static char GWDBBase_Key_RowID;

@implementation GWBaseDAO
+ (void)propertyContainer:(id)container objectWithClassDecider:(BOOL(^)(Class tmpClass, BOOL *stop))classDecider
{
    Class tmpClass = [self class];
    while(tmpClass)
    {
        if(classDecider)
        {
            BOOL stop = NO;
            while(tmpClass && !classDecider(tmpClass, &stop))
            {
                tmpClass = class_getSuperclass(tmpClass);
            }
            if(stop)
            {
                break;
            }
        }
        
        unsigned int count = 0;
        objc_property_t *firstProperty = class_copyPropertyList(tmpClass, &count);
        objc_property_t property;
        for(NSInteger i = 0; i < count; ++i)
        {
            property = *(firstProperty + i);
            
            const char *propertyName = property_getName(property);
            if([@(propertyName) isEqualToString:@"rowid"])
            {
                continue;
            }
            
            GWDBProperty* dbProperty = [[GWDBProperty alloc] initWithProperty:&property];
            if(dbProperty)
            {
                [[self class] addConstraintWithProperty:dbProperty];
                
                if([container respondsToSelector:@selector(addObject:)])
                {
                    [container addObject:dbProperty];
                }
                else if([container respondsToSelector:@selector(setObject:forKey:)])
                {
                    [container setObject:dbProperty forKey:dbProperty.columnName];
                }
            }
        }
        free(firstProperty);
        
        tmpClass = class_getSuperclass(tmpClass);
    }
}

+ (NSMutableArray*)propertyListFromObject
{
    NSMutableArray* pairs = [[NSMutableArray alloc] init];
    [[self class] propertyContainer:pairs
             objectWithClassDecider:^BOOL(__unsafe_unretained Class tmpClass, BOOL *stop) {
                 if(tmpClass == [NSObject class])
                 {
                     *stop = YES;
                     return NO;
                 }
                 return YES;
             }];
    
    return pairs;
}

+ (NSMutableDictionary*)propertyDictionaryFromObject
{
    NSMutableDictionary* pairs = [[NSMutableDictionary alloc] init];
    [[self class] propertyContainer:pairs
             objectWithClassDecider:^BOOL(__unsafe_unretained Class tmpClass, BOOL *stop) {
                 if(tmpClass == [NSObject class])
                 {
                     *stop = YES;
                     return NO;
                 }
                 return YES;
             }];
    
    return pairs;
}

+ (NSString*)tableName
{
//    D_Log(@"tableName error!, subclass not implementation");
    // Subclasses must be override this method...
    [[self class] doesNotRecognizeSelector:_cmd];
    
    return nil;
}

+ (void)addConstraintWithProperty:(GWDBProperty*)property
{
    //subclasses can implementation
}

- (void)modelWithProperty:(GWDBProperty*)property value:(id)value
{
    ///参试获取属性的Class
    Class columnClass = NSClassFromString(property.propertyType);
    
    id modelValue = nil;
    NSString* columnType = property.columnType;
    if(columnClass == nil)
    {
        ///当找不到 class 时，就是 基础类型 int,float CGRect 之类的
        if([columnType isEqualToString:GWDB_Type_Double])
        {
            double number = [value doubleValue];
            modelValue = [NSNumber numberWithDouble:number];
        }
        else if([columnType isEqualToString:GWDB_Type_Int])
        {
            if([property.propertyType isEqualToString:@"long"])
            {
                long long number = [value longLongValue];
                modelValue = [NSNumber numberWithLongLong:number];
            }
            else
            {
                NSInteger number = [value integerValue];
                modelValue = [NSNumber numberWithInteger:number];
            }
        }
        else if([columnType isEqualToString:@"CGRect"])
        {
            CGRect rect = CGRectFromString(value);
            modelValue = [NSValue valueWithCGRect:rect];
        }
        else if([columnType isEqualToString:@"CGPoint"])
        {
            CGPoint point = CGPointFromString(value);
            modelValue = [NSValue valueWithCGPoint:point];
        }
        else if([columnType isEqualToString:@"CGSize"])
        {
            CGSize size = CGSizeFromString(value);
            modelValue = [NSValue valueWithCGSize:size];
        }
        else if([columnType isEqualToString:@"_NSRange"])
        {
            NSRange range = NSRangeFromString(value);
            modelValue = [NSValue valueWithRange:range];
        }

        ///如果都没有值 默认给个0
        if(modelValue == nil)
        {
            modelValue = [NSNumber numberWithInt:0];
        }
    }
    else if([columnType isEqualToString:GWDB_Type_Blob])
    {
        if([columnClass isSubclassOfClass:[NSObject class]])
        {
            modelValue = [NSKeyedUnarchiver unarchiveObjectWithData:value];
        }
    }
    else if([value length] == 0)
    {
        //为了不继续遍历
    }
    else if([columnClass isSubclassOfClass:[NSString class]])
    {
        modelValue = value;
    }
    else if([columnClass isSubclassOfClass:[NSNumber class]])
    {
        modelValue = [NSNumber numberWithDouble:[value doubleValue]];
    }
    else if([columnClass isSubclassOfClass:[UIImage class]])
    {
        //TODO 存在本地，存本地文件url，防止数据库过大
        modelValue = [UIImage imageWithContentsOfFile:value];
    }
    else
    {
        if([columnClass isKindOfClass:[NSArray class]])
        {
//            modelValue = [value objectFromJSONString];
        }
        else if([columnClass isKindOfClass:[NSDictionary class]])
        {
//            modelValue = [value objectFromJSONString];
        }
    }
    
    [self setValue:modelValue forKey:property.columnName];
}

- (id)valueForProperty:(GWDBProperty*)property
{
    //subclasses can implementation
    id value = [self valueForKey:property.columnName];
    id returnValue = value;
    if(value == nil)
    {
        return nil;
    }
    else if([value isKindOfClass:[NSString class]])
    {
        returnValue = value;
    }
    else if([value isKindOfClass:[NSNumber class]])
    {
        returnValue = [value stringValue];
    }
    else if([value isKindOfClass:[NSValue class]])
    {
        NSString* columnType = property.propertyType;
        
        if([columnType isEqualToString:@"CGRect"])
        {
            returnValue = NSStringFromCGRect([value CGRectValue]);
        }
        else if([columnType isEqualToString:@"CGPoint"])
        {
            returnValue = NSStringFromCGPoint([value CGPointValue]);
        }
        else if([columnType isEqualToString:@"CGSize"])
        {
            returnValue = NSStringFromCGSize([value CGSizeValue]);
        }
        else if([columnType isEqualToString:@"_NSRange"])
        {
            returnValue = NSStringFromRange([value rangeValue]);
        }
    }
    else if([value isKindOfClass:[NSObject class]])
    {
        returnValue = [NSKeyedArchiver archivedDataWithRootObject:value];
    }
    else if([value isSubclassOfClass:[UIImage class]])
    {
        //TODO 存在本地，存本地文件url，防止数据库过大
        returnValue = nil;
    }
    else
    {
        if([value isKindOfClass:[NSArray class]])
        {
//            returnValue = [value JSONString];
        }
        else if([value isKindOfClass:[NSDictionary class]])
        {
//            returnValue = [value JSONString];
        }
    }
    
    return returnValue;
}



- (NSString*)joinedDeleteConditionColume:(NSString*)column
{
    //subclasses can implementation
    //@"DELETE FROM xxx WHERE date LIKE ?", [NSString stringWithFormat:@"%@%%", date]
    return [NSString stringWithFormat:@"%@=?", column];
}

#pragma mark
-(void)setRowid:(NSInteger)rowid
{
    objc_setAssociatedObject(self, &GWDBBase_Key_RowID, [NSNumber numberWithInteger:rowid], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)rowid
{
    return [objc_getAssociatedObject(self, &GWDBBase_Key_RowID) integerValue];
}

+ (GWDBManager*)dbManager
{
    return [GWDBManager shareDBManager];
}

#pragma mark create
+ (BOOL)createTable
{
    GWDBManager* manager = [[self class] dbManager];
    return [manager createTableWithClass:[self class]];
}

#pragma mark search
+ (void)searchWithCondition:(GWDBSearchCondition*)condition
                     completion:(void(^)(NSArray*))completion
{
    GWDBManager* manager = [[self class] dbManager];
    [manager searchWithClass:[self class]
                   condition:condition
                  completion:completion];
}

+ (NSArray*)searchWithCondition:(GWDBSearchCondition*)condition
{
    GWDBManager* manager = [[self class] dbManager];
    return [manager searchWithClass:[self class]
                          condition:condition];
}

#pragma mark update
- (void)updateModelWithCondition:(GWDBCondition*)condition
                      completion:(void(^)(BOOL))completion
{
    GWDBManager* manager = [[self class] dbManager];
    [manager updateWithDAO:self
             withCondition:condition
                completion:completion];
}

- (BOOL)updateModelWithCondition:(GWDBCondition*)condition
{
    GWDBManager* manager = [[self class] dbManager];
    return [manager updateWithDAO:self withCondition:condition];
}

#pragma mark insert
- (void)insertModelCompletion:(void(^)(BOOL))completion
{
    GWDBManager* manager = [[self class] dbManager];
    [manager insertWithDAO:self
                completion:completion];
}

- (BOOL)insertModel
{
    GWDBManager* manager = [[self class] dbManager];
    return [manager insertWithDAO:self];
}

#pragma mark delete
- (void)deleteModelCompletion:(void(^)(BOOL))completion
{
    GWDBManager* manager = [[self class] dbManager];
    return [manager deleteWithDAO:self
                       completion:completion];
}

- (BOOL)deleteModel
{
    GWDBManager* manager = [[self class] dbManager];
    return [manager deleteWithDAO:self];
}

#pragma mark trigger by user
+ (void)clearCacheByUser
{
    GWDBManager* manager = [[self class] dbManager];
    [manager deleteAllWithClass:[self class]];
}

@end



