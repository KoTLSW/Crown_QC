//
//  AppDelegate.m
//  Emerald_Measure
//
//  Created by Michael on 2017/4/24.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginWindow.h"
#import "ChooseWindowController.h"
#import "TestWindowController.h"

@interface AppDelegate ()
{
    LoginWindow *loginWindow;
    
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    //如果plist文件没有保存过，直接加载选择框
    
    
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"word"];
//    
//    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"word"] boolValue]) {
//        
//        chooseWindowController = [ChooseWindowController windowController];
//        
//        //2.强应用这个Window,不然这个Window会在跳转之后ide瞬间被销毁
//       AppDelegate * appdelegate = (AppDelegate*)[NSApplication sharedApplication].delegate;
//        appdelegate.mainWindowController = chooseWindowController;
//        //3.设为KeyWindow并前置
//        [chooseWindowController.window makeKeyAndOrderFront:self];
//        //4.关闭现在的登录窗口
//        //[chooseWindowController.window orderOut:self];
//
//    }
//    else
//    {
//        testWindowController = [TestWindowController windowController];
//        //2.强应用这个Window,不然这个Window会在跳转之后ide瞬间被销毁
//        AppDelegate * appdelegate = (AppDelegate*)[NSApplication sharedApplication].delegate;
//        appdelegate.mainWindowController = testWindowController;
//        //3.设为KeyWindow并前置
//        [testWindowController.window makeKeyAndOrderFront:self];
//        
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"word"];
//    
//    }
//    

    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)StationControl_Tool:(id)sender
{
    
    if (!loginWindow)
    {
        loginWindow = [[LoginWindow alloc] init];
    }
    
    [loginWindow showWindow:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableToSelectStationNoti" object:nil];
    
}

- (IBAction)OnSelectSingleTest:(id)sender {
   //selectOnCS
     [[NSNotificationCenter defaultCenter] postNotificationName:@"OnSelectSingleTest" object:nil];
    
}
- (IBAction)OffSelectSingleTest:(id)sender {
    //selectOnCS
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OffSelectSingleTest" object:nil];
    
}




@end
