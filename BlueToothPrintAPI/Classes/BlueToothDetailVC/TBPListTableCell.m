//
//  BlutToothListTableCell.m
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/3.
//

#import "TBPListTableCell.h"

@implementation TBPListTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: reuseIdentifier];
    if(self){
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = UIColor.tertiarySystemBackgroundColor;
        } else {
            // Fallback on earlier versions
//            self.contentView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:244.0/255.0 alpha: 1];
        }
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
