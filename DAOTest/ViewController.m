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
- (IBAction)insertModel:(id)sender;
- (IBAction)delteModel:(id)sender;
- (IBAction)updateModel:(id)sender;
- (IBAction)searchModel:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)insertModel:(id)sender {
    GoodsInfoDAO * userDao = [[GoodsInfoDAO alloc] init];
    userDao.goodsID = (id)@"123456";
    userDao.userInfo = [[UserInfoModel alloc] init];
    userDao.testFrame = self.view.bounds;
    userDao.testSize = self.view.bounds.size;
    userDao.testPoint = self.view.center;
    [userDao insertModelWithCompeletion:^(BOOL result) {
        
    }];

}

- (IBAction)delteModel:(id)sender {
}

- (IBAction)updateModel:(id)sender {
}

- (IBAction)searchModel:(id)sender {
}
@end
