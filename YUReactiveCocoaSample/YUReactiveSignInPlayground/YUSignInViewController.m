//
//  YUSignInViewController.m
//  YUReactiveCocoaSample
//
//  Created by BruceYu on 15/11/9.
//  Copyright © 2015年 BruceYu. All rights reserved.
//

#import "YUSignInViewController.h"
#import "ReactiveCocoa.h"
#import "RWDummySignInService.h"

@interface YUSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureText;

@property (strong, nonatomic) RWDummySignInService *signInService;
@end

@implementation YUSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.signInService = [RWDummySignInService new];
    
    // initially hide the failure message
    self.signInFailureText.hidden = YES;
    
//    
//    // setp 1
//    [[[self.signInButton
//       rac_signalForControlEvents:UIControlEventTouchUpInside]
//      map:^id(id x){
//          return[self signInSignal];
//      }]
//     subscribeNext:^(id x){
//         NSLog(@"Sign in result: %@", x);
//     }];
//    
//    
//    // setp 2
//    [[[self.signInButton
//       rac_signalForControlEvents:UIControlEventTouchUpInside]
//      flattenMap:^id(id x){
//          return[self signInSignal];
//      }]
//     subscribeNext:^(id x){
//         NSLog(@"Sign in result: %@", x);
//     }];
//    
//    
//    // setp 3
//    [[[self.signInButton
//       rac_signalForControlEvents:UIControlEventTouchUpInside]
//      flattenMap:^id(id x){
//          return[self signInSignal];
//      }]
//     subscribeNext:^(NSNumber*signedIn){
//         BOOL success =[signedIn boolValue];
//         self.signInFailureText.hidden = success;
//         if(success){
//             [self performSegueWithIdentifier:@"signInSuccess" sender:self];
//         }
//     }];
//
    
    
    RACSignal *validUsernameSignal =
    [self.usernameTextField.rac_textSignal
     map:^id(NSString *text) {
         return @([self isValidUsername:text]);
     }];
    RACSignal *validPasswordSignal =
    [self.passwordTextField.rac_textSignal
     map:^id(NSString *text) {
         return @([self isValidPassword:text]);
     }];
    
    RAC(self.passwordTextField, backgroundColor) =
    [validPasswordSignal
     map:^id(NSNumber *passwordValid){
         return[passwordValid boolValue] ? [UIColor clearColor]:[UIColor yellowColor];
     }];
    
    RAC(self.usernameTextField, backgroundColor) =
    [validUsernameSignal
     map:^id(NSNumber *passwordValid){
         return[passwordValid boolValue] ? [UIColor clearColor]:[UIColor yellowColor];
     }];
    

    
    
    RACSignal *signUpActiveSignal =
    [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
                      reduce:^id(NSNumber*usernameValid, NSNumber *passwordValid){
                          return @([usernameValid boolValue]&&[passwordValid boolValue]);
                      }];
    [signUpActiveSignal subscribeNext:^(NSNumber*signupActive){
        self.signInButton.enabled =[signupActive boolValue];
    }];
    
    
    // setp 4
    [[[[self.signInButton
        rac_signalForControlEvents:UIControlEventTouchUpInside]
       doNext:^(id x){
           self.signInButton.enabled =NO;
           self.signInFailureText.hidden =YES;
       }]
      flattenMap:^id(id x){
          return[self signInSignal];
      }]
     
     subscribeNext:^(NSNumber*signedIn){
         self.signInButton.enabled =YES;
         BOOL success =[signedIn boolValue];
         self.signInFailureText.hidden = success;
         if(success){
             [self performSegueWithIdentifier:@"signInSuccess" sender:self];
         }
     }];
    


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - private

- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 3;
}

- (RACSignal *)signInSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        [self.signInService
         signInWithUsername:self.usernameTextField.text
         password:self.passwordTextField.text
         complete:^(BOOL success){
             [subscriber sendNext:@(success)];
             [subscriber sendCompleted];
         }];
        return nil;
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
