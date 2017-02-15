//
//  RegistViewController.m
//  MChat
//
//  Created by 林涛 on 2017/2/4.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import "RegistViewController.h"
#import "CustomerController.h"

@interface RegistViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userCode;
@property (weak, nonatomic) IBOutlet UITextField *userCode2;

@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}

-(void)resignKeyboard{
    [self.userCode resignFirstResponder];
    [self.userName resignFirstResponder];
    [self.userCode2 resignFirstResponder];
}

- (IBAction)regist:(id)sender {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SockManager * manager = [SockManager shareManager];
    if (manager.getSockStatue == DISCONNECT) {
        [self.view makeToast:@"注册失败" duration:3 position:CSToastPositionBottom];
        return;
    }
    if(manager.getSockStatue == CONNECTING){
        return;
    }
    
    NSString * name = _userName.text;
    NSString * code = _userCode.text;
    NSString * code2 = _userCode2.text;
    
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (name.length == 0||code.length == 0||![code isEqualToString:code2]) {
        [self.view makeToast:@"输入的信息有误!" duration:3 position:CSToastPositionBottom];
        return;
    }
    
    NSDictionary * msgDic = @{@"handle":@"register",@"msg":@{@"name":name,@"code":code}};
    [manager sendData:msgDic withBack:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([response isKindOfClass:[NSDictionary class]]) {
                NSDictionary * dict = response;
                if ([dict[@"code"] isEqual:@(1009)]) {
                    [self.view makeToast:@"连接服务器失败" duration:2 position:CSToastPositionBottom];
                    return ;
                }
                if ([dict[@"code"] isEqual:@(1006)]) {
                    [self.view makeToast:@"改用户已存在" duration:2 position:CSToastPositionCenter];
                    return ;
                }
                if (![dict[@"code"] isEqual:@(8888)]) {
                    [self.view makeToast:@"注册失败!" duration:3 position:CSToastPositionBottom];
                    return ;
                }
                
                [self.view makeToast:@"注册成功!" duration:3 position:CSToastPositionBottom];
                CustomerController * CVC = [[CustomerController alloc] init];
                CVC.userName = name;
                int idx = arc4random() %13;
                UserModel * model = [UserModel shareModel];
                model.name = name;
                model.code = code;
                model.isOnline = YES;
                NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:name forKey:@"name"];
                [ud setObject:code forKey:@"code"];
                [ud synchronize];

                CVC.userImage = [NSString stringWithFormat:@"user_%d",idx];
                CVC.isRoomChat = YES;
                [self.navigationController pushViewController:CVC animated:YES];
            }
        });
    }];
    MBProgressHUD * progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progress.label.text = @"正在注册...";
}


@end
