//
//  AppDelegate.h
//  聊天界面
//
//  Created by  王伟 on 2016/12/4.
//  Copyright © 2016年  王伟. All rights reserved.
//

#import "MessageCell.h"
#define CELL_MARGIN_TB  4.0
#define CELL_MARING_LR  10.0
#define CELL_CORNOR     18.0
#define CELL_TAIL_WIDTH 16.0
#define MAX_WIDTH_OF_TEXT  200.0
#define CELL_PADDING    8.0     
#define SCREENWIDTH     [UIScreen mainScreen].bounds.size.width
@interface MessageCell()
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic ,strong) UIImageView *popView;
@property (nonatomic ,strong) UILabel *messageLB;
@property (nonatomic, strong) UILabel *userNameLB;
@property (nonatomic, strong) UIImageView * errorImageView;
@end
@implementation MessageCell
-(UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [UIImageView new];
        _headerView.layer.cornerRadius = 15;
        _headerView.layer.masksToBounds = YES;
    }
    return _headerView;
}

-(UIImageView *)popView{
    if (!_popView) {
        _popView = [UIImageView new];
    }
    return _popView;
}
-(UILabel *)messageLB{
    if (!_messageLB) {
        _messageLB = [UILabel new];
        _messageLB.font = [UIFont systemFontOfSize:14];
        _messageLB.numberOfLines = 0;
    }
    return _messageLB;
}

-(UILabel *)userNameLB{
    if (!_userNameLB) {
        _userNameLB = [UILabel new];
        _userNameLB.font = [UIFont systemFontOfSize:12];
    }
    return _userNameLB;
}

-(UIImageView *)errorImageView{
    if (!_errorImageView) {
        _errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
    }
    return _errorImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}



- (void)setMessage:(Message *)message {
    _message = message;
    self.messageLB.text = message.content;
    self.bounds = _message.bounds;
    self.messageLB.frame = message.contentframe;
    self.headerView.frame = message.headerFrame;
    self.popView.frame = message.popframe;
    self.userNameLB.frame = message.userFrame;
    self.userNameLB.text = message.userName;
    UIImage * image = [UIImage imageNamed:message.headImageName];
    self.headerView.image =  image;
    self.errorImageView.frame = message.errorFrame;
    self.errorImageView.hidden = !message.isError;
    if (message.isRight) {
        self.messageLB.textColor = [UIColor whiteColor];
        self.popView.image = [[UIImage imageNamed:@"message_i"]resizableImageWithCapInsets:UIEdgeInsetsMake(CELL_CORNOR, CELL_CORNOR, CELL_CORNOR, CELL_CORNOR + CELL_TAIL_WIDTH)];
        self.userNameLB.textAlignment = NSTextAlignmentRight;
    } else {
        self.messageLB.textColor = [UIColor blackColor];
        self.popView.image = [[UIImage imageNamed:@"message_other"]resizableImageWithCapInsets:UIEdgeInsetsMake(CELL_CORNOR, CELL_CORNOR + CELL_TAIL_WIDTH, CELL_CORNOR, CELL_CORNOR)];
        self.userNameLB.textAlignment = NSTextAlignmentLeft;
    }
    [self.contentView addSubview:self.popView];
    [self.contentView addSubview:self.messageLB];
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.userNameLB];
    [self.contentView addSubview:self.errorImageView];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
}



@end
