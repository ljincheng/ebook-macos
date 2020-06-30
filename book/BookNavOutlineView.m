//
//  BookNavOutlineView.m
//  book
//
//  Created by ljc on 2018/10/20.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookNavOutlineView.h"

@implementation BookNavOutlineView
{
    WKWebView *_bookWebView;
    BookNav * _rootBookNav;
}


-(void)defaultConfig:(WKWebView *)webView bookNav:(BookNav *)nav{
    _bookWebView=webView;
    _rootBookNav=nav;
    self.dataSource=self;
    self.delegate=self;
    [self sizeLastColumnToFit];
    [self setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    [self setDoubleAction:@selector(selectorbookNavOutlineViewDoubleClickAction:)];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:10.0f];
    [self expandItem:nil expandChildren:YES];
    [NSAnimationContext endGrouping];
    
}



#pragma mark -
#pragma mark NSOutlineView delegate/datasource methods

-(NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
#pragma unused (outlineView)
    //return (item == nil) ? 1 : [item numberOfChildren];
    if(item!=nil)
    {
        BookNav *bookNav=item;
        if([bookNav children]!=nil )
        {
            NSInteger count=[[NSNumber numberWithUnsignedInteger:[[bookNav children] count]] integerValue];
            if(count>0)
            {
                return count;
            }
        }
    }
    NSInteger count=[[NSNumber numberWithUnsignedInteger:[[_rootBookNav children] count]] integerValue];
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
        BookNav *bookNav=item;
        if([bookNav children]!=nil )
        {
            return [bookNav childAtIndex:index];
        }
        return [(BookNav *)item childAtIndex:index];
    }
    //return [[rootBookNav children] objectAtIndex:index];
    return [_rootBookNav childAtIndex:index];
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



- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
#pragma unused (outlineView,tableColumn,item)
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
#pragma unused (outlineView,item)
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
#pragma unused (outlineView,item)
    return YES;
}



/*
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
#pragma unused (notification)
    [self selectedNavBookChapter];
    
}
 */
-(void) selectedNavBookChapter{
    if ([self  selectedRow] != -1)
    {
        
        BookNav *item = [self itemAtRow:[self  selectedRow]];
        NSLog(@"选中%@,src=%@",[item text],[item src]);
        NSString *partUrl=[NSString stringWithFormat:@"ebook://%@",[item src]];
        NSURL *url=[NSURL URLWithString:partUrl];
        [_bookWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

-(void)keyUp:(NSEvent *)theEvent{
    NSLog(@"表格点击keycode=%hu",theEvent.keyCode);
    
    if(theEvent.keyCode==49 || theEvent.keyCode==36)
    { 
        [self selectedNavBookChapter];
    }
}

- (void) selectorbookNavOutlineViewDoubleClickAction:(id)sender
{
    NSOutlineView *theTableView =(NSOutlineView *)sender;
    NSInteger selectedRow = [theTableView selectedRow];
    if (selectedRow != -1)
    {
       [self selectedNavBookChapter];
    }
    
}

@end
