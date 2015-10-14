//
//  ViewController.m
//  DAOTest
//
//  Created by dcj on 15/10/9.
//  Copyright © 2015年 dcj. All rights reserved.
//

#import "ViewController.h"
#import "UserInfoModel.h"
#import "BaseDAOCondition.h"
#import "GoodsInfoDAO.h"

@interface ViewController (){

    NSInteger goodinfoid;
    
}



@end


@interface ViewController ()
- (IBAction)insertModel:(id)sender;
- (IBAction)delteModel:(id)sender;
- (IBAction)updateModel:(id)sender;
- (IBAction)searchModel:(id)sender;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    goodinfoid = 123456;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)insertModel:(id)sender {
    GoodsInfoDAO * userDao = [[GoodsInfoDAO alloc] init];
    userDao.goodsID = (id)[NSString stringWithFormat:@"%ld",goodinfoid];
    userDao.userInfo = [[UserInfoModel alloc] init];
    userDao.testFrame = self.view.bounds;
    userDao.testSize = self.view.bounds.size;
    userDao.testPoint = self.view.center;
    [userDao insertModelWithCompeletion:^(BOOL result) {
        
    }];
    goodinfoid ++;
}

- (IBAction)delteModel:(id)sender {
    goodinfoid --;

    GoodsInfoDAO * userDao = [[GoodsInfoDAO alloc] init];
    userDao.goodsID = (id)[NSString stringWithFormat:@"%ld",goodinfoid];
    [userDao deleteModelWithCompeletion:^(BOOL result) {
        
    }];
   }

- (IBAction)updateModel:(id)sender {
}

- (IBAction)searchModel:(id)sender {
    NSString * goodsID = [NSString stringWithFormat:@"%ld",goodinfoid];
    BaseDBPair * pair = [[BaseDBPair alloc] init];
    pair.equlPair = @{@"goodsID":goodsID};
    BaseDAOSerchCondition * searchCondition = [[BaseDAOSerchCondition alloc] init];
    searchCondition.andPairs = pair;
    [[[GoodsInfoDAO alloc] init] searchModelWithCompeletion:^(id result) {
        if (result) {
            
        }else{
        
        }
    } andCondition:searchCondition];
}
@end
