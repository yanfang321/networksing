//
//  ActivityTableViewController.m
//  realTableView
//
//  Created by ZIYAO YANG on 15/8/6.
//  Copyright (c) 2015年 ZIYAO YANG. All rights reserved.
//

#import "ActivityTableViewController.h"
#import "ActivityTableViewCell.h"
#import "ActivityObject.h"
#import "appAPIClient.h"
#import "Utilities.h"
#import "UIImageView+WebCache.h"
//#define UI_SCREEN_W=
@interface ActivityTableViewController ()

@end

@implementation ActivityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self naviConfiguration];
    [self dataPreparation];
    [self uiConfiguration];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)naviConfiguration {
    NSDictionary* textTitleOpt = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:textTitleOpt];
    self.navigationItem.title = @"活动";
    self.navigationController.navigationBar.barTintColor = [UIColor brownColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)dataPreparation {//进入页面菊花膜—＋初始化＋初始数据
//    NSDictionary *dicA = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"imgUrl", @"骑行", @"name", @"绕城骑行", @"content", @20, @"like", @2, @"unlike", @0, @"applied", nil];
//    NSDictionary *dicB = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"imgUrl", @"浮潜", @"name", @"近海浮潜近海浮潜", @"content", @20, @"like", @2, @"unlike", @0, @"applied", nil];
//    NSDictionary *dicC = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"imgUrl", @"徒步", @"name", @"操场徒步操场徒步操场徒步操场徒步操场徒步", @"content", @20, @"like", @2, @"unlike", @0, @"applied", nil];
//    NSMutableArray *arr = [NSMutableArray arrayWithObjects:dicA, dicB, dicC, nil];
//    
//    _objectsForShow = [NSMutableArray new];
//    for (NSDictionary *dic in arr) {
//        [_objectsForShow addObject:[[ActivityObject alloc] initWithDictionary:dic]];
//    }
//    [self.tableView reloadData];
    _objectsForShow=nil;
    _objectsForShow=[NSMutableArray new];
    _aiv=[Utilities getCoverOnView:[[UIApplication sharedApplication]keyWindow]];//jiazai菊花
    [self initializeData];//初始化请求数据
}
-(void)initializeData//下拉刷新：刷新器＋初始数据（第一页数据）
{
    loadCound=1;//页码
    perPage=3;//
    
    [self urlAction];
}
-(void)urlAction//上拉翻页：footer菊花＋新－－页面
{
    loadingMore=NO;//
    
NSString* url = @"http://v0430.api.gym.yundongbang.com/event/list";//接口返回的数据
    NSString *decodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:loadCound], @"page", [NSNumber numberWithInteger:perPage], @"perPage", nil];
    [[appAPIClient sharedClient] GET:decodedUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([[responseObject objectForKey:@"resultFlag"] integerValue] == 8001) {
            NSDictionary *resultDic=[responseObject objectForKey:@"result"];
            NSArray *models=[resultDic objectForKey:@"models"];
            if (loadCound==1) {
                _objectsForShow=nil;//清空
                _objectsForShow=[NSMutableArray new];
               
            }
            for (NSDictionary *dic in models) {
                [_objectsForShow addObject:[[ActivityObject alloc]initWithDictionary:dic]];
            }
            NSDictionary *pageDic=[resultDic objectForKey:@"pagingInfo"];
            totalPage=[[pageDic objectForKey:@"totalPage"]intValue];
            [self.tableView reloadData];
            
        } else {
            [Utilities popUpAlertViewWithMsg:[responseObject objectForKey:@"message"] andTitle:nil];
        }
        [_aiv stopAnimating];
        [self loadDataEnd];
//        下拉刷新
        UIRefreshControl *refreshControl = (UIRefreshControl *)[self.tableView viewWithTag:8001];
        [refreshControl endRefreshing];
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utilities popUpAlertViewWithMsg:[error localizedDescription] andTitle:nil];
        
         [_aiv stopAnimating];
        [self loadDataEnd];//请求终止
        UIRefreshControl *refreshControl = (UIRefreshControl *)[self.tableView viewWithTag:8001];
        [refreshControl endRefreshing];
    }];
    
}


- (void)uiConfiguration {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    NSString *title = [NSString stringWithFormat:@"下拉即可刷新"];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *attrsDictionary = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                      NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                      NSParagraphStyleAttributeName:style,
                                      NSForegroundColorAttributeName:[UIColor brownColor]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    refreshControl.attributedTitle = attributedTitle;
    refreshControl.tintColor = [UIColor brownColor];
    refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    refreshControl.tag=8001;
    [refreshControl addTarget:self action:@selector(initializeData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.tableView.tableFooterView=[[UIView alloc]init];
}

- (void)refreshData:(UIRefreshControl *)rc {
    [self.tableView reloadData];
    [self performSelector:@selector(endRefreshing:) withObject:rc afterDelay:1.f];
}

- (void)endRefreshing:(UIRefreshControl *)rc {
    [rc endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _objectsForShow.count;
}
//异步下载图片
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    获得cell实例
//    ActivityTableViewCell *myCell = (ActivityTableViewCell *)cell;
//    //    创建新线程
//    dispatch_queue_t newQueue = dispatch_queue_create("imageCache", NULL);
//    //     dispatch_async异步进行｛｝新线程执行的操作
//    dispatch_async(newQueue, ^(void) {
//        [self updateImageForCell:myCell AtIndexPath:indexPath];
//    });
//}

//获取图片
//- (void)updateImageForCell:(ActivityTableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
//{
//    ActivityObject *object = [_objectsForShow objectAtIndex:indexPath.row];
//    
//    UIImage *image = [Utilities imageUrl:object.imgUrl];
//    //    回到主线程
//    dispatch_async(dispatch_get_main_queue(), ^{
//        cell.photoView.image = image;
//    });
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell" forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];//底边下划线充满整个屏幕
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];//
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    ActivityObject *object = [_objectsForShow objectAtIndex:indexPath.row];
//    
//    [cell.photoView sd_setImageWithURL:[NSURL URLWithString:object.imgUrl] placeholderImage:[UIImage imageNamed:@"mo"]];//sd_setImageWithUR照片地址  placeholderImage默认图片
    [cell.photoView sd_setImageWithURL:[NSURL URLWithString:[object.imgUrl isKindOfClass:[NSNull class]] ? nil : object.imgUrl] placeholderImage:[UIImage imageNamed:@"mo"]];
    
    cell.nameLabel.text = object.name;
    cell.contentLabel.text = object.content;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityObject *object = [_objectsForShow objectAtIndex:indexPath.row];
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
    CGSize maxSize = CGSizeMake(cell.contentView.frame.size.width - 30, 1000);
    CGSize contentLabelSize = [object.content boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:cell.contentLabel.font} context:nil].size;
    return cell.contentLabel.frame.origin.y + contentLabelSize.height + 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentSize.height > scrollView.frame.size.height) {
        if (!loadingMore && scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height)) {
            [self loadDataBegin];//内容高度大于屏幕高度 scallview显示位置大于scallview的内容高度减去scallview本身高度，
        }
    } else {
        if (!loadingMore && scrollView.contentOffset.y > 0) {
            [self loadDataBegin];
        }
    }
}
- (void)loadDataBegin {
   
    if (loadingMore == NO) {//不加载
        loadingMore = YES;
         [self createTableFooter];
        _tableFooterAI = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((UI_SCREEN_W - 86.0f) / 2 - 30.0f, 10.0f, 20.0f, 20.0f)];
        [_tableFooterAI setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.tableView.tableFooterView addSubview:_tableFooterAI];
        [_tableFooterAI startAnimating];
        [self loadDataing];
    }
}
- (void)createTableFooter {
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 40.0f)];
    UILabel *loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake((UI_SCREEN_W - 86.0f) / 2, 0.0f, 116.0f, 40.0f)];//创建label加载更多数据
    loadMoreText.tag = 9001;//label标签
    [loadMoreText setFont:[UIFont systemFontOfSize:B_Font]];
    [loadMoreText setText:@"上拉显示更多数据"];
    [tableFooterView addSubview:loadMoreText];
    loadMoreText.textColor = [UIColor grayColor];
    self.tableView.tableFooterView = tableFooterView;
}
- (void)loadDataing {//翻页
    if (totalPage > loadCound) {
        loadCound ++;
        [self urlAction];
    } else {
        [self performSelector:@selector(beforeLoadEnd) withObject:nil afterDelay:0.25];
//         loadingMore = NO;
    }
   
}
- (void)beforeLoadEnd {
    UILabel *label = (UILabel *)[self.tableView.tableFooterView viewWithTag:9001];
    [label setText:@"当前已无更多数据"];
    [_tableFooterAI stopAnimating];
    _tableFooterAI = nil;//内存释放
    [self performSelector:@selector(loadDataEnd) withObject:nil afterDelay:0.25];
}
- (void)loadDataEnd {
    self.tableView.tableFooterView = [[UIView alloc] init];//重新初始化
      loadingMore = NO;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
