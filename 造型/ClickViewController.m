//
//  ClickViewController.m
//  Hair
//
//  Created by 冰刀画的圈。 on 15/10/8.
//  Copyright (c) 2015年 dzx. All rights reserved.
//

#import "ClickViewController.h"
#import"goodOrderController.h"
@interface ClickViewController ()

@end

@implementation ClickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableview.tableFooterView = [[UIView alloc] init];//去掉tableView多余的横线
    //到Parserq去读取数据
    [self requestData];
    [self uiConfiguration];
}

-(void)viewWillAppear:(BOOL)animated {
    //单利化全局变量
    if ([[[storageMgr singletonStorageMgr] objectForKey:@"background"] integerValue] == 0) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BJ-1"]];
//        cell.image=[UIColor colorWithPatternImage:[UIImage imageNamed:@"BJ-1"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BJ-2"]];
        
    }
    [super viewWillAppear:animated];//视图出现之前做的事情
}
-(void)uiConfiguration
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    NSString *title = [NSString stringWithFormat:@"下拉即可刷新"];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *attrsDictionary = @{NSUnderlineStyleAttributeName:
                                          @(NSUnderlineStyleNone),
                                      NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                      NSParagraphStyleAttributeName:style,
                                      NSForegroundColorAttributeName:[UIColor brownColor]};
    
    
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    refreshControl.attributedTitle = attributedTitle;
    //tintColor旋转的小花的颜色
    refreshControl.tintColor = [UIColor brownColor];
    //背景色 浅灰色
    refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //执行的动作
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    [_tableview addSubview:refreshControl];
}
- (void)refreshData:(UIRefreshControl *)rc
{
    [self requestData];
    [_tableview reloadData];
    
    //怎么样让方法延迟执行的
    [self performSelector:@selector(endRefreshing:) withObject:rc afterDelay:1.f];
}
//下拉刷新闭合
- (void)endRefreshing:(UIRefreshControl *)rc
{
    [rc endRefreshing];//闭合
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)requestData {
    PFQuery *query = [PFQuery queryWithClassName:@"product"];//查询的是那张表
    if ([_nameitem isEqualToString:@"3"])
    {
        [query whereKey:@"Type" equalTo:@"染发"];
        
    } else if ([_nameitem isEqualToString:@"2"])
    {
        [query whereKey:@"Type" equalTo:@"烫发"];
        
    } else if ([_nameitem isEqualToString:@"1"])
    {
        [query whereKey:@"Type" equalTo:@"洗吹"];
        
    } else if ([_nameitem isEqualToString:@"4"])
    {
        [query whereKey:@"Type" equalTo:@"洗剪吹"];
        
    } else if ([_nameitem isEqualToString:@"5"])
    {
        [query whereKey:@"Type" equalTo:@"护理"];
    }
  
    [query selectKeys:@[@"productPrice",@"productName",@"pbusinessId"]];//查询条件，自己数据库里的城市后面的是城市名
    [query includeKey:@"pbusinessId"];
    UIActivityIndicatorView *aiv = [Utilities getCoverOnView:self.view];
    [query findObjectsInBackgroundWithBlock:^(NSArray *returnedObjects, NSError *error) {
        [aiv stopAnimating];
        if (!error) {
            _objectsForShow = returnedObjects;
            NSLog(@"%@", _objectsForShow);
            [_tableview reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *object = [_objectsForShow objectAtIndex:indexPath.row];
   goodOrderController *pvc = [Utilities getStoryboardInstanceByIdentity:@"ASD"];
    //    PFObject *par = object[@"owner"];
    //    pvc.ownername = par;
    pvc.like = object;
    pvc.hidesBottomBarWhenPushed = YES;//把切换按钮隐藏掉
    [self.navigationController pushViewController:pvc animated:YES];
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objectsForShow.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        static NSString *TableSampleIdentifier = @"Cell";
        
        ClickTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                  TableSampleIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ClickTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:TableSampleIdentifier];
        }
        PFObject *object = [_objectsForShow objectAtIndex:indexPath.row];
        PFObject *Buser = object[@"pbusinessId"];
    
        [Buser[@"businessPhoto"] getDataInBackgroundWithBlock:^(NSData *photoData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:photoData];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    cell.imgge.image = image;
                } else {
                    NSLog(@"IN");
                    cell.imgge.image = nil;
                }
            });
        }
    }];
    
    if ([[[storageMgr singletonStorageMgr] objectForKey:@"background"] integerValue] == 0) {
        cell.Oneicon.image=[UIImage imageNamed:@"TB-4"];
        cell.Twoico.image=[UIImage imageNamed:@"TB-10"];
    } else {
         cell.Oneicon.image=[UIImage imageNamed:@"TB-5"];
         cell.Twoico.image=[UIImage imageNamed:@"TB-8"];
    }
    
      cell.packname.text = [NSString stringWithFormat:@"%@",object[@"productName"]];
      cell.price.text = [NSString stringWithFormat:@"%@",object[@"productPrice"]];
      cell.storename.text = [NSString stringWithFormat:@"%@",Buser[@"businessName"]];
        return cell;
}
@end
