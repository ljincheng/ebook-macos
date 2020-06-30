//
//  主窗口
//  BookMainWindow.h
//  mobi
//
//  Created by ljc on 2018/10/23.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookMain_h
#define BookMain_h

#import <Cocoa/Cocoa.h>
#import "BookMarkOutlineView.h"
#import "BookInfoTableView.h"
#import "BookSearchField.h"

@interface BookMainWindow:NSWindow<NSWindowDelegate,NSSplitViewDelegate>

@property (weak) IBOutlet NSSplitView *mainSplitView;

@property (weak) IBOutlet BookInfoTableView *bookTableView;
@property (weak) IBOutlet BookMarkOutlineView *bookMarkOutlineView;
@property (weak) IBOutlet BookSearchField *bookSearchField;

- (IBAction)bookImport:(id)sender;
@property (weak) IBOutlet NSSegmentedControl *bookViewSegmentedControl;

@end

#endif /* BookMain_h */
