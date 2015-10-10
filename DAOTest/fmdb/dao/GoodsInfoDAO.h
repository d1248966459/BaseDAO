//
//  GoodsInfoDAO.h
//  DAOTest
//
//  Created by dcj on 15/10/10.
//  Copyright © 2015年 dcj. All rights reserved.
//

#import "BaseDAO.h"
@class UserInfoModel;

@interface GoodsInfoDAO : BaseDAO

@property (nonatomic,copy) NSString * goodsID;
@property (nonatomic,strong) UserInfoModel * userInfo;


@end
