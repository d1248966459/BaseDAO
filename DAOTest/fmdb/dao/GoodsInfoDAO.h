//
//  GoodsInfoDAO.h
//  DAOTest
//
//  Created by dcj on 15/10/10.
//  Copyright © 2015年 dcj. All rights reserved.
//

#import "BaseDAO.h"
#import <UIKit/UIKit.h>
@class UserInfoModel;

@interface GoodsInfoDAO : BaseDAO

@property (nonatomic,copy) NSString <DataBaseIsNotNull,DataBaseIsUnique>* goodsID;
@property (nonatomic,strong) UserInfoModel * userInfo;
@property (nonatomic,assign) CGRect testFrame;
@property (nonatomic,assign) CGPoint testPoint;
@property (nonatomic,assign) CGSize testSize;


@end
