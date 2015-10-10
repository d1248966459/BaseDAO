
//
//  UserInfoDAO.m
//  BESTKEEP
//
//  Created by dcj on 15/10/9.
//  Copyright © 2015年 YISHANG. All rights reserved.
//

#import "UserInfoDAO.h"

@implementation UserInfoDAO

-(instancetype)init{
    if (self = [super init]) {
//        self.child = self;
    }
    return self;
}

-(NSString *)tableName{

    return @"userInfo";
}


@end
