//
//  CELSignUpViewController.m
//  
//
//  Created by Carter Levin on 7/17/14.
//
//

#import "CELSignUpViewController.h"
#import "CELCoreDataStore.h"
#import "User.h"

@interface CELSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)signUpButton:(id)sender;

@end

@implementation CELSignUpViewController

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

- (IBAction)signUpButton:(id)sender {
    CELCoreDataStore *store = [CELCoreDataStore sharedDataStore];
    NSString *username = self.userNameField.text;
    NSString *password = self.passwordField.text;
    
    [store createUserWithName:username passWord:password completion:^(NSString *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            NSLog(@"%@", error);
            [self performSegueWithIdentifier:@"finishedSignUp" sender:self];
        }];
    }];
}
@end
