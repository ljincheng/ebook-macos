//
//  BrowserWindowController.h
//  mobi
//
//  Created by ljc on 2019/11/29.
//  Copyright © 2019 Bartek Fabiszewski. All rights reserved.
//

#ifndef BrowserWindowController_h
#define BrowserWindowController_h


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BrowserWindow.h"
#import "BookInfo.h"

@interface BrowserWindowController:NSWindowController<NSWindowDelegate>
@property (strong) IBOutlet BrowserWindow *browserWindow;

//@property (strong) IBOutlet BrowserWindow *mainWindow;
-(instancetype)initWithURL:(NSString *)url;
//-(instancetype)initWithInfo:(BookInfo *)bookInfo;

@end

#endif /* BrowserWindowController_h */
