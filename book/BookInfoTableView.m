//
//  BookInfoTableView.m
//  book
//
//  Created by ljc on 2018/10/19.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfoTableView.h"
#import "BookWindow.h"
#import "BrowserWindowController.h"

@implementation BookInfoTableView{
    NSMutableArray *_tableContents;
}

-(void)defaultConfig{
    
        self.delegate=self;
        self.dataSource=self;
    self.usesAlternatingRowBackgroundColors = YES; //背景颜色的交替，一行白色，一行灰色。设置后，原来设置的 backgroundColor 就无效了。
    
    [self setTarget:self];
    [self setDoubleAction:@selector(bookTableViewDoubleClickAction:)];
}


- (void) bookTableViewDoubleClickAction:(id)sender
{
    
    
    NSTableView *theTableView = (NSTableView *)sender;
    NSInteger selectedRow = [theTableView selectedRow];
    if (selectedRow != -1)
    {
        //        NSDictionary *objectDict = [tableRecords objectAtIndex: selectedRow];
        //        if (objectDict != nil)
        //        {
        //            NSString *pathStr = [objectDict valueForKey:kPathKey];
        //            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:pathStr]];
        //        }
        
        BookInfo *bookInfo = [_tableContents objectAtIndex:[[NSNumber numberWithInteger:selectedRow]unsignedIntegerValue]];
        
        if([bookInfo bookMark])
        {
            // 打开浏览器窗口
            if([bookInfo webUrl] != nil)
            {
                BrowserWindowController *bookWindow=[[BrowserWindowController alloc]initWithURL:[bookInfo webUrl]];
                [bookWindow showWindow:self];
//                    [[bookWindow mainWindow ] isKeyWindow];
                return;
            }
            if([bookInfo webUrl] == nil)
            {
                // 打开读书窗口
                NSData *data=[[ bookInfo bookMark] dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary *dict001 = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                // 初始化
                // NSDictionary *dict001 = [[NSDictionary alloc] initWithObjectsAndKeys:bookInfo.bookSrc, @"Src", @"6", @"chapterIndex",@"3",@"pageIndex", nil];
                NSLog(@"\n dict001 = %@ \n", dict001);

                BookWindow *booWin=[[BookWindow alloc]initWithConfig:bookInfo config: dict001];

                [booWin showWindow:self];
                //        [booWin.window makeMainWindow];
                [[booWin mainWindow ] isKeyWindow];
            }
            
        }else{
            if([bookInfo webUrl] != nil)
            {
                BrowserWindowController *bookWindow=[[BrowserWindowController alloc]initWithURL:[bookInfo webUrl]];
                [bookWindow showWindow:self];
                
                return;
            }else{
                BookWindow *booWin=[[BookWindow alloc]initWithConfig:bookInfo config:nil];
                //        [booWin.window makeMainWindow];
                //        [booWin.window setAccessibilityFocused:TRUE];
                [booWin showWindow:self];
                [[booWin mainWindow ] isKeyWindow];
                //[self respondsToSelector:booWin.mainWindow  ];
                //[booWin showWindow:nil];
            }
        }
        
    }
}

 
-(void) loadBookInfo:(NSMutableArray *) data{
    _tableContents=data;
}

-(void)keyUp:(NSEvent *)theEvent{
    NSLog(@"表格点击keycode=%hu",theEvent.keyCode);
    
    if(theEvent.keyCode==49 || theEvent.keyCode==36)
    {
        NSInteger selectedRow = [self selectedRow];
        if (selectedRow != -1)
        {
          
            
            BookInfo *bookInfo = [_tableContents objectAtIndex:[[NSNumber numberWithInteger:selectedRow]unsignedIntegerValue]];
            
            if([bookInfo bookMark])
            {
                // 打开浏览器窗口
                if([bookInfo webUrl] != nil)
                {
                    BrowserWindowController *bookWindow=[[BrowserWindowController alloc]initWithURL:[bookInfo webUrl]];
                    [bookWindow showWindow:self];
//                    [[bookWindow mainWindow ] isKeyWindow];
                    return;
                }
                if([bookInfo webUrl] == nil)
                {
                    
                    NSData *data=[[ bookInfo bookMark] dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error;
                    NSDictionary *dict001 = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    // 初始化
                    // NSDictionary *dict001 = [[NSDictionary alloc] initWithObjectsAndKeys:bookInfo.bookSrc, @"Src", @"6", @"chapterIndex",@"3",@"pageIndex", nil];
                    NSLog(@"\n dict001 = %@ \n", dict001);
                    
                    BookWindow *booWin=[[BookWindow alloc]initWithConfig:bookInfo config: dict001];
                    
                    [booWin showWindow:self];
                    //        [booWin.window makeMainWindow];
                   // [[booWin mainWindow ] isKeyWindow];
                }
                
            }else{
                // 打开浏览器窗口
                if([bookInfo webUrl] != nil)
                {
                    BrowserWindowController *bookWindow=[[BrowserWindowController alloc]initWithURL:[bookInfo webUrl]];
                    [bookWindow showWindow:self];
                   // [[bookWindow mainWindow ] isKeyWindow];
                    return;
                }
                if([bookInfo webUrl] == nil)
                {
                    BookWindow *booWin=[[BookWindow alloc]initWithConfig:bookInfo config:nil];
                    //        [booWin.window makeMainWindow];
                    //        [booWin.window setAccessibilityFocused:TRUE];
                    [booWin showWindow:self];
                    [[booWin mainWindow ] isKeyWindow]; 
                    //[self respondsToSelector:booWin.mainWindow  ];
                    //[booWin showWindow:nil];
                }
            }
            
        }
    }
}


#pragma mark -
#pragma mark NSTableView delegate/datasource methods
// The only essential/required tableview dataSource method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
#pragma unused (tableView)
    NSInteger count=[[NSNumber numberWithUnsignedInteger:[_tableContents count]] integerValue];
    return count;
    
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    // NSDictionary *dictionary = [_tableContents objectAtIndex:[[NSNumber numberWithInteger:row]unsignedIntegerValue]];
    BookInfo *bookInfo = (BookInfo *)[_tableContents objectAtIndex:[[NSNumber numberWithInteger:row]unsignedIntegerValue]];
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"bookTitle"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        
        if (!cellView)
            cellView = [[NSTableCellView alloc]initWithFrame:CGRectMake(0, 0, tableColumn.width, 58)];
        cellView.textField.stringValue=bookInfo.bookTitle;
        cellView.imageView.objectValue= [NSImage imageNamed:@"NSBookmarksTemplate"];
        return cellView;
        
        //        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        //        NSString *author=bookInfo.bookTitle;//[dictionary objectForKey:@"Author"];
        //        cellView.textField.stringValue=(author==nil?@"":author);
        
        //        return cellView;
    } else if ([identifier isEqualToString:@"bookAuthor"]) {
        /*
         NSImage *image = [dictionary objectForKey:@"Image"];
         NSSize size = image ? [image size] : NSZeroSize;
         NSString *sizeString = [NSString stringWithFormat:@"%.0fx%.0f", size.width, size.height];
         */
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        NSString *author=bookInfo.bookAuthor;//[dictionary objectForKey:@"Author"];
        cellView.textField.stringValue=(author==nil?@"":author);
        
        return cellView;
    } else if([identifier isEqualToString:@"bookOpenTime"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        NSString *openTime=bookInfo.bookOpenTime;//[dictionary objectForKey:@"Author"];
        cellView.textField.stringValue=(openTime==nil?@"":openTime);
        
        return cellView;
        // NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
        
    } else if([identifier isEqualToString:@"bookCreateTime"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        NSString *createTime=bookInfo.bookCreateTime;//[dictionary objectForKey:@"Author"];
        cellView.textField.stringValue=(createTime==nil?@"":createTime);
        
        return cellView;
        // NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
       
    }
     return nil;
}
-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
#pragma unused (tableView,row)
    return 20;
}

// -------------------------------------------------------------------------------
//    sortWithDescriptor:descriptor
// -------------------------------------------------------------------------------
- (void)sortWithDescriptor:(id)descriptor
{
#pragma unused (descriptor)
    NSUInteger count= [_tableContents count];
    if(count<1)
    {
        count=1;
    }
    NSMutableArray *sorted = [[NSMutableArray alloc] initWithCapacity:count];
    [sorted addObjectsFromArray:[_tableContents sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]]];
    [_tableContents removeAllObjects];
    [_tableContents addObjectsFromArray:sorted];
    [self reloadData];
}
- (void)tableView:(NSTableView *)inTableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    NSArray *allColumns=[inTableView tableColumns];
    NSInteger i;
    for (i=0; i<[inTableView numberOfColumns]; i++)
    {
        if ([allColumns objectAtIndex:[[NSNumber numberWithInteger:i] unsignedIntegerValue]]!=tableColumn)
        {
            [inTableView setIndicatorImage:nil inTableColumn:[allColumns objectAtIndex:[[NSNumber numberWithInteger:i] unsignedIntegerValue]]];
        }
    }
    [inTableView setHighlightedTableColumn:tableColumn];
    
    if ([inTableView indicatorImageInTableColumn:tableColumn] != [NSImage imageNamed:@"NSAscendingSortIndicator"])
    {
        [inTableView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];
        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:YES];
        [self sortWithDescriptor:sortDesc];
    }
    else
    {
        [inTableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:NO];
        [self sortWithDescriptor:sortDesc];
    }
}





@end
