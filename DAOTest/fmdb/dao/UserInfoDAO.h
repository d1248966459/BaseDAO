//
//  UserInfoDAO.h
//  BESTKEEP
//
//  Created by dcj on 15/10/9.
//  Copyright © 2015年 YISHANG. All rights reserved.
//

#import "BaseDAO.h"
#import "UserInfoModel.h"

@interface UserInfoDAO : BaseDAO

@property (nonatomic,copy) NSString * userID;
@property (nonatomic,strong) UserInfoModel * userInfo;

@end
