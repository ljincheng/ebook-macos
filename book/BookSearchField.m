//
//  BookSearchField.m
//  book
//
//  Created by ljc on 2018/10/24.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BookSearchField.h"

@implementation BookSearchField{
    NSMutableArray            *allKeywords;
    NSMutableArray            *builtInKeywords;
    BookInfoTableView *_tableView;
    NSMutableArray *_data;
    BookDatabase *_bookDatabase;
    
    
}

-(void) searchConfig:(NSMutableArray *) data tableView:(BookInfoTableView *) view bookDatabase:(BookDatabase *) db{
    _data=data;
    _tableView=view;
    _bookDatabase=db;
}
- (void)textDidChange:(NSNotification *)aNotification{
     #pragma unused(aNotification)
    NSLog(@"textDidChange:%@",aNotification);
    _data=[_bookDatabase queryKey:[self stringValue]];
    
    [_tableView loadBookInfo:_data];
    [_tableView reloadData];
    NSLog(@"textDidChange textview=%@",[self stringValue]);
    
}

- (NSArray *)allKeywords
{
    NSArray *array = [[NSArray alloc] init];
  //  unsigned int i;
    unsigned long i,count;
    
    if (allKeywords == nil)
    {
        if(builtInKeywords==nil)
        {
            builtInKeywords = [[NSMutableArray alloc] initWithObjects:
                               @"Favorite", @"Favorite1", @"Favorite11", @"Favorite3", @"Vacations1", @"Vacations2",
                               @"Hawaii", @"Family", @"Important", @"Important2",@"Personal", nil];
        }
        allKeywords = [builtInKeywords mutableCopy];
        
        if (array != nil)
        {
            count = [array count];
            for (i=0; i<count; i++)
            {
                if ([allKeywords indexOfObject:[array objectAtIndex:i]] == NSNotFound)
                    [allKeywords addObject:[array objectAtIndex:i]];
            }
        }
        [allKeywords sortUsingSelector:@selector(compare:)];
    }
    return allKeywords;
}


- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words
 forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    #pragma unused(control,textView,words,charRange,index)
    NSMutableArray*    matches = NULL;
    NSString*        partialString;
    NSArray*        keywords;
    unsigned long    i,count;
    NSString*        string;
    
    partialString = [[textView string] substringWithRange:charRange];
    keywords      = [self allKeywords];
    count         = [keywords count];
//    count=0;
    matches       = [NSMutableArray array];
    
    // find any match in our keyword array against what was typed -
    for (i=0; i< count; i++)
    {
        string = [keywords objectAtIndex:i];
        if ([string rangeOfString:partialString
                          options:NSAnchoredSearch | NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [string length])].location != NSNotFound)
        {
            [matches addObject:string];
        }
    }
    [matches sortUsingSelector:@selector(compare:)];
    
    return matches;
}


@end
