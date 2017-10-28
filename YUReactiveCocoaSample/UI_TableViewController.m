//
//  UI_TableViewController.m
//  YUReactiveCocoaSample
//
//  Created by BruceYu on 15/11/9.
//  Copyright © 2015年 BruceYu. All rights reserved.
//


#import "UI_TableViewController.h"
#import "RWViewController.h"
#import "YUSignInViewController.h"

#define Storyboard(identifier) [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:identifier]

//http://benbeng.leanote.com/post/ReactiveCocoaTutorial-part1


@interface UI_TableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *functionalBtn;
@property (weak, nonatomic) IBOutlet UIButton *reactiveBtn;

@end

@implementation UI_TableViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    /**
     *  textField
     */
    //step 1
    [self.textField.rac_textSignal subscribeNext:^(id x){
        NSLog(@"step 1 %@", x);
    }];
    
    
    //step 2
    [[self.textField.rac_textSignal filter:^BOOL(id value) {
        NSString*text = value;
        return text.length > 3;
    }] subscribeNext:^(id x) {
        NSLog(@"step 2 %@", x);
    }];
    

    //step 3
    RACSignal *usernameSourceSignal = self.textField.rac_textSignal;
    
    RACSignal *filteredUsername = [usernameSourceSignal filter:^BOOL(id value)
    {
          NSString*text = value;
          return text.length > 3;
    }];
    [filteredUsername subscribeNext:^(id x){
        
        NSLog(@"step 3 %@", x);
    }];
    
    
    //step 4
    [[self.textField.rac_textSignal
      filter:^BOOL(id value){
          NSString*text = value; // implicit cast
          return text.length > 3;
      }]
     subscribeNext:^(id x){
         NSLog(@"step 4 %@", x);
     }];
    
    
    //step 5
    [[self.textField.rac_textSignal
      filter:^BOOL(NSString*text){
          return text.length > 3;
      }]
     subscribeNext:^(id x){
         NSLog(@"step 5 %@", x);
     }];
    
    
    
    [[[self.textField.rac_textSignal map:^id(NSString*value){
        return @(value.length);
    }]filter:^BOOL(NSNumber*value){
        return YES;
    }]subscribeNext:^(id x){
        NSLog(@"step 6 %@", x);
    }];
    
    //step 6
//    [[[self.textField.rac_textSignal
//        map:^id(NSString*text){
//           return @(text.length);
//        }]
//        filter:^BOOL(NSNumber*length){
//          return[length integerValue] > 30;
//        }]
//        subscribeNext:^(id x){
//         NSLog(@"step 6 %@", x);
//    }];
    
    
    /**
     *  textView
     */
    [self.textView.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"textView %@",x);
    }];
    
    
    /**
     *  button
     */
    @weakify(self);
    [[self.functionalBtn
      rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
        NSLog(@"functionalBtn clicked");
         dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
             RWViewController *signIn = Storyboard(@"RWViewController");
             [self.navigationController pushViewController:signIn animated:YES];
         });
        
     }];
    
    [[self.reactiveBtn
      rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         NSLog(@"reactiveBtn clicked");
//         [self performSegueWithIdentifier:@"YUSignIn" sender:self];
         
     }];
    
    
    


    

    
    
//    @weakify(self);
//    [[RACObserve(self, warningText)
//      filter:^(NSString *newString) {
//          self.resultLabel.text = newString;
//          return YES;
//          //          return [newString hasPrefix:@"Success"];
//      }]
//     subscribeNext:^(NSString *newString) {
//         @strongify(self);
//         self.bt.enabled = [newString hasPrefix:@"Success"];
//     }];
//    
//    
//    RAC(self,self.warningText) = [RACSignal combineLatest:@[
//                                                            RACObserve(self,self.input.text),RACObserve(self, self.verifyInput.text)]
//                                                   reduce:^(NSString *password, NSString *passwordConfirm)
//    {
//        if ([passwordConfirm isEqualToString:password])
//        {
//            return @"Success";
//        }
//        else if([password length] == 0 || [passwordConfirm length] ==0 )
//        {
//            return @"Please Input";
//        }
//        else
//            return @"Input Error";
//    }
//                                  ];
    
    
//    [self createSignalTest1];
//    [self createSignalTest2];
    [self createSignalTest3];
}

//RACSubject替换代理
-(void)createSignalTest3{
    // 需求:
    // 1.给当前控制器添加一个按钮，modal到另一个控制器界面
    // 2.另一个控制器view中有个按钮，点击按钮，通知当前控制器
    
    //步骤一：在第二个控制器.h，添加一个RACSubject代替代理。
    @interface TwoViewController : UIViewController
    
    @property (nonatomic, strong) RACSubject *delegateSignal;
    
    @end
    
    //步骤二：监听第二个控制器按钮点击
    @implementation TwoViewController
    - (IBAction)notice:(id)sender {
        // 通知第一个控制器，告诉它，按钮被点了
        
        // 通知代理
        // 判断代理信号是否有值
        if (self.delegateSignal) {
            // 有值，才需要通知
            [self.delegateSignal sendNext:nil];
        }
    }
    @end
    
    //步骤三：在第一个控制器中，监听跳转按钮，给第二个控制器的代理信号赋值，并且监听.
    @implementation OneViewController
    - (IBAction)btnClick:(id)sender {
        
        // 创建第二个控制器
        TwoViewController *twoVc = [[TwoViewController alloc] init];
        
        // 设置代理信号
        twoVc.delegateSignal = [RACSubject subject];
        
        // 订阅代理信号
        [twoVc.delegateSignal subscribeNext:^(id x) {
            
            NSLog(@"点击了通知按钮");
        }];
        
        // 跳转到第二个控制器
        [self presentViewController:twoVc animated:YES completion:nil];
        
    }
    @end
}

///RACSubject和RACReplaySubject简单使用:
-(void)createSignalTest2{
    // RACSubject使用步骤
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 sendNext:(id)value
    
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@[@(1),@(2)]];
    
    
    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.可以先订阅信号，也可以先发送信号。
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第二个订阅者接收到的数据%@",x);
    }];
}

///RACSiganl简单使用:
-(void)createSignalTest1{
    // 1.创建信号
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        
        // 2.发送信号
        [subscriber sendNext:@1];
        
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        //        [subscriber sendError:[NSError new]];
        
        return [RACDisposable disposableWithBlock:^{
            
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            
            // 执行完Block后，当前信号就不在被订阅了。
            
            NSLog(@"信号被销毁");
            
        }];
    }];
    
    // 3.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
@end
