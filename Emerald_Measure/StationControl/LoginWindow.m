//
//  LoginWindow.m
//  Emerald_Measure
//
//  Created by Michael on 2017/5/6.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "LoginWindow.h"

@interface LoginWindow ()
{
    NSMutableDictionary *m_Dic;
    
    __weak IBOutlet NSButton *SB_Button;
    
    __weak IBOutlet NSButton *CF_Button;
    
    __weak IBOutlet NSButton *ER_Button;
    
}
@end

@implementation LoginWindow

-(id)init
{
    self = [super initWithWindowNibName:@"LoginWindow"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserLogin" ofType:@"plist"];
    m_Dic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
}

- (IBAction)clickToLogin:(NSButton *)sender
{
    if ([_userName.stringValue isEqualToString:[m_Dic objectForKey:@"username"]] && [_passWord.stringValue isEqualToString:[m_Dic objectForKey:@"password"]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _messageLab.stringValue = @"enter !";
            _messageLab.textColor = [NSColor blueColor];
        
        });
        
        [self.window orderOut:self];
        
        //发送通知, 激活 PDCA 按钮功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PDCAButtonLimit_Notification" object:nil];
        
        //关闭StationControlWindow窗口的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseStationControlWindow_Notificcation" object:nil];
        
        
        if (SB_Button.state) {
            
            [[NSUserDefaults standardUserDefaults] setObject:@"SersonBoard" forKey:@"CurrentStationStatus"];
            [[NSUserDefaults standardUserDefaults] setObject:@"SB_Param" forKey:@"CurrentParam"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changePlistFileNotification" object:@"SersonBoard"];
        }
        if (CF_Button.state) {
            [[NSUserDefaults standardUserDefaults] setObject:@"CrownFlex" forKey:@"CurrentStationStatus"];
            [[NSUserDefaults standardUserDefaults] setObject:@"CF_Param" forKey:@"CurrentParam"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changePlistFileNotification" object:@"CrownFlex"];
        }
        if (ER_Button.state) {
            
            [[NSUserDefaults standardUserDefaults] setObject:@"Erbium" forKey:@"CurrentStationStatus"];
            [[NSUserDefaults standardUserDefaults] setObject:@"ER_Param" forKey:@"CurrentParam"];
            [[NSUserDefaults standardUserDefaults] synchronize];

             [[NSNotificationCenter defaultCenter] postNotificationName:@"changePlistFileNotification" object:@"Erbium"];
        }
        
        //切换之后直接关闭软件
        exit(1);
        
    }
    
    if ([_userName.stringValue isEqualToString:@"admin"] && [_passWord.stringValue isEqualToString:@"admin123"])
    {
         [self.window orderOut:self];
        
        //发送通知,激活按钮状态
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectButtonlimit_Notification" object:nil];
        
        //发送通知, 激活 PDCA 按钮功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PDCAButtonLimit_Notification" object:nil];
    }
    else if ([_userName.stringValue isEqualToString:@"op"]&&[_passWord.stringValue isEqualToString:@"op"]) {
        
        
        [self.window orderOut:self];
        
        //发送通知,激活按钮状态
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CancellButtonlimit_Notification" object:nil];
        
    }
    //新增无限循环测试
    else if([_userName.stringValue isEqualToString:@"unlimit"]&&[_passWord.stringValue isEqualToString:@"unlimit"])
    {
        
        [self.window orderOut:self];
        
        
       
        //发送通知, 激活无限循环测试功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TestUnLimit_Notification" object:nil];
        //发送通知, 激活 PDCA 按钮功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PDCAButtonLimit_Notification" object:nil];
        
    
    }
    
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _messageLab.stringValue = @"userName or passWord error!!";
            _messageLab.textColor = [NSColor redColor];
        });
    }
    
}

- (IBAction)clickToCancel:(NSButton *)sender
{
    // 4.关闭当前的登录窗口
    [self.window orderOut:self];
    
}


- (IBAction)SB_Station_Action:(id)sender {
    
    if (SB_Button.state == YES) {
        
        CF_Button.state = NO;
        
        ER_Button.state = NO;          
    }
    
    
    
}


- (IBAction)CF_Station_Action:(id)sender {
    
    
    if (CF_Button.state == YES) {
        
        SB_Button.state = NO;
        
        ER_Button.state = NO;
        
    }

   
}


- (IBAction)ER_Station_Action:(id)sender {
    
    if (ER_Button.state == YES) {
        
        SB_Button.state = NO;
        
        CF_Button.state = NO;
        
    }

}





@end
