//
//  ViewController.m
//  MoveMouse
//
//  Created by Anil Unnikrishnan on 11/09/12.
//  Copyright (c) 2012 Sourcebits. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize ipOutlet;
@synthesize labelOutlet;
@synthesize leftOutlet;
@synthesize rightOutlet;
@synthesize ip;
@synthesize connectionTimeoutTimer;
@synthesize error;
@synthesize delegate = _delegate;

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"stream:handleEvent: is invoked...");
    
    switch(eventCode) {
        case NSStreamEventErrorOccurred:
        {
            NSError *theError = [outputStream streamError];
            NSLog(@"%d",[theError code]);
            if ([theError code] == 2)
            {
                
                error = [theError code]; 
            }
            [stream close];
            [stream release];
            break;
        }
            // continued ....
    }
    [self.delegate error:self];
}

- (void)initNetworkCommunication {
    
    NSLog(@"IP IS ----%@",ip);
    ip = @"192.168.18.24";
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)ip, 5555, &readStream, &writeStream);
    
    outputStream = (NSOutputStream *)writeStream;
    [outputStream setDelegate:self];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream open];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initNetworkCommunication];
    mDir = [[NSString alloc]init];
    click = [[NSString alloc]init];;
}

- (void)viewDidUnload
{
    [self setLeftOutlet:nil];
    [self setRightOutlet:nil];
    [self setIpOutlet:nil];
    [self setLabelOutlet:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
    
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint newPoint = [touch locationInView:self.view];
    CGPoint oldPoint = [touch previousLocationInView:self.view];
    //NSLog(@"%f %f", touchPoint.x, touchPoint.y);
    //NSLog(@"Previous ====== %f %f",newPoint.x, newPoint.y);
    if (newPoint.x > oldPoint.x)
        mDir = [NSString stringWithFormat:@"R"];
    if (newPoint.x < oldPoint.x)
        mDir = [NSString stringWithFormat:@"L"];
    if (newPoint.y < oldPoint.y)
        mDir = [NSString stringWithFormat:@"U"];
    if (newPoint.y > oldPoint.y)
        mDir = [NSString stringWithFormat:@"D"];
    NSString *response  = [NSString stringWithFormat:mDir];
   	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
   	[outputStream write:[data bytes] maxLength:[data length]];
    //NSLog(@"%d", [data length]);    
}


- (IBAction)leftClicked:(id)sender {
    click = [NSString stringWithFormat:@"E"];
    NSLog(@"%@",click);
    NSString *response1  = [NSString stringWithFormat:click];
    NSData *data1 = [[NSData alloc] initWithData:[response1 dataUsingEncoding:NSUTF8StringEncoding]];
    [outputStream write:[data1 bytes] maxLength:[data1 length]];

}

- (IBAction)rightClicked:(id)sender {
    click = [NSString stringWithFormat:@"I"];
    NSLog(@"%@",click);
    NSString *response1  = [NSString stringWithFormat:click];
    NSData *data1 = [[NSData alloc] initWithData:[response1 dataUsingEncoding:NSUTF8StringEncoding]];
    [outputStream write:[data1 bytes] maxLength:[data1 length]];
}
- (void)dealloc {
    [leftOutlet release];
    [rightOutlet release];
    [ipOutlet release];
    [labelOutlet release];
    [super dealloc];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    self.ip = ipOutlet.text;
    [textField resignFirstResponder];
    return YES;
}

@end
