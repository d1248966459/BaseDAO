//
//  GWDBProperty.m
//  GWMovie
//
//  Created by wushengtao on 14-12-2.
//  Copyright (c) 2014年 gewara. All rights reserved.
//

#import "GWDBProperty.h"


NSString* const GWDB_Type_Text = @"text";
NSString* const GWDB_Type_Int = @"integer";
NSString* const GWDB_Type_Double = @"double";
NSString* const GWDB_Type_Blob = @"blob";


@implementation GWDBProperty


- (BOOL)propertyCanUpdate
{
    if(self.isIgnore || EGWDBColumnStatusRemove == self.columnStatus)
    {
        return NO;
    }
    
    return YES;
}

- (id)initWithProperty:(objc_property_t*)property
{
    if(self = [super init])
    {
        _isPrimary = NO;
        _isIgnore = NO;
        _columnStatus = EGWDBColumnStatusNormal;
        
        const char *propertyName = property_getName(*property);
        _columnName = @(propertyName);
        
        const char* attrs = property_getAttributes(*property);
        NSString* propertyAttributes = @(attrs);
//        NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
        NSString* propertyType = nil;

        
        NSScanner* scanner = [NSScanner scannerWithString:propertyAttributes];
        [scanner scanUpToString:@"T" intoString: nil];
        [scanner scanString:@"T" intoString:nil];
        
        //check if the property is an instance of a class
        if([scanner scanString:@"@\"" intoString: &propertyType])
        {
            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                    intoString:&propertyType];
            _propertyType = propertyType;
            _columnType = [[NSClassFromString(propertyType) class] isSubclassOfClass:NSClassFromString(@"GWObject")] ? GWDB_Type_Blob : GWDB_Type_Text;
            
            //read through the property protocols
            while ([scanner scanString:@"<" intoString:NULL])
            {
                NSString* protocolName = nil;
                
                [scanner scanUpToString:@">" intoString: &protocolName];
                
                if([protocolName isEqualToString:@"GWDBKeyIgnore"])
                {
                    _isIgnore = YES;
                }
                else if([protocolName isEqualToString:@"GWDBKeyPrimary"])
                {
                    _isPrimary = YES;
//                    _isUnique = YES;
//                    _isNotNull = YES;
                }
                else
                {
                    if([protocolName isEqualToString:@"GWDBKeyAddition"])
                    {
                        _columnStatus = EGWDBColumnStatusAddition;
                    }
                    else if([protocolName isEqualToString:@"GWDBKeyRemove"])
                    {
                        _columnStatus = EGWDBColumnStatusRemove;
                    }
                    else if([protocolName isEqualToString:@"GWDBKeyUnique"])
                    {
                        _isUnique = YES;
                    }
                    else if([protocolName isEqualToString:@"GWDBKeyNotNull"])
                    {
                        _isNotNull = YES;
                    }
                }
                
                [scanner scanString:@">" intoString:NULL];
            }
            
        }
        //check if the property is a structure
        else if ([scanner scanString:@"{" intoString: &propertyType])
        {
            [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                intoString:&propertyType];
            _propertyType = propertyType;
            return nil;
        }
        //the property must be a primitive
        else
        {
             NSDictionary* primitivesNames = @{@"f":@"float",
                                               @"i":@"int",
                                               @"d":@"double",
                                               @"l":@"long",
                                               @"c":@"BOOL",
                                               @"s":@"short",
                                               @"q":@"long",
                                 //and some famos aliases of primitive types
                                 // BOOL is now "B" on iOS __LP64 builds
                                               @"I":@"NSInteger",
                                               @"Q":@"NSUInteger",
                                               @"B":@"BOOL",
                                               @"@?":@"Block"};
            
             NSDictionary* mapTypes = @{@"float" : GWDB_Type_Double,
                                        @"double" : GWDB_Type_Double,
                                        @"decimal" : GWDB_Type_Double,
                                        @"int" : GWDB_Type_Int,
                                        @"char" : GWDB_Type_Int,
                                        @"short" : GWDB_Type_Int,
                                        @"long" : GWDB_Type_Int,
                                        @"NSInteger" : GWDB_Type_Int,
                                        @"NSUInteger" : GWDB_Type_Int,
                                        @"BOOL" : GWDB_Type_Int,};
            
            
            //the property contains a primitive data type
            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                    intoString:&propertyType];
            
            //get the full name of the primitive type
            _propertyType = primitivesNames[propertyType];
            propertyType = mapTypes[_propertyType];
            _columnType = [propertyType length] ? propertyType : GWDB_Type_Blob;
            
            if([_propertyType isEqualToString:@"Block"])
            {
                return nil;
            }
        }
    }
    
    return self;
}
@end
