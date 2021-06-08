//
//  BlueToothListTableVC.m
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/3.
//

#import "TBPListTableVC.h"
#import "TBPBlueToothManager.h"
#import "TBPBlueToothCoconut.h"
#import "TBPDetailTableVC.h"
#import "TBPListTableCell.h"
#import "TBPTableHeaderView.h"
#import "TBPCachePerInfoManager.h"

static NSString *cellIdentifier = @"UITableViewCell";
static CGFloat miniHeight = 0.01;

static NSString *headerIdentifier = @"BlueToothHeaderView";
static CGFloat normalHeaderHeight = 44;

static NSString *deviceListStr = @"设备列表";
@interface TBPListTableVC ()
@property (nonatomic, strong)NSArray<CBPeripheral *> *dataList;
@property (nonatomic, assign)BOOL isconnect;
@end

@implementation TBPListTableVC

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    if(self.isconnect){
        self.isconnect = NO;
        [[TBPBlueToothManager shareInstance] stopScan];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    if(self.isconnect){ return; }
    self.isconnect = YES;
    [[TBPBlueToothManager shareInstance] searchPeripheralsBlock:^(NSArray<CBPeripheral *> * _Nonnull perials) {
        self.dataList = perials;
        [self.tableView reloadData];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotificationHandler];
    self.title = @"蓝牙";
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionFooterHeight = miniHeight;
    self.tableView.estimatedSectionHeaderHeight = miniHeight;
    [self.tableView registerClass:[TBPListTableCell class] forCellReuseIdentifier: cellIdentifier];
    [self.tableView registerClass:[TBPTableHeaderView class] forHeaderFooterViewReuseIdentifier: headerIdentifier];
    if (@available(iOS 13.0, *)) {
        self.tableView.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:244.0/255.0 alpha: 1];
    }
 
    
}

#pragma mark ============================ 监听蓝牙设备连接和断开的状态 ============================
- (void)addNotificationHandler{
    //监听蓝牙设备的连接状态
    [[NSNotificationCenter defaultCenter] addObserverForName: kkEVT_DEVICE_CONNECT_STATE object: nil queue: NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
}
//- (void)scanPrePeriDeviceAndConnect{
//    if(self.isconnect){
//        return;
//    }
//    [[NativeBlueToothManager shareInstance] retrieveConnectedPeripheralsWithServices:^(BOOL isFind) {
//        if(isFind){
//            self.isconnect = YES;
//        }
//    }];
//}
//获取数据源
- (NSArray<CBPeripheral *> *)dataList{
    if(nil == _dataList){
        _dataList =  [NSArray array];
    }
    return _dataList;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TBPTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier: headerIdentifier];
    headerView.titleStr = deviceListStr;
    return  headerView;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return miniHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return normalHeaderHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBPListTableCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    CBPeripheral *periheralModel = [self.dataList objectAtIndex: indexPath.row];
    //蓝牙的标题
    cell.textLabel.text = periheralModel.name;
    //是否连接
//    cell.detailTextLabel.textColor = cell.textLabel.textColor;
    BOOL isConnect = [[TBPBlueToothManager shareInstance] connectThePerpheralWith: periheralModel];
    if(isConnect){
        cell.detailTextLabel.text = @"已连接";
    }else{
        cell.detailTextLabel.text = @"未连接";
    }
    //是否能进入蓝牙设备详情
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
//    详情图标，点击事件
//    cell.accessoryAction
    return cell;
}

//点击cell右边的详情页事件
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
//    __weak BlueToothListTableVC *weakSelf = self;
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle: UIAlertControllerStyleAlert];
//    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakSelf.navigationController popViewControllerAnimated: true];
//    }];
//    [alertController addAction: sureAction];
//    [self presentViewController: alertController animated:YES completion: nil];
    CBPeripheral *periheralModel = [self.dataList objectAtIndex: indexPath.row];
    TBPDetailTableVC *detailVC = [[TBPDetailTableVC alloc] init];
    detailVC.peripheral = periheralModel;
    [self.navigationController pushViewController: detailVC animated: YES];
    
}
//选中cell开始连接
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    CBPeripheral *periheralModel = [self.dataList objectAtIndex: indexPath.row];
    [[TBPBlueToothManager shareInstance] connect:periheralModel.identifier.UUIDString];
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
