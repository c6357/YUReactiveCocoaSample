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
        NSLog(@"%@", x);
    }];
    
    
    //step 2
    [[self.textField.rac_textSignal filter:^BOOL(id value) {
        NSString*text = value;
        return text.length > 3;
    }] subscribeNext:^(id x) {
         NSLog(@"%@", x);
    }];
    

    //step 3
    RACSignal *usernameSourceSignal = self.textField.rac_textSignal;
    
    RACSignal *filteredUsername =[usernameSourceSignal filter:^BOOL(id value)
    {
          NSString*text = value;
          return text.length > 3;
    }];
    [filteredUsername subscribeNext:^(id x){
        
        NSLog(@"%@", x);
    }];
    
    
    //step 4
    [[self.textField.rac_textSignal
      filter:^BOOL(id value){
          NSString*text = value; // implicit cast
          return text.length > 3;
      }]
     subscribeNext:^(id x){
         NSLog(@"%@", x);
     }];
    
    
    //step 5
    [[self.textField.rac_textSignal
      filter:^BOOL(NSString*text){
          return text.length > 3;
      }]
     subscribeNext:^(id x){
         NSLog(@"%@", x);
     }];
    
    
    //step 6
    [[[self.textField.rac_textSignal
        map:^id(NSString*text){
           return @(text.length);
        }]
        filter:^BOOL(NSNumber*length){
          return[length integerValue] > 3;
        }]
        subscribeNext:^(id x){
         NSLog(@"%@", x);
    }];
    
    
    /**
     *  textView
     */
    [self.textView.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
@end
