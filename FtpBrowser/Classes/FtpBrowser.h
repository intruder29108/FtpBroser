//
//  FtpBrowser.h
//  FtpBrowser
//
//  Created by intruder on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"
#include <sys/socket.h>
#include <sys/dirent.h>
#include <CFNetwork/CFNetwork.h>
#import "PasswordView.h"
#import "BButton.h"
#import <QuartzCore/QuartzCore.h>
#import "PSDirectoryPickerController.h"
#import "Uploader.h"
#import "EGORefreshTableHeaderView.h"
#import "Delete.h"
#import "UIViewController+MJPopupViewController.h"
#import "Entry.h"
#import "DDAlertPrompt.h"

typedef enum
{
    LIST,GET,PUT
} REQ;

@interface FtpBrowser : UIViewController <UITextFieldDelegate,NSStreamDelegate,UITableViewDelegate,UITableViewDataSource,AuthenticationDelegate,EGORefreshTableHeaderDelegate,DeleteDelegate,UploadDelegate,PSDirectoryPickerDelegate,UIAlertViewDelegate>
{
    CGRect urlFieldFrame;
    BOOL editURL;
    NSMutableArray *mServers;
    BOOL entrySelected;
    NSString *username;
    NSString *password;
    int selectedServer;
    NSArray *searchResults;
    NSMutableArray *historyStack;
    REQ req_type;
    NSString *selectedFile;
    int size;
    int total;
    NSMutableArray *myStack;
    
    
    // Pull to refresh
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
        
    
    // For Delete Operation
    Delete *delete;
    
    int mCount;
    NSIndexPath *mSelectedIndexPath;
    
    
    // Login
    BOOL firstTimeConnection;
}


// Outlets

@property (nonatomic,retain) IBOutlet UITableView *listTable;
@property (nonatomic,retain) IBOutlet UITextField *urlField;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic,retain) NSMutableArray *mServers;
@property (nonatomic,retain) PasswordView *passwordView;
@property (nonatomic,retain) IBOutlet UIView *subView;
@property (nonatomic,retain) IBOutlet BButton *downloadButton;


// Network related parameters

@property (nonatomic, assign, readonly ) BOOL              isReceiving;
@property (nonatomic, strong, readwrite) NSInputStream *   networkStream;
@property (nonatomic, strong, readwrite) NSMutableData *   listData;
@property (nonatomic, strong, readwrite) NSMutableArray *  listEntries;
@property (nonatomic, copy,   readwrite) NSString *        status;
@property (nonatomic,strong) NSString *                    username;
@property (nonatomic,strong) NSString *                    password;
@property (nonatomic,retain) NSMutableArray *              historyStack;
@property (nonatomic,retain) NSOutputStream *              fileStream;
@property (nonatomic,retain) NSString *                    filePath;
@property (nonatomic,retain) NSString *                    selectedFile;

// Details View Outlets

@property (nonatomic,retain) IBOutlet UIView *detailsView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) IBOutlet UILabel *dateLabel;
@property (nonatomic,retain) IBOutlet UILabel *permissionLabel;
@property (nonatomic,retain) IBOutlet UILabel *sizeLabel;
@property (nonatomic,retain) IBOutlet UIProgressView *progressBar;
@property (nonatomic,retain) IBOutlet UILabel *speedLabel;



// Loading Cell Outlets
@property (nonatomic,retain) IBOutlet UITableViewCell*loadingCell;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic,retain) IBOutlet UIButton *uploadButton;
@property (nonatomic,retain) Uploader *upload;


@property (nonatomic,retain) UILocalizedIndexedCollation *collation;
@property (nonatomic,retain) NSMutableArray *sectionsArray;


@property (nonatomic) NSTimeInterval start_time;
@property (nonatomic) int total_bytes;



// Info View


@property (nonatomic,retain) IBOutlet UIView *infoView;
@property (nonatomic,retain) IBOutlet UILabel *infoLabel;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *infoActivityIndicator;
@property (nonatomic,retain) IBOutlet UIProgressView *uploadProgressBar;


// Login View

@property (nonatomic,retain) IBOutlet UIView *loginView;
@property (nonatomic,retain) IBOutlet UITextField *loginUsername;
@property (nonatomic,retain) IBOutlet UITextField *loginPassword;
@property (nonatomic,retain) IBOutlet UILabel *loginStatus;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *loginActivity;


// Actions


// Login Actions

- (IBAction)loginAction:(UIButton *)sender;


// Details View Action

- (IBAction) buttonPressed:(UIButton *)sender;

- (IBAction)controlButtonPressed:(UIBarButtonItem *)sender;
- (void) startRecieve;
- (NSDictionary *)entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding;
- (void) parseListData;
- (void)addListEntries:(NSArray *)newEntries;
- (void) clearList;
- (void)stopReceiveWithStatus:(NSString*)status;
- (void)receiveDidStart;
- (BOOL)isReceiving;
- (void)receiveDidStopWithStatus:(NSString *)statusString;


// Formatting functions

- (NSString *)stringForNumber:(double)num asUnits:(NSString *)units;
- (NSString *)stringForFileSize:(unsigned long long)fileSizeExact;


- (void) configureSections;



// Pull to refresh

- (void)doneLoadingTableViewData;


@end
