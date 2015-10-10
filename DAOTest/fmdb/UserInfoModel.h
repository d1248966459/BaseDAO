//
//  UserInfoModel.h
//  DAOTest
//
//  Created by dcj on 15/10/9.
//  Copyright © 2015年 dcj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDAO.h"


@interface UserInfoModel : BaseDAO

@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * age;

@end
