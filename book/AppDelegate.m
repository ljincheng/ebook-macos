//
//  AppDelegate.m
//  book
//
//  Created by ljc on 2018/9/18.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import "AppDelegate.h"
#import "BookDatabase.h"


@interface AppDelegate ()

@end

@implementation AppDelegate{
    BookDatabase *bookDatabase;
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification{
    //notification.
#pragma unused (notification)
    bookDatabase=[[BookDatabase alloc]init];
//    [bookDatabase databaseCheck];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification{
    #pragma unused (notification)
//    BookMainWindowController *mainWinContrl=[[BookMainWindowController alloc]initWithWindowNibName:@"MainBook" owner:self];
//    [mainWinContrl showWindow:self];
}




- (IBAction)importBookDir:(id)sender {
    #pragma unused (sender)
//    NSOpenPanel *panel = [NSOpenPanel openPanel];
//    [panel setDirectoryURL:[NSURL fileURLWithPath:@"/workspace/temp"]];
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]] ;
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"mobi",@"azw3"]];
    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == 1) {
        NSString *path = [panel.URLs.firstObject path];
        NSLog(@"path=%@",path);
//        SqliteConection *con=[[SqliteConection alloc]init];
//        [con importBook:path];
//        BookDatabase * bookDatabase=[[BookDatabase alloc]init];
        [bookDatabase importBook:path];
        //code
    }
}
@end
