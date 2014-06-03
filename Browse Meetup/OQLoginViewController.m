//
//  OQLoginViewController.m
//  BrowseMeetup
//
//  Created by Chris Morse on 6/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "OQLoginViewController.h"

#import "MasterViewController.h"
#import "OQConnectionManager.h"
#import "OQLocationManager.h"

@interface OQLoginViewController ()

@end

@implementation OQLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)loginAction:(UIButton *)sender {
    //Lock-out login button to prevent double taps
    sender.userInteractionEnabled = NO;
    sender.enabled = NO;
    [self.busySpinner startAnimating];

    //Call singleton connection manager to perform the login. He'll call our block when he's done
    OQConnectionManager* connManager = [OQConnectionManager sharedOQConnectionManager];
    [connManager login:self.userNameTextField.text
              password:self.passwordTextField.text
            completion:^(NSError *error)
    {
        if (!error && connManager.isAuthenticated) {
            //Show main screen now
            [self performSegueWithIdentifier:@"loginSegue" sender:self];

            //Post last known location
            OQLocation* lastKnownLocation = [OQLocationManager sharedOQLocationManager].locationHistory.lastObject;
            if (lastKnownLocation) [connManager postLocation:lastKnownLocation];
        } else {
            //Failed API call, abort
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                            message:@"Your username or password is incorrect. Please try again"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }

        //Restore login button state
        sender.userInteractionEnabled = YES;
        sender.enabled = YES;
        [self.busySpinner stopAnimating];
    }]; //end login completion block
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self loginAction:self.loginButton];
    }
    return YES;
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

@end
