//
//  BookWindow.h
//  mobi
//
//  Created by ljc on 2018/10/12.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookWindow_h
#define BookWindow_h


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BookInfo.h"
#import "BookNavOutlineView.h"
#import "BookToolbar.h"
#import "BookReadWindow.h"

@interface BookWindow:NSWindowController<NSWindowDelegate,NSSplitViewDelegate>
@property(atomic,assign) bool paginating;
@property (weak) IBOutlet NSSplitView *mainSplitView;
@property (weak) IBOutlet BookNavOutlineView *menuOutlineView;

@property (strong) IBOutlet BookReadWindow *mainWindow;

-(instancetype)initWithBookFile:(NSString *)filePath;
-(instancetype)initWithConfig:(BookInfo *)bookInfo config:(NSDictionary *)config;
@property (weak) IBOutlet BookToolbar *mainToolbar;
@property (weak) IBOutlet NSTextField *bookTitleLabel;

@property (nonatomic, assign) NSUInteger selectBookViewMode;
 

//@property (weak) IBOutlet NSSegmentedControl *bookSegmentedContrl;
@property (weak) IBOutlet NSSegmentedControl *bookColorSegmentedContrl;
@property (weak) IBOutlet NSSegmentedControl *bookMenuSegmentedContrl;
//@property (weak) IBOutlet NSToolbarItem *bookMenuToolbarItem;
//@property (weak) IBOutlet NSToolbarItem *bookMenuToolbarItem;

@end



#endif /* BookWindow_h */
