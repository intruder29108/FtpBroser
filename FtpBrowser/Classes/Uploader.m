//
//  Uploader.m
//  FtpBrowser
//
//  Created by intruder on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Uploader.h"

@implementation Uploader

@synthesize networkStream = _networkStream;
@synthesize fileStream    = _fileStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;
@synthesize isSending     = _isSending;

@synthesize username = _username;
@synthesize password = _password;
@synthesize delegate = _delegate;



- (id) initWithUserName:(NSString *)username Password:(NSString *)password
{
    self = [super init];
    if(self)
    {
        self.username = username;
        self.password = password;
        self.fileStream = nil;
        self.networkStream = nil;
        
    }
    return self;
}
#pragma mark * Core transfer code

// This is the code that actually does the networking.

// Because buffer is declared as an array, you have to use a custom getter.  
// A synthesised getter doesn't compile.

- (uint8_t *)buffer
{
    return self->_buffer;
}

- (BOOL)isSending
{
    return (self.networkStream != nil);
}

- (void)startSendingFile:(NSString *)filePath ToServer:(NSString *)serverPath
{
    BOOL                    success;
    NSURL *                 url;
    
    assert(filePath != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    assert(self.networkStream == nil);      // don't tap send twice in a row!
    assert(self.fileStream == nil);         // ditto
    
    // First get and check the URL.
    
    serverPath = [serverPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [[NetworkManager sharedInstance] smartURLForString:serverPath];
    success = (url != nil);
    
    
    // Get the size of the file to upload
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager  attributesOfItemAtPath:filePath error:nil];
    size = [attributes fileSize];
    if (success) 
    {
        // Add the last part of the file name to the end of the URL to form the final 
        // URL that we're going to put to.
        
        url = CFBridgingRelease(
                                CFURLCreateCopyAppendingPathComponent(NULL, (__bridge CFURLRef) url, (__bridge CFStringRef) [filePath lastPathComponent], false)
                                );
        success = (url != nil);
    }
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) 
    {
        NSLog(@"Invalide URL");
    } 
    else 
    {
        
        // Open a stream for the file we're going to send.  We do not open this stream; 
        // NSURLConnection will do it for us.
        
        self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        // Open a CFFTPStream for the URL.
        
        self.networkStream = CFBridgingRelease(
                                               CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url)
                                               );
        assert(self.networkStream != nil);
        
        success = [self.networkStream setProperty:self.username forKey:(id)kCFStreamPropertyFTPUserName];
        assert(success);
        success = [self.networkStream setProperty:self.password forKey:(id)kCFStreamPropertyFTPPassword];
        assert(success);
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];
        
        // Tell the UI we're sending.
        
        [self.delegate sendDidStart:@"Started upload"];
    }
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self.delegate sendDidStopWithStatus:statusString];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.networkStream);
    switch (eventCode) 
    {
        case NSStreamEventOpenCompleted: 
        {
            [self.delegate updateStatus:@"Opened connection"];
        } 
            break;
        case NSStreamEventHasBytesAvailable: 
        {
            assert(NO);     // should never happen for the output stream
        } 
            break;
        case NSStreamEventHasSpaceAvailable: 
        {
            [self.delegate updateStatus:@"Sending"];
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit)
            {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
                total += bytesRead;
                
                [self.delegate updateProgressWithValue:(float)total/size];
                if (bytesRead == -1)
                {
                    [self stopSendWithStatus:@"File read error"];
                } 
                else if (bytesRead == 0) 
                {
                    [self stopSendWithStatus:@"Finished"];
                } 
                else 
                {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit)
            {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) 
                {
                    [self stopSendWithStatus:@"Network write error"];
                } 
                else
                {
                    self.bufferOffset += bytesWritten;
                }
            }
        } 
            break;
        case NSStreamEventErrorOccurred:
        {
            [self stopSendWithStatus:@"Stream open error"];
        } 
            break;
        case NSStreamEventEndEncountered:
        {
            // ignore
        } 
            break;
        default: 
        {
            assert(NO);
        }
            break;
    }
}


@end
