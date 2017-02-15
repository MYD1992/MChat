//
//  ViewController.m
//  MChat
//
//  Created by 林涛 on 2017/2/4.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import "ViewController.h"
#import "RegistViewController.h"
#import "CustomerController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userCode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}

-(void)resignKeyboard{
    [self.userName resignFirstResponder];
    [self.userCode resignFirstResponder];
}

- (IBAction)login:(id)sender {
    __block NSString * name = _userName.text;
    __block NSString * code = _userCode.text;
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (name.length == 0||code.length == 0) {
        [self.view makeToast:@"输入的信息有误" duration:2 position:CSToastPositionBottom];
        return;
    }
    
    NSDictionary * dict = @{@"msg":@{@"name":name,
                                     @"code":code},
                            @"handle":@"login"};
    
    SockManager * manager = [SockManager shareManager];
    [manager sendData:dict withBack:^(id response) {
        if([response isKindOfClass:[NSDictionary class]]){
            NSDictionary * respDic = response;
            if ([respDic[@"code"] isEqual:@(1009)]) {
                [self.view makeToast:@"连接服务器失败" duration:2 position:CSToastPositionBottom];
                return ;
            }
            if ([respDic[@"code"] isEqual:@(8888)]) {
                UserModel * model = [UserModel shareModel];
                model.name = name;
                model.code = code;
                model.isOnline = YES;
                NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:name forKey:@"name"];
                [ud setObject:code forKey:@"code"];
                [ud synchronize];
                CustomerController * CVC = [[CustomerController alloc] init];
                CVC.userName = name;
                int idx = arc4random() %13;
                NSString * image = [NSString stringWithFormat:@"user_%d",idx];
                CVC.userImage = image;
                CVC.isRoomChat = YES;
                [self.navigationController pushViewController:CVC animated:YES];
            }
        }
    }];
}

- (IBAction)regist:(id)sender {
    RegistViewController * registVC = [[RegistViewController alloc] init];
    [self.navigationController pushViewController:registVC animated:YES];
}


@end
