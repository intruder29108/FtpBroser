//
//  Delete.m
//  FtpBrowser
//
//  Created by intruder on 21/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Delete.h"

@implementation Delete

@synthesize networkStream = _networkStream;
@synthesize listData = _listData;
@synthesize status = _status;
@synthesize delegate = _delegate;
@synthesize path = mPath;


- (id) initWithUser:(NSString *)username Password:(NSString *)passowrd AtPath:(NSString *)path
{
    self = [super init];
    if(self)
    {
        mUsername = username;
        mPassword = passowrd;
        mPath = [path retain];
        mCount = 0;
    }
    return  self;
}

- (void) receiveDidStart
{
    // Clear the previous data
    
    NSLog(@"Recieve started!!");
}

// fucntions to parse the data recieved from network stream

- (void) parseListData
{
    NSUInteger          offset;
    
    offset = 0;
    NSString *fileName;
    NSString *typeNum;
    do 
    {
        CFIndex bytesConsumed;
        CFDictionaryRef thisEntry;
        
        thisEntry = NULL;
        
        assert(offset <= [self.listData length]);
        bytesConsumed = CFFTPCreateParsedResourceListing(NULL, &((const uint8_t *) self.listData.bytes)[offset], (CFIndex) ([self.listData length] - offset), &thisEntry);
        if(bytesConsumed > 0)
        {
            // It is possible for CFFTPCreateParsedResourceListing to return a 
            // positive number but not create a parse dictionary.  For example, 
            // if the end of the listing text contains stuff that can't be parsed, 
            // CFFTPCreateParsedResourceListing returns a positive number (to tell 
            // the caller that it has consumed the data), but doesn't create a parse 
            // dictionary (because it couldn't make sense of the data).  So, it's 
            // important that we check for NULL.
            
            if(thisEntry != NULL)
            {
                NSDictionary *entryToAdd;
                // Try to interpret the name as UTF-8, which makes things work properly 
                // with many UNIX-like systems, including the Mac OS X built-in FTP 
                // server.  If you have some idea what type of text your target system 
                // is going to return, you could tweak this encoding.  For example, 
                // if you know that the target system is running Windows, then 
                // NSWindowsCP1252StringEncoding would be a good choice here.
                // 
                // Alternatively you could let the user choose the encoding up 
                // front, or reencode the listing after they've seen it and decided 
                // it's wrong.
                //
                // Ain't FTP a wonderful protocol!
                
                entryToAdd = [self entryByReencodingNameInEntry:(__bridge NSDictionary *) thisEntry encoding:NSUTF8StringEncoding];
                if(entryToAdd != nil)
                {    
                    int type;
                    fileName = [entryToAdd objectForKey:@"kCFFTPResourceName"];
                    typeNum =  [entryToAdd objectForKey:@"kCFFTPResourceType"];
                    type = [typeNum intValue];
                    NSLog(@"File name %@ type %@",fileName,typeNum);
                    if(type == 4)
                    {
                        deleteDir = [[Delete alloc]initWithUser:mUsername Password:mPassword AtPath:[NSString stringWithFormat:@"%@%@/",mPath,fileName]];
                        deleteDir.delegate = self;
                        NSLog(@"Entering directory %@",fileName);
                        mCount++;
                        [deleteDir startDeleteDirectory];
                       
                    }
                    
                    else
                    {
                        
                        SInt32 errorCode;
                        NSString *authentication;
                        NSMutableString *path = [[ NSMutableString alloc]initWithString:[[NSString stringWithFormat:@"%@%@",mPath,fileName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
                        authentication = [[NSString stringWithFormat:@"%@:%@@",mUsername,mPassword] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        [path insertString:authentication atIndex:6];
                        NSLog(@"delete url : %@",path);
                        CFURLRef url = (CFURLRef)[[NSURL alloc] initWithString:path];
                        
                        if(CFURLDestroyResource(url,&errorCode))
                        {
                            NSLog(@"Destroy Succeded");

                        }
                        else
                        {
                            NSLog(@"Error");
                        }

                    }
                }   
            }
            
            // We consume the bytes regardless of whether we get and entry.
            offset += (NSUInteger) bytesConsumed;
            
        }
        if(thisEntry != NULL)
        {
            CFRelease(thisEntry);
        }
        if(bytesConsumed == 0)
        {
            //We haven't yet got enought data to parse an entry. Wait for more data to arrive
            break;
        }
        else if(bytesConsumed < 0)
        {
            //We totally failed to parse the listing. Fail
            [self receiveDidStopWithStatus:@"Error parsing"];
            NSLog(@"Failed to parse the listing .. Stop...");
            break;
        }
    }while (YES);
    
    if(mCount == 0)
    {
        NSLog(@"Deleted all files in %@",mPath);
        SInt32 errorCode;
        NSString *authentication;
        NSMutableString *path = [[ NSMutableString alloc]initWithString:[[NSString stringWithFormat:@"%@",mPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
        authentication = [[NSString stringWithFormat:@"%@:%@@",mUsername,mPassword] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [path insertString:authentication atIndex:6];
        NSLog(@"delete url : %@",path);
        CFURLRef url = (CFURLRef)[[NSURL alloc] initWithString:path];
        
        if(CFURLDestroyResource(url,&errorCode))
        {
            NSLog(@"Destroy Succeded");
            [self.delegate deleteEnded:self];
            
        }
        else
        {
            NSLog(@"Error");
        }
        

    }
    
    if(offset != 0)
    {
        [self.listData replaceBytesInRange:NSMakeRange(0, offset) withBytes:NULL length:0];
    }
    
}

- (NSDictionary *)entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding
// CFFTPCreateParsedResourceListing always interprets the file name as MacRoman, 
// which is clearly bogus <rdar://problem/7420589>.  This code attempts to fix 
// that by converting the Unicode name back to MacRoman (to get the original bytes; 
// this works because there's a lossless round trip between MacRoman and Unicode) 
// and then reconverting those bytes to Unicode using the encoding provided. 
{
    NSDictionary *  result;
    NSString *      name;
    NSData *        nameData;
    NSString *      newName;
    
    newName = nil;
    
    // Try to get the name, convert it back to MacRoman, and then reconvert it 
    // with the preferred encoding.
    
    name = [entry objectForKey:(id) kCFFTPResourceName];
    if (name != nil) {
        assert([name isKindOfClass:[NSString class]]);
        
        nameData = [name dataUsingEncoding:NSMacOSRomanStringEncoding];
        if (nameData != nil) {
            newName = [[NSString alloc] initWithData:nameData encoding:newEncoding];
        }
    }
    
    // If the above failed, just return the entry unmodified.  If it succeeded, 
    // make a copy of the entry and replace the name with the new name that we 
    // calculated.
    
    if (newName == nil) 
    {
        //assert(NO);                 // in the debug builds, if this fails, we should investigate why
        result = nil;
    } else 
    {
        NSMutableDictionary *   newEntry;
        
        newEntry = [entry mutableCopy];
        assert(newEntry != nil);
        
        [newEntry setObject:newName forKey:(id) kCFFTPResourceName];
        
        result = newEntry;
    }
    
    return result;
}



- (void) receiveDidStopWithStatus:(NSString *)statusString
{
    if(statusString == nil)
    {
        NSLog(@"List Succeeded");
    }
    else
    {
        NSLog(@"%@",statusString);
    }
    
}


- (BOOL) isReceiving
{
    return (self.networkStream != nil);
}


- (void) startDeleteDirectory
{
    BOOL success;
    NSURL *url;
    
    assert(self.networkStream == nil);
    
    // First get the URL 
    
    url = [[NetworkManager sharedInstance] smartURLForString:[mPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    success = (url != nil);
    
    
    if(!success)
        NSLog(@"Invalid URL");
    else
    {
        // Create a mutable data into which we will recieve the data
        
        self.listData = [NSMutableData data];
        assert(self.listData != nil);
    
        // Open a CFFTPStream for the URL
        
        self.networkStream = CFBridgingRelease(CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url));
        assert(self.networkStream != nil);
        [self.networkStream setProperty:mUsername forKey:(id)kCFStreamPropertyFTPUserName];
        assert(success);
        [self.networkStream setProperty:mPassword forKey:(id)kCFStreamPropertyFTPPassword];
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];
        [self receiveDidStart];
        
        NSLog(@"Stream Opened");
    }
    
}



// NSStream delegate when a even heppens on the stream

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    assert(aStream == self.networkStream);
    
    switch (eventCode) 
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream Open completed");
            break;
        case NSStreamEventHasBytesAvailable:
        {
            NSInteger   bytesRead;
            uint8_t     buffer[32768];
            NSLog(@"Recieving....");
            
            
            // Pull some data off the network
            
            bytesRead = [self.networkStream read:buffer maxLength:sizeof(buffer)];
            if(bytesRead < 0)
            {
                [self receiveDidStopWithStatus:@"network error"];
                NSLog(@"Network read error");
            }
            else if(bytesRead  == 0)
            {
                [self receiveDidStopWithStatus:nil];
                NSLog(@"Read Completed");
                if(mCount == 0)
                {
                    NSLog(@"Deleted all files in %@",mPath);
                    SInt32 errorCode;
                    NSString *authentication;
                    NSMutableString *path = [[ NSMutableString alloc]initWithString:[[NSString stringWithFormat:@"%@",mPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
                    authentication = [[NSString stringWithFormat:@"%@:%@@",mUsername,mPassword] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [path insertString:authentication atIndex:6];
                    NSLog(@"delete url : %@",path);
                    CFURLRef url = (CFURLRef)[[NSURL alloc] initWithString:path];
                    
                    if(CFURLDestroyResource(url,&errorCode))
                    {
                        NSLog(@"Destroy Succeded");
                        [self.delegate deleteEnded:self];

                        
                    }
                    else
                    {
                        NSLog(@"Error");
                    }
                    
                    
                }
            }
            else
            {
            
       
                assert(self.listData != nil);
                // Append the data to our listing buffer
                
                [self.listData appendBytes:buffer length:(NSUInteger) bytesRead];
                NSLog(@"Appending data....");                
                // add code here to parse the list
                [self parseListData];
       
            }
            
        }
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            assert(NO);
            // Should never happen for a output stream
        }
            break;
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"Error in stream...");
        }
            break;
        case NSStreamEventEndEncountered:
        {
            // do nothing
        }
            break;
            
        default:
        {
            assert(NO);
        }
            break;
    }
}

// Delete Delegate

- (void) deleteEnded:(Delete *)sender
{
    if(mCount == 0)
    {
        NSLog(@"Deleted all files in %@",mPath);
        [self.delegate deleteEnded:self];
    }
    else
    {
        mCount--;
        if(mCount == 0)
        {
            NSLog(@"Deleted all files in %@",mPath);
            SInt32 errorCode;
            NSString *authentication;
            NSMutableString *path = [[ NSMutableString alloc]initWithString:[[NSString stringWithFormat:@"%@",mPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
            authentication = [[NSString stringWithFormat:@"%@:%@@",mUsername,mPassword] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [path insertString:authentication atIndex:6];
            NSLog(@"delete url : %@",path);
            CFURLRef url = (CFURLRef)[[NSURL alloc] initWithString:path];
            
            if(CFURLDestroyResource(url,&errorCode))
            {
                NSLog(@"Destroy Succeded");
                [self.delegate deleteEnded:self];
                
            }
            else
            {
                NSLog(@"Error");
            }


        }
    }
    
}




- (void) dealloc
{
    [deleteDir release];
    [super dealloc];
}
@end
