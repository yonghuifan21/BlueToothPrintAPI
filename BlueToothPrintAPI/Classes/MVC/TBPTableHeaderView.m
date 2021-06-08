//
//  BlueToothHeaderView.m
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/4.
//

#import "TBPTableHeaderView.h"
@interface TBPTableHeaderView()
@property (nonatomic, strong)UILabel *headerLabel;
@end
@implementation TBPTableHeaderView


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier: reuseIdentifier];
    if(self){
        [self setUI];
    }
    return self;
}

#pragma mark ============================ Initialize UI ============================
- (UILabel *)headerLabel{
    if(nil == _headerLabel){
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.font = [UIFont systemFontOfSize:16];
        _headerLabel.textColor = [UIColor blackColor];
        _headerLabel.textAlignment = NSTextAlignmentLeft;
        [_headerLabel sizeToFit];
    }
    return _headerLabel;
}
#pragma mark ============================ Set UI ============================

/// 布局子视图
- (void)setUI{
    if (@available(iOS 13.0, *)) {
        self.contentView.backgroundColor = UIColor.systemGroupedBackgroundColor;
        self.headerLabel.textColor = [UIColor labelColor];
    } else {
        // Fallback on earlier versions
        self.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:244.0/255.0 alpha: 1];
        self.headerLabel.textColor = [UIColor blackColor];
    }
    [self.contentView addSubview: self.headerLabel];
}

#pragma mark ============================ Layout Constant ============================

//商品选中按钮
static const CGFloat titleLeftMargin = 15;

static const CGFloat titleBottomMargin = 10;

#pragma mark ============================ Data Combina ============================
- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    self.headerLabel.text = titleStr;
}
#pragma mark ============================ Method/Action ============================
- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize headerSize = [self.headerLabel sizeThatFits:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 2*titleLeftMargin, self.bounds.size.height)];
    self.headerLabel.frame = CGRectMake(titleLeftMargin, self.bounds.size.height - titleBottomMargin - headerSize.height, headerSize.width, headerSize.height);
}
#pragma mark ============================ Other ============================

@end
