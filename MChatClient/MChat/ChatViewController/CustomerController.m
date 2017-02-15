//
//  AppDelegate.h
//  聊天界面
//
//  Created by  王伟 on 2016/12/4.
//  Copyright © 2016年  王伟. All rights reserved.
//

#import "CustomerController.h"
#import "MessageCell.h"
#import "HCInputBar.h"
#import "MessageImageCell.h"
#import "showImgView.h"
#import "OnLineListView.h"
#import "LTBarButtonItem.h"
#define SCREENWIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT     [UIScreen mainScreen].bounds.size.height
@interface CustomerController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) HCInputBar *inputBar;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *MessageArr;

@property (nonatomic,strong) UIView *inputView;
@property (nonatomic,strong) UITextView *inputTextView;
@property (nonatomic,strong) UIButton *sendBtn;

@property (nonatomic,strong) UIButton *statusBtn;

@property (nonatomic,assign) BOOL Temp;

@property (nonatomic,strong) UIImagePickerController *picker;

@property (nonatomic, strong) NSMutableArray * users;

@property (nonatomic, strong) OnLineListView * friendListView;

@property (nonatomic, strong) UIView * backView;

@property (nonatomic, strong) NSMutableDictionary * offMsgs;

@property (nonatomic, strong) LTBarButtonItem * leftBarButton;

@property (nonatomic, strong) LTBarButtonItem * rightBarButton;

@property (nonatomic, assign) NSInteger offMessageNumber;

@property (nonatomic, assign) NSInteger otherMessageNumber;
@end

@implementation CustomerController
static NSString *identifier = @"Cell";
static NSString *identifierMessageImageCell = @"MessageImageCell";
-(NSMutableArray *)MessageArr {
    if (!_MessageArr) {
        _MessageArr = [NSMutableArray array];
    }
    return _MessageArr;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(openKeyboard:)
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getNewMessage:)
                                                 name:SockReceiveNewDataNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reconnect:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    if (self.isRoomChat == YES) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(getFriends)
//                                                     name:UIApplicationDidBecomeActiveNotification
//                                                   object:nil];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isRoomChat) {
        self.navigationItem.rightBarButtonItem = [self rightButton];
        [self.navigationItem.rightBarButtonItem setBackButtonBackgroundVerticalPositionAdjustment:120 forBarMetrics:UIBarMetricsCompact];
    }
    self.navigationItem.leftBarButtonItem = [self leftButton];
    if (_isRoomChat) {
        self.title = @"聊天室";
    }else{
        self.title = _friendName;
    }
    [self createPicker];
    [self createTableView];
    [self.view addSubview:self.tableView];
    [self setInputConfig];
    [self.view addSubview:self.inputBar];
    if (self.isRoomChat) {
       [self getFriends];
    }
    [self.view addSubview:self.friendListView];
    [self addOffMsg];
}

-(NSMutableArray *)users{
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}

-(OnLineListView *)friendListView{
    if (!_friendListView) {
        _friendListView = [[OnLineListView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 10, 70, 0, 0)];
        _friendListView.users = self.users;
        __weak CustomerController * weakSelf = self;
        [_friendListView setSelectCallBack:^(NSInteger idx){
            [weakSelf callBack:idx];
        }];
        [self.view addSubview:_friendListView];
    }
    
    return _friendListView;
}

-(UIView *)backView{
    if (_backView == nil) {
        _backView = [[UIView alloc] initWithFrame:self.view.frame];
        _backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFriends)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

-(UIBarButtonItem *)leftButton{
    UIBarButtonItem * item;
    if(_isRoomChat){
        item = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    }else{
        _leftBarButton = [[LTBarButtonItem alloc] initWithTarget:self action:@selector(exit) image:[UIImage imageNamed:@"back"]];
        item = [[UIBarButtonItem alloc] initWithCustomView:_leftBarButton];
    }
    return item;
}

-(UIBarButtonItem *)rightButton{
    _rightBarButton = [[LTBarButtonItem alloc] initWithTarget:self action:@selector(showFriends) image:[UIImage imageNamed:@"Category"]];
    [_rightBarButton setVerticalPositionAdjustment:5];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButton];
    return item;
}

-(void)addOffMsg{
    if ([_offMsg isKindOfClass:[NSArray class]]&&_offMsg.count != 0) {
        [_offMsg enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString * from = obj[@"from"];
            NSString * content = obj[@"msg"];
            Message * message = [Message messageWihtContent:content isRight:NO];
            message.userName = from;
            message.headImageName = self.friendImage;
            [self.MessageArr addObject:message];
        }];
        [self.tableView reloadData];
        [self scrollToBottom];
    }
}

- (HCInputBar *)inputBar {
    if (!_inputBar) {
        
        _inputBar = [[HCInputBar alloc]initWithStyle:DefaultInputBarStyle];
        
        _inputBar.keyboard.showAddBtn = NO;
        
        _inputBar.placeHolder = @"输入新消息";
    }
    return _inputBar;
}

-(NSMutableDictionary *)offMsgs{
    if (_offMsgs == nil) {
        _offMsgs = [NSMutableDictionary dictionary];
    }
    return _offMsgs;
}

-(void)createPicker{
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker.delegate = self;
}

-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:identifier];
    [self.tableView registerClass:[MessageImageCell class] forCellReuseIdentifier:identifierMessageImageCell];
}

-(void)setInputConfig{
    __block typeof(self) weakSelf = self;
    self.inputBar.chooseImages = ^{
        [weakSelf presentViewController:weakSelf.picker animated:YES completion:nil];
    };
    [self.inputBar showInputViewContents:^(NSString *contents) {
        contents = [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (contents.length == 0) {
            [self.view makeToast:@"输入的内容不能为空!" duration:2 position:CSToastPositionBottom];
            return ;
        }
        __block Message *msg = [Message messageWihtContent:contents isRight:YES];
        msg.userName = self.userName;
        msg.isError = NO;
        msg.headImageName = self.userImage;
        [self.MessageArr addObject:msg];
        [self.tableView reloadData];
        [self scrollToBottom];
        SockManager * manager = [SockManager shareManager];
        NSDictionary * sendDic;
        if (_isRoomChat) {
            sendDic = @{@"handle":@"chat",@"msg":contents,@"from":self.userName,@"to":[NSNull null]};
        }else{
            sendDic = @{@"handle":@"chat",@"msg":contents,@"from":self.userName,@"to":self.friendName};
        }
        [manager sendData:sendDic withBack:^(id response) {
            if (![response[@"code"] isEqual:@(8888)]) {
                NSInteger idx = [self.MessageArr indexOfObject:msg];
                [self.MessageArr removeObject:msg];
                msg.isError = YES;
                [self.MessageArr insertObject:msg atIndex:idx];
                [self.tableView reloadData];
            }
        }];
    }];
}

-(void)getFriends{
    NSDictionary * dict = @{@"handle":@"getFriend",@"name":self.userName};
    SockManager * manager = [SockManager shareManager];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [manager sendData:dict withBack:^(id response) {
        if (![response isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSDictionary * dict = response;
        NSArray <NSDictionary *> * users = dict[@"users"];
        _offMessageNumber = 0;
        __block NSInteger _idx = -1;
        [users enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString * image = [NSString stringWithFormat:@"user_%d",arc4random()%13];
            if ([obj[@"name"] isEqualToString:@"all"]) {//过滤群聊信息
                _idx = idx;
                return ;
            }
            if ([obj[@"name"] isEqualToString:self.userName]) {
                return;
            }
            NSDictionary * dict = @{
                                    @"name":obj[@"name"],
                                    @"image":image,
                                    @"newMsg":obj[@"newMsg"]!=nil?obj[@"newMsg"]:[NSNull null]
                                    };
            if (![obj[@"newMsg"] isEqual:[NSNull null]]) {
                _offMessageNumber = _offMessageNumber + [obj[@"newMsg"] count];
            }
            [self.users addObject:dict];
        }];
        if (_idx != -1) {
            NSDictionary * roomMsgDic = users[_idx];//处理离线群聊信息
            if ([roomMsgDic[@"newMsg"] isKindOfClass:[NSArray class]]&&[roomMsgDic[@"newMsg"] count] > 0) {
                NSArray * roomMsgs = roomMsgDic[@"newMsg"];
                [roomMsgs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString * from = obj[@"from"];
                    NSString * content = obj[@"msg"];
                    __block NSString * userImage;
                    [self.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj[@"name"] isEqualToString:from]) {
                            userImage = obj[@"image"];
                        }
                    }];
                    Message * newmssage = [Message messageWihtContent:content isRight:NO];
                    newmssage.isError = NO;
                    newmssage.headImageName = userImage;
                    newmssage.userName = from;
                    [self.MessageArr addObject:newmssage];
                    
                }];
            }
            [self.tableView reloadData];
            [self scrollToBottom];
        }
        [self.rightBarButton setNumber:_offMessageNumber];
        self.friendListView.users = self.users;
    }];
}

-(void)getNewMessage:(NSNotification *)notification{
    NSDictionary * message = notification.userInfo;
    NSString * from = message[@"from"];
    NSString * content = message[@"msg"];
    NSString * to = message[@"to"];
    __block NSString * userImage;
    if ([self.title isEqualToString:from]) {
        userImage = self.friendImage;
    }else{
        [self.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"name"] isEqualToString:from]) {
                userImage = obj[@"image"];
            }
        }];
    }
    if (from.length != 0 && content.length != 0) {
        if ([to isEqual:[NSNull null]]||to == nil||[to isEqualToString:@"all"]) {//群聊消息
            if([self.title isEqualToString:@"聊天室"]){//在群聊界面
                Message * newmssage = [Message messageWihtContent:content isRight:NO];
                newmssage.isError = NO;
                newmssage.headImageName = userImage;
                newmssage.userName = from;
                [self.MessageArr addObject:newmssage];
                [self.tableView reloadData];
                [self scrollToBottom];
            }else{//在私聊界面
                if (_NewMessageCallBack) {
                    _NewMessageCallBack(notification.userInfo, YES);
                }
            }
        }else{//私聊消息
            if([self.title isEqualToString:@"聊天室"]){//在群聊界面
                __block NSMutableDictionary * fromObj;
                __block NSInteger _idx = -1;
                [self.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj[@"name"] isEqualToString:from]) {
                        fromObj = [NSMutableDictionary dictionaryWithDictionary:obj];
                        _idx = idx;
                        *stop = YES;
                    }
                }];
                NSMutableArray * offMessage = fromObj[@"newMsg"];
                if ([offMessage isEqual:[NSNull null]]||offMessage == nil) {
                    offMessage = [NSMutableArray array];
                }
                [offMessage addObject:message];
                NSMutableDictionary * newObj;
                if (fromObj!=nil&&![from isEqual:[NSNull null]]) {
                    newObj = [fromObj mutableCopy];
                }else{
                    newObj = [NSMutableDictionary dictionary];
                }
                newObj[@"newMsg"] = offMessage;
                _idx!=-1?[self.users replaceObjectAtIndex:_idx withObject:newObj]:[self.users addObject:newObj];
                self.friendListView.users = self.users;
                [self.friendListView reload];
                _offMessageNumber ++;
                [self.rightBarButton setNumber:_offMessageNumber];
            }else{//在私聊界面
                if([from isEqualToString:self.friendName]){//当前用户发送的消息
                    Message * newmssage = [Message messageWihtContent:content isRight:NO];
                    newmssage.isError = NO;
                    newmssage.headImageName = userImage;
                    newmssage.userName = from;
                    [self.MessageArr addObject:newmssage];
                    [self.tableView reloadData];
                    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.MessageArr.count - 1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
                }else{
                    if (_NewMessageCallBack) {
                        _NewMessageCallBack(notification.userInfo, NO);
                        _otherMessageNumber++;
                        [self.leftBarButton setNumber:_otherMessageNumber];
                    }
                }
            }
        }
    }
}

-(void)callBack:(NSInteger)idx{
    NSMutableDictionary * user = [NSMutableDictionary dictionaryWithDictionary: self.users[idx]];
    NSString * name = user[@"name"];
    NSString * image = user[@"image"];
    NSArray * newMsg = user[@"newMsg"];
    CustomerController * oneToOneVC = [[CustomerController alloc] init];
    oneToOneVC.userName = self.userName;
    oneToOneVC.userImage = self.userImage;
    oneToOneVC.friendName = name;
    oneToOneVC.friendImage = image;
    oneToOneVC.offMsg = newMsg;
    [oneToOneVC setNewMessageCallBack:^(NSDictionary * newMessage, BOOL isRoomChat) {
        NSString * from = newMessage[@"from"];
        NSString * content = newMessage[@"msg"];
        if (isRoomChat) {
            __block NSString * userImage ;
            [self.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"name"] isEqualToString:newMessage[@"from"]]) {
                    userImage = obj[@"image"];
                }
            }];
            Message * newmssage = [Message messageWihtContent:content isRight:NO];
            newmssage.isError = NO;
            newmssage.headImageName = userImage;
            newmssage.userName = newMessage[@"from"];
            [self.MessageArr addObject:newmssage];
            [self.tableView reloadData];
            [self scrollToBottom];
        }else{
            __block NSMutableDictionary * fromObj;
            __block NSInteger _idx = -1;;
            [self.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"name"] isEqualToString:from]) {
                    fromObj = [NSMutableDictionary dictionaryWithDictionary:obj];
                    _idx = idx;
                }
            }];
            NSMutableArray * offMessage = [NSMutableArray array];
            if (![fromObj[@"newMsg"] isEqual:[NSNull null]]&&fromObj!=nil) {
                [offMessage addObject:newMessage];
            }
            NSMutableDictionary * newObj ;
            if (![fromObj isEqual:[NSNull null]]&&fromObj!=nil) {
                newObj = [fromObj mutableCopy];
            }else{
                newObj = [NSMutableDictionary dictionary];
            }
            newObj[@"newMsg"] = offMessage;
            _idx==-1?[self.users addObject:newObj]:[self.users replaceObjectAtIndex:_idx withObject:offMessage];
            self.friendListView.users = self.users;
            [self.friendListView reload];
            _offMessageNumber ++;
            [self.rightBarButton setNumber:_offMessageNumber];
        }
    }];
    [oneToOneVC setAPPBecomeActivity:^(NSString * name, void (^NewMessageCallBack)(NSArray * message)) {
        NSDictionary * dict = @{@"handle":@"getNewMessage",@"name":self.userName};
        SockManager * manager = [SockManager shareManager];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [manager sendData:dict withBack:^(id response) {
            if (![response isKindOfClass:[NSDictionary class]]) {
                return ;
            }
            NSInteger  (^getUser)(NSString *) = ^(NSString * name) {
                __block NSInteger _idx = -1;
                [self.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj[@"name"] isEqualToString:name]) {
                        _idx = idx;
                    }
                }];
                return _idx;
            };
            NSDictionary * responseDic = response[@"newMsg"];
            if (responseDic == nil||[responseDic isEqual:[NSNull null]]) {
                return;
            }
            [responseDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull _obj, BOOL * _Nonnull stop) {
                if ([key isEqualToString:@"all"]) {//群聊消息
                    if ([_obj isKindOfClass:[NSArray class]]&&[_obj count] != 0) {
                        [_obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            Message * message = [Message messageWihtContent:obj[@"msg"] isRight:NO];
                            message.userName = obj[@"from"];
                            NSDictionary * userDic = self.users[getUser(obj[@"from"])];
                            message.headImageName = userDic[@"image"];
                            [self.MessageArr addObject:message];
                        }];
                    }
                }else if([key isEqualToString:name]){//私聊消息
                    if([_obj isKindOfClass:[NSArray class]]&&[_obj count] != 0){
                        NewMessageCallBack(_obj);
                    }
                }else{//私聊消息
                    if([_obj isKindOfClass:[NSArray class]]&&[_obj count] != 0){
                        NSMutableDictionary * userDic = self.users[getUser(key)];
                        NSMutableArray * msgArray = userDic[@"newMsg"] ;
                        if([msgArray isEqual:[NSNull null]]||msgArray == nil){
                            msgArray = [NSMutableArray array];
                        }
                        [msgArray addObjectsFromArray:_obj];
                        [self.users replaceObjectAtIndex:getUser(key) withObject:msgArray];
                        _offMessageNumber += [_obj count];
                    }
                }
            }];
            
            [self.rightBarButton setNumber:_offMessageNumber];
            self.friendListView.users = self.users;
            __block NSInteger _idx = -1;
            [self.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"name"] isEqualToString:name]) {
                    _idx = idx;
                }
            }];
            if (_idx != -1) {
                NSDictionary * dict = self.users[_idx];
                if ([dict[@"newMsg"] isKindOfClass:[NSArray class]]&&[dict[@"newMsg"] count] != 0) {
                    NewMessageCallBack(dict[@"newMsg"]);
                }
            }
        }];
    }];
    [self.navigationController pushViewController:oneToOneVC animated:YES];
    if (![newMsg isEqual:[NSNull null]]) {
        self.offMessageNumber = self.offMessageNumber - newMsg.count;
    }
    [self.rightBarButton setNumber:self.offMessageNumber];
    user[@"newMsg"] = [NSNull null];
    [self.users replaceObjectAtIndex:idx withObject:user];
    self.friendListView.users = self.users;
    [self.friendListView reload];
    [self.friendListView showWithFrame:CGRectMake(SCREENWIDTH - 10, 70, 0, 0)];
    [self.backView removeFromSuperview];
}

-(void)reconnect:(NSNotification *)notification{
    if (!self.isRoomChat) {
        if (self.APPBecomeActivity) {
            self.APPBecomeActivity(self.friendName,^(NSArray * newMessages){
                [newMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString * content = obj[@"msg"];
                    NSString * from = obj[@"from"];
                    Message * newmssage = [Message messageWihtContent:content isRight:NO];
                    newmssage.isError = NO;
                    newmssage.headImageName = self.friendImage;
                    newmssage.userName = from;
                    [self.MessageArr addObject:newmssage];
                }];
            });
        }
    }else{
        NSDictionary * dict = @{@"handle":@"getNewMessage",@"name":self.userName};
        SockManager * manager = [SockManager shareManager];
        [manager sendData:dict withBack:^(id response) {
            if (![response isKindOfClass:[NSDictionary class]]) {
                return ;
            }
            NSInteger  (^getUser)(NSString *) = ^(NSString * name) {
                __block NSInteger _idx = -1;
                [self.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj[@"name"] isEqualToString:name]) {
                        _idx = idx;
                    }
                }];
                return _idx;
            };
            NSDictionary * responseDic = response[@"newMsg"];
            if (responseDic == nil||[responseDic isEqual:[NSNull null]]) {
                return;
            }
            [responseDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull _obj, BOOL * _Nonnull stop) {
                if ([key isEqualToString:@"all"]) {//群聊消息
                    if ([_obj isKindOfClass:[NSArray class]]&&[_obj count] != 0) {
                        [_obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            Message * message = [Message messageWihtContent:obj[@"msg"] isRight:NO];
                            message.userName = obj[@"from"];
                            NSDictionary * userDic = self.users[getUser(obj[@"from"])];
                            message.headImageName = userDic[@"image"];
                            [self.MessageArr addObject:message];
                        }];
                    }
                }else{//私聊消息
                    if([_obj isKindOfClass:[NSArray class]]&&[_obj count] != 0){
                        NSMutableDictionary * userDic = self.users[getUser(key)];
                        NSMutableArray * msgArray;
                        if([userDic[@"newMsg"] isEqual:[NSNull null]]||userDic[@"newMsg"] == nil){
                            msgArray = [NSMutableArray array];
                        }else{
                            msgArray = [NSMutableArray arrayWithArray:msgArray];
                        }
                        [msgArray addObjectsFromArray:_obj];
                        [self.users replaceObjectAtIndex:getUser(key) withObject:msgArray];
                        _offMessageNumber += [_obj count];
                    }
                }
            }];
            [self.rightBarButton setNumber:_offMessageNumber];
            self.friendListView.users = self.users;
            [self.tableView reloadData];
            [self scrollToBottom];
            
        }];
    }
    
}

-(void)scrollToBottom{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.MessageArr.count > 0) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.MessageArr.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

-(void)showFriends{
    CGRect rect;
    if (self.friendListView.isShow) {
        rect = CGRectMake(SCREENWIDTH - 10, 70, 0, 0);
    }else{
        if (self.users.count < 5){
            rect = CGRectMake(SCREENWIDTH - 190, 70, 180, self.users.count * 50);
        }else{
            rect = CGRectMake(SCREENWIDTH - 190, 70, 180, 250);
        }
        [self.view addSubview:self.backView];
        [self.view bringSubviewToFront:self.friendListView];
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.friendListView showWithFrame:rect];
    } completion:^(BOOL finished) {
        if (!self.friendListView.isShow) {
            [self.backView removeFromSuperview];
        }
    }];
}


-(void)exit{
    if (_isRoomChat) {
        SockManager * manager = [SockManager shareManager];
        NSDictionary * disconDic = @{@"handle":@"exit",@"name":self.userName};
        [manager sendData:disconDic withBack:^(id response) {
            [self.view makeToast:@"已退出" duration:1 position:CSToastPositionBottom];
        }];
    }
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)openKeyboard:(NSNotification*)notification{
    
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    NSTimeInterval durition = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    UIViewAnimationOptions option = [notification.userInfo [UIKeyboardAnimationCurveUserInfoKey]intValue];
    [UIView animateWithDuration:durition delay:0 options:option animations:^{
        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50 - frame.size.height);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.MessageArr.count - 1 inSection:0];
        if(self.MessageArr.count > 0){
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    } completion:nil];
}

-(void)closeKeyboard:(NSNotification*)notification{
    NSTimeInterval durition = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    UIViewAnimationOptions option = [notification.userInfo [UIKeyboardAnimationCurveUserInfoKey]intValue];
    [UIView animateWithDuration:durition delay:0 options:option animations:^{
        
        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50);
    } completion:nil];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.MessageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    MessageImageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:identifierMessageImageCell];
    Message *msg = self.MessageArr[indexPath.row];
    
    if (msg.image != nil) {
        imageCell.message = msg;
        return imageCell;
    }
    cell.message = msg;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message *msg = self.MessageArr[indexPath.row];
    return msg.bounds.size.height;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    Message *msg = self.MessageArr[indexPath.row];
    if (msg.image != nil) {
        CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];//获取cell在tableView中的位置
        CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]];
        
        CGRect rect = CGRectMake(msg.imageFrame.origin.x, rectInSuperview.origin.y + msg.imageFrame.origin.y, msg.imageFrame.size.width, msg.imageFrame.size.height);
        
        
        showImgView *show = [showImgView initWithImg:msg.image withFame:rect];
        [[UIApplication sharedApplication].keyWindow addSubview:show];
    }

}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - UIImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    
    if (image != nil) {
        [self performSelector:@selector(SendImage:)  withObject:image afterDelay:0.5];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)SendImage:(UIImage *)image {
    if(_isRoomChat){//聊天室
        Message *msg = [Message messageWihtImage:image isRight:YES];
        [self.MessageArr addObject:msg];
        [self.tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.MessageArr.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }else{//私聊
        Message *msg = [Message messageWihtImage:image isRight:YES];
        [self.MessageArr addObject:msg];
        [self.tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.MessageArr.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}




@end
