//
//  Entry.m
//  FtpBrowser
//
//  Created by intruder on 19/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Entry.h"

@implementation Entry

@synthesize fileName = _fileName;
@synthesize dict = _dict;

- (void) dealloc
{
    [_fileName release];
    [_dict release];
}
@end
