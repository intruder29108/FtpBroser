//
//  ViewController.h
//  MoveMouse
//
//  Created by Anil Unnikrishnan on 11/09/12.
//  Copyright (c) 2012 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@protocol ProcessDataDelegate <NSObject>
@required
- (void) error:(ViewController*)sender;
@end

@interface ViewController : UIViewController <NSStreamDelegate,UITextFieldDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *mDir;
    NSString *click;
    NSString *ip;
    NSTimer* connectionTimeoutTimer;
    NSInteger error;
}
- (IBAction)leftClicked:(id)sender;
- (IBAction)rightClicked:(id)sender;
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode;
@property (retain, nonatomic) IBOutlet UITextField *ipOutlet;
@property (retain, nonatomic) IBOutlet UILabel *labelOutlet;

@property (retain, nonatomic) IBOutlet UIButton *leftOutlet;
@property (retain, nonatomic) IBOutlet UIButton *rightOutlet;
@property (retain, nonatomic) NSString *ip;
@property (nonatomic, retain) NSTimer* connectionTimeoutTimer;
@property (nonatomic) NSInteger error;
@property (nonatomic, assign) id <ProcessDataDelegate> delegate;
@end
