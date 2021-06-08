//
//  BlueToothDetailTableVC.m
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/3.
//

#import "TBPDetailTableVC.h"
#import "TBPBlueToothManager.h"
#import "TBPListTableCell.h"
#import "TBPTableHeaderView.h"
#import "TBPBlueToothCoconut.h"
#import "TBPCachePerInfoManager.h"

static NSString *cellIdentifier = @"UITableViewCell";

static NSString *headerIdentifier = @"BlueToothHeaderView";
static CGFloat normalHeaderHeight = 44;

static CGFloat miniHeight = 0.01;
static CGFloat cellHeaderHeight = 44.0;

static NSString *deviceListStr = @"关于";

static NSString *perName = @"型号名称";
static NSString *perCode = @"型号号码";
static NSString *perMac = @"序列号";
static NSString *perVersion = @"版本";

static NSString *ignorTitle = @"断开连接";
static NSString *removeTitle = @"忽略";



@interface TBPDetailTableVC ()
@property (nonatomic, assign)NSInteger sectionCount;
@property (nonatomic, strong)NSArray<BlueToothDetailSectionModel *> *datasourceList;
@end

@implementation TBPDetailTableVC

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    [self reloadnumberOfSections];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.peripheral.name;
    [self addNotificationHandler];
    self.sectionCount = 0;
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
    [self reloadnumberOfSections];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (NSArray<BlueToothDetailSectionModel *> *)datasourceList{
    if(_datasourceList == nil){
        _datasourceList = [NSArray array];
    }
    return _datasourceList;
}

#pragma mark ============================ 监听蓝牙设备连接和断开的状态 ============================
- (void)addNotificationHandler{
    //监听蓝牙设备的连接状态
    [[NSNotificationCenter defaultCenter] addObserverForName: kkEVT_DEVICE_CONNECT_STATE object: nil queue: NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [self reloadnumberOfSections];
    }];
}

//重构数据，刷新UI
- (void)reloadnumberOfSections{
    [self combinaData];
    [self.tableView reloadData];
}

//判断当前蓝牙设备是否在缓存
- (BOOL)isContainTheLocal{
    NSArray *locals = [[TBPCachePerInfoManager shareInstance] localList];
    for(NativeCacheModel *cacheModel in locals){
        if([cacheModel.uuidString isEqualToString: self.peripheral.identifier.UUIDString]){
            return YES;
        }
    }
    return NO;
}

//数据构造
- (void)combinaData{
    //是否连接上设备
    BOOL isConnect = [[TBPBlueToothManager shareInstance] connectThePerpheralWith: self.peripheral];
    //本地是否有缓存
    BOOL isLocal = [self isContainTheLocal];
    
    NSMutableArray *list = [NSMutableArray array];
    //蓝牙信息
    BlueToothDetailSectionModel *sectionModel = [BlueToothDetailSectionModel new];
    sectionModel.title = deviceListStr;
    sectionModel.height = normalHeaderHeight;

    //蓝牙名称
    BlueToothDetailModel *itemModel = [BlueToothDetailModel new];
    itemModel.title = perName;
    itemModel.detail = self.peripheral.name;
    itemModel.height = cellHeaderHeight;
    itemModel.detaType = BlueToothDetailModelDataTypeName;
    //蓝牙uuid
    BlueToothDetailModel *itemModel1 = [BlueToothDetailModel new];
    itemModel1.title = perMac;
    itemModel1.detail = self.peripheral.identifier.UUIDString;
    itemModel1.height = cellHeaderHeight;
    itemModel1.detaType = BlueToothDetailModelDataTypeUUID;

    sectionModel.detailList = @[itemModel, itemModel1];
    [list addObject: sectionModel];
    if(isConnect || isLocal){ //断开蓝牙或者忽略
        
        BlueToothDetailSectionModel *desectionModel = [BlueToothDetailSectionModel new];
        desectionModel.title = nil;
        desectionModel.height = normalHeaderHeight;
        NSMutableArray *detaillist = [NSMutableArray array];
        if(isConnect){
            //断开设备
            BlueToothDetailModel *itemModel = [BlueToothDetailModel new];
            itemModel.title = ignorTitle;
            itemModel.detail = nil;
            itemModel.height = cellHeaderHeight;
            itemModel.detaType = BlueToothDetailModelDataTypeDISCONNECT;

            [detaillist addObject: itemModel];
        }
        if(isLocal){
            //忽略
            BlueToothDetailModel *itemModelig = [BlueToothDetailModel new];
            itemModelig.title = removeTitle;
            itemModelig.detail = nil;
            itemModelig.height = cellHeaderHeight;
            itemModelig.detaType = BlueToothDetailModelDataTypeIGNORE;
            [detaillist addObject: itemModelig];
        }
        
        desectionModel.detailList = [NSArray arrayWithArray: detaillist];
        [list addObject: desectionModel];
    }
    self.datasourceList = list;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasourceList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BlueToothDetailSectionModel *sectionModel = self.datasourceList[section];
    return sectionModel.detailList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TBPTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier: headerIdentifier];
    BlueToothDetailSectionModel *sectionModel = self.datasourceList[section];
    headerView.titleStr = sectionModel.title;
    return  headerView;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    BlueToothDetailSectionModel *sectionModel = self.datasourceList[section];
    return sectionModel.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return miniHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BlueToothDetailSectionModel *sectionModel = self.datasourceList[indexPath.section];
    BlueToothDetailModel *model = sectionModel.detailList[indexPath.row];
    return model.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TBPListTableCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath:indexPath];
    BlueToothDetailSectionModel *sectionModel = self.datasourceList[indexPath.section];
    BlueToothDetailModel *model = sectionModel.detailList[indexPath.row];
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.detail;
    if (@available(iOS 13.0, *)) {
        cell.textLabel.textColor = UIColor.labelColor;
    } else {
        // Fallback on earlier versions
        cell.textLabel.textColor = [UIColor blackColor];
    }

    //样式文字样式
    if(model.detaType == BlueToothDetailModelDataTypeIGNORE || model.detaType == BlueToothDetailModelDataTypeDISCONNECT){
        if (@available(iOS 13.0, *)) {
            cell.textLabel.textColor = UIColor.systemBlueColor;
        } else {
            // Fallback on earlier versions
            cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:0.48 blue:1 alpha:1];
        }
    }

    return cell;
}

//选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    BlueToothDetailSectionModel *sectionModel = self.datasourceList[indexPath.section];
    BlueToothDetailModel *model = sectionModel.detailList[indexPath.row];
    
    //忽略本地缓存
    if(model.detaType == BlueToothDetailModelDataTypeIGNORE ){
        [[TBPCachePerInfoManager shareInstance] removeCachePeripheral: self.peripheral.identifier.UUIDString];
        [self reloadnumberOfSections];
    }
    
    //断开连接
    if(model.detaType == BlueToothDetailModelDataTypeDISCONNECT){
        if(![[TBPBlueToothManager shareInstance] connectThePerpheralWith: self.peripheral]){
            return;
        }
        [self disconnectThePeripheralAction];
    }
    
}

#pragma mark ============================ Action ============================
//关闭蓝牙连接
- (void)disconnectThePeripheralAction{
    [[TBPBlueToothManager shareInstance] disconnect];
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
/*
 @interface BlueToothDetailModel : NSObject

 */

@implementation BlueToothDetailModel

@end

@implementation BlueToothDetailSectionModel

@end
