//
//  BookMarkOutlineView.m
//  book
//
//  Created by ljc on 2018/10/20.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookMarkOutlineView.h"
#import "Book-mark.h"
#import "BookDatabase.h"

@implementation BookMarkOutlineView{
    BookInfoTableView *_bookTableView;
    BookDatabase * _bookDatabase;
    NSMutableArray *_tableContents;
    BookMark * _rootBookList;
}
 


-(void)defaultConfig:(BookInfoTableView *)tableView bookDatabase:(BookDatabase *) db{
    _bookTableView=tableView;
    _bookDatabase=db;
    //_bookDatabase=[[BookDatabase alloc]init];
    NSString *bookdirectory =[db queryParam:@"bookdirectory"];
    if(bookdirectory)
    {
        NSData *data=[ bookdirectory dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *bebejson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        BookMark *dbBookMark=[[BookMark alloc]init];
        [dbBookMark parseDict:bebejson];
        _rootBookList=dbBookMark;
    }else{
    _rootBookList=[BookMark rootItem];
    }
   
    self.delegate=self;
    self.dataSource=self;
   // self.usesAlternatingRowBackgroundColors = YES; //背景颜色的交替，一行白色，一行灰色。设置后，原来设置的 backgroundColor 就无效了。
    
    //[self setTarget:self];
   
    [self sizeLastColumnToFit];
    [self reloadData];
    [self setFloatsGroupRows:NO];
     [self setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    
//    [NSAnimationContext beginGrouping];
//    [[NSAnimationContext currentContext] setDuration:1.0f];
    [self expandItem:nil expandChildren:YES];
//    [NSAnimationContext endGrouping];
     [self setDoubleAction:@selector(selectorbookMarkOutlineViewDoubleClickAction:)];
    
}

-(void) reloadTableViewData:(NSInteger) selectedRow{
    BookMark *item = [self itemAtRow:selectedRow];
    // NSLog(@"选中%@,src=%@",[item text],[item src]);
    if(![item isDirectory] && ![item isSpecialGroup])
    {
        int markValue=[item mark];
        if(markValue==-11 || markValue== - 12|| markValue== - 13)
        {
            _tableContents=[_bookDatabase queryNewsList:markValue];
            [_bookTableView loadBookInfo:_tableContents];
            [_bookTableView reloadData];
            
        }else{
        _tableContents=[_bookDatabase queryBookList:markValue];
        [_bookTableView loadBookInfo:_tableContents];
        [_bookTableView reloadData];
        }
    }
}
- (void) selectorbookMarkOutlineViewDoubleClickAction:(id)sender
{
    NSOutlineView *theTableView =(NSOutlineView *)sender;
    NSInteger selectedRow = [theTableView selectedRow];
    
 
    if (selectedRow != -1)
    {
       // BookMark *bookMark=(BookMark*) [theTableView itemAtRow:selectedRow];
        [self reloadTableViewData:selectedRow];
    }
    
}


-(void)keyUp:(NSEvent *)theEvent{
    NSLog(@"表格点击keycode=%hu",theEvent.keyCode);
    
    if(theEvent.keyCode==49 || theEvent.keyCode==36)
    {
        
        NSInteger selectedRow = [self selectedRow];
        if (selectedRow != -1)
        {
             [self reloadTableViewData:selectedRow];
        }
    }
}


#pragma mark -
#pragma mark NSOutlineView delegate/datasource methods

-(NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
#pragma unused (outlineView)
    //return (item == nil) ? 1 : [item numberOfChildren];
    if(item!=nil)
    {
        BookMark *bookNav=item;
        if([bookNav children]!=nil )
        {
            NSInteger count=[[NSNumber numberWithUnsignedInteger:[[bookNav children] count]] integerValue];
            if(count>0)
            {
                return count;
            }
        }
    }
    NSInteger count=[[NSNumber numberWithUnsignedInteger:[[_rootBookList children] count]] integerValue];
    return count;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
#pragma unused (outlineView)
    //NSLog(@"coutn:%lu",[item childCount]);
    // return (item == nil) ? YES : ([item numberOfChildren] != -1);
    // return (item == nil) ? YES : NO;
    if(item!=nil)
    {
        return [item children]!=nil;
    }
    return YES;
}

-(id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
#pragma unused (outlineView)
    // return (item == nil)?[self.xmldoc rootElement]:[(NSXMLElement*)item childAtIndex:index];
    //return (item == nil) ? [BookNav rootItem] : [(BookNav *)item childAtIndex:index];
    if(item!=nil)
    {
        BookMark *bookNav=item;
        if([bookNav children]!=nil )
        {
            return [bookNav childAtIndex:index];
        }
        return [(BookMark *)item childAtIndex:index];
    }
    //return [[rootBookNav children] objectAtIndex:index];
    return [_rootBookList childAtIndex:index];
}

-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
#pragma unused (outlineView,tableColumn)
    if(item==nil)
    {
        NSLog(@"没有找到菜单目录");
    }
    return (item == nil) ? @"/" : (id)[item text];
    //return @"OK";
}


- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    
    // The cell is setup in IB. The textField and imageView outlets are properly setup.
    // Special attributes are automatically applied by NSTableView/NSOutlineView for the source list
    //NSString *identifier = [tableColumn identifier];
    BookMark *bookmarkitem = (BookMark *)item;
    if([bookmarkitem isSpecialGroup])
    {
        NSTextField *result = [outlineView makeViewWithIdentifier:@"markHeader" owner:self];
        // Uppercase the string value, but don't set anything else. NSOutlineView automatically applies attributes as necessary
        NSString *value = [bookmarkitem.text uppercaseString];
        [result setStringValue:value];
        return result;
    }
   
     NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"markItem" owner:self];
   // if ([identifier isEqualToString:@"markItem"]) {
       // NSTableCellView *cellView = [outlineView makeViewWithIdentifier:identifier owner:self];
        
        if (!cellView)
            cellView = [[NSTableCellView alloc]initWithFrame:CGRectMake(0, 0, tableColumn.width, 58)];
        cellView.textField.stringValue=bookmarkitem.text;
    if(bookmarkitem.src !=nil  )
    {
        
          cellView.imageView.objectValue= [NSImage imageNamed:bookmarkitem.src];
    
//    }else{
//        if([bookmarkitem numberOfChildren]==-1 )
//        {
//            cellView.imageView.objectValue= [NSImage imageNamed:@"NSStatusAvailable"];
//            [cellView.imageView setHidden:false];
//        }else{
//            [cellView.imageView setHidden:TRUE];
//        }
    }else{
        [cellView.imageView setHidden:TRUE];
    }
    
        return cellView;
   // }
   // return nil;
    
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
#pragma unused (outlineView,tableColumn,item)
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
#pragma unused (outlineView,item)
    return YES;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    #pragma unused (outlineView,item)
   if(item)
   {
      BookMark *node = (BookMark *)item;
    return (!node.isSpecialGroup );
   }
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    #pragma unused (outlineView,item)
//    return NO;
    if(item)
    {
    BookMark *node = (BookMark *)item;
    return ([node isSpecialGroup] ? YES : NO);
    }
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
   #pragma unused (outlineView,item)
    if(item)
    {
        BookMark *bookmark=(BookMark *)item;
        if(bookmark.cannotHide)
        {
            return NO;
        }
    }
    return YES;
}
/*
 - (void)outlineViewSelectionDidChange:(NSNotification *)notification
 {
 #pragma unused (notification)
 if ([_bookMarkOutlineView  selectedRow] != -1)
 {
 
 BookMark *item = [_bookMarkOutlineView itemAtRow:[_bookMarkOutlineView  selectedRow]];
 NSLog(@"选中%@,src=%@",[item text],[item src]);
 
 if([item src]!=nil)
 {
 _tableContents=[[self bookDatabase] queryBookList:[item mark]];
 [_bookTableView reloadData];
 }
 }
 
 }
 */


@end
