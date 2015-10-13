//
//  GoodsInfoDAO.m
//  DAOTest
//
//  Created by dcj on 15/10/10.
//  Copyright © 2015年 dcj. All rights reserved.
//

#import "GoodsInfoDAO.h"
#import "GoodsInfoDAO_Add.h"


@implementation GoodsInfoDAO

-(instancetype)init{
    if (self = [super init]) {
    }
    return self;
    

}
-(NSString *)tableName{
    return @"goodsInfo";
}

-(void)save{

}


@end
