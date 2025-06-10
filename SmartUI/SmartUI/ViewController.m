//
//  ViewController.m
//  SmartUI
//
//  Created by why on 2024/10/9.
//

#import "ViewController.h"
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import <insideSDK/SDKTestVC.h>


@interface ViewController ()
@property (nonatomic,strong) AVSpeechSynthesizer *synthsizer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initilizationUI];
    // Do any additional setup after loading the view.
}

-(void)initilizationUI{
    self.view.backgroundColor = [UIColor orangeColor];
    self.title = @"PBG";
    self.synthsizer = [[AVSpeechSynthesizer alloc]init];
    UIButton *request = [self createActionButtonWithTitle:@"请求" selector:@selector(requestTap:)];
    [self.view addSubview:request];
    [request mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(@30);
        make.right.equalTo(@-30);
        make.height.equalTo(@40);
    }];
    
    UIButton *pushConfig = [self createActionButtonWithTitle:@"消息设置" selector:@selector(configTap:)];
    [self.view addSubview:pushConfig];
    [pushConfig mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(request.mas_bottom);
        make.right.equalTo(@-30);
        make.height.equalTo(@40);
    }];
    
    UIButton *mine = [self createActionButtonWithTitle:@"我的" selector:@selector(mineTap:)];
    [self.view addSubview:mine];
    [mine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(pushConfig.mas_bottom);
        make.right.equalTo(@-30);
        make.height.equalTo(@40);
    }];
    
    UIButton *care = [self createActionButtonWithTitle:@"关爱模式" selector:@selector(careTap:)];
    [self.view addSubview:care];
    [care mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(mine.mas_bottom);
        make.right.equalTo(@-30);
        make.height.equalTo(@40);
    }];
    
    UIButton *sdk = [self createActionButtonWithTitle:@"SDK调用主工程能力" selector:@selector(sdkTap:)];
    [self.view addSubview:sdk];
    [sdk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(care.mas_bottom);
        make.right.equalTo(@-30);
        make.height.equalTo(@40);
    }];
    
    UIButton *ottAccount = [self createActionButtonWithTitle:@"OTT账号选择" selector:@selector(ottTap:)];
    [self.view addSubview:ottAccount];
    [ottAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(sdk.mas_bottom);
        make.right.equalTo(@-30);
        make.height.equalTo(@40);
    }];
    
    UIButton *sort = [self createActionButtonWithTitle:@"排序" selector:@selector(sortTap:)];
    [self.view addSubview:sort];
    [sort mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(ottAccount.mas_bottom);
        make.right.equalTo(@-30);
        make.height.equalTo(@40);
    }];
    
    UIButton *mp = [self createActionButtonWithTitle:@"小程序" selector:@selector(miniProgram:)];
    [self.view addSubview:mp];
    [mp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(sort.mas_bottom);
        make.right.equalTo(@-30);
        make.height.equalTo(@40);
    }];
}

-(UIButton *)createActionButtonWithTitle:(NSString *)title selector:(SEL)sel{
    UIButton *button = [[UIButton alloc]init];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

#pragma mark -- UIControlEvent

-(void)sortTap:(UIButton *)sender{
    SortListVC *vc = [[SortListVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)ottTap:(UIButton *)sender{
    UBOTTAccountListVC *vc = [[UBOTTAccountListVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)sdkTap:(UIButton *)sender{
    SDKTestVC *vc = [[SDKTestVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)mineTap:(UIButton *)sender{
    MineVC *vc = [[MineVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    NSString *encryptedString = @"jqp0nsbu8AvqTtr3/xKT9Q==";  // 示例密文（base64 编码）
    NSString *key = @"CdOuDmJpLZkJPaE6";  // 解密密钥
    NSString *decryptedString = [CommonUtils decryptAES128WithBase64String:encryptedString key:key];
    if (decryptedString != nil) {
        NSLog(@"Decrypted String: %@", decryptedString);
    } else {
        NSLog(@"Decryption failed");
    }
}

-(void)requestTap:(UIButton *)sender{
    RequstVC *vc = [[RequstVC alloc]init];
    
    [self.navigationController presentViewController:vc animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            RequstVC *vc2 = [[RequstVC alloc]init];
            [self.navigationController presentViewController:vc2 animated:YES completion:^{
                
            }];
        });
    }];
    
//    [self.navigationController pushViewController:vc animated:YES];
}

-(void)configTap:(UIButton *)sender{
    PushConfigVC *vc = [[PushConfigVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)careTap:(UIButton *)sender{
    CareViewController *vc = [[CareViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)miniProgram:(UIButton *)sender{
    MiniProgremVC *vc = [[MiniProgremVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(AVSpeechUtterance *)getSpeechUtteranceWithString:(NSString *)string{
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:string  ];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    return utterance;
}

@end
