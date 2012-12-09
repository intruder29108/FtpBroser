//
//  FtpBrowser.m
//  FtpBrowser
//
//  Created by intruder on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FtpBrowser.h"

@implementation FtpBrowser

@synthesize listTable = _listTable;
@synthesize urlField = _urlField;
@synthesize backButton = _backButton;
@synthesize uploadButton = _uploadButton;
@synthesize mServers;
@synthesize passwordView;

@synthesize networkStream   = _networkStream;
@synthesize listData        = _listData;
@synthesize listEntries     = _listEntries;
@synthesize password;
@synthesize username;     
@synthesize isReceiving     = _isReceiving;
@synthesize status          = _status;
@synthesize historyStack;
@synthesize subView;
@synthesize fileStream      = _fileStream;
@synthesize filePath        = _filePath;
@synthesize selectedFile;
@synthesize upload          = _upload;

// Details View Outlets

@synthesize detailsView;
@synthesize titleLabel;
@synthesize sizeLabel;
@synthesize permissionLabel;
@synthesize imageView;
@synthesize dateLabel;
@synthesize downloadButton;
@synthesize activityView;
@synthesize speedLabel;
@synthesize progressBar;


// Loading Cell Outlets

@synthesize loadingIndicator;
@synthesize loadingCell;


// Sorting table data into sections

@synthesize collation = _collation;
@synthesize sectionsArray = _sectionsArray;

// Date

@synthesize start_time = _start_time;
@synthesize total_bytes = _total_bytes;


// Info View

@synthesize infoView;
@synthesize infoLabel;
@synthesize infoActivityIndicator;
@synthesize uploadProgressBar;

// Login View

@synthesize loginView;
@synthesize loginStatus;
@synthesize loginActivity;
@synthesize loginPassword;
@synthesize loginUsername;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    // Load Previous Stored servers
    mServers = [[NSUserDefaults standardUserDefaults] objectForKey:@"ServerList"];  
    if(!mServers)
    {
        mServers = [[NSMutableArray alloc] init];
    }
    if (self.listEntries == nil) {
        self.listEntries = [NSMutableArray array];
        assert(self.listEntries != nil);
    }
    if(myStack == nil)
    {
        myStack = [[NSMutableArray alloc]init];
        assert(myStack != nil);
    }
    if(historyStack == nil)
    {
        historyStack = [[NSMutableArray alloc]init];
        assert(historyStack != nil);
    }
    [super viewDidLoad];
    
    
    // Pull to refresh stuff
    
    
    if (_refreshHeaderView == nil) 
    {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.listTable.bounds.size.height, self.view.frame.size.width, self.listTable.bounds.size.height)];
		view.delegate = self;
		[self.listTable addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];

    self.view.backgroundColor = [UIColor blackColor];
    [subView addSubview:detailsView];
    downloadButton.color = [UIColor whiteColor];
    self.backButton.enabled = NO;
    
    
    // info view
    
    [[infoView layer] setCornerRadius:10.0];
    [[infoView layer] setBorderWidth:4.0];
    [[infoView layer] setBorderColor:[UIColor blackColor].CGColor];
    
    
    // login view
    [[loginView layer] setCornerRadius:10.0];
    [[loginView layer] setBorderWidth:4.0];
    [[loginView layer] setBorderColor:[UIColor blackColor].CGColor];
    firstTimeConnection = NO;
    
    [self.uploadButton setEnabled:NO];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc
{
    // Delete
    
    [delete release];
    
    
    // Login View Components
    
    [loginView release];
    [loginPassword release];
    [loginActivity release];
    [loginStatus release];
    [loginUsername release];
    
    // Info View Components

    [infoView release];
    [infoLabel release];
    [infoActivityIndicator release];
    [uploadProgressBar release];
    
    // Details View Components
    [detailsView release];
    [activityView release];
    [titleLabel release];
    [imageView release];
    [dateLabel release];
    [permissionLabel release];
    [sizeLabel release];
    [progressBar release];
    [subView release];
    
    // Main View Components
    [_sectionsArray release];
    [progressBar dealloc];
    [loadingCell release];
    [loadingIndicator release];
    [_filePath release];
    [_fileStream release];
    [selectedFile release];
    [detailsView release];
    [subView release];
    [historyStack release];
    [passwordView release];
    [mServers release];
    [_urlField release];
    [_listTable release];
    [_uploadButton release];
    [_backButton release];
    
    
    // Loading Cell
    
    [loadingCell release];
    [loadingIndicator release];
    
    
}

// Delegates

// UITextFiled Delegates
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 0)
    {

        if(textField.text.length != 0 && !entrySelected)
        {    
            [self clearList];
            for(NSString *server in mServers)
            {
                if([server isEqualToString:textField.text])
                {
                    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:server];
                    username = [dict objectForKey:@"username"];
                    password = [dict objectForKey:@"password"];
                    NSLog(@"Server Found!!");
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:.25];
                    [textField setFrame:urlFieldFrame];
                    [UIView commitAnimations];
                    editURL = FALSE;
                    [self.listTable reloadData];
                    [textField resignFirstResponder];
                    if(self.isReceiving)
                    {
                        [self stopReceiveWithStatus:@"Cancelled"];
                    }
                    else
                    {
                        NSLog(@"New Connection started");
                        req_type = LIST;
                        [self startRecieve];
                        [loadingIndicator startAnimating];
                    }
                    return YES;
                }
            }
            NSArray *topLevel = [[NSBundle mainBundle] loadNibNamed:@"PasswordView" owner:nil options:nil];
            for(id obj in topLevel)
            {
                if([obj isKindOfClass:[PasswordView class]])
                {
                    passwordView = obj;
                    passwordView.delegate = self;
                }
            }
            //[self presentModalViewController:passwordView animated:YES];
            
            
            // DDAlert View implementation
            
//            DDAlertPrompt *loginPrompt = [[DDAlertPrompt alloc] initWithTitle:@"Sign in to FTP" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitle:@"Sign In"]; 
//            [loginPrompt show];
//            [loginPrompt release];
            
            firstTimeConnection = YES;
            loginUsername.text= @"";
            loginPassword.text = @"";
            loginStatus.text = @"";
            [self presentPopupView:loginView animationType:MJPopupViewAnimationSlideBottomTop];

        }
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.25];
        [textField setFrame:urlFieldFrame];
        [UIView commitAnimations];
        editURL = FALSE;
        NSLog(@"URL Field Entered");
        [self.listTable reloadData];
    }
    [textField resignFirstResponder];
   
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        editURL = TRUE;
        entrySelected = NO;
        urlFieldFrame = textField.frame;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.25];
        [textField setFrame:CGRectMake(0, urlFieldFrame.origin.y, 200, urlFieldFrame.size.height)];
        [UIView commitAnimations];
        [self.listTable reloadData];
    }
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(editURL || self.listEntries.count == 0)
        return 1;
    return [[_collation sectionTitles] count];;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(editURL)
    {
        return mServers.count;
    }
    if(self.listEntries.count == 0)
        return  1;
    
    NSArray *dataForSection = [self.sectionsArray objectAtIndex:section];
    return  dataForSection.count;
}

// Fuctions to make files pareameters in to human readable format

- (NSString *)stringForNumber:(double)num asUnits:(NSString *)units
{
    NSString *  result;
    double      fractional;
    double      integral;
    
    fractional = modf(num, &integral);
    if ( (fractional < 0.1) || (fractional > 0.9) ) {
        result = [NSString stringWithFormat:@"%.0f %@", round(num), units];
    } else {
        result = [NSString stringWithFormat:@"%.1f %@", num, units];
    }
    return result;
}

- (NSString *)stringForFileSize:(unsigned long long)fileSizeExact
{
    double  fileSize;
    NSString *  result;
    
    fileSize = (double) fileSizeExact;
    if (fileSizeExact == 1) {
        result = @"1 byte";
    } else if (fileSizeExact < 1024) {
        result = [NSString stringWithFormat:@"%llu bytes", fileSizeExact];
    } else if (fileSize < (1024.0 * 1024.0 * 0.1)) {
        result = [self stringForNumber:fileSize / 1024.0 asUnits:@"KB"];
    } else if (fileSize < (1024.0 * 1024.0 * 1024.0 * 0.1)) {
        result = [self stringForNumber:fileSize / (1024.0 * 1024.0) asUnits:@"MB"];
    } else {
        result = [self stringForNumber:fileSize / (1024.0 * 1024.0 * 1024.0) asUnits:@"MB"];
    }
    return result;
}

static NSDateFormatter *    sDateFormatter;

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Folder&Files";
    UITableViewCell *cell;
    if(cell == nil)
    {
               // do something;
    }
    
    if(editURL)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ServerList"];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ServerList"];
            cell.textLabel.font = [UIFont fontWithName:@"Gills Sans" size:18.0];

        }
        cell.textLabel.text = [mServers objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [[[NSUserDefaults standardUserDefaults] objectForKey:[mServers objectAtIndex:indexPath.row]] objectForKey:@"username"];
    }
    
    else
    {
        NSString *fileName;
        NSString *sizeStr;
        NSString *typeNum;
        NSNumber *sizeNum;
        if(self.listEntries.count == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            if(cell == nil)
            {
                cell = loadingCell;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            return cell;
    
        }

        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.textLabel.font = [UIFont fontWithName:@"Gills Sans" size:18.0];

            [cell.imageView  setContentMode:UIViewContentModeScaleAspectFit];
        }
        NSArray *dataForSection = [self.sectionsArray objectAtIndex:indexPath.section];
        NSDictionary *listEntry = [dataForSection objectAtIndex:indexPath.row];
        fileName = [listEntry objectForKey:@"kCFFTPResourceName"];
        typeNum =  [listEntry objectForKey:@"kCFFTPResourceType"];
        sizeNum =  [listEntry objectForKey:@"kCFFTPResourceSize"];
        cell.textLabel.text = fileName;
        int type;
        typeNum = [listEntry objectForKey:(id) kCFFTPResourceType];
        
        type = [typeNum intValue];
        // Get size in humam readable format
        if (sizeNum != nil) 
        {
            if (type == DT_REG) 
            {
                assert([sizeNum isKindOfClass:[NSNumber class]]);
                sizeStr = [self stringForFileSize:[sizeNum unsignedLongLongValue]];
            } 
            else 
            {
                sizeStr = @"-";
            }
        } 
        else 
        {
            sizeStr = @"?";
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",sizeStr];

        
        if (typeNum != nil) 
        {
            assert([typeNum isKindOfClass:[NSNumber class]]);
            type = [typeNum intValue];
        }
        else 
        {
            type = 0;
        }
        
        
        
        if(type == 4)
        {
            cell.imageView.image = [UIImage imageNamed:@"folder1.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"txt"])
        {
            cell.imageView.image  = [UIImage imageNamed:@"text.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"png"] || [fileName.pathExtension isEqualToString:@"jpg"] || [fileName.pathExtension isEqualToString:@"jpeg"])
        {
            cell.imageView.image = [UIImage imageNamed:@"image1.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"zip"] || [fileName.pathExtension isEqualToString:@"tar.gz"] || [fileName.pathExtension isEqualToString:@"gz"] || [fileName.pathExtension isEqualToString:@"tar"] || [fileName.pathExtension isEqualToString:@"bz2"])
        {
            cell.imageView.image = [UIImage imageNamed:@"zip1.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"iso"])
        {
            cell.imageView.image = [UIImage imageNamed:@"iso.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"html"] || [fileName.pathExtension isEqualToString:@"htm"])
        {
            cell.imageView.image = [UIImage imageNamed:@"html1.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"pdf"])
        {
            cell.imageView.image = [UIImage imageNamed:@"pdf1.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"sh"] || [fileName.pathExtension isEqualToString:@"bash"])
        {
            cell.imageView.image = [UIImage imageNamed:@"script.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"doc"] || [fileName.pathExtension isEqualToString:@"docx"])
        {
            cell.imageView.image = [UIImage imageNamed:@"doc.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"ppt"] || [fileName.pathExtension isEqualToString:@"odp"])
        {
            cell.imageView.image = [UIImage imageNamed:@"ppt.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"sqlite3"])
        {
            cell.imageView.image = [UIImage imageNamed:@"sql.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"py"])
        {
            cell.imageView.image = [UIImage imageNamed:@"python.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"c"])
        {
            cell.imageView.image = [UIImage imageNamed:@"c.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"h"])
        {
            cell.imageView.image = [UIImage imageNamed:@"h.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"m"])
        {
            cell.imageView.image = [UIImage imageNamed:@"c.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"xib"])
        {
            cell.imageView.image = [UIImage imageNamed:@"glade.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"rtf"] || [fileName.pathExtension isEqualToString:@"rtfd"])
        {
            cell.imageView.image = [UIImage imageNamed:@"richtext.png"];
        }
        else if([fileName.pathExtension isEqualToString:@"pkg"] || [fileName.pathExtension isEqualToString:@"ipa"] || [fileName.pathExtension isEqualToString:@"apk"] || [fileName.pathExtension isEqualToString:@"exe"] || [fileName.pathExtension isEqualToString:@"pet"]||[fileName.pathExtension isEqualToString:@"deb"])
        {
            cell.imageView.image = [UIImage imageNamed:@"executable.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"unknown.png"];
        }

        
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([username isEqualToString:@"anonymous"])
        return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    int type;
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        if(editURL)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[mServers objectAtIndex:indexPath.row]];
            [mServers removeObjectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:mServers forKey:@"ServerList"];
        }
        else
        {
            NSArray *dataForSection = [self.sectionsArray objectAtIndex:indexPath.section];
            NSDictionary *listEntry = [dataForSection objectAtIndex:indexPath.row];
            type =  [[listEntry objectForKey:@"kCFFTPResourceType"]intValue];
            if(type != 4)
            {
                SInt32 errorCode;
                NSString *authentication;
                NSMutableString *path = [[ NSMutableString alloc]initWithString:[[NSString stringWithFormat:@"%@%@",self.urlField.text,cell.textLabel.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
                authentication = [[NSString stringWithFormat:@"%@:%@@",self.username,self.password] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [path insertString:authentication atIndex:6];
                NSLog(@"delete url : %@",path);
                CFURLRef url = (CFURLRef)[[NSURL alloc] initWithString:path];
                
                
                if(CFURLDestroyResource(url,&errorCode))
                {
                    NSLog(@"Destroy Succeded");
                    NSMutableArray *dataForSection = [self.sectionsArray objectAtIndex:indexPath.section];
                    [dataForSection removeObjectAtIndex:indexPath.row];
                }
                else
                {
                    NSLog(@"Error");
                }
            }
            
            else
            {
                mSelectedIndexPath = [indexPath retain];
                mCount = 0;
                delete  =    [[Delete alloc] initWithUser:self.username Password:self.password AtPath:[NSString stringWithFormat:@"%@%@/",self.urlField.text,cell.textLabel.text]];
                delete.delegate = self;
                mCount ++;
                
                //Pop Up Animations
                infoLabel.text = @"Deleting...";
                [infoActivityIndicator startAnimating];
                [self presentPopupView:infoView animationType:MJPopupViewAnimationSlideLeftRight];
                
                NSLog(@"Entering Directory %@",cell.textLabel.text);
                [delete startDeleteDirectory];
            }
        }
        [self.listTable reloadData];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editURL)
    {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:[mServers objectAtIndex:indexPath.row]];
        username = [dict objectForKey:@"username"];
        password = [dict objectForKey:@"password"];
        NSLog(@"Username %@ and password %@ for ftp server %@",username,password,[mServers objectAtIndex:indexPath.row]);
        selectedServer = indexPath.row;
        [self.urlField setText:[mServers objectAtIndex:indexPath.row]];
        entrySelected = YES;
        [self.urlField resignFirstResponder];
        self.backButton.enabled = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.25];
        [self.urlField setFrame:urlFieldFrame];
        [UIView commitAnimations];
        editURL = FALSE;
        if(self.isReceiving)
        {
            [self stopReceiveWithStatus:@"Cancelled"];
        }
        else
        {
            NSLog(@"New Connection started");
            req_type = LIST;
            [self startRecieve];
            [loadingIndicator startAnimating];
        }

    }
    
    else if(self.listEntries.count > 0)
    {
        NSString *          fileName;
        NSNumber *          sizeNum;
        NSString *          sizeStr;
        NSNumber *          modeNum;
        char                modeCStr[12];
        NSDate *            date;
        NSString *          dateStr;
        NSArray *dataForSection = [self.sectionsArray objectAtIndex:indexPath.section];
        NSDictionary *listEntry = [dataForSection objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSNumber *typeNum = [listEntry objectForKey:@"kCFFTPResourceType"];
        int type = [typeNum intValue];
        NSLog(@"%d",type);
        if(type != 4 )
        {
            
            // fetch the various file attributes
            progressBar.hidden = YES;
            fileName = [listEntry objectForKey:(id)kCFFTPResourceName];
            selectedFile = fileName;
            modeNum = [listEntry objectForKey:(id) kCFFTPResourceMode];
            if (modeNum != nil) 
            {
                assert([modeNum isKindOfClass:[NSNumber class]]);
                
                strmode([modeNum intValue] + DTTOIF(type), modeCStr);
            } 
            else 
            {
                strlcat(modeCStr, "???????????", sizeof(modeCStr));
            }
            
            sizeNum = [listEntry objectForKey:(id) kCFFTPResourceSize];
            size = [sizeNum intValue];
            if (sizeNum != nil) 
            {
                if (type == DT_REG) 
                {
                    assert([sizeNum isKindOfClass:[NSNumber class]]);
                    sizeStr = [self stringForFileSize:[sizeNum unsignedLongLongValue]];
                } 
                else 
                {
                    sizeStr = @"-";
                }
            } 
            else 
            {
                sizeStr = @"?";
            }
            
            date = [listEntry objectForKey:(id) kCFFTPResourceModDate];
            if (date != nil) 
            {
                if (sDateFormatter == nil) 
                {
                    sDateFormatter = [[NSDateFormatter alloc] init];
                    assert(sDateFormatter != nil);
                    
                    sDateFormatter.dateStyle = NSDateFormatterShortStyle;
                    sDateFormatter.timeStyle = NSDateFormatterShortStyle;
                }
                dateStr = [sDateFormatter stringFromDate:date];
            } 
            else 
            {
                dateStr = @"";
            }
            
       
            if([fileName.pathExtension isEqualToString:@"txt"])
            {
                imageView.image  = [UIImage imageNamed:@"text.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"png"] || [fileName.pathExtension isEqualToString:@"jpg"] || [fileName.pathExtension isEqualToString:@"jpeg"])
            {
                imageView.image = [UIImage imageNamed:@"image1.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"zip"] || [fileName.pathExtension isEqualToString:@"tar.gz"] || [fileName.pathExtension isEqualToString:@"gz"] || [fileName.pathExtension isEqualToString:@"tar"] || [fileName.pathExtension isEqualToString:@"bz2"])
            {
               imageView.image = [UIImage imageNamed:@"zip1.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"iso"])
            {
                imageView.image = [UIImage imageNamed:@"iso.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"html"] || [fileName.pathExtension isEqualToString:@"htm"])
            {
                imageView.image = [UIImage imageNamed:@"html1.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"pdf"])
            {
                imageView.image = [UIImage imageNamed:@"pdf1.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"sh"] || [fileName.pathExtension isEqualToString:@"bash"])
            {
                imageView.image = [UIImage imageNamed:@"script.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"doc"] || [fileName.pathExtension isEqualToString:@"docx"])
            {
                imageView.image = [UIImage imageNamed:@"doc.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"ppt"] || [fileName.pathExtension isEqualToString:@"odp"])
            {
                imageView.image = [UIImage imageNamed:@"ppt.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"sqlite3"])
            {
                imageView.image = [UIImage imageNamed:@"sql.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"py"])
            {
                imageView.image = [UIImage imageNamed:@"python.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"c"])
            {
                imageView.image = [UIImage imageNamed:@"c.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"h"])
            {
                imageView.image = [UIImage imageNamed:@"h.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"m"])
            {
                imageView.image = [UIImage imageNamed:@"c.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"xib"])
            {
                imageView.image = [UIImage imageNamed:@"glade.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"rtf"] || [fileName.pathExtension isEqualToString:@"rtfd"])
            {
                imageView.image = [UIImage imageNamed:@"richtext.png"];
            }
            else if([fileName.pathExtension isEqualToString:@"pkg"] || [fileName.pathExtension isEqualToString:@"ipa"] || [fileName.pathExtension isEqualToString:@"apk"] || [fileName.pathExtension isEqualToString:@"exe"] || [fileName.pathExtension isEqualToString:@"pet"]||[fileName.pathExtension isEqualToString:@"deb"])
            {
                imageView.image = [UIImage imageNamed:@"executable.png"];
            }
            else
            {
                imageView.image = [UIImage imageNamed:@"unknown.png"];
            }
            titleLabel.text = fileName;
            permissionLabel.text = [NSString stringWithFormat:@"%s",modeCStr];
            sizeLabel.text = sizeStr;
            dateLabel.text = dateStr;
            
            
            // Code to present details view
//            [modalBackground setBackgroundColor: [UIColor blackColor]];
//            [modalBackground setAlpha: 0.7];
//                        
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.25];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//            
//            subView.alpha = 1.0;
//            
            [[subView layer]setCornerRadius:20.0];
            [[detailsView layer] setCornerRadius:10.0];
            [[detailsView layer] setBorderWidth:4.0];
            [[detailsView layer] setBorderColor:[UIColor blackColor].CGColor];
//            [self.view insertSubview:modalBackground aboveSubview:self.listTable];
//            [self.view insertSubview:subView aboveSubview:modalBackground];
            
            [speedLabel setText:@""];
            [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
//            [UIView commitAnimations];
            
            [self presentPopupView:subView animationType:MJPopupViewAnimationSlideBottomTop];
            
            
            
        }
        else
        {
            [historyStack addObject:self.urlField.text];
            if(!self.backButton.enabled)
                self.backButton.enabled = YES;
            self.urlField.text = [NSString stringWithFormat:@"%@%@/",self.urlField.text,cell.textLabel.text];
            if(self.isReceiving)
            {
                [self stopReceiveWithStatus:@"Cancelled"];
            }
            else
            {
                NSLog(@"New Connection started");
                req_type = LIST;
                [self startRecieve];
                [loadingIndicator startAnimating];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


/*
 Section-related methods: Retrieve the section titles and section index titles from the collation.
 */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    NSArray *dataForSection = [self.sectionsArray objectAtIndex:section];
    if(dataForSection.count > 0)
        return [[_collation sectionTitles] objectAtIndex:section];
    return nil;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    if(editURL)
        return nil;
    return [_collation sectionIndexTitles];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
    return [_collation sectionForSectionIndexTitleAtIndex:index];
}

// Action implementation
- (IBAction)controlButtonPressed:(UIBarButtonItem *)sender
{
    if(sender.tag == 0)
    {
        if(historyStack.count > 0)
        {
            self.urlField.text = [historyStack lastObject];
            [historyStack removeLastObject];
            if(self.isReceiving)
            {
                [self stopReceiveWithStatus:@"Cancelled"];
            }
            else
            {
                NSLog(@"New Connection started");
                req_type = LIST;
                [self startRecieve];
                [loadingIndicator startAnimating];
            }
            if(historyStack.count == 0)
                self.backButton.enabled = NO;
        }
    }
}


- (void) authenticationComplete:(PasswordView *)sender
{
    NSDictionary *authentication;
    username = sender.usernameField.text;
    password = sender.passwordField.text;
    NSLog(@"Server : %@",self.urlField.text);
    [mServers addObject:self.urlField.text];
    authentication = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",password,@"password", nil];
    [[NSUserDefaults standardUserDefaults] setObject:mServers forKey:@"ServerList"];
    [[NSUserDefaults standardUserDefaults] setObject:authentication forKey:self.urlField.text];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Username %@ and password %@ for ftp server %@",username,password,self.urlField.text);
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.urlField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.25];
    [self.urlField setFrame:urlFieldFrame];
    [UIView commitAnimations];
    editURL = FALSE;
    [self.urlField setText:[mServers lastObject]];
    if(self.isReceiving)
    {
        [self stopReceiveWithStatus:@"Cancelled"];
    }
    else
    {
        NSLog(@"New Connection started");
        req_type = LIST;
        [self startRecieve];
        [loadingIndicator startAnimating];
    }
}


- (BOOL)isReceiving
{
    return (self.networkStream != nil);
}

- (void)receiveDidStart
{
    // Clear the current image so that we get a nice visual cue if the receive fails.
    if(req_type == LIST)
    {
        [self.listEntries removeAllObjects];
        [self.listTable reloadData];
    }
    else if(req_type == GET)
    {
        NSLog(@"GET action started");
    }
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}

// To remove existing connections
- (void)stopReceiveWithStatus:(NSString *) status
{
    [loadingIndicator stopAnimating];
    NSLog(@"Stop receiving with statues %@",status);
    
    if (self.networkStream != nil) 
    {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    
    if(self.fileStream != nil)
    {
        [self.fileStream close];
        self.fileStream = nil;
    }
    
    self.filePath = nil;
    [self receiveDidStopWithStatus:status];
    self.listData = nil;
}

- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if ([statusString isEqualToString:@"Finished"]) 
    {
        if(req_type == LIST)
        {
            if([username isEqualToString:@"anonymous"])
            {
                [self.uploadButton setEnabled:NO];
            }
            else
            {
                [self.uploadButton setEnabled:YES];
            }
            if(firstTimeConnection)
            {
                [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
                [loginActivity stopAnimating];
                firstTimeConnection = NO;
            }
            
            [self configureSections];
            if(_reloading)
                [self doneLoadingTableViewData];
            statusString = @"List succeeded";
        }
        
        else if(req_type == GET)
        {
            [activityView stopAnimating];
            // Code to remove Pop Up
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.25];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//            [modalBackground removeFromSuperview];
//            subView.alpha = 0.0;
//            [UIView commitAnimations];
            
            [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
            self.backButton.enabled = YES;
            NSLog(@"Download Completed");
        }
    }
    
    else
    {
        if(firstTimeConnection)
        {
            [mServers removeLastObject];
            [[NSUserDefaults standardUserDefaults] setObject:mServers forKey:@"ServerList"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.urlField.text];
            [[NSUserDefaults standardUserDefaults] synchronize];
            loginStatus.hidden = NO;
            loginStatus.textColor = [UIColor redColor];
            loginStatus.text = @"Incorrect Username or Password";
            [loginActivity stopAnimating];
        }
//        UIAlertView *errorView =  [[[UIAlertView alloc]initWithTitle:@"Info" message:@"Error in Stream" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil]autorelease];
//        [errorView show];
    }
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}


- (IBAction)buttonPressed:(UIButton *)sender
{
    if(sender.tag == 0)
    {
        //dismiss view
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.25];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        [modalBackground removeFromSuperview];
//        subView.alpha = 0.0;
//        [UIView commitAnimations];
//        self.backButton.enabled = YES;
        
        [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
        
    }
    
    else
    {
        if(self.isReceiving)
        {
            [downloadButton setTitle:@"Download" forState:UIControlStateNormal];

            [self stopReceiveWithStatus:@"Cancelled"];
            speedLabel.text = @"";
            [self.progressBar setProgress:0.0];
            [self.activityView stopAnimating];
        }
        else
        {
            [downloadButton setTitle:@"Cancel" forState:UIControlStateNormal];
            [downloadButton setNeedsDisplay];
            NSLog(@"New Connection started");
            req_type = GET;
            total = 0;
            self.progressBar.hidden = NO;
            self.progressBar.progress = 0.0;
            [self startRecieve];
        }
        //perform download
        
    }
    
    
   

}

// fucntions to parse the data recieved from network stream

- (void) parseListData
{
    NSMutableArray *    newEntries;
    NSUInteger          offset;
    
    
    // We accumulate new entries to an array to avoid updating table one by one
    
    newEntries = [NSMutableArray array];
    assert(newEntries != nil);
    offset = 0;
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
//                    NSLog(@"New entry is %@",entryToAdd);
                    [newEntries addObject:entryToAdd];
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
            [self stopReceiveWithStatus:@"Error parsing"];
            NSLog(@"Failed to parse the listing .. Stop...");
            break;
        }
    }while (YES);
    
    if([newEntries count] != 0)
    {
        [self addListEntries:newEntries];
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

- (void)addListEntries:(NSArray *)newEntries
{
    if(self.listEntries != nil)
    {
        [self.listEntries addObjectsFromArray:newEntries];
        [self.listTable reloadData];
    }
}

- (void) clearList
{
    [self.listEntries removeAllObjects];
}

// network related functions

- (void) startRecieve
{
    BOOL success;
    NSURL *url;
    
    if(req_type == LIST)
    {
        assert(self.networkStream == nil);
    }
    
    else if(req_type == GET)
    {
        [activityView startAnimating];
        assert(self.networkStream == nil);
        assert(self.fileStream == nil);
        assert(self.filePath == nil);
    }
    
    // First get tand check the URL
    
    if(req_type == LIST)
    {
        NSString *path = [self.urlField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"new path is = %@",path);
        url = [[NetworkManager sharedInstance] smartURLForString:path];

    }
    
    else if(req_type == GET)
    {
        NSString *path = [[NSString stringWithFormat:@"%@%@",self.urlField.text,selectedFile] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"new path is = %@",path);
        url = [[NetworkManager sharedInstance] smartURLForString:path];
    }
    success = (url != nil);
    
    // If url is invalid log it
    
    if(!success)
    {
        NSLog(@"Invalid URL!");
    }
    else
    {
        // Create a mutable data into which we will recieve the data
        if(req_type == LIST)
        {
            self.listData = [NSMutableData data];
            assert(self.listData != nil);
        }
        
        else if(req_type == GET)
        {
            NSFileManager *filemgr = [[NSFileManager defaultManager] autorelease];
            
            //Edit for ipad
            //[filemgr createFileAtPath:[NSString stringWithFormat:@"/Users/sourcebits/%@",selectedFile] contents:nil attributes:nil];
            [filemgr createFileAtPath:[NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],selectedFile] contents:nil attributes:nil];

            //self.filePath = [NSString stringWithFormat:@"/Users/sourcebits/%@",selectedFile];
            
            self.filePath = [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],selectedFile];
            // Open a stream for the file we're going to receive into.
            assert(self.filePath != nil);
            NSLog(@"Download Started file path = %@",self.filePath);
            self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
            assert(self.fileStream != nil);
            [self.fileStream open];
        }
        
        
        // Open a CFFTPStream for the URL
        
        self.networkStream = CFBridgingRelease(CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url));
        assert(self.networkStream != nil);
        [self.networkStream setProperty:self.username forKey:(id)kCFStreamPropertyFTPUserName];
        assert(success);
        [self.networkStream setProperty:self.password forKey:(id)kCFStreamPropertyFTPPassword];
        
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
        {
            self.total_bytes = 0;
            self.start_time = [NSDate timeIntervalSinceReferenceDate];
            NSLog(@"Stream Open completed");

        }
            break;
        case NSStreamEventHasBytesAvailable:
        {
            NSInteger   bytesRead;
            uint8_t     buffer[32768];
            NSLog(@"Recieving....");
            
            
            // Pull some data off the network
            
            bytesRead = [self.networkStream read:buffer maxLength:sizeof(buffer)]; 
            self.total_bytes += bytesRead;
            if(bytesRead < 0)
            {
                [self stopReceiveWithStatus:@"Network Error"];
                NSLog(@"Network read error");
            }
            else if(bytesRead  == 0)
            {
                [self stopReceiveWithStatus:@"Finished"];
                NSLog(@"Read Completed");
            }
            else
            {
                if(req_type == LIST)
                {
                    assert(self.listData != nil);
                    // Append the data to our listing buffer
                    
                    [self.listData appendBytes:buffer length:(NSUInteger) bytesRead];
                    NSLog(@"Appending data....");                
                    // add code here to parse the list
                    [self parseListData];
                }
                else if(req_type == GET)
                {
                    NSInteger bytesWritten;
                    NSInteger bytesWrittenSoFar;
                    
                    // Write to file
                    total += bytesRead;
                    self.progressBar.progress = (float)total/size;
                    float speed  = self.total_bytes/(([NSDate timeIntervalSinceReferenceDate] - self.start_time)*1000);
                    NSLog(@"Speed : %f KB/s",speed);
                    if(speed > 1000)
                    {
                        self.speedLabel.text = [NSString stringWithFormat:@"%.2f MB/s",speed/1000];
                    }
                    else
                        self.speedLabel.text = [NSString stringWithFormat:@"%.2f KB/s",speed];
                    bytesWrittenSoFar = 0;
                    do 
                    {
                        bytesWritten = [self.fileStream write:&buffer[bytesWrittenSoFar] maxLength:(NSUInteger)(bytesRead - bytesWrittenSoFar)];
                        if(bytesWritten == -1)
                        {
                            [self stopReceiveWithStatus:@"File write error"];
                            break;
                        }
                        else
                        {
                            bytesWrittenSoFar += bytesWritten;
                        }
                    } while (bytesWrittenSoFar != bytesWritten);
                }
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
            [self stopReceiveWithStatus:@"Network Error"];
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

// Upload Action

- (IBAction)uploadPressed:(UIBarButtonItem *)sender
{
    //PSDirectoryPickerController *directoryPicker = [[PSDirectoryPickerController alloc] initWithRootDirectory:@"/Users/sourcebits/"];
    
    PSDirectoryPickerController *directoryPicker = [[PSDirectoryPickerController alloc] initWithRootDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    [directoryPicker setDelegate:self];
    [directoryPicker setPrompt:@"Choose a file to upload"];
    [directoryPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self presentModalViewController:directoryPicker animated:YES];
}

#pragma mark - Directory Picker Delegate
- (void)directoryPickerControllerDidCancel:(PSDirectoryPickerController *)picker
{
    NSLog(@"Cancelled!");
}

- (void)directoryPickerController:(PSDirectoryPickerController *)picker didFinishPickingDirectoryAtPath:(NSString *)path
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManger attributesOfItemAtPath:path error:nil];
    
    NSLog(@"Picked file at %@ with size %llu bytes", path,[attributes fileSize]);
    self.upload = [[Uploader alloc] initWithUserName:username Password:password] ;
    self.upload.delegate = self;
    
    // Pop Up Animations
    infoLabel.text = @"Uploading...";
    [infoActivityIndicator startAnimating];
    [self presentPopupView:infoView animationType:MJPopupViewAnimationSlideRightLeft];
    
    [self.upload startSendingFile:path ToServer:self.urlField.text];
}




// Uploader Delegates

- (void) sendDidStopWithStatus:(NSString *) status
{
    // Pop Animations
    [infoActivityIndicator stopAnimating];
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideRightLeft];

    [self.upload release];
    NSLog(@"Upload -- %@",status);
    uploadProgressBar.hidden = YES;
}

- (void) sendDidStart:(NSString *) status
{
    uploadProgressBar.hidden = NO;
    NSLog(@"Upload -- %@",status);
}

- (void) updateStatus:(NSString *) status
{
    NSLog(@"Upload -- %@",status);
}

- (void) updateProgressWithValue:(float)value
{
    [uploadProgressBar setProgress:value];
}


// Pull to refresh stuff

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    if(self.isReceiving)
    {
        [self stopReceiveWithStatus:@"Cancelled"];
    }
    else
    {
        NSLog(@"New Connection started");
        req_type = LIST;
        [self startRecieve];
        [loadingIndicator startAnimating];
    }
}

- (void)doneLoadingTableViewData
{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.listTable];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	
	return [NSDate date]; // should return date data source was last changed
	
}


// Function to sort data into sections
- (void) configureSections
{
    self.collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger index,sectionTitlesCount = [[_collation sectionTitles]count];
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc]initWithCapacity:sectionTitlesCount];
    
    // Set up the section elements are mutable arrays that will contain data for each section
    for(index = 0;index < sectionTitlesCount;index++)
    {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        [newSectionsArray addObject:array];
        [array release];
    }
    
    // Sort arrays into individual sections
    
    for(NSDictionary *dict in self.listEntries)
    {
        Entry *entry = [[Entry alloc]init];
        entry.dict = dict;
        entry.fileName = [dict objectForKey:@"kCFFTPResourceName"];
        
        NSInteger sectionNumber = [_collation sectionForObject:entry collationStringSelector:@selector(fileName)];
        
        // Get Mutable array corresponding to that section
        NSMutableArray *dataForSection = [newSectionsArray objectAtIndex:sectionNumber];
        
        // Add this object to that section
        
        [dataForSection addObject:dict];
        [entry release];
    }
    
    
//    // Now each section is in order sort each section
//    
//    for(index = 0;index < sectionTitlesCount;index++)
//    {
//        NSMutableArray *dataForSection = [newSectionsArray objectAtIndex:index];
//        NSArray *sortedDataForSection = [_collation sortedArrayFromArray:dataForSection collationStringSelector:@selector(localeName)];
//        
//        // Replace existing array with the sorted array
//        
//        [newSectionsArray replaceObjectAtIndex:index withObject:sortedDataForSection];
//    }
    
    self.sectionsArray = newSectionsArray;
    [newSectionsArray release];
    [self.listTable reloadData];
}


- (void) deleteEnded:(Delete *)sender
{
    if (mCount == 0) 
    {
        NSLog(@"Deleted all files in %@",sender.path);
    }
    else
    {
        mCount--;
        if(mCount == 0)
        {
            NSMutableArray *dataForSection = [self.sectionsArray objectAtIndex:mSelectedIndexPath.section];
            [dataForSection removeObjectAtIndex:mSelectedIndexPath.row];
            
            // Pop Up Animaitons
            
            [infoActivityIndicator stopAnimating];
            [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
            
            NSLog(@"Deleted all files in %@",sender.path);
            [mSelectedIndexPath release];
            [self.listTable reloadData];
        }
    }
}

// UIAlertView delegates

- (void)didPresentAlertView:(UIAlertView *)alertView 
{
    if ([alertView isKindOfClass:[DDAlertPrompt class]]) 
    {
        DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
        [loginPrompt.plainTextField becomeFirstResponder];      
        [loginPrompt setNeedsLayout];
    }
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == [alertView cancelButtonIndex]) 
    {
        // Do something
    } 
    else 
    {
        if ([alertView isKindOfClass:[DDAlertPrompt class]]) 
        {
            DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
            NSLog(@"textField: %@", loginPrompt.plainTextField.text);
            NSLog(@"secretTextField: %@", loginPrompt.secretTextField.text);
            NSDictionary *authentication;
            username = loginPrompt.plainTextField.text;
            password = loginPrompt.secretTextField.text;
            NSLog(@"Server : %@",self.urlField.text);
            [mServers addObject:self.urlField.text];
            authentication = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",password,@"password", nil];
            [[NSUserDefaults standardUserDefaults] setObject:mServers forKey:@"ServerList"];
            [[NSUserDefaults standardUserDefaults] setObject:authentication forKey:self.urlField.text];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"Username %@ and password %@ for ftp server %@",username,password,self.urlField.text);
            [self.urlField resignFirstResponder];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.25];
            [self.urlField setFrame:urlFieldFrame];
            [UIView commitAnimations];
            editURL = FALSE;
            [self.urlField setText:[mServers lastObject]];
            if(self.isReceiving)
            {
                [self stopReceiveWithStatus:@"Cancelled"];
            }
            else
            {
                NSLog(@"New Connection started");
                req_type = LIST;
                [self startRecieve];
                [loadingIndicator startAnimating];
            }

        }
    }
}


// Login Action

- (IBAction)loginAction:(UIButton *)sender
{
    if(sender.tag == 0)
    {
        NSLog(@"textField: %@", loginUsername.text);
        NSLog(@"secretTextField: %@", loginPassword.text);
        NSDictionary *authentication;
        username = loginUsername.text;
        password = loginPassword.text;
        NSLog(@"Server : %@",self.urlField.text);
        [mServers addObject:self.urlField.text];
        authentication = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",password,@"password", nil];
        [[NSUserDefaults standardUserDefaults] setObject:mServers forKey:@"ServerList"];
        [[NSUserDefaults standardUserDefaults] setObject:authentication forKey:self.urlField.text];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Username %@ and password %@ for ftp server %@",username,password,self.urlField.text);
        [self.urlField resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.25];
        [self.urlField setFrame:urlFieldFrame];
        [UIView commitAnimations];
        editURL = FALSE;
        [self.urlField setText:[mServers lastObject]];
        if(self.isReceiving)
        {
            [self stopReceiveWithStatus:@"Cancelled"];
        }
        else
        {

            NSLog(@"New Connection started");
            req_type = LIST;
            [self startRecieve];
            [loadingIndicator startAnimating];
            [loginActivity startAnimating];
        }

    }
    
    else
    {
        username = @"";
        password = @"";
        [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    }
        

}

@end
