//
//  PSTableViewController.m
//  PSFilePickerController
//
//  Created by Josh Kugelmann on 18/08/12.
//  Copyright (c) 2012 Josh Kugelmann. All rights reserved.
//

#import "PSDirectoryListViewController.h"
#import "PSDirectoryPickerController.h"
#import "PSDirectoryPickerEntry.h"

@implementation PSDirectoryListViewController

@synthesize path = _path;
@synthesize files = _files;

- (PSDirectoryListViewController *)initWithDirectoryAtPath:(NSString *)aPath
{
    self = [super init];
    
    if (self) {
        _path = [aPath copy];
        [self rebuildFileList];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the prompt text
    [[self navigationItem] setPrompt:[(PSDirectoryPickerController *)[self navigationController] prompt]];
    
    // Create the "New Folder" button and add it to the navigation bar.
    UIBarButtonItem *newFolderButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    [newFolderButton setTarget:self];
    [newFolderButton setAction:@selector(newFolderButtonTapped)];
    
    //[[self navigationItem] setRightBarButtonItem:newFolderButton];
    [newFolderButton release];
    
    // Create toolbar items.
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:[self navigationController] action:@selector(cancelButtonTapped)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSString *doneButtonTitle = [(PSDirectoryPickerController *)[self navigationController] doneButtonTitle];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:doneButtonTitle style:UIBarButtonItemStyleDone target:[self navigationController] action:@selector(doneButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = cancelButton;
    // Add them to the toolbar.
    [self setToolbarItems:[NSArray arrayWithObjects:cancelButton, flexibleSpace, doneButton, nil]];
    [cancelButton release];
    [flexibleSpace release];
    [doneButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_files release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [_path release];
    
    [super dealloc];
}

- (NSString *)title
{
    return [[self path] lastPathComponent];
}

- (void)rebuildFileList
{
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:nil];
    NSMutableArray *visibleFiles = [NSMutableArray arrayWithCapacity:[allFiles count]];
    
    for (NSString *file in allFiles) {
        if (![file hasPrefix:@"."]) {
            NSString *fullPath = [[self path] stringByAppendingPathComponent:file];
            BOOL isDir = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
            
            PSDirectoryPickerEntry *entry = [[PSDirectoryPickerEntry alloc] initWithPath:fullPath name:file dir:isDir];
            [visibleFiles addObject:entry];
            [entry release];

        }
    }

    [self setFiles:visibleFiles];
}

- (void)newFolderButtonTapped
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Folder" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setPlaceholder:@"New Folder"];
    
    [alert show];
    [alert release];
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *newFolderPath = [[self path] stringByAppendingPathComponent:[[alertView textFieldAtIndex:0] text]];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        [self rebuildFileList];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self files] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    PSDirectoryPickerEntry *entry = [[self files] objectAtIndex:[indexPath row]];

    if ([entry isDir])
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    
    [[cell textLabel] setFont:[UIFont fontWithName:@"Gills Sans" size:18.0]];
    [[cell textLabel] setText:[entry name]];
    
    
    
    
    if([entry isDir])
    {
        cell.imageView.image = [UIImage imageNamed:@"folder1.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"txt"])
    {
        cell.imageView.image  = [UIImage imageNamed:@"text.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"png"] || [entry.name.pathExtension isEqualToString:@"jpg"] || [entry.name.pathExtension isEqualToString:@"jpeg"])
    {
        cell.imageView.image = [UIImage imageNamed:@"image1.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"zip"] || [entry.name.pathExtension isEqualToString:@"tar.gz"] || [entry.name.pathExtension isEqualToString:@"gz"] || [entry.name.pathExtension isEqualToString:@"tar"] || [entry.name.pathExtension isEqualToString:@"bz2"])
    {
        cell.imageView.image = [UIImage imageNamed:@"zip1.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"iso"])
    {
        cell.imageView.image = [UIImage imageNamed:@"iso.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"html"] || [entry.name.pathExtension isEqualToString:@"htm"])
    {
        cell.imageView.image = [UIImage imageNamed:@"html1.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"pdf"])
    {
        cell.imageView.image = [UIImage imageNamed:@"pdf1.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"sh"] || [entry.name.pathExtension isEqualToString:@"bash"])
    {
        cell.imageView.image = [UIImage imageNamed:@"script.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"doc"] || [entry.name.pathExtension isEqualToString:@"docx"])
    {
        cell.imageView.image = [UIImage imageNamed:@"doc.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"ppt"] || [entry.name.pathExtension isEqualToString:@"odp"])
    {
        cell.imageView.image = [UIImage imageNamed:@"ppt.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"sqlite3"])
    {
        cell.imageView.image = [UIImage imageNamed:@"sql.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"py"])
    {
        cell.imageView.image = [UIImage imageNamed:@"python.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"c"])
    {
        cell.imageView.image = [UIImage imageNamed:@"c.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"h"])
    {
        cell.imageView.image = [UIImage imageNamed:@"h.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"m"])
    {
        cell.imageView.image = [UIImage imageNamed:@"c.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"xib"])
    {
        cell.imageView.image = [UIImage imageNamed:@"glade.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"rtf"] || [entry.name.pathExtension isEqualToString:@"rtfd"])
    {
        cell.imageView.image = [UIImage imageNamed:@"richtext.png"];
    }
    else if([entry.name.pathExtension isEqualToString:@"pkg"] || [entry.name.pathExtension isEqualToString:@"ipa"] || [entry.name.pathExtension isEqualToString:@"apk"] || [entry.name.pathExtension isEqualToString:@"exe"] || [entry.name.pathExtension isEqualToString:@"pet"]||[entry.name.pathExtension isEqualToString:@"deb"])
    {
        cell.imageView.image = [UIImage imageNamed:@"executable.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"unknown.png"];
    }

        
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSDirectoryPickerEntry *entry = [[self files] objectAtIndex:[indexPath row]];
    
    if ([entry isDir])
        return indexPath;
    else
        return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSDirectoryPickerEntry *entry = [[self files] objectAtIndex:[indexPath row]];
    
    if([entry isDir])
    {
        PSDirectoryListViewController *detailViewController = [[PSDirectoryListViewController alloc] initWithDirectoryAtPath:[entry path]];

        [[self navigationController] pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
    else
    {
        [self.navigationController fileSelectedWithPath:entry.path];

    }
    
}

@end
