//
// 主窗口
//  BookMainWindow.h
//  book
//
//  Created by ljc on 2018/10/23.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookMainWindow.h"
#import "Book-mark.h"
#import "BookWindow.h"
#import "BookDatabase.h"
#import "BookSearchField.h"
#import "BookFileImport.h"
#import "book-play.h"

@implementation  BookMainWindow {
    NSMutableArray *_tableContents;
BookDatabase *_bookDatabase;
    int _isInit;
}

-(BookDatabase *) bookDatabase{
    if(_bookDatabase)
    {
        return _bookDatabase;
    }else{
        _bookDatabase=[[BookDatabase alloc]init];
    }
    return _bookDatabase;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
#pragma unused(style)
    self = [super initWithContentRect:contentRect
                            styleMask:style
                              backing:backingStoreType
                                defer:flag];
    if (self) {
        self.titleVisibility = NSWindowTitleHidden;
       // self.titlebarAppearsTransparent = YES;
//        self.styleMask |= NSWindowStyleMaskFullSizeContentView;

        
        
    }
    return self;
}

- (void)awakeFromNib {
 
    if(_isInit!=999)
    {
    BookDatabase *bookDatabase=[self bookDatabase];
    // bookDatabase=[[BookDatabase alloc]init];
    [bookDatabase databaseCheck];
    
    _tableContents=[bookDatabase queryBookList:-2];
    [_bookTableView loadBookInfo:_tableContents];
    [_bookTableView defaultConfig];
    [_bookMarkOutlineView defaultConfig:_bookTableView bookDatabase:bookDatabase];
    
    [self setTitle:@"BOOK"];
    self.mainSplitView.delegate=self;
        
         NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
        [self setFrame:NSMakeRect(60, 60, screenVisibleFrame.size.width-120,screenVisibleFrame.size.height) display:true];
    
    
    
    self.delegate=self;
   // BookSearchField *mysearchField=[[BookSearchField alloc]init];
    _bookSearchField.delegate=_bookSearchField;
        [_bookSearchField searchConfig:_tableContents tableView:_bookTableView bookDatabase:_bookDatabase];
    [_bookViewSegmentedControl setAction:@selector(bookViewSegmentAction:)];
    [_bookViewSegmentedControl setSelectedSegment:0];
  
        _isInit=999;
    }
}

- (void)bookViewSegmentAction:(id)sender{
#pragma unused(sender)
    
    NSInteger selectedIndex=  [_bookViewSegmentedControl selectedSegment];
    NSLog(@"选择：%zu",selectedIndex);
    //=======测试============
    BookPlay *bookPlay=[[BookPlay alloc] init];
    [bookPlay play:@"/Users/ljc/Movies/movie/test.mp4"];
    //========测试 end========
//     BookDatabase *bookDatabase=[self bookDatabase];
//    if(selectedIndex==0)
//    {
//        _tableContents=[bookDatabase queryBookList:-2];
//          [_bookTableView loadBookInfo:_tableContents];
//       [_bookTableView reloadData];
//    }else if(selectedIndex==1)
//    {
//        _tableContents=[bookDatabase queryBookList:-1];
//        [_bookTableView loadBookInfo:_tableContents];
//        [_bookTableView reloadData];
//    }
}
 
-(void)buttonClick:(id)sender
{
#pragma unused (sender)
    NSLog(@"button 点击");
    //BookWindowController * bookWin=[[BookWindowController alloc] initWithWindowNibName:@"Book-window"];
    //      BookWindowController * bookWin=[[BookWindowController alloc] initWithBookFile:@"/workspace/ebook/bookfere/zh/传记/奥威尔传：冷峻的良心.azw3"];
    //    [bookWin showWindow:nil];
    
    //  NSWindowController *testwin=[[NSWindowController alloc]init];
    // [testwin showWindow:nil];
    NSLog(@"button 点击完成");
}


#pragma mark NSSplitView delegate/datasource methods
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
#pragma unused (oldSize)
    CGFloat oldWidth = splitView.arrangedSubviews.firstObject.frame.size.width;
    [splitView adjustSubviews];
    [splitView setPosition:oldWidth ofDividerAtIndex:0];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
#pragma unused (splitView,dividerIndex,proposedMinimumPosition)
    return 0;
}


-(void) bookImportToDB:(NSString *)path{

     [[self bookDatabase] importBook:path];
}


- (IBAction)bookImport:(id)sender {
#pragma unused(sender)
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]] ;
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"mobi",@"azw3",@"epub"]];
    [panel setAllowsOtherFileTypes:YES];
    
//    [panel beginWithCompletionHandler:^(NSModalResponse result) {
//#pragma unused(result)
//                NSString *path = [panel.URLs.firstObject path];
////                NSLog(@"path=%@",path);
//
//        NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(bookImportToDB:) object:path];
//        [[NSOperationQueue mainQueue] addOperation:op1];
//    }];
    
      if ([panel runModal] == 1) {
          NSString *path = [panel.URLs.firstObject path];
           NSLog(@"path=%@",path);
//          NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(bookImportToDB:) object:path];
//          [[NSOperationQueue mainQueue] addOperation:op1];
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                [[self bookDatabase] importBook:path];
//            }];
          
          NSBlockOperation *operation=[NSBlockOperation blockOperationWithBlock:^{
                       NSLog(@"NSBlockOperation------%@",[NSThread currentThread]);
               [[self bookDatabase] importBook:path];
                   }];
          
           NSOperationQueue * queue=[[NSOperationQueue alloc]init];
          [queue addOperation:operation];
//          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//          [ operation start];
//                          }];
          
          NSLog(@" import end:path=%@",path);
          
      }

}




- (void)windowWillClose:(NSNotification *)notification
{
    #pragma unused (notification)
    NSWindow *window = notification.object;
    if(window == self) {
     [NSApp terminate:self];
     [[NSApplication sharedApplication] terminate:nil];  //或这句也行
    }
    
}


@end
