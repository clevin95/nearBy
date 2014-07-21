//
//  CELLogInViewController.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/18/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELLogInViewController.h"
#import "CELCoreDataStore.h"

@interface CELLogInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)signInTapped:(id)sender;

@end

@implementation CELLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)signInTapped:(id)sender {
    
    
    CELCoreDataStore *store = [CELCoreDataStore sharedDataStore];
    NSString *inputName = self.usernameField.text;
    NSString *inputPassword = self.passwordField.text;
    [store validateForUserWithName:inputName password:inputPassword wasErrorBlock:^(NSString *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            if (error){
                [self createAlertViewWithTitle:error];
            }else{
                [self performSegueWithIdentifier:@"finishLogIn" sender:self];
            }
        }];
    }];
}


- (void)createAlertViewWithTitle:(NSString *)title
{
    UIAlertView *invalidLogin = [[UIAlertView alloc]initWithTitle:title message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
   [invalidLogin show];
    
}




@end
