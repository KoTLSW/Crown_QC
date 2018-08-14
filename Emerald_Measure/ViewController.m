//
//  ViewController.m
//  MK_TestingModel_Sample
//
//  Created by Michael on 16/11/10.
//  Copyright © 2016年 Michael. All rights reserved.
//DLC,  0-90000

#import "ViewController.h"
#import "MK_Table.pch"
#import "MK_File.pch"
#import "MK_Alert.pch"
#import "MK_Timer.pch"
#import "AppDelegate.h"
#import "Agilent3458A.h"
#import "Agilent33210A.h"
#import "Param.h"
#import "InstantPudding_API_QT1.h"
#import "ORSSerialPort.h"
#import "Agilent34461A.h"
//#import "Agilent34410A.h"
#import "AgilentTools.h"
#import <math.h>
#import "AgilentE4980A.h"

static ViewController * selfClass=nil;

//SN:FG772050032j5L215

//sesorboard

//  28，30，29，62，
//  34，49，33


//Erbium
//172.22.111.17
//172.22.110.28
//172.22.110.18
//172.22.111.18


//***************************
//@"CROWN_One"   测试项有1项的plist
//@"CROWN_Five"  测试项有5项plist
//@"Agilent34461A_MODE_RES_4W"
#define testPlist  @"CROWN_One" //选择不同的plist文件
#define indexItemOfDut  1   //测试项有5项
#define lingCE   @"Agilent34461A_MODE_RES_2W"
//***************************
//不同项的表头
//@"Test_A_Value"
//@"Test_A_Value,Test_B_Value,Test_C_Value,Test_D_Value,Test_E_Value"
#define testTittle_Num @"DUT_Value"
//***************************
#define  DLC_Range      @"100000"
#define  Normal_Range   @"10000"



//***************************
@interface ViewController()<ORSSerialPortDelegate,NSTextFieldDelegate>

@end

@implementation ViewController
{
    //************ Device *************
    ORSSerialPort          * fixtureSerial;   //治具串口
    Agilent3458A           * agilent3458A;    //安捷伦万用表
    Agilent33210A          * agilent33210A;   //波形发生器
    Agilent34461A          * agilent34461A;   //万用表
  //  Agilent34410A          * aglient34410A;   //万用表
    AgilentTools           * aglientTools;    //安捷伦万用表
    AgilentE4980A          * agilentE4980A;   //LCR表

    //************* timer *************
    NSString *start_time;               //启动单项测试的时间
    NSString *end_time;                 //单项结束测试的时间
    NSString *sunStart_time;            //整个的开始时间
    NSString *sunEnd_time;              //整个程序的结束时间
    NSString *cost_time;                //程序测试花费的时间
    NSThread * myThrad;                // 自定义主线程
    
    //************ table **************
    Table *mk_table;                       // table类
    Plist *plist;                          // plist类
    Param *param;                          // param参数类
    NSMutableArray *itemArr;            // plist文件测试项数组
    Item *testItem ;
    NSString *itemResult;               //每一个测试项的结果
    int index;                          // 测试流程下标
    int item_index;                     // 测试项下标
    int row_index;                      // table 每一行下标
    int  havaSN_num;                    //记录有值SN的坐标
    NSMutableArray *loadArr;            //存放需要测试的测试项
    
    
    
    __weak IBOutlet NSTextField *bigTitleTF;
    __weak IBOutlet NSTextField *versionTF;
    __weak IBOutlet NSView *tab_View;               // 与storyboard 关联的 outline_Tab
    __unsafe_unretained IBOutlet NSTextView *logView_Info; //log_View 中显示的信息
    __unsafe_unretained IBOutlet NSTextView *FailItemView;
    __weak IBOutlet NSPopUpButton *selesRa;
    __weak IBOutlet NSPopUpButton *agilentTestNum;
    
    IBOutlet NSPopUpButton *productTypePop;
    
    //************ testItems ************
    NSMutableArray  *txtLogMutableArr;
    NSString        *agilentReadString;
    NSDictionary    *dic;
    NSString        *SonTestDevice;
    NSString        *SonTestCommand;
    int             delayTime;
    int             ct_cnt;                //记录cycle time定时器中断的次数
    int             num_Dut;
    
    
    NSMutableArray  *testResultArr;        // 返回的结果数组
    NSMutableArray  *testItemTitleArr;     //每个测试标题都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemValueArr;     //每个测试结果都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemMinLimitArr;  //每个测试项最小值数组
    NSMutableArray  *testItesmMaxLimitArr; //每个测试项最大值数组
    NSMutableArray  *sonSnArr;             //记录有值得SN数组
    NSMutableArray  *havaSN;            //记录SN是否有值;
    NSString        * set;
    NSMutableArray  *SN_SnLocationArr;        //记录SN的位置
    NSMutableString *sonListFailingTest;
    
    //************ right_Side_Window *************
    MKTimer *mkTimer;               //MK 定时器对象
    int testNum;                        //测试次数
    int passNum;                        //通过次数
    NSString *testResultStr;     //测试结果
    int      SN_location  ;        //记录SN的位置
    
    NSString *selRange;
    NSString* agilentTestCount;
    NSString* productType;
    
   
    __weak IBOutlet NSTextField *currentStateMsg;   //当前的状态信息
    __weak IBOutlet NSTextField *currentStateMsgBG;
    
    __weak IBOutlet NSTextField *testResult;        //测试结果
    
    __weak IBOutlet NSTextField *testFieldTimes;    //测试时间
    __weak IBOutlet NSTextField *testCount;         //测试次数
    
    __weak IBOutlet NSButton *PDCA_Btn;             //PDCA 按钮
    __weak IBOutlet NSButton *SFC_Btn;              //SFC  按钮
    
    __weak IBOutlet NSButton *S3T1Btn;
    
    
    __weak IBOutlet NSButton *S2T3Btn;
    
    
    __weak IBOutlet NSTextField *passNumInfoTF;
    __weak IBOutlet NSTextField *passNumCalculateTF;
    __weak IBOutlet NSTextField *failNumInfoTF;
    __weak IBOutlet NSTextField *failNumCalculateTF;
    __weak IBOutlet NSTextField *totalNumInfo;
    __weak IBOutlet NSTextField *stationID_TF;
    __unsafe_unretained IBOutlet NSTextView *SN_Collector;//sn 收集器
    
    
    
    
    //添加的属性===========5.10====chen
    BOOL          isUpLoadSFC;      //是否上传SFC
    BOOL          isUpLoadPDCA;     //是否上传PDCA
    
    BOOL          boolTotalResult;  //测试总结果
    
    BOOL          all_SN_OK;            //检测all状态下SN是否为17位
    
    
    //    PDCA         *pdca;             //PDCA对象
    
    BOOL         all_Pass;          //testPDCA
    NSString     *ReStaName;
    NSString     *ReStaID;
    BOOL debug_skip_pudding_error;
    
    NSMutableArray *failItemsArr;
    NSMutableArray *passItemsArr;
    
    
    //================09.08新增csv项，ListFailingTest 和 Error Descrition===============
    NSMutableArray * ListFailingTest;
    NSMutableString * errorDescription;
    
    
    //testItem...
    double num;
    

    
    //具中返回来的cp
    NSString *backStr;                      //从治具中返回来的值
    NSMutableString * appendString;         //从治具中返回来的字符
    
    NSMutableArray* logGlobalArray;
    //增加无限循环限制设定
    BOOL  unLimitTest;                               //无限循环设定
    
    //设置BOOL变量====================10.10
    BOOL  isReceive;                                 //是否接收数据
    NSString      *   station_Name;                  //plist文件中工站名称
    NSString      *   param_Name;                    //plist文件中参数的名称
    NSString      *   SNString;                      //输入的序列号SN

    

    //========csv用到的数组==============
    NSMutableArray * SNArr;              //存放SN的数组
    NSMutableArray * startTimeArr ; //存放开始时间的数组
    NSMutableArray * endTimeArr;    //存放结束时间的数组
    NSMutableArray * snResultArry;  //存放单个产品的数组
    NSMutableString * txtContentMutableStr; //记录txt可变字符串
    NSMutableArray * txtLogArr;     //存放txt可变字符串的数组
    
    int              snIndex;
    
    NSMutableArray  *dataArr;
    
    NSString       * fixtureID; //治具的fixture ID
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
     param = [[Param alloc]init];
  
    appendString=[[NSMutableString alloc]initWithCapacity:10];
    ListFailingTest = [NSMutableArray arrayWithCapacity:0];
    errorDescription =[[NSMutableString  alloc]initWithCapacity:10];
    itemArr = [NSMutableArray arrayWithCapacity:0];
    txtLogMutableArr = [NSMutableArray arrayWithCapacity:0];
    passItemsArr = [NSMutableArray arrayWithCapacity:0];
    failItemsArr = [NSMutableArray arrayWithCapacity:0];
    testItemValueArr = [NSMutableArray arrayWithCapacity:0];
    testItemTitleArr = [NSMutableArray arrayWithCapacity:0];
    testItemMinLimitArr = [NSMutableArray arrayWithCapacity:0];
    testItesmMaxLimitArr = [NSMutableArray arrayWithCapacity:0];
    testResultArr  = [NSMutableArray arrayWithCapacity:0];
    logGlobalArray = [NSMutableArray arrayWithCapacity:10];
    havaSN     = [NSMutableArray arrayWithCapacity:10];
    loadArr   = [NSMutableArray arrayWithCapacity:10 ];
    SN_SnLocationArr = [NSMutableArray arrayWithCapacity:10];
    sonListFailingTest = [[NSMutableString alloc]initWithCapacity:10];
    dataArr = [[NSMutableArray alloc] initWithCapacity:10];
     //========csv用到的数组==============
    
    SNArr        = [NSMutableArray arrayWithCapacity:0];
    startTimeArr = [NSMutableArray arrayWithCapacity:0];
    endTimeArr   = [NSMutableArray arrayWithCapacity:0];
    snResultArry = [NSMutableArray arrayWithCapacity:0];
    txtLogArr    = [NSMutableArray arrayWithCapacity:0];
    txtContentMutableStr = [[NSMutableString alloc] initWithCapacity:10];
    sonSnArr = [[NSMutableArray alloc]initWithCapacity:10];
    
    //table界面
    mkTimer = [[MKTimer alloc] init];
    plist = [[Plist alloc] init];
    mk_table = [[Table alloc] init];
    
    selRange = selesRa.titleOfSelectedItem;
    agilentTestCount = @"10";
    productType = productTypePop.titleOfSelectedItem;
    
    
    
    //仪器仪表类
    agilent33210A =[[Agilent33210A alloc] init];
    agilent3458A =[[Agilent3458A alloc] init];
    agilent34461A=[[Agilent34461A alloc] init];
  //  aglient34410A=[[Agilent34410A alloc] init];
    aglientTools =[AgilentTools Instance];
    agilentE4980A=[[AgilentE4980A alloc]init];

    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectStationNoti:) name:@"changePlistFileNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCA_SFC_LimitNoti:) name:@"PDCAButtonLimit_Notification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CancellPDCA_SFC_LimitNoti:) name:@"CancellButtonlimit_Notification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetUnLimit_Notification:) name:@"TestUnLimit_Notification" object:nil];
    //OnselectSingleTest
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSelectSingleTest:) name:@"OnSelectSingleTest" object:nil];
    //OffselectSingleTest
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OffSelectSingleTest:) name:@"OffSelectSingleTest" object:nil];
   

    //控件状态
      logView_Info.editable = NO;
      PDCA_Btn.enabled = NO;
      SFC_Btn.enabled = NO;
      _startBtn.enabled =NO;
      isReceive = NO;
    
   
    //相关赋值
    boolTotalResult = NO;
    all_Pass = NO;
    unLimitTest=NO;
    all_SN_OK  = NO;
    item_index = 0;
    row_index = 0;
    index= 0;
    testNum = 0;
    passNum = 0;
    snIndex = 0;
    num_Dut = 0;
    havaSN_num = 0;
    SN_location = 0;

 
    
    // station_Name = @"CROWN_All";
     param_Name = @"Param";
    
     [param ParamRead:param_Name];
    
    //读取 plist 文件
    
    itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
    
    mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN Set:set number_test:indexItemOfDut];

    fixtureSerial=[ORSSerialPort serialPortWithPath:param.fixture_uart_port_name];
    fixtureSerial.baudRate=@B115200;
    fixtureSerial.delegate=self;
   
    

    
      [self redirectSTD:STDOUT_FILENO];  //冲定向log
      [self redirectSTD:STDERR_FILENO];
//
    if (param.isDebug)
    {
        bigTitleTF.stringValue = @"Debug Mode";
    }
    else
    {
        
        bigTitleTF.stringValue = param.sw_name;
        
        
    }
    versionTF.stringValue =[NSString stringWithFormat:@"Version: %@",param.sw_ver];
    
    stationID_TF.stringValue = param.sw_name;

    
    
    
    NSArray  *  arr =[aglientTools getUsbArray];
    
    for (NSString * agilentString in arr)
    {
        if ([agilentString containsString:@"0x0607"]||[agilentString containsString:@"0x2A8D"]||[agilentString containsString:@"0x0957"])
        {
            aglientTools.multimeter  = agilentString;
        }
    }
    
    

    //测试项线程
      myThrad = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
     [myThrad start];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
        [_SN1 becomeFirstResponder];
      
    });
}
//选择万用表量程
- (IBAction)selse_Range_Acion:(NSPopUpButton *)sender {
    
    selRange = selesRa.titleOfSelectedItem;
    
    NSLog(@"当前量程===%@",selRange);
}

//选择万用表测量数
- (IBAction)selectTestNumAction:(NSPopUpButton *)sender {
    
    agilentTestCount = agilentTestNum.titleOfSelectedItem;
     NSLog(@"当前测量数===%@",agilentTestCount);
}



-(void)selectPDCA_SFC_LimitNoti:(NSNotification *)noti
{
    PDCA_Btn.enabled = YES;
    SFC_Btn.enabled = YES;
}


-(void)CancellPDCA_SFC_LimitNoti:(NSNotification *)noti
{
    PDCA_Btn.state=YES;
    SFC_Btn.state= YES;
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled  = NO;
}

//无限循环限制设定
-(void)SetUnLimit_Notification:(NSNotification *)noti
{
    
    unLimitTest=YES;
}

- (IBAction)single_Btn_Actiong:(NSButton *)sender {
    
    _all_btn.state = NO;
    
    
    
}
- (IBAction)all_Btn_Action:(NSButton *)sender {
    
    _single_btn.state = NO;
    
}




-(void)OnSelectSingleTest:(NSNotification *)noti{
    
    

}
-(void)OffSelectSingleTest:(NSNotification *)noti{
    
    
}

- (IBAction)chooseProductAction:(id)sender {
    
    productType = productTypePop.titleOfSelectedItem;
    NSLog(@"当前测试产品类型===%@",productType);
    
    if ([productType isEqualToString:@"DLC"]) {
        
        itemArr = [plist PlistRead:testPlist Key:@"AllItems_DLC"];
        
        mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN Set:set number_test:indexItemOfDut];
    }
    else
    {
        itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
        
        mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN Set:set number_test:indexItemOfDut];
    
    }
}



#pragma mark 判断SN是否为17位

-(BOOL)detetion_SN{
    
    BOOL detetion = NO;
    BOOL SN_have = NO;
    
    if (_all_btn.state == YES) {
        
        for (int i = 0; i < 10 ; i++) {
            
            NSTextField * tf = (NSTextField *) [self.view viewWithTag:1 + i];
            
            if (tf.stringValue.length != 17) {
                
                detetion = YES;
                break;
                
            }else{
                
                detetion = NO;
                
            }
        }
    }
    else if(_single_btn.state == YES){
        
        for (int i = 0; i < 10 ; i++) {
            
            NSTextField * tf = (NSTextField *) [self.view viewWithTag:1 + i];
            
            if ([havaSN[i] isEqualToString:@"hava"]) {
                SN_have =YES;
                
                if (tf.stringValue.length == 17) {
                    
                    detetion = NO;
                  
                }else{
                    
                    detetion = YES;
                    break;
                }
            }
            
            if (!SN_have) {
                detetion = YES;
            }
        }
    }
    return detetion;

}


- (IBAction)Clear_SN_action:(NSButton *)sender {
    
  //  dispatch_sync(dispatch_get_main_queue(), ^{
        
        for (int i = 0; i < 10; i++) {
            NSTextField * TF = (NSTextField *) [self.view viewWithTag:1 + i];
            TF.stringValue = @"";
        }
        
        [_SN1 becomeFirstResponder];
        
   // });
    

}


-(void)selectStationNoti:(NSNotification *)noti
{
    if (plist == nil)
    {
        plist = [[Plist alloc] init];
    }
    
    if (mk_table == nil)
    {
        mk_table = [[Table alloc] init];
    }

    
    if ([noti.object isEqualToString:@"SersonBoard"] || [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"SersonBoard"])
    {
        NSLog(@"进入 SersonBoard 工站");
        stationID_TF.stringValue = @"Sensor Board";

        //读取 plist 文件
        itemArr = [plist PlistRead:@"SersonBoard" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN  Set: set number_test:indexItemOfDut];
        
    }
    
    if ([noti.object isEqualToString:@"CrownFlex"]|| [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"CrownFlex"])
    {
        NSLog(@"进入 CrownFlex 工站");
        stationID_TF.stringValue = @"Crown Flex";
        
        //读取 plist 文件
        itemArr = [plist PlistRead:@"CrownFlex" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN Set: set number_test:indexItemOfDut];
        
    }
    
    if ([noti.object isEqualToString:@"Erbium"]|| [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"Erbium"])
    {
        NSLog(@"进入 Erbium 工站");
        stationID_TF.stringValue = @"Sensor Flex Sub Assembly";
        
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Erbium" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN Set: set  number_test:indexItemOfDut];
        
    }
    
    //重新加载参数
    //获取沙盒中的工站和参数
    station_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"];
    param_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentParam"];
    [param ParamRead:param_Name];
    
    
}


//sn = 123456
//================================================
//测试动作流程
//================================================
-(void)Working
{
    
    if (testItem == nil)
    {
        testItem  = [[Item alloc] init];
    }
    
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
#pragma mark index=0 打开治具，串口通信
        //------------------------------------------------------------
        //index=0
        //------------------------------------------------------------
        if (index == 0)
        {
                [fixtureSerial open];
                BOOL uartConnect=NO;
                //Debug mode
                if (param.isDebug)
                {
                    uartConnect = YES;
                    
                    fixtureID=@"Debug";
                    index = 1;
                }
                else if([fixtureSerial isOpen])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,fixture connect ok!";
                        NSLog(@"index=0,fixture connect ok!");
                        
                        [currentStateMsg setTextColor:[NSColor blueColor]];
                    });
                    
                    [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=0,fixture connect ok!\n", [[GetTimeDay shareInstance] getLogTime]]];
                    
                   
                    NSLog(@"Time of send command of Fixture id%@",[[GetTimeDay shareInstance] getCurrentMinuteAndSecond]);
                    [NSThread sleepForTimeInterval:0.5];
                    fixtureID = [self getValueFromFixture_SendCommand:@"FIXTURE_ID?"];
                    
                    
                    [self Fixture:fixtureSerial writeCommand:@"reset"];
                    
                    
                    [self whileLoopTest];
                    
                    
                    if ([[backStr uppercaseString ]containsString:@"OK"])
                    {
                        
                        backStr = @"";
                        index = 1;
                        currentStateMsg.stringValue=@"index=0,fixture reset ok!";
                        [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=0,fixture reset ok!\n", [[GetTimeDay shareInstance] getLogTime]]];
                    }
                    
                    }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,fixture connect fail!";
                        
                        [currentStateMsg setTextColor:[NSColor redColor]];
                    });
                    
                    [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=0,fixture connect fail!\n", [[GetTimeDay shareInstance] getLogTime]]];
                    
                
                    
                }
            
        }
        
#pragma mark index=1  打开安捷伦万用表---GPIB通信
        // "USB0::0x0957::0x1507::MY57000142::INSTR",        32210A
        // "USB0::0x0957::0x0607::MY47017314::INSTR",        34410A
        // "USB0::0x2A8D::0x1301::MY53226586::INSTR"         34461A
        //------------------------------------------------------------
        //index=1
        //------------------------------------------------------------
        
        if (index==1)
        {
            BOOL agilent_isOpen;
            //Debug mode

            if (param.isDebug)
            {
                agilent_isOpen = YES;
            }
            else
            {
                
                agilent_isOpen = [agilent34461A Find:nil andCommunicateType:Agilent34461A_MODE_USB_Type]&&[agilent34461A OpenDevice: nil andCommunicateType:Agilent34461A_MODE_USB_Type];
        
//                else if([aglientTools.multimeter containsString:@"0x0607"])
//                {
//                    agilent_isOpen = [aglient34410A Find:nil andCommunicateType:MODE_USB_Type]&&[aglient34410A OpenDevice:nil andCommunicateType:MODE_USB_Type];
//                }
//                else if([aglientTools.multimeter containsString:@"0x0957"]){
//                
//                  agilent_isOpen  =[agilentE4980A Find:nil andCommunicateType:AgilentE4980A_USB_Type]&&[agilentE4980A OpenDevice:nil andCommunicateType:AgilentE4980A_USB_Type];
//                
//                }
//                else
//                {
//                    agilent_isOpen = [agilent3458A FindAndOpen:nil];
//                    
//                }
            }
            
            [NSThread sleepForTimeInterval:0.2];
            
            if (agilent_isOpen)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=1,aglient connect ok!";
                    NSLog(@"index=1,aglient connect ok!");
                   
                    index = 1000;
                    
                });
                
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=1,aglient connect ok!\n", [[GetTimeDay shareInstance] getLogTime]]];
                sleep(1);
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   currentStateMsg.stringValue=@"index=1,Please enter the SN!";
                    [currentStateMsg setTextColor:[NSColor blueColor]];
                    _startBtn.enabled =YES;
                   
                    });
                
            }            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=1,aglient connect fail!";
                    NSLog(@"index=1,aglient connect fail!");
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=1,aglient connect fail!\n", [[GetTimeDay shareInstance] getLogTime]]];
                
            }
        }
#pragma mark index =2 判断门和气缸的状态
        
        if (index == 2) {
            
            [self Fixture:fixtureSerial writeCommand:@"read door"];
            
            
            [self whileLoopTest];
            
            
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>> read door \n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial]];

            
              //判断门的开关
            if ([backStr containsString:@"close"] || param.isDebug) {
                
                backStr = @"";
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                     [logGlobalArray addObject:[NSString stringWithFormat: @"%@:read door Pass\n", [[GetTimeDay shareInstance] getLogTime]]];
                    
                     index = 3 ;
                    
                });

            }else{
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    currentStateMsg.stringValue=@"Please close the door";
                    [logGlobalArray addObject:[NSString stringWithFormat: @"%@:read door Fail\n", [[GetTimeDay shareInstance] getLogTime]]];
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });

            
            }//判断门关没关
            
            
        }
        
#pragma mark index=3  获取SN,获取上传状态
        //------------------------------------------------------------
        //index=3
        //------------------------------------------------------------
        if (index == 3)
        {
           
            [self Fixture:fixtureSerial writeCommand:@"reset"];
            
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>> reset \n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial]];
            
            [self whileLoopTest];
            
            if ([[backStr uppercaseString] containsString:@"OK"]) {
                backStr = @"";
                //*****************************打开气缸
            
                while (YES) {
                    //打开气缸 X轴
                    [self Fixture:fixtureSerial writeCommand:@"xcylinder on"];
                    
                    //[NSThread sleepForTimeInterval:0.5];
                    [self whileLoopTest];
                    
                    [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>xcylinder on X\n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial]];
                    
                    if ([backStr containsString:@"pass"]) {
                        
                        backStr = @"";
                        
                        //打开气缸 Y轴
                        [self Fixture:fixtureSerial writeCommand:@"ycylinder on"];
                        
                        [self whileLoopTest];
                        sleep(2);
                        [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>xcylinder on Y\n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial]];
                        
                        if ([backStr containsString:@"pass"])
                        {
                            backStr = @"";
                            
                            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===3 air cylinder on Y-axis Pass", [[GetTimeDay shareInstance] getLogTime]]];
                            
                            break;
                            
                        }else{
                            
                            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===3 air cylinder on Y-axis Fail", [[GetTimeDay shareInstance] getLogTime]]];
                            
                        }
                        
                        [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===3 air cylinder on X-axis Pass", [[GetTimeDay shareInstance] getLogTime]]];
                        
                        
                    }else{
                        
                        [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===3 air cylinder on X-axis Fail", [[GetTimeDay shareInstance] getLogTime]]];
                        
                    }
                    sleep(1);
                }
            //*****************************
            }else {
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=0,fixture connect fail!";
                    
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=3,fixture connect fail!\n", [[GetTimeDay shareInstance] getLogTime]]];
            
            }
            
            //加载数据
            if (_single_btn.state == YES) {
              
                for ( int i = 0;  i < itemArr.count ; i++) {
                    
                    if ([havaSN[havaSN_num] isEqualToString:@"hava"]) {
                        
                       [loadArr addObject:itemArr[i]];
                
                    }else{
                        
                        i+=indexItemOfDut;
                        
                    }
                    
                    if (i % (indexItemOfDut +1) == indexItemOfDut) {
                        
                        havaSN_num ++;
                    }
                    
                }//for循环
                  
                //获取SN的下标、显示测试结果的时候用到
                for (id obj in havaSN) {
                   
                    if ([obj isEqualToString:@"hava"]) {
                        
                        [SN_SnLocationArr addObject:[NSNumber numberWithInt:SN_location+1]];
                    }
                    SN_location++;
                    
                }
            }
            else{
                SN_SnLocationArr = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
            }
            //if-_single_btn.state == YES
             //testItem = itemArr[item_index];
          
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=3 agin SN ", [[GetTimeDay shareInstance] getLogTime]]];
            
            [self GetSFC_PDCAState];//获取是否上传的状态
            ct_cnt = 0;
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===3 after time %@\n", [[GetTimeDay shareInstance] getLogTime], [[GetTimeDay shareInstance] getCurrentTime]]];
            
            index = 4;
            
        }
        
#pragma mark  index =4        
        //------------------------------------------------------------
        //index=4
        //------------------------------------------------------------
        if (index == 4)
        {
            index =5;
        }
        
        
    
#pragma mark index=5   SFC 检验 SN 是否过站
        //------------------------------------------------------------
        //index=5
        //------------------------------------------------------------
        if (index == 5)
        {
            //根据SFC状态，检验SN是否过站
            //            if (isUpLoadSFC)
            //            {
            //                [TestStep Instance].strSN=importSN.stringValue;
            //                if (![[TestStep Instance]StepSFC_CheckUploadSN:isUpLoadSFC])
            //                {
            //                    NSLog(@"index=6,SFC check fail");
            //                    currentStateMsg.stringValue = @"index=6,SFC check fail";
            //                    [currentStateMsg setTextColor:[NSColor redColor]];
            //                    sleep(1);
            //                }
            //                else
            //                {
            //                    NSLog(@"index=5,SFC No message");
            //                    currentStateMsg.stringValue = @"index=6,SFC No message";
            //                    [currentStateMsg setTextColor:[NSColor redColor]];
            //                    sleep(1);
            //                    index = 7;//进入正常测试中
            //                }
            //            }
            //            else
            //            {
            //            }
            
            NSLog(@"index=4,SFC No check!");
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=4,SFC No check!\n", [[GetTimeDay shareInstance] getLogTime]]];
            currentStateMsg.stringValue = @"index=4,SFC No check!";
            [currentStateMsg setTextColor:[NSColor redColor]];
            
            index = 6;
        }
        
#pragma mark index = 6
        //------------------------------------------------------------
        //index=6
        //------------------------------------------------------------
        if (index == 6)
        {
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=6 before time %@\n", [[GetTimeDay shareInstance] getLogTime], [[GetTimeDay shareInstance] getCurrentTime]]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
               
                currentStateMsg.stringValue = @"index=6 running...";
                NSLog(@"index=6 running...");
                [currentStateMsg setTextColor:[NSColor blueColor]];
                
            });
            
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=6 running...\n", [[GetTimeDay shareInstance] getLogTime]]];
            
            //========定时器开始========
            if (ct_cnt == 0)
            {
                /**df
                 *  GCD 定时器
                 */
                dispatch_async(dispatch_get_main_queue(), ^{
                [mkTimer setTimer:0.1];
                [mkTimer startTimerWithTextField:testFieldTimes];
                ct_cnt = 1;
                    
                });
            }
            //=========================
            
            //记录每一项开始的时间
            if (row_index %(indexItemOfDut+1) == 0)
            {
                // NSLog(@"记录 pdca 的起始测试时间");
                start_time = [[GetTimeDay shareInstance] getFileTime];    //启动测试的时间,csv里面用
                
                [startTimeArr addObject:start_time];
                
                
            }
            if (_single_btn.state == YES)
            {
                
                testItem = loadArr[item_index];
            }
            else
            {
            
                testItem = itemArr[item_index];
            }
            
            
            
            
            NSLog(@"%@=========%@========%@",testItem.testName, testItem.value, _single_btn.state ? loadArr[item_index]: itemArr[item_index]);
            [logGlobalArray addObject:[NSString stringWithFormat:@"%@: %@=========%@========%@\n",[[GetTimeDay shareInstance] getLogTime], testItem.testName, testItem.value, _single_btn.state ? loadArr[item_index]: itemArr[item_index]]];
            
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=== 6,正在测试的产品SN: %@\n", [[GetTimeDay shareInstance] getLogTime],sonSnArr[snIndex]]];
            
            //txt log
            [txtContentMutableStr appendString:[NSString stringWithFormat:@"\n\nStartTimer:%@\nTestName:%@\nUnit:%@\nLowerLimit:%@\nUpperLimit:%@\n",[[GetTimeDay shareInstance] getCurrentTime],testItem.testName,testItem.units,testItem.min,testItem.max]];
            
            //加载测试项
            BOOL boolResult = [self TestItem:testItem];
            
            
            //测试结果转为字符串格式
            if (boolResult == YES)
            {
                itemResult = @"PASS";
                
            }
            else
            {
                
                itemResult = @"FAIL";
    
            }
            
            //把测试结果加入到可变数组中
            [testResultArr addObject:itemResult];
            
            //[snResultArry addObject:itemResult];
            
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===7 after time %@\n", [[GetTimeDay shareInstance] getLogTime], [[GetTimeDay shareInstance] getCurrentTime]]];
            
            [mk_table flushTableRow:testItem RowIndex:row_index];
            
            //更新失败项内容
            if ([testItem.result isEqualToString:@"FAIL"]) {
                
                [self UpdateTextView:[NSString stringWithFormat:@"FailItem->TestName:%@\n",testItem.testName] andClear:NO andTextView:FailItemView];
                
              //  [ListFailingTest appendString:[NSString stringWithFormat:@":%@",testItem.testName]];
                
            }
            
            
            NSLog(@"index===5 ==== time %@",[[GetTimeDay shareInstance] getCurrentTime]);
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=== 6 ==== time %@\n", [[GetTimeDay shareInstance] getLogTime], [[GetTimeDay shareInstance] getCurrentTime]]];
            
            if ( item_index % (indexItemOfDut + 1) == (indexItemOfDut)) {
                //单个产品测试结束时间
                end_time = [[GetTimeDay shareInstance] getFileTime];
                [endTimeArr addObject:end_time];
                
                //获取单个产品的测试结果
                [snResultArry addObject:[testResultArr containsObject:@"FAIL" ]?@"FAIL":@"PASS"];
                
                [testResultArr removeAllObjects];
                
                //获取txt记录
                [txtLogArr addObject:txtContentMutableStr];
                txtContentMutableStr = [NSMutableString stringWithString:@""];
            
                
                if (_single_btn.state == YES) {
                    
                    if ( row_index%(indexItemOfDut + 1 ) == indexItemOfDut ){
                        
                        [ListFailingTest addObject:sonListFailingTest];
                        
                        sonListFailingTest =[NSMutableString stringWithString:@""];
                    }
                    
                }
                else
                {
                    
                    if (row_index%(indexItemOfDut + 1) == indexItemOfDut) {
                        
                        [ListFailingTest addObject:[NSString stringWithFormat:@"%@",sonListFailingTest]];
                        
                         sonListFailingTest =[NSMutableString stringWithString:@""];
                    }
                    
                    
                }
                
                //显示测试结果
                if (_single_btn.state == YES) {
                    
                    int BB = [SN_SnLocationArr[snIndex] intValue] - 1 ;
                    
                        NSTextField * tf = (NSTextField *) [self.view viewWithTag:101 + BB];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if ([snResultArry[snIndex] containsString:@"FAIL"]) {
                                
                                tf.backgroundColor = [NSColor redColor];
                                
                                [self Fixture:fixtureSerial writeCommand:[NSString stringWithFormat:@"show fail %d",(BB+1)]];
                                
                                [self whileLoopTest];
                                
                                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>show fail %d\n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial,(BB+1)]];
                                
                            }
                            else
                            {
                                tf.backgroundColor = [NSColor greenColor];
                                passNum++;
                                [self Fixture:fixtureSerial writeCommand:[NSString stringWithFormat:@"show pass %d",(BB+1)]];
                                [self whileLoopTest];
                                
                                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>show pass %d\n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial,(BB+1)]];
                                
                            }
                            
                            snIndex++;
                            testNum++;
                            
                        });
                 
                    
                }
                else
                {
                    NSTextField * tf = (NSTextField *) [self.view viewWithTag:101 + snIndex];
                
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                        if ([snResultArry[snIndex] containsString:@"FAIL"]) {
                            
                            tf.backgroundColor = [NSColor redColor];
                            
                            [self Fixture:fixtureSerial writeCommand:[NSString stringWithFormat:@"show fail %d",(snIndex+1)]];
                            
                            [self whileLoopTest];
                            
                            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>show fail %d\n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial,(snIndex+1)]];
                            
                        }
                        else
                        {
                            tf.backgroundColor = [NSColor greenColor];
                            passNum++;
                            
                            [self Fixture:fixtureSerial writeCommand:[NSString stringWithFormat:@"show pass %d",snIndex+1]];
                            [self whileLoopTest];
                            
                            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>show pass %d\n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial,snIndex+1]];

                            
                        }
                    
                        snIndex++;
                        testNum++;
                
                    });
                }

                if (snIndex == 9) {
                    NSMutableArray * failSNNum = [NSMutableArray arrayWithCapacity:0];
                    int i = 0;
                    for (id re in snResultArry) {
                        i++;
                        if ([re isEqualToString:@"FAIL"]) {
                            
                            [failSNNum addObject:[NSNumber numberWithInt:i]];
                            
                        }else{
                            NSLog(@"All  products is PASS");
                        }
                        
                    }
                    NSString *str = [failSNNum componentsJoinedByString:@","];
                    NSLog(@"sn=%@ is FAIL",str);
                }//snIndex = 9
              
            }//item_index % 6 == 5
            
           
            row_index++;
            item_index++;
            
            //走完测试流程,进入下一步
            
            if (_single_btn.state == YES) {
                
                if (item_index == loadArr.count) {
                    
                    index = 7;
                }

                
            }else{
            
                if (item_index == itemArr.count) {
                    
                    index = 7;
                }

            
            }
            
        }
        
#pragma mark index=7  上传pdca，生成本地数据报表
        //------------------------------------------------------------
        //index=7
        //------------------------------------------------------------
        if (index == 7)
        {
            //================09.08新增csv项，ListFailingTest 和 Error Descrition===============west

            errorDescription = [NSMutableString stringWithString:@"N/A"];
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=7 create log file...";
                NSLog(@"index=7 create log file...");
                [currentStateMsg setTextColor:[NSColor blueColor]];
            });
            
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=7 create log file...\n", [[GetTimeDay shareInstance] getLogTime]]];
            
            sleep(1);
            
            if([MK_FileCSV shareInstance]!= nil)       //生成本地数据报表
            {
                //文件夹路径
                NSString *currentPath=@"/vault";
                //创建总文件夹
                [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:currentPath SubjectName:@"CROWN_QC"];
                
                //从 json 文件获取本机工站等信息, 拼接到主文件夹中
//                NSString * jsonProductKey =[self getValueFromJsonFileWithKey:@"PRODUCT"];
//                NSString * jsonStationTypeKey = [self getValueFromJsonFileWithKey:@"STATION_TYPE"];
                
                //创建对应不同工站的文件夹
               // NSString *mainFolderName = [NSString stringWithFormat:@"%@_%@_Station_%@_%@",param.sw_name,param.sw_ver,jsonProductKey,jsonStationTypeKey];
                
                 NSString *mainFolderName = [NSString stringWithFormat:@"%@_Station_%@",param.sw_name,param.sw_ver];
                
                //创建
                [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:[NSString stringWithFormat:@"%@/CROWN_QC/%@/",currentPath,[[GetTimeDay shareInstance] getCurrentDay]] SubjectName:[NSString stringWithFormat:@"%@/",mainFolderName]];
                
                //路径
                NSString *mainfolderPath = [NSString stringWithFormat:@"%@/CROWN_QC/%@/%@/",currentPath,[[GetTimeDay shareInstance] getCurrentDay],mainFolderName];
                //存储
                [[NSUserDefaults standardUserDefaults] setObject:mainfolderPath forKey:@"mainFolderPathKey"];
                
                [[NSUserDefaults standardUserDefaults] setObject:mainFolderName forKey:@"mainFolderNameKey"];
                
                
                //csv文件列表头,测试标题项遍历当前plisth文件的测试项(拼接),温湿度传感器
                NSString *min_Str;
                NSMutableString *minMutableStr;
                
                NSString *max_Str;
                NSMutableString *maxMutableStr;
                
                if (minMutableStr == nil)
                {
                    minMutableStr = [[NSMutableString alloc] init];
                }
                if (maxMutableStr == nil)
                {
                    maxMutableStr = [[NSMutableString alloc] init];
                }
                
                for (int i = 0; i< testItemTitleArr.count; i++)
                {
                    min_Str = [testItemMinLimitArr objectAtIndex:i];
                    [minMutableStr appendString:[NSString stringWithFormat:@",%@",min_Str]];
                    
                    
                    max_Str = [testItesmMaxLimitArr objectAtIndex:i];
                    [maxMutableStr appendString:[NSString stringWithFormat:@",%@",max_Str]];
                    
                    if (i%(indexItemOfDut)==(indexItemOfDut-1)) {
                        
                        break;
                    }
                }
                
                NSString *csvTitle = [NSString stringWithFormat:@"%@,SW_Version:%@\nSerialNumber,Test Pass/Fail Status,Slot,Fixture ID,List of Failing Test,Error Description,StartTime, EndTime,%@\nUpper Limits---->,,,,,,%@\nLower Limits---->,,,,,,%@",param.sw_name,param.sw_ver,testTittle_Num,maxMutableStr,minMutableStr];
                
                //csv测试项内容,同上
                NSString *csvContentStr;
                NSMutableString *csvContentMutableStr;
                if (csvContentMutableStr == nil)
                {
                    csvContentMutableStr = [[NSMutableString alloc] init];
                }
                
                
                for (int i=0; i < testItemValueArr.count; i++)
                {
                    csvContentStr = [testItemValueArr objectAtIndex:i];
                    
                    if (i == 0 ||i == testItemValueArr.count-1) {
                        [csvContentMutableStr appendString:[NSString stringWithFormat:@"%@", csvContentStr]];
                    }else{
                    
                     [csvContentMutableStr appendString:[NSString stringWithFormat:@",%@", csvContentStr]];
                    }
                   
                }
                //将数组拆分
                NSArray   *appArray    =  [csvContentMutableStr componentsSeparatedByString:@",,"];
                
                
                //创建 csv 总文件,并写入数据
            
                for (int i = 0; i < sonSnArr.count; i ++) {
                    
                    
                    [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:mainfolderPath Sn:sonSnArr[i] ListFail:ListFailingTest[i] ErrorDescription:errorDescription TestItemStartTime:startTimeArr[i] TestItemEndTime:endTimeArr[i] TestItemContent:appArray[i] TestItemTitle:csvTitle TestResult:snResultArry[i] andBool:YES andSNLocation:SN_SnLocationArr[i] andFixture:fixtureID] ;
                    
                }
                
                
                //对应每个 SN 创建 csv 文件,并写入数据
                for (int i = 0; i < sonSnArr.count ; i ++) {
                    
                    [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:mainfolderPath Sn:sonSnArr[i] ListFail:ListFailingTest[i] ErrorDescription:errorDescription TestItemStartTime:startTimeArr[i] TestItemEndTime:endTimeArr[i] TestItemContent:appArray[i] TestItemTitle:csvTitle TestResult:snResultArry[i] andBool:NO andSNLocation:SN_SnLocationArr[i] andFixture:fixtureID];
                    
                }
                
                
                //写入txt文件中
            
                for (int i=0;i<[sonSnArr count];i++) {
                 
                    [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:sonSnArr[i] TestItemStartTime:startTimeArr[i] TestItemEndTime:endTimeArr[i] TestItemContent:[NSString stringWithFormat:@"\nVersion:%@\nSerialNumber:%@\n%@",param.sw_ver,sonSnArr[i],txtLogArr[i]] TestResult:snResultArry[i]];
                   
                }
                
                
            }
            
#pragma mark ------ 上传 PDCA
            if (isUpLoadPDCA)
            {
                NSLog(@"start to upload pdca");
                
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: start to upload pdca\n", [[GetTimeDay shareInstance] getLogTime]]];
                
                
                
                
                //将所有文件夹进行压缩
                //NSMutableArray  * Zip_Path_Array = [self pressDirectoryToZIP:dataArr];
            
                //将数据从数组中等分成[snArray count]数组
//                NSArray   *  item_Arr = [self GetArrayWithArray];
//                
//                for (int i=0;i<[item_Arr count];i++) {
//                    
//                    [self uploadPDCA_FeicuiWithItemArr:item_Arr[i] withZipString:Zip_Path_Array[i] withItemResultString:snResultArry[i] withSNString:sonSnArr[i] withDataArr:dataArr[i]];
//                }
                
                
                

            }
            
#pragma mark ------ 上传 SFC
            if (isUpLoadSFC)
            {
                NSLog(@"上传SFC");
                [logGlobalArray addObject:@"上传SFC\n"];
                
            }
            
            index = 8;
        }
        
#pragma mark index=8 结束测试 刷新界面
        //------------------------------------------------------------
        //index=8
        //------------------------------------------------------------
        if (index == 8)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=8 endding!";
                NSLog(@"index=8 endding!");
                [logGlobalArray addObject:@"index=8 endding!\n"];
                [currentStateMsg setTextColor:[NSColor blueColor]];
            });
            sleep(1);
            [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index=8 endding!\n", [[GetTimeDay shareInstance] getLogTime]]];
            //每次结束测试都刷新主界面
            
            if ([testResult.stringValue isEqualToString:@"PASS"])
            {
                passNum++;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                testCount.stringValue = [NSString stringWithFormat:@"%d/%d",passNum,testNum];
                NSLog(@"testCount.stringValue: %d/%d", passNum,testNum);
                
                totalNumInfo.stringValue = [NSString stringWithFormat:@"%d",testNum];
                
                passNumInfoTF.stringValue = [NSString stringWithFormat:@"%d",passNum];
                passNumCalculateTF.stringValue = [NSString stringWithFormat:@"%.2f%%",((double)passNum/(double)testNum)*100];
                
                failNumInfoTF.stringValue = [NSString stringWithFormat:@"%d",(testNum - passNum)];
                failNumCalculateTF.stringValue = [NSString stringWithFormat:@"%.2f%%",((double)(testNum-passNum)/(double)testNum)*100];
                
                //录入sn 收集器
                NSString *str1 = [NSString stringWithFormat:@"%@___%@__%@",[[NSUserDefaults standardUserDefaults]  objectForKey:@"theSN"],testResultStr,[[GetTimeDay shareInstance] getCurrentTime]];
                NSString *str2 = SN_Collector.string;
                 SN_Collector.string = [str2 stringByAppendingString:[NSString stringWithFormat:@"%@\n",str1]];
                [SN_Collector setTextColor:[NSColor blueColor]];
                
                if (_Clear_SN.state) {
                    
                    for (int i = 0; i < 10; i++) {
                   NSTextField * TF = (NSTextField *) [self.view viewWithTag:1 + i];
                        TF.stringValue = @"";
                    }
                    
                    [_SN1 becomeFirstResponder];
                }

                
            });
            
            
            
            index=9;
        }
        
#pragma mark index=9  跳出循环 清空数组
        //------------------------------------------------------------
        //index=9
        //------------------------------------------------------------
        if (index == 9)
        {
            
            
            while (YES) {
                
                
                [self Fixture:fixtureSerial writeCommand:@"ycylinder off"];
                //[NSThread sleepForTimeInterval:0.5];
                [self whileLoopTest];
                
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>xcylinder off Y\n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial]];
                
                if ([backStr containsString:@"pass"]|| param.isDebug) {
                    backStr = @"";
                    
                    [self Fixture:fixtureSerial writeCommand:@"xcylinder off"];
                    
                    [self whileLoopTest];
                    //[NSThread sleepForTimeInterval:0.5];
                    
                    [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>xcylinder off X\n", [[GetTimeDay shareInstance] getLogTime],fixtureSerial]];
                    
                    if ([backStr containsString:@"pass"]||param.isDebug) {
                        backStr = @"";
                        
                        [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===9 air cylinder off X-axis Pass", [[GetTimeDay shareInstance] getLogTime]]];
                        
                        break;
                        
                    }else{
                        
                        [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===9 air cylinder off X-axis Fial", [[GetTimeDay shareInstance] getLogTime]]];
                    }
                    
                    [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===9 air cylinder off Y-axis Pass", [[GetTimeDay shareInstance] getLogTime]]];
                }else{
                    
                    [logGlobalArray addObject:[NSString stringWithFormat: @"%@: index===9 air cylinder off Y-axis Fial", [[GetTimeDay shareInstance] getLogTime]]];
                    
                }
                sleep(1);
            }
           
            
            //写入详细的Log日志
            [self writeDetailLog];

            dispatch_sync(dispatch_get_main_queue(), ^{
            
                _all_btn.enabled = YES;
                _single_btn.enabled = YES;
                _startBtn.enabled = YES;
                
            });
            
            item_index = 0;
            row_index=0;
            snIndex = 0;
            [dataArr removeAllObjects];
    
            //无限循环测试
            if (unLimitTest==YES)
            {
                 //sleep(2);
                index = 3;
                [mk_table ClearTable];
                [self UpdateTextView:@"\n\n" andClear:YES andTextView:FailItemView];
                havaSN_num = 0;
                snIndex = 0;
                [loadArr removeAllObjects];
                SN_location = 0;
                
                
                for (int i = 0; i < 10; i++) {
                    
                    NSTextField * tf = (NSTextField *) [self.view viewWithTag:101 + i];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        tf.backgroundColor = [NSColor selectedControlColor];
                        
                        
                    });
                    
                }//for
                [self removeDataFromArray];
                
            }else {
            
                index =1000;
               
            }
            
            //========定时器结束========
            [mkTimer endTimer];
            ct_cnt = 0;
            //========================
            
        }
#pragma mark index=1000 等待状态
        //------------------------------------------------------------
        //index=1000
        //------------------------------------------------------------
        if (index == 1000)
        {
            [NSThread sleepForTimeInterval:0.2];
        }
    }
}


//==================== 冲定向log ============================
- (void)redirectNotificationHandle:(NSNotification *)nf{
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if(logView_Info != nil)
    {
        NSRange range;
        range = NSMakeRange ([[logView_Info string] length], 0);
        [logView_Info replaceCharactersInRange: range withString: str];
        [logView_Info scrollRangeToVisible:range];
    }
    [[nf object] readInBackgroundAndNotify];
}

- (void)redirectSTD:(int )fd{
    
    NSPipe * pipe = [NSPipe pipe] ;
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle] ;
    
    [pipeReadHandle readInBackgroundAndNotify];
}
//==================== 冲定向log ============================


//================================================
//测试项指令解析
//================================================
-(BOOL)TestItem:(Item*)testitem
{
    BOOL ispass=NO;
    
#pragma mark--------具体测试指令执行流程
    for (int i=0; i<[testitem.testAllCommand count]; i++)
    {
        //治具===================Fixture
        //波形发生器==============OscillDevice
        //安捷伦万用表============Aglient
        //延迟时间================SW
        dic=[testitem.testAllCommand objectAtIndex:i];
        SonTestDevice=dic[@"TestDevice"];
        SonTestCommand=dic[@"TestCommand"];
        delayTime = [dic[@"TestDelayTime"] floatValue]/1000;
        

        //**************************治具=Fixture
        if ([SonTestDevice isEqualToString:@"Fixture"])
        {
            
            if (param.isDebug)
            {
                
                backStr = @"debug";
            }
            else
            {
                appendString=[[NSMutableString alloc]initWithString:@""];
                
                int indexTime=0;
                while (YES)
                {
                    [self Fixture:fixtureSerial writeCommand:SonTestCommand];
                    
                    
                    NSLog(@"%@ send:>>%@",SonTestDevice,SonTestCommand);
                    
                    [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ send:>>%@\n", [[GetTimeDay shareInstance] getLogTime],SonTestDevice,SonTestCommand]];
                    
                    [self whileLoopTest];
                    
                    if ([backStr containsString:@"OK"]||indexTime==[testitem.retryTimes intValue])
                    {
                        NSLog(@"%@ receive:<<%@",SonTestDevice,SonTestCommand);
                        [logGlobalArray addObject:[NSString stringWithFormat: @"%@: %@ receive:>>%@\n", [[GetTimeDay shareInstance] getLogTime],SonTestDevice,SonTestCommand]];
                            backStr = @"";
                        break;
                    }
                    
                    indexTime++;
                }
            }
            
        }
        
        //**************************波形发生器=WaveDevice
        else if ([SonTestDevice isEqualToString:@"WaveDevice"])
        {
            //获取频率
            NSString   * frequence =[self cutOutStringFromStr:SonTestCommand withDivisionString:@"_" andIndex:3];
            
            if ([SonTestCommand containsString:@"MODE_Sine"])
            {
                NSLog(@"print the waveDevice MODE_Sine");
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: print the waveDevice MODE_Sine\n", [[GetTimeDay shareInstance] getLogTime]]];
                [agilent33210A SetMessureMode:MODE_Sine andCommunicateType:Agilent33210A_USB_Type andFREQuency:frequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
                
                
            }
            else if([SonTestCommand containsString:@"MODE_Square"])
            {
                NSLog(@"print the waveDevice MODE_Square");
                
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: print the waveDevice MODE_Square\n", [[GetTimeDay shareInstance] getLogTime]]];
                [agilent33210A SetMessureMode:MODE_Square andCommunicateType:Agilent33210A_USB_Type andFREQuency:frequence andVOLTage:@"1.8" andOFFSet:@"0"];
                
            }
            else if([SonTestCommand containsString:@"MODE_Ramp"])
            {
                NSLog(@"print the waveDevice MODE_Ramp");
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: print the waveDevice MODE_Ramp\n", [[GetTimeDay shareInstance] getLogTime]]];
                [agilent33210A SetMessureMode:MODE_Ramp andCommunicateType:Agilent33210A_USB_Type andFREQuency:frequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            }
            else if([SonTestCommand containsString:@"MODE_Pulse"])
            {
                NSLog(@"print the waveDevice MODE_Pulse");
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: print the waveDevice MODE_Pulse\n", [[GetTimeDay shareInstance] getLogTime]]];
                [agilent33210A SetMessureMode:MODE_Pulse andCommunicateType:Agilent33210A_USB_Type andFREQuency:frequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
                
            }
            else if([SonTestCommand containsString:@"MODE_Noise"])
            {
                NSLog(@"print the waveDevice MODE_Noise");
                [logGlobalArray addObject:[NSString stringWithFormat: @"%@: print the waveDevice MODE_Noise\n", [[GetTimeDay shareInstance] getLogTime]]];
                [agilent33210A SetMessureMode:MODE_Noise andCommunicateType:Agilent33210A_USB_Type andFREQuency:frequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            }
            
            else//其它情况
            {
                NSLog(@"%@: %@ other condition",[[GetTimeDay shareInstance] getLogTime],SonTestDevice);
                [logGlobalArray addObject:[NSString stringWithFormat:@"%@ other condition\n",SonTestDevice]];
                
            }
            
            sleep(1);
            
        }
        
        //**************************万用表==Agilent或者Keithley
        else if ([SonTestDevice isEqualToString:@"Agilent"]||[SonTestDevice isEqualToString:@"Keithley"])
        {
            
            //0x2A8D      34461A;
            if ([aglientTools.multimeter containsString:@"0x2A8D"])
            {
                //万用表发送指令
                if ([SonTestCommand isEqualToString:@"DC Volt"])
                {
                    //直流电压测试
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_VOLT_DC andCommunicateType:Agilent34461A_MODE_USB_Type range:selRange];
                    NSLog(@"Aglient34461A set VOLT_DC");
                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient34461A set VOLT_DC\n",[[GetTimeDay shareInstance] getLogTime]]];
                    //如果是最后一项，新增加测试范围
                    if ([testItem.testName containsString:@"ESD_VOLTAGE"]) {
                        
                        [agilent34461A WriteLine:@":SENS:VOLT:DC:RANG 100" andCommunicateType:Agilent34461A_MODE_USB_Type];
                        
                    }
                
                }
                else if([SonTestCommand isEqualToString:@"AC Volt"])
                {
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_VOLT_AC andCommunicateType:Agilent34461A_MODE_USB_Type range:selRange];
                    NSLog(@"Aglient34461A set AC_Volt");
                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient34461A set AC_Volt\n",[[GetTimeDay shareInstance] getLogTime]]];
                }
                else if ([SonTestCommand isEqualToString:@"DC Current"])
                {
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_CURR_DC andCommunicateType:Agilent34461A_MODE_USB_Type range:selRange];
                    NSLog(@"Aglient34461A set DC_Current");
                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient34461A set DC_Current\n",[[GetTimeDay shareInstance] getLogTime]]];
                    
                }
                else if ([SonTestCommand isEqualToString:@"AC Current"])
                {
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_CURR_AC andCommunicateType:Agilent34461A_MODE_USB_Type range:selRange];
                    
                    NSLog(@"Aglient34461A set AC_Current");
                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient34461A set AC_Current\n",[[GetTimeDay shareInstance] getLogTime]]];
                }
                else if ([SonTestCommand containsString:@"RES"])//电阻分单位KΩ,MΩ,GΩ
                {
                    //Agilent34461A_MODE_RES_4W
                    //Agilent34461A_MODE_RES_2W
                    if ([productType isEqualToString:@"DLC"]) {
                        
                         [agilent34461A SetMessureMode:Agilent34461A_MODE_RES_2W andCommunicateType:Agilent34461A_MODE_USB_Type range:DLC_Range];
                    }
                    else
                    {
                         [agilent34461A SetMessureMode:Agilent34461A_MODE_RES_2W andCommunicateType:Agilent34461A_MODE_USB_Type range:Normal_Range];
                    }
                    
                    NSLog(@"Aglient34461A set RES");
                    
                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient34461A set RES\n",[[GetTimeDay shareInstance] getLogTime]]];
                    
                }
                else if([SonTestCommand containsString:@"Read"])
                {
//                    [agilent34461A WriteLine:@"READ?" andCommunicateType:Agilent34461A_MODE_USB_Type];
//                    
//                 agilentReadString=[agilent34461A ReadData:16 andCommunicateType:Agilent34461A_MODE_USB_Type];
                    
//                     if (param.isDebug)
//                    {
//                        //测试代码
//                        agilentReadString = @"30.838383";
//                        
//                        num = [agilentReadString floatValue];
//                    }
                    
                //**********
                    NSNumber* numberS;
                    NSMutableArray *ArrNUM;
//                    float max = 0;
//                    float min = 0;
                    ArrNUM = [NSMutableArray arrayWithCapacity:0];
                    
                    for (int i = 0; i < [agilentTestCount floatValue] ; i++) {
                        
                        [agilent34461A WriteLine:@"READ?" andCommunicateType:Agilent34461A_MODE_USB_Type];
                        
                        agilentReadString=[agilent34461A ReadData:16 andCommunicateType:Agilent34461A_MODE_USB_Type];
                        
                        numberS = @([agilentReadString floatValue]);
                        
                        NSLog(@"%d===%@",i,numberS);
                        
                        [ArrNUM addObject:[NSString stringWithFormat:@"%@", numberS]];
                        
                        //sleep([param.sleepTime floatValue]);
                        [NSThread sleepForTimeInterval:[param.sleepTime floatValue]];
                        
                    }
                    
                    [dataArr addObject:ArrNUM];
//                   NSNumber * max = [ArrNUM valueForKeyPath:@"@max.floatValue"];
//                   NSNumber * min = [ArrNUM valueForKeyPath:@"@min.floatValue"];
//                    
//                    //去掉最大值和最小值
//                    [ArrNUM removeObject:max];
//                    [ArrNUM removeObject:min];
                    
                    
                    //取平均值
                    //**************
                    num = [[ArrNUM valueForKeyPath:@"@avg.floatValue"] floatValue];
                    
                   // num = [agilentReadString floatValue];

                    NSLog(@"num ===== %f",num);
                    
                }
                else
                {
                    NSLog(@"Other Situation");
                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Other Situation\n",[[GetTimeDay shareInstance] getLogTime]]];
                }
            }
            //E4980A
//            else if([aglientTools.multimeter containsString:@"0x0957"]){
//                
//                 [agilentE4980A Find:nil andCommunicateType:AgilentE4980A_USB_Type]&&[agilentE4980A OpenDevice:nil andCommunicateType:AgilentE4980A_USB_Type];
//                    
//                    if ([SonTestCommand containsString:@"RES"])
//                    {
//                        
//                        [agilentE4980A SetMessureMode:AgilentE4980A_RX andCommunicateType:AgilentE4980A_USB_Type];
//                    
//                    }else if([SonTestCommand containsString:@"Read"]){
//                    
//                    
//                        [agilentE4980A WriteLine:@":FETC?" andCommunicateType:AgilentE4980A_USB_Type];
//                    
//                        agilentReadString=[agilentE4980A ReadData:16 andCommunicateType:AgilentE4980A_USB_Type];
//                        
//                         [agilentE4980A CloseDevice];
//                    
//                        
//                        num = [agilentReadString floatValue];
//                        
//                        NSLog(@"num ===== %f",num);
//
//                    }
//            
//            
//            
//            }
//            //3458A
//            else
//            {
//                //万用表发送指令
//                if ([SonTestCommand isEqualToString:@"DC Volt"])
//                {
//                    //直流电压测试
//                    [agilent3458A SetMessureMode:Agilent3458A_VOLT_DC];
//                    NSLog(@"Aglient3458A set VOLT_DC");
//                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient3458A set VOLT_DC\n",[[GetTimeDay shareInstance] getLogTime]]];
//                }
//                else if([SonTestCommand isEqualToString:@"AC Volt"])
//                {
//                    [agilent3458A SetMessureMode:Agilent3458A_VOLT_AC];
//                    NSLog(@"Aglient3458A set AC_Volt");
//                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient3458A set AC_Volt\n",[[GetTimeDay shareInstance] getLogTime]]];
//                    
//                }
//                else if ([SonTestCommand isEqualToString:@"DC Current"])
//                {
//                    [agilent3458A SetMessureMode:Agilent3458A_CURR_DC];
//                    NSLog(@"Aglient3458A set DC_Current");
//                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient3458A set DC_Current\n",[[GetTimeDay shareInstance] getLogTime]]];
//                    
//                }
//                else if ([SonTestCommand isEqualToString:@"AC Current"])
//                {
//                    [agilent3458A SetMessureMode:Agilent3458A_CURR_AC];
//                    
//                    NSLog(@"Aglient3458A set AC_Current");
//                    
//                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient3458A set AC_Current\n",[[GetTimeDay shareInstance] getLogTime]]];
//                    
//                }
//                else if ([SonTestCommand containsString:@"RES"])//电阻分单位KΩ,MΩ,GΩ
//                {
//                    [agilent3458A SetMessureMode:Agilent3458A_RES_2W];
//                    NSLog(@"Aglient3458A set RES");
//                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Aglient3458A set RES\n",[[GetTimeDay shareInstance] getLogTime]]];
//                    
//                }
//                else if([SonTestCommand containsString:@"Read"])
//                {
//                    
//                    [agilent3458A WriteLine:@"END"];
//                    
//                    if (param.isDebug)
//                    {
//                        //测试代码
//                        agilentReadString = @"30.838383";
//                    }
//                    else
//                    {
//                        agilentReadString=[agilent3458A ReadData:16];
//                        
//                    }
//                    
//                    num = [agilentReadString floatValue];
//                }
//                else
//                {
//                    NSLog(@"Other Situation");
//                    [logGlobalArray addObject:[NSString stringWithFormat:@"%@: Other Situation\n",[[GetTimeDay shareInstance] getLogTime]]];
//                    
//                }
//            }
            
        }
        
        else if([SonTestDevice isEqualToString:@"SW"])
        {
            //延迟时间
            NSLog(@"delayTime: %d", delayTime);
            
            [logGlobalArray addObject:[NSString stringWithFormat:@"%@: delayTime: %d\n",[[GetTimeDay shareInstance] getLogTime], delayTime]];
            
            if (!param.isDebug) {
                
            [NSThread sleepForTimeInterval:delayTime];
            }
        }
        
        //txt log
        [txtContentMutableStr appendString:[NSString stringWithFormat:@"%@ send command %@\n",SonTestDevice,SonTestCommand]];
        NSLog(@"SubTestDevice %@=====SubTestCommand %@",SonTestDevice,SonTestCommand);

        [logGlobalArray addObject:[NSString stringWithFormat:@"%@: SubTestDevice %@=====SubTestCommand %@\n",[[GetTimeDay shareInstance] getLogTime],SonTestDevice,SonTestCommand]];
    }
    

    
#pragma mark--------最终显示在 table 的测试项值
    
    testitem.value = [NSString stringWithFormat:@"%.3f",num];
    
#pragma mark--------相关单位进行换算
    //单位换算
    if ([testitem.units isEqualToString: @"mV"])
    {
        testitem.value = [NSString stringWithFormat:@"%.9f",[testitem.value floatValue]*1000];
    }
    
    if ([testitem.units isEqualToString:@"nA"])
    {
        testitem.value = [NSString stringWithFormat:@"%.9f",num*1000000000];
    }
    if ([testitem.units isEqualToString:@"uA"])
    {
        testitem.value = [NSString stringWithFormat:@"%.9f",num*1000000];
    }
    
    if ([testitem.units isEqualToString:@"A"] || [testitem.units isEqualToString:@"V"] || [testitem.units isEqualToString:@"OHM"])
    {
        testitem.value = [NSString stringWithFormat:@"%.9f",num];
    }
    if ([testitem.units isEqualToString:@"mΩ"])
    {
        testitem.value = [NSString stringWithFormat:@"%.9f",num*1000];
    }
    
    
    

#pragma mark--------对测试出来的结果进行判断和赋值
    //上下限值对比
    if (([testitem.value floatValue]>[testitem.min floatValue]&&[testitem.value floatValue]<[testitem.max floatValue]) || ([testitem.max isEqualToString:@"--"]&&[testitem.value floatValue]>[testitem.min floatValue]) || ([testitem.max isEqualToString:@"--"] && [testitem.min isEqualToString:@"--"]) || ([testitem.min isEqualToString:@"--"]&&[testitem.value floatValue]<[testitem.max floatValue]))
    {
        testitem.result = @"PASS";
        testItem.messageError=@"";
        [passItemsArr addObject: @"PASS"];
        ispass = YES;
        
      
        
    }
     else if([testitem.testName isEqualToString:@""])
    {
        
        testitem.value = @"";
        testitem.result = @"";
        ispass = YES;
        testItem.messageError=@"";
        
        
    
    }
    else
    {   
        testitem.result = @"FAIL";
        testItem.messageError=[NSString stringWithFormat:@"%@Fail",testitem.testName];
        [failItemsArr addObject:@"FAIL"];
        [sonListFailingTest appendString:[NSString stringWithFormat:@"%@:",testitem.testName]];
        ispass = NO;
    }
    
        
    [txtContentMutableStr appendString:[NSString stringWithFormat:@"TestValue:%@\nTestResult:%@\nEndTimer:%@\n-------------------\n",testitem.value,testitem.result,[[GetTimeDay shareInstance] getCurrentTime]]];
    
    //每次的测试项与测试标题存入可变数组中
    if (testItem.value!=nil&&testItem.testName!=nil&&testItem.min!=nil&&testItem.max!=nil) {
        [testItemValueArr addObject:testItem.value];
        [testItemTitleArr addObject: testItem.testName];
        [testItemMinLimitArr  addObject:testItem.min];
        [testItesmMaxLimitArr addObject:testItem.max];
        
    }
    else
    {
        [testItemValueArr addObject:@""];
        [testItemTitleArr addObject:@""];
        [testItemMinLimitArr  addObject:@""];
        [testItesmMaxLimitArr addObject:@""];
    }
    
    return ispass;
}

-(void)refreshTheInfoBox
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        passNumInfoTF.stringValue = @"0";
        passNumCalculateTF.stringValue = @"0%";
        failNumInfoTF.stringValue = @"0";
        failNumCalculateTF.stringValue = @"0%";
        totalNumInfo.stringValue = @"0";
        testNum = 0;
        passNum = 0;
        testCount.stringValue = @"0/0";
        SN_Collector.string = @"";
    });
    
}

#pragma mark-----Button action

- (IBAction)clickToTestPDCA:(NSButton *)sender
{
    if (all_Pass == YES)
    {
        [sender setTitle:@"all_pass_YES"];
        all_Pass = NO;
        NSLog(@"all_pass status is NO");
        [logGlobalArray addObject:@"all_pass status is NO\n"];
        return;
    }
    if (all_Pass == NO)
    {
        [sender setTitle:@"all_pass_NO"];
        all_Pass = YES;
        NSLog(@"all_pass status is YES");
        [logGlobalArray addObject:@"all_pass status is YES\n"];
        return;
    }
}

- (IBAction)clickToRefreshInfoBox:(NSButton *)sender
{
    [self refreshTheInfoBox];
}



//开始按钮
- (IBAction)start_Button_Action:(NSButton *)sender
{
    
    if (index == 1000)
    {
     
        
        [self removeDataFromArray];
        
        [SNArr addObjectsFromArray:@[_SN1.stringValue,_SN2.stringValue,_SN3.stringValue,_SN4.stringValue,_SN5.stringValue,_SN6.stringValue,_SN7.stringValue,_SN8.stringValue,_SN9.stringValue,_SN10.stringValue]];
        
        for (NSString * obj in SNArr) {
            
            
            if (obj.length > 0) {
                
                [sonSnArr addObject:obj];
                [havaSN addObject:@"hava"];
                
            }else{
                
                [havaSN addObject:@"NO"];
                
            }
            
        }

    
        _startBtn.enabled = NO;
   
    
        for (int i = 0; i < 10; i++) {
            
            NSTextField * tf = (NSTextField *) [self.view viewWithTag:101 + i];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                tf.backgroundColor = [NSColor selectedControlColor];
                
                
            });
            
        }//for
    
        all_SN_OK = [self detetion_SN];//确定全测的情况下SN是否为17位的方法
        
        
        if ( _single_btn.state == YES  || _all_btn.state == YES)
        {
            
            _startBtn.enabled = NO;
           
            
            if (_single_btn.state == YES  )
            {
                
                if ( all_SN_OK) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        currentStateMsg.stringValue=@"Please Enter test mode or SN";
                        
                        [currentStateMsg setTextColor:[NSColor redColor]];
                        _startBtn.enabled = YES;
                        
                    });

                }
                else{
                
                set = @"YES";
                //station_Name = @"CROWN_All";
                [mk_table ClearTable];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    
//                    itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
//                    mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN Set:set number_test:indexItemOfDut];
                    
                    if ([productType isEqualToString:@"DLC"])
                    {
                        itemArr = [plist PlistRead:testPlist Key:@"AllItems_DLC"];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_DLC" forKey:@"currentPlistKey"];
                    }
                    
                    else if ([productType isEqualToString:@"RG3"])
                    {
                        itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_RG3" forKey:@"currentPlistKey"];
                    }
                    else if ([productType isEqualToString:@"CR5"])
                    {
                        itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_CR5" forKey:@"currentPlistKey"];

                    }
                    else if ([productType isEqualToString:@"Bare Ti"])
                    {
                        itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_Bare_Ti" forKey:@"currentPlistKey"];
                    }
                    else if ([productType isEqualToString:@"BG1"])
                    {
                        itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_BG1" forKey:@"currentPlistKey"];
                    }
                    else if ([productType isEqualToString:@"DOE"])
                    {
                        itemArr = [plist PlistRead:testPlist Key:@"AllItems_DOE"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_DOE" forKey:@"currentPlistKey"];
                    }
                    else
                    {
                        itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems" forKey:@"currentPlistKey"];
                    }

                    mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN Set:set number_test:indexItemOfDut];
                    
                    index = 2;
                    _all_btn.enabled = NO;
                    _single_btn.enabled = NO;
                    
                    
                    });
                }
                
            }
            else if(_all_btn.state == YES)
            {
                
                if ([havaSN containsObject:@"NO"] || all_SN_OK) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        currentStateMsg.stringValue=@"Please Enter test mode or SN";
                        
                        [currentStateMsg setTextColor:[NSColor redColor]];
                         _startBtn.enabled = YES;
                        
                    });

                }
                else
                {
                    set = @"NO";
                   // station_Name = @"CROWN_All";
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        if ([productType isEqualToString:@"DLC"])
                        {
                            itemArr = [plist PlistRead:testPlist Key:@"AllItems_DLC"];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_DLC" forKey:@"currentPlistKey"];
                        }
                        else if ([productType isEqualToString:@"RG3"])
                        {
                            itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_RG3" forKey:@"currentPlistKey"];
                        }
                        else if ([productType isEqualToString:@"CR5"])
                        {
                            itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_CR5" forKey:@"currentPlistKey"];
                            
                        }
                        else if ([productType isEqualToString:@"Bare Ti"])
                        {
                            itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_Bare_Ti" forKey:@"currentPlistKey"];
                        }
                        else if ([productType isEqualToString:@"BG1"])
                        {
                            itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_BG1" forKey:@"currentPlistKey"];
                        }
                        else if ([productType isEqualToString:@"DOE"])
                        {
                            itemArr = [plist PlistRead:testPlist Key:@"AllItems_DOE"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"AllItems_DOE" forKey:@"currentPlistKey"];
                        }
                        else
                        {
                            itemArr = [plist PlistRead:testPlist Key:@"AllItems"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"AllItems" forKey:@"currentPlistKey"];
                        }
                        
                        mk_table = [mk_table init:tab_View DisplayData:itemArr JudgeSN:havaSN Set:set number_test:indexItemOfDut];
                        
                        index = 2;
                        _all_btn.enabled = NO;
                        _single_btn.enabled = NO;
                        
                       
                    });
                }
            }
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                currentStateMsg.stringValue=@"Please select a test mode！！";
                
                [currentStateMsg setTextColor:[NSColor redColor]];
                
                _startBtn.enabled = YES;
                
            });
            
        }
    
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            currentStateMsg.stringValue=@"Please close the door";
            
            [currentStateMsg setTextColor:[NSColor redColor]];
        });
    }
    
}


- (IBAction)ClickUploadPDCAAction:(NSButton *)sender
{
    NSLog(@"点击上传 PDCA");
}

- (IBAction)clickUpLoadSFCAction:(NSButton *)sender
{
    NSLog(@"点击上传 SFC");
}


/**
 *  必须要清除本地的存储数据,否则可能导致文件创建失败
 */
//界面消失后取消线程
-(void)viewWillDisappear
{
    //=================
    [myThrad cancel];
    myThrad = nil;
    
    //主动释放掉
    [self closeAllDevice];
    
}

-(void)viewDidDisappear{
    
    [myThrad cancel];
    myThrad = nil;
    
    //主动释放掉
    [self closeAllDevice];
    
    
    
}


//获取按钮的状态
-(void)GetSFC_PDCAState
{
    dispatch_sync(dispatch_get_main_queue(),^{
        isUpLoadSFC=[SFC_Btn state]==1?YES:NO;
        isUpLoadPDCA=[PDCA_Btn state]==1?YES:NO;
    });
}

#pragma mark----PDCA相关
//================================================
//上传pdca
//================================================
-(NSString *)GetSpecStr:(NSString *)Original thestartStr:(NSString *)startStr theendStr:(NSString *)endStr
{
    
    if([startStr length]>0 && [Original rangeOfString:startStr].length)
    {
        int sP=(int)[Original rangeOfString:startStr].location;
        sP= sP + (int)[startStr length];
        Original=[Original substringFromIndex:sP];
    }
    if([endStr length]>0 && [Original rangeOfString:endStr].length)
    {
        int eL=(int)[Original rangeOfString:endStr].location;
        return [Original substringToIndex:eL];
    }
    
    return Original;
}

BOOL stringisnumber(NSString *stringvalues){
    
    NSString *temp;
    if ([stringvalues length]) {
        for(int i=0;i<[stringvalues length];i++){
            temp=[[stringvalues substringFromIndex:i] substringToIndex:1];
            if (![@"-1234567890." rangeOfString:temp].length) {
                return FALSE;
            }
        }
    }else {
        return FALSE;
    }
    return TRUE;
}


void handleReply( IP_API_Reply reply )
{
    if ( !IP_success( reply ) )
    {
        [selfClass showAlertMessage:@"Upload PDCA data error"];
         NSLog(@"Upload PDCA data error");
        //[logGlobalArray addObject:@"Upload PDCA data error\n"];
        
        //exit(-1);
    }
    IP_reply_destroy(reply);
}



-(void)uploadPDCA_FeicuiWithItemArr:(NSArray *)ItemArray withZipString:(NSString *)ZIP_String withItemResultString:(NSString *)ItemResultString withSNString:(NSString *)Sn_Str withDataArr:(NSArray *)dataArray
{
    /**
     * info :
     *  cfailItems     ----->    all the failItems
     *  param.sw_ver   ------>  we can get the param infomation form the (Param.plist) file, like this: param.sw_ver, param.isDebug...
     *  theSN   =   importSN.stringValue
     *  itemArr ---------> All test Items  , the way to get , itemArr = [plist PlistRead:@"Station_0" Key:@"AllItems"];
     *  testItem -------->  form Item class  ,  testItem = [itemArr objectAtIndex:i],we can get different testItem ; than we have all the item infomation like this : testItem.testName/ testItem.units / testItem.min / testItem.value /testItem.max / testItem.result
     *
     */
    ReStaName =[self getValueFromJsonFileWithKey:@"STATION_TYPE"];
    
    
    IP_UUTHandle UID;
    Boolean APIcheck;
    IP_TestSpecHandle testSpec;
    
    IP_API_Reply reply = IP_UUTStart(&UID);
    
    if(!IP_success(reply))
    {
        [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(reply) encoding:1]];
    }
    
    IP_reply_destroy(reply);
    
    //上传版本，软件名，版本等
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, [ [NSString stringWithFormat:@"%@",param.sw_ver] cStringUsingEncoding:1]  ));
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWARENAME, [ReStaName cStringUsingEncoding:1]  ));
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONLIMITSVERSION, [[NSString stringWithFormat:@"%@",param.sw_ver] cStringUsingEncoding:1]));
    
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_SERIALNUMBER, [Sn_Str cStringUsingEncoding:1] ));
    
    NSLog(@"param.sw_ver=====%@",param.sw_ver);
    NSLog(@"ReStaName =======%@",ReStaName);
    
    
    
    IP_addBlob(UID, [[[NSString stringWithFormat:@"%@_%@",param.sw_name,param.sw_ver] stringByAppendingString:@"_ZIP_Log"] cStringUsingEncoding:1], [ZIP_String cStringUsingEncoding:1]);
    NSLog(@"上传zip地址***%@***",ZIP_String);
    
    
    
    
    //[itemTime appendString:[NSString stringWithFormat:@"Total Time:,%f",totalTime]];
    
    
    
    //==========================================================================================
    //----------------------- change the loop 2017.5.25 _MK ------------------------------------
    for(int i=0;i<[ItemArray count];i++)
    {
        testItem = [ItemArray objectAtIndex:i];
        //---------------------------------------
        NSString *testitemNameStr = testItem.testName;
        NSString *testitemMinStr = testItem.min;
        NSString *testitemMaxStr = testItem.max;
        NSString *testitemUnitStr = testItem.units;
        NSString *testitemValueStr = testItem.value;
        
        if ([testitemUnitStr isEqualToString:@"GΩ"])
        {
            testitemUnitStr = @"GOHM";
        }
        if ([testitemUnitStr isEqualToString:@"MΩ"])
        {
            testitemUnitStr = @"MOHM";
        }
        if ([testitemUnitStr isEqualToString:@"KΩ"])
               {
            testitemUnitStr = @"KOHM";
        }
        if ([testitemUnitStr isEqualToString:@"Ω"])
        {
            testitemUnitStr = @"OHM";
        }
        if ([testitemUnitStr isEqualToString:@"%"])
        {
            testitemUnitStr = @"PERCENT";
        }
        if ([testitemUnitStr isEqualToString:@"℃"])
        {
            testitemUnitStr = @"CELSIUS";
        }
        if ([testitemUnitStr isEqualToString:@"--"])
        {
            testitemUnitStr = @"N/A";
        }
        if(testitemMaxStr==nil || [testitemMaxStr isEqualToString:@"--"])
        {
            testitemMaxStr=@"N/A";
        }
        if(testitemMinStr==nil || [testitemMinStr isEqualToString:@"--"])
        {
            testitemMinStr=@"N/A";
        }
        
        testitemNameStr = [testitemNameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemMinStr = [testitemMinStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemMaxStr = [testitemMaxStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemUnitStr = [testitemUnitStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemValueStr=[testitemValueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        //------------------------------------------
        
        testSpec=IP_testSpec_create();
        
        //--------------------- title---------------------------
        APIcheck=IP_testSpec_setTestName(testSpec, [testitemNameStr cStringUsingEncoding:1], [testitemNameStr length]);
        
        //----------------- limits ------------------------------
        APIcheck=IP_testSpec_setLimits(testSpec, [testitemMinStr cStringUsingEncoding:1], [testitemMinStr length], [testitemMaxStr cStringUsingEncoding:1], [testitemMaxStr length]);
        
        //----------------- unit ---------------------------
        APIcheck=IP_testSpec_setUnits(testSpec, [testitemUnitStr cStringUsingEncoding:1], [testitemUnitStr length]);
        
        //----------------- priority --------------------------------
        APIcheck=IP_testSpec_setPriority(testSpec, IP_PRIORITY_REALTIME);
        
        IP_TestResultHandle puddingResult=IP_testResult_create();
        
        if(NSOrderedSame==[testitemValueStr compare:@"Pass" options:NSCaseInsensitiveSearch] || NSOrderedSame==[testitemValueStr compare:@"Fail" options:NSCaseInsensitiveSearch])
        {
            testitemValueStr=@"";
        }
        
        const char *value=[testitemValueStr cStringUsingEncoding:1];
        
        int valueLength=(int)[testitemValueStr length];
        
        int result=IP_FAIL;
        
        if([testItem.result isEqualToString:@"PASS"])
        {
            result=IP_PASS;
        }
        
        if (stringisnumber(testitemValueStr))
        {
            APIcheck=IP_testResult_setValue(puddingResult, value,valueLength);
        }
        
        APIcheck=IP_testResult_setResult(puddingResult, result);
        
        if(!result)
        {
            NSString *failDes=@"";
            
            //==========errorcode@errormessage================
            if([testItem.result length]==0)
            {
                failDes=[failDes stringByAppendingString:@"N/A" ];
            }
            
            else
            {
                failDes=[failDes stringByAppendingString:testItem.messageError==nil?@"":testItem.messageError];
            }
            
            failDes=[failDes stringByAppendingString:@","];
            
            APIcheck=IP_testResult_setMessage(puddingResult, [failDes cStringUsingEncoding:1], [failDes length]);
        }
        
        reply=IP_addResult(UID, testSpec, puddingResult);
        
        if(!IP_success(reply))
        {
            
            [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(reply) encoding:1]];
        }
        
        IP_reply_destroy(reply);
        
        IP_testResult_destroy(puddingResult);
        
        IP_testSpec_destroy(testSpec);
    }
    
    //------------------------ nothing change --------------------------------------
    IP_API_Reply doneReply=IP_UUTDone(UID);
    if(!IP_success(doneReply)){
        [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(doneReply) encoding:1]];
        
        //        exit(-1);
        IP_API_Reply amiReply = IP_amIOkay(UID, [Sn_Str cStringUsingEncoding:1]);
        if (!IP_success(amiReply))
        {
            IP_reply_destroy(amiReply);
        }
    }
    
    IP_reply_destroy(doneReply);
    
    IP_API_Reply commitReply;
    
    if([ItemResultString containsString:@"FAIL"] )
    {
        commitReply=IP_UUTCommit(UID, IP_FAIL);
    }
    else
    {
        commitReply=IP_UUTCommit(UID, IP_PASS);
    }
    
    if(!IP_success(commitReply)){}
    IP_reply_destroy(commitReply);
    IP_UID_destroy(UID);
    
}






#pragma mark--------释放所有设备
-(void)closeAllDevice
{
    //主动释放掉
    [fixtureSerial close];
    [agilent33210A CloseDevice];
    [agilent3458A CloseDevice];
    [agilent34461A CloseDevice];
    
}


#pragma mark------------------串口代理方法
-(void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    if (serialPort==fixtureSerial)
    {
        //NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [appendString appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        
        NSLog(@"打印返回的值%@",appendString);
        
        if (([appendString containsString:@"OK"]||[appendString containsString:@"start"])||([appendString containsString:@":"]&&[appendString containsString:@"\r\n"]))
        {
            backStr =appendString;
            NSLog(@"%@: fixtureSerial backStr : %@",[[GetTimeDay shareInstance] getLogTime], backStr);
            [logGlobalArray addObject:[NSString stringWithFormat:@"fixtureSerial backStr: %@\n",backStr]];
            
            appendString=[[NSMutableString alloc]initWithString:@""];
            
            isReceive = YES;
        }
        else
        {
            NSLog(@"print back string:%@",appendString);
        
        }
        
    }

}



#pragma mark-----------------UpdateTextView

-(void)UpdateTextView:(NSString*)strMsg andClear:(BOOL)flagClearContent andTextView:(NSTextView *)textView
{
    if (flagClearContent)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [textView setString:@""];
                       });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           if ([[textView string]length]>0)
                           {
                               [textView insertText:[NSString stringWithFormat:@"\n%@",strMsg]];;
                           }
                           else
                           {
                               [textView setString:[NSString stringWithFormat:@"\n\n%@",strMsg]];
                           }
                           
                           [textView setTextColor:[NSColor redColor]];
                       });
    }
}


#pragma mark-------提示框的内容
-(void)showAlertMessage:(NSString *)showMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"Comfirm";
        alert.informativeText = showMessage;
        [alert addButtonWithTitle:@"YES"];
        //第一种方式，以modal的方式出现
        [alert runModal];
    });
}



#pragma mark--------------------清空数组
-(void)removeDataFromArray
{
    [passItemsArr removeAllObjects];
    [failItemsArr removeAllObjects];
    [testItemTitleArr removeAllObjects];
    [testItemValueArr removeAllObjects];
    [testItemMinLimitArr removeAllObjects];
    [testItesmMaxLimitArr removeAllObjects];
    [testResultArr removeAllObjects];
     havaSN_num = 0;
     SN_location = 0;
     //set = @"NO";
     snIndex = 0;
    
    [ListFailingTest removeAllObjects];
    [startTimeArr removeAllObjects];
    [endTimeArr removeAllObjects];
    [snResultArry removeAllObjects];
    //[txtLogArr removeAllObjects];
    //[SNArr removeAllObjects];
    //[sonSnArr removeAllObjects];
    //[havaSN removeAllObjects];
   // [loadArr removeAllObjects];
    //[SN_SnLocationArr removeAllObjects];
    //[logGlobalArray removeAllObjects];
    if (unLimitTest) {
        
        NSLog(@"无限模式——————————");
        
    }else{
        [SNArr removeAllObjects];
        [sonSnArr removeAllObjects];
        [havaSN removeAllObjects];
        [loadArr removeAllObjects];
        [SN_SnLocationArr removeAllObjects];
        [txtLogArr removeAllObjects];
    }
    
}



#pragma mark--------------------ORSSerialPort串口中发送指令
-(void)Fixture:(ORSSerialPort *)serialPort writeCommand:(NSString *)command
{
    NSString * commandString =[NSString stringWithFormat:@"%@\r\n",command];
    NSData    * data =[commandString dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data];
}

#pragma mark---------------------cutOutStringFromStr
-(NSString  *)cutOutStringFromStr:(NSString *)Str withDivisionString:(NSString *)diviString andIndex:(int)chooseIndex
{
    
    NSString   * numStr;
    NSArray    *   numArray =[Str componentsSeparatedByString:diviString];
    if ([numArray count] >= chooseIndex) {
        
        numStr =[numArray objectAtIndex:chooseIndex-1];
    }
    
    //numStr  1000HZ 将HZ/M/G 用“”字符替代
    numStr = [numStr stringByReplacingOccurrencesOfString:@"HZ" withString:@""];
    numStr = [numStr stringByReplacingOccurrencesOfString:@"M" withString:@""];
    numStr = [numStr stringByReplacingOccurrencesOfString:@"G" withString:@""];
    
    return numStr.length>0?numStr:@"0";
}



-(NSString *)getValueFromFixture_SendCommand:(NSString *)str
{
    [self Fixture:fixtureSerial writeCommand:str];
    isReceive = NO;
    [self whileLoopTest];
    
    NSString * regexString;
    
    if([backStr containsString:@"\r\n"]){
        
        regexString = [backStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        
        //regexString = [[self parseTxt:regexString] objectAtIndex:0];
        regexString = [[regexString componentsSeparatedByString:@":"] objectAtIndex:1];
        
    }
    
    if ([regexString doubleValue]==0) {
        
        NSLog(@"打印返回来的值%@",regexString);
    }
    
    backStr = @"";
    
    return [regexString length]>0?regexString:@"1111111111";
}



-(double)getValueFromFixtureCP:(double)fixtureCp andINT:(int)CpNum
{
    double ZinValue;
    
    ZinValue = 1000000/(2*3.1415926*CpNum*fixtureCp);
    
    return ZinValue;
    
}


#pragma mark ----------getValueFromJsonFile
-(NSString *)getValueFromJsonFileWithKey:(NSString *)key
{
    
    NSError  * error;
    NSData  * data=[NSData dataWithContentsOfFile:@"/vault/data_collection/test_station_config/gh_station_info.json"];
    NSDictionary * jsonDic=[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] objectForKey:@"ghinfo"];

    return  [jsonDic objectForKey:key];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}



#pragma  mark----------循环等待，直到数据有返回
-(void)whileLoopTest
{
   [NSThread sleepForTimeInterval:0.3];

//    while (!isReceive) {
//        
//        NSLog(@"ppppppppppppp");
//        if (isReceive || param.isDebug) {
//               break;
//        }
//    }
//    
//    isReceive = NO;
   
}


#pragma mark --------------超时等待,直到有数据返回
-(void)receiveDataWithTimeOut:(float)time
{
    float  timeNum = time/10;
    float  timeadd = 0;
    while (!isReceive) {
        
        sleep(0.001);
        timeadd = timeadd + 0.001;
        
        if (isReceive||timeadd>=timeNum) {
            break;
        }
    }
    isReceive = NO;
    
}


#pragma mark---------------正则表达式
-(NSArray*)parseTxt:(NSString*)content{
    
    NSString* txtContent = [NSString stringWithFormat:@"%@", content];
    
    NSString* Pattern = @".*?\\?(.*?)\\*.*?";
    
    //NSString* Pattern = @"[0-9]";
    
    NSString *pattern = [NSString stringWithFormat:@"%@", Pattern];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *results = [regex matchesInString:txtContent options:0 range:NSMakeRange(0, txtContent.length)];
    
    NSMutableArray* stringArray = [[NSMutableArray alloc] init];
    
    if (results.count != 0) {
        for (NSTextCheckingResult* result in results) {
            for (int i=1; i<[result numberOfRanges]; i++)
            {
                [stringArray addObject:[txtContent substringWithRange:[result rangeAtIndex:i]]];
            }
        }
    }
    
    return stringArray;
}
#pragma mark 控制光标 成为第一响应者

-(void)controlTextDidChange:(NSNotification *)obj{
    
    NSTextField *tf = (NSTextField *)obj.object;
    
//    if (tf.tag == 10) {
//        
//        [tf setEditable:YES];
//    }
//    
    if (tf.stringValue.length == 17) {
        
        NSTextField *nextTF;
        
        nextTF = [self.view viewWithTag:tf.tag+1];
        
        [tf resignFirstResponder];
        [nextTF becomeFirstResponder];
        
    }
    if (tf.stringValue.length>17 &&tf.tag==10) {
        
        NSTextField * nextTF = [self.view viewWithTag:1];
        
        [nextTF setEditable:YES];
        [tf resignFirstResponder];
        [nextTF becomeFirstResponder];
        
        [tf setStringValue:[tf.stringValue substringToIndex:17]];
    }
    
}
#pragma mark---------------压缩文件
-(NSMutableArray *)pressDirectoryToZIP:(NSArray*)dataArray
{
    NSMutableArray  * ZIP_Path_Array = [[NSMutableArray alloc]initWithCapacity:10];
    
    for (int i=0; i<sonSnArr.count; i++)
    {
        
        NSString *raw_zip_folder = [[NSUserDefaults standardUserDefaults] objectForKey:@"folderPathKey"];
        
        
        NSString* data_path_csv;
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentPlistKey"] isEqualToString:@"AllItems_DLC"]) {
            
            
            //defaultFileName = [NSString stringWithFormat:@"%@%@_DLC.csv", folderPath,singlefolderDateStr];
            data_path_csv = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/%@/%@_DLC_%@.csv", sonSnArr[i],sonSnArr[i], [[GetTimeDay shareInstance] getDiretoryTime]]];
        }
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentPlistKey"] isEqualToString:@"AllItems_RG3"]){
            
             data_path_csv = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/%@/%@_RG3_%@.csv", sonSnArr[i],sonSnArr[i], [[GetTimeDay shareInstance] getDiretoryTime]]];
            
        }
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentPlistKey"] isEqualToString:@"AllItems_CR5"]){
            
            data_path_csv = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/%@/%@_CR5_%@.csv", sonSnArr[i],sonSnArr[i], [[GetTimeDay shareInstance] getDiretoryTime]]];
            
        }
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentPlistKey"] isEqualToString:@"AllItems_BG1"]){
            
            data_path_csv = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/%@/%@_BG1_%@.csv", sonSnArr[i],sonSnArr[i], [[GetTimeDay shareInstance] getDiretoryTime]]];
            
        }
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentPlistKey"] isEqualToString:@"AllItems_Bare_Ti"]){
            
            data_path_csv = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/%@/%@_Bare_Ti_%@.csv", sonSnArr[i],sonSnArr[i], [[GetTimeDay shareInstance] getDiretoryTime]]];
            
        }
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentPlistKey"] isEqualToString:@"AllItems_DOE"]){
            
            data_path_csv = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/%@/%@_DOE_%@.csv", sonSnArr[i],sonSnArr[i], [[GetTimeDay shareInstance] getDiretoryTime]]];
            
        }
        else{
            data_path_csv = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/%@/%@_%@.csv", sonSnArr[i],sonSnArr[i], [[GetTimeDay shareInstance] getDiretoryTime]]];
        }
        //NSString* data_path_csv = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/%@/%@_data_%@.csv", sonSnArr[i],sonSnArr[i], [[GetTimeDay shareInstance] getDiretoryTime]]];
        
        NSMutableString* itemCmrr = [NSMutableString string];
        
        NSString* itemTimeCmrrCsvTitle = [NSString stringWithFormat:@"SerialNumber:,%@\n", sonSnArr[i]];
        
        [itemCmrr appendString:itemTimeCmrrCsvTitle];
        
        [itemCmrr appendString:@",,"];
        
        for (id obj in dataArray[i]) {
            
            [itemCmrr appendString:[NSString stringWithFormat:@"%@,", obj]];
            
        }
        
//        for(int i = 0; i < [dataArray[i] count]; i++){
//            
//            if (i != [dataArray[i] count]-1) {
//             
//                [itemCmrr appendString:[NSString stringWithFormat:@"%@,", dataArray[i]]];
//            }
//            else{
//                [itemCmrr appendString:[NSString stringWithFormat:@"%@", dataArray[i]]];
//                
//                
//            }
//        }
        
        
        [itemCmrr writeToFile:data_path_csv atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        //------------ 压缩并上传文件到服务器------------------------------
//        NSTask *task;
//        task = [[NSTask alloc] init];
//        [task setLaunchPath:@"/bin/sh"];
//        NSString *cmd = [NSString stringWithFormat:@"cd %@; zip -r %@.zip %@",[MK_FileFolder shareInstance].folderPath,sonSnArr[i],sonSnArr[i]];
//        
//        NSLog(@"============cmd: %@", cmd);
//        [logGlobalArray addObject:[NSString stringWithFormat:@"%@: ============cmd: %@\n", [[GetTimeDay shareInstance] getLogTime],cmd]];
//        NSArray *argument = [NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"%@", cmd], nil];
//        [task setArguments: argument];
//        NSPipe *pipe;
//        pipe = [NSPipe pipe];
//        [task setStandardOutput: pipe];
//        [task launch];
//        NSString *ZIP_path = [NSString stringWithFormat:@"%@/%@.zip",[MK_FileFolder shareInstance].folderPath,sonSnArr[i]];
//        [logGlobalArray addObject:[NSString stringWithFormat:@"%@: ZIP_FilePath == %@\n",[[GetTimeDay shareInstance] getLogTime],ZIP_path]];
//        sleep(1);
//        int FileCount = 0;
//        while (true) {
//            
//            if([[NSFileManager defaultManager] fileExistsAtPath:ZIP_path]){
//                NSLog(@"file has been existed");
//                [logGlobalArray addObject:@"file has been existed"];
//                break;
//            }
//            else
//            {
//                NSLog(@"file has been not existed");
//                [logGlobalArray addObject:@"file has been not existed"];
//                FileCount++;
//                
//                sleep(0.5);
//                
//                if (FileCount>=3) {
//                    break;
//                }
//            }
//            
//            
//        }
//        [ZIP_Path_Array addObject:ZIP_path];
    }
    return ZIP_Path_Array;
}
#pragma mark-----------------将数组进行分组
-(NSMutableArray *)GetArrayWithArray
{
    NSMutableArray   *  item_Arr = [[NSMutableArray alloc]init];
    NSMutableArray    * arr      = [[NSMutableArray alloc]init];
    
    NSLog(@"打印当前的数组个数%lu",(unsigned long)[sonSnArr count] * (indexItemOfDut+1));
    for (int i=0; i<[sonSnArr count] * (indexItemOfDut+1); i++) {
        
        [arr addObject:_single_btn.state ? loadArr[i]: itemArr[i]];
        
        if (i%(indexItemOfDut+1)==indexItemOfDut) {
            
            [item_Arr addObject:arr];
            arr = [[NSMutableArray alloc]init];
        }
        if (i==[sonSnArr count] * (indexItemOfDut + 1 )-1) {
            
            NSLog(@"打印i变量的值%d",i);
            
            break;
        }
    }
    
    return item_Arr;
}
#pragma mark-----------------详细的Log日志
-(void)writeDetailLog
{
    //================================详细的Log日志
    NSString *raw_zip_folder = [[NSUserDefaults standardUserDefaults] objectForKey:@"folderPathKey"];
    NSString* log_path = [raw_zip_folder stringByAppendingString:[NSString stringWithFormat:@"/detailLog.txt"]];
    
    NSMutableString* logGlobalTxt= [NSMutableString string];
    for (id obj in logGlobalArray) {
        [logGlobalTxt appendString:[NSString stringWithFormat:@"%@\n", obj]];
    }
    [logGlobalTxt writeToFile:log_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}





@end
