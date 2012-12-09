//
//  PasswordView.h
//  FtpBrowser
//
//  Created by intruder on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  PasswordView;
@protocol AuthenticationDelegate <NSObject>

- (void) authenticationComplete:(PasswordView *)sender;

@end

@interface PasswordView : UIViewController <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITextField *usernameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (assign, nonatomic) id <AuthenticationDelegate> delegate;
- (IBAction)submitAction:(id)sender;

@end
