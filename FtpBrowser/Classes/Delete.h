//
//  Delete.h
//  FtpBrowser
//
//  Created by intruder on 21/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#include <CFNetwork/CFNetwork.h>

@class Delete;

@protocol DeleteDelegate <NSObject>

- (void) deleteEnded:(Delete *)sender;

@end

@interface Delete : NSObject <NSStreamDelegate,DeleteDelegate>
{
    NSString *mUsername;
    NSString *mPassword;
    NSString *mPath;
    int mCount;
    Delete *deleteDir;
}


@property (nonatomic,assign,readonly) BOOL isReceiving;
@property (nonatomic,strong,readwrite) NSInputStream *networkStream;
@property (nonatomic,strong,readwrite) NSMutableData *listData;
@property (nonatomic,strong,readwrite) NSString *status;
@property (nonatomic,assign) id <DeleteDelegate> delegate;
@property (nonatomic,retain) NSString *path;

- (id) initWithUser:(NSString *)username Password:(NSString *)passowrd AtPath:(NSString *)path;
- (void) receiveDidStopWithStatus:(NSString *)statusString;
- (void) receiveDidStart;
- (void) startDeleteDirectory;
- (NSDictionary *)entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding;



@end
