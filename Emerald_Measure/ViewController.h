//
//  ViewController.h
//  MK_TestingModel_Sample
//
//  Created by Michael on 16/11/10.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSTextViewDelegate,NSTextFieldDelegate>



@property (weak) IBOutlet NSTextField *SN1;

@property (weak) IBOutlet NSTextField *SN2;
@property (weak) IBOutlet NSTextField *SN3;
@property (weak) IBOutlet NSTextField *SN4;
@property (weak) IBOutlet NSTextField *SN5;
@property (weak) IBOutlet NSTextField *SN6;
@property (weak) IBOutlet NSTextField *SN7;
@property (weak) IBOutlet NSTextField *SN8;
@property (weak) IBOutlet NSTextField *SN9;
@property (weak) IBOutlet NSTextField *SN10;

@property (weak) IBOutlet NSButton *single_btn;
@property (weak) IBOutlet NSButton *all_btn;
@property (weak) IBOutlet NSButton *Clear_SN;


@property (weak) IBOutlet NSButton *startBtn;
@end