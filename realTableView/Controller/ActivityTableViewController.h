//
//  ActivityTableViewController.h
//  realTableView
//
//  Created by ZIYAO YANG on 15/8/6.
//  Copyright (c) 2015年 ZIYAO YANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTableViewController : UITableViewController<UIActionSheetDelegate>
{
    NSIndexPath *ip;
    BOOL loadingMore;//加载更多
    NSInteger loadCound;// 上线检查
    NSInteger perPage;
    NSInteger totalPage;
}

@property (strong, nonatomic) NSMutableArray *objectsForShow;
@property(strong,nonatomic)UIActivityIndicatorView *aiv;
@property(strong,nonatomic)UIActivityIndicatorView *tableFooterAI;
@end
