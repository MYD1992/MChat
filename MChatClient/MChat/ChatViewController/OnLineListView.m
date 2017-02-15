//
//  OnLineListView.m
//  MChat
//
//  Created by 林涛 on 2017/2/7.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import "OnLineListView.h"

@interface OnLineListViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView * headView;
@property (nonatomic, strong) UILabel * userNameLB;
@property (nonatomic, strong) UILabel * msNumberLB;
@property (nonatomic, strong) UIView * lineView;
-(void)setUserInfo:(NSDictionary *)userInfo;
@end

@implementation OnLineListViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

-(UIImageView *)headView{
    if (_headView == nil) {
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        _headView.layer.cornerRadius = 15;
        _headView.layer.masksToBounds = YES;
        [self.contentView addSubview:_headView];
    }
    return _headView;
}

-(UILabel *)userNameLB{
    if (!_userNameLB) {
        _userNameLB = [[UILabel alloc] initWithFrame:CGRectMake(50, 12.5, 95, 25)];
        _userNameLB.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_userNameLB];
    }
    return _userNameLB;
}

-(UILabel *)msNumberLB{
    if (!_msNumberLB) {
        _msNumberLB = [[UILabel alloc] initWithFrame:CGRectMake(150, 16, 18, 18)];
        _msNumberLB.font = [UIFont systemFontOfSize:12];
        _msNumberLB.textAlignment = NSTextAlignmentCenter;
        _msNumberLB.backgroundColor = [UIColor redColor];
        _msNumberLB.textColor = [UIColor whiteColor];
        _msNumberLB.layer.masksToBounds = YES;
        _msNumberLB.layer.cornerRadius = 9;
        _msNumberLB.text = @"88";
        [self.contentView addSubview:_msNumberLB];
    }
    return _msNumberLB;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, 180, 0.5)];
        _lineView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    }
    return _lineView;
}

-(void)setUserInfo:(NSDictionary *)userInfo{
    self.headView.image = [UIImage imageNamed:userInfo[@"image"]];
    self.userNameLB.text = userInfo[@"name"];
    [self.contentView addSubview:self.msNumberLB];
    if ([userInfo[@"newMsg"] isEqual:[NSNull null]]) {
        _msNumberLB.hidden = YES;
    }else {
        self.msNumberLB.text = [NSString stringWithFormat:@"%ld",[userInfo[@"newMsg"] count]];
    }
}


@end



@interface OnLineListView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation OnLineListView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tableView];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
    }
    return self;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        [_tableView registerClass:[OnLineListViewCell class] forCellReuseIdentifier:@"OnLineListViewCell"];
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
    }
    return _tableView;
}

-(void)setUsers:(NSMutableArray<NSDictionary *> *)users{
    _users = users;
    [self.tableView reloadData];
}

-(void)showWithFrame:(CGRect)frame{
    self.isShow = !self.isShow;
    self.frame = frame;
    self.tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void)hide{
    self.isShow = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectZero;
    }];
}

-(void)reload{
    [self.tableView reloadData];
}
#pragma mark --TableViewDelegate--
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OnLineListViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OnLineListViewCell"
                                                                forIndexPath:indexPath];
    NSDictionary * userInfo = [self.users objectAtIndex:indexPath.row];
    [cell setUserInfo:userInfo];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectCallBack) {
        self.selectCallBack(indexPath.row);
    }
}
@end
