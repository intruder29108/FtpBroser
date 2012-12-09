//
//  Uploader.h
//  FtpBrowser
//
//  Created by intruder on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#include <CFNetwork/CFNetwork.h>

@class Uploader;

@protocol UploadDelegate <NSObject>

- (void) sendDidStopWithStatus:(NSString *) status;
- (void) sendDidStart:(NSString *) status;
- (void) updateStatus:(NSString *) status;
- (void) updateProgressWithValue:(float) value;

@end

enum 
{
    kSendBufferSize = 32768
};

@interface Uploader : NSObject <NSStreamDelegate>
{
    uint8_t                     _buffer[kSendBufferSize];
    int size;
    int total;
}


// network related parameters


@property (nonatomic, assign, readonly ) BOOL              isSending;
@property (nonatomic, strong, readwrite) NSOutputStream *  networkStream;
@property (nonatomic, strong, readwrite) NSInputStream *   fileStream;
@property (nonatomic, assign, readonly ) uint8_t *         buffer;
@property (nonatomic, assign, readwrite) size_t            bufferOffset;
@property (nonatomic, assign, readwrite) size_t            bufferLimit;
@property (nonatomic, retain)            NSString *        username;
@property (nonatomic, retain)            NSString *        password;
@property (nonatomic, assign)            id <UploadDelegate> delegate;

- (id) initWithUserName:(NSString *)username Password:(NSString *)password;
- (void)startSendingFile:(NSString *)filePath ToServer:(NSString *)serverPath;


@end
