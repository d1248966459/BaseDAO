//
//  ViewController.m
//  DAOTest
//
//  Created by dcj on 15/10/9.
//  Copyright © 2015年 dcj. All rights reserved.
//

#import "ViewController.h"
#import "UserInfoModel.h"

#import "GoodsInfoDAO.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GoodsInfoDAO * userDao = [[GoodsInfoDAO alloc] init];
    userDao.goodsID = @"123456";
    userDao.userInfo = [[UserInfoModel alloc] init];
    [userDao createTable];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
