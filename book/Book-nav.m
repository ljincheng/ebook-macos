//
//  Book-nav.m
//  book
//
//  Created by ljc on 2018/9/30.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import "Book-nav.h"
#import <objc/runtime.h>

@implementation BookNav

static BookNav *rootItem = nil;

#define IsALeafNode ((id)-1)

- (id)init
{
    if (self = [super init]) {
        _text =nil;
        _src =nil;
        _parent=nil;
        _level=1;
       // _children=[[NSMutableArray alloc] init];
        _children=nil;
    }
    
    return self;
}


- (id)initWithText:(NSString *)text parent:(BookNav *)obj {
    if (self = [super init]) {
        self.text=text;
        self.parent = obj;
        self.level=obj.level+1;
        //self.children=[[NSMutableArray alloc] init];
        self.children=nil;
    }
    return self;
}


+ (BookNav *)rootItem {
    if (rootItem == nil)
    {
        
        rootItem = [[BookNav alloc] initWithText:@"菜单" parent:nil];
        [rootItem setChildren:[NSMutableArray new]];
       //  NSMutableArray * topMenuNodelist=[NSMutableArray new];;
        NSData *data=[ @"[{\"text\":\"项目\",\"src\":\"ContentView1\",\"children\":[{\"text\":\"Content Views\",\"src\":\"ContentView1\"},{\"text\":\"Mailboxes\",\"src\":\"ContentView3\"}]},{\"text\":\"目录2\",\"src\":\"ContentView2\",\"children\":[{\"text\":\"A Fourth Group\",\"src\":\"ContentView2\"}]}]" dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *bebejson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //        if(error)
        //            NSLog(@"%@", [error description]);
        for(NSDictionary *arraydict in bebejson)
        {
            BookNav *menu = [[BookNav alloc] init];
            [menu parseDict:arraydict];
            //[topMenuNodelist addObject:menu];
            [[rootItem children]addObject:menu];
        }
        //[rootItem children:_topMenuNodelist];
    }
    return rootItem;
}


- (BookNav *)childAtIndex:(NSInteger)n{
    if([self children]==nil)
    {
        return nil;
    }
    return [[self children] objectAtIndex:[[NSNumber numberWithInteger: n] unsignedIntegerValue] ];
}

- (NSInteger)numberOfChildren {
    id tmp = [self children];
    return (tmp ==nil) ? (-1) :[ [NSNumber numberWithUnsignedInteger:[tmp count]] integerValue];
}



-(void) parseDict:(NSDictionary *)dict
{
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (unsigned long i = 0; i < outCount; i++) {
        const char *name = property_getName(properties[i]);
        NSString * keyname=[NSString stringWithUTF8String:name];
        if(dict[keyname])
        {
            if(![dict[keyname] isEqual:[NSNull null]] && [dict[keyname] isKindOfClass:[NSString class]])
            {
                if(![dict[keyname] isEqualToString:@""])
                {
                    
                    [self setValue:dict[keyname] forKey:keyname];
                    
                }
            }else{
                if([keyname isEqualToString:@"children"]  )
                {
                    
                    NSArray *childs=(NSArray *)dict[keyname];
                    for(unsigned long c=0,ck=[childs count];c<ck;c++)
                    {
                        BookNav *menu=[[BookNav alloc]init];
                        [menu parseDict:(NSDictionary *)dict[keyname][c]];
                        if([self children]==nil)
                        {
                            [self setChildren:[NSMutableArray new]];
                        }
                        [[self children] addObject:menu];
                    }
                }else{
                    [self setValue:dict[keyname] forKey:keyname];
                }
            }
        }
    }
    NSLog(@"property:%d",outCount);
    free(properties);
}

+(BookNav *) toBookNavNode:(BookNavPoint *) bookNavPoint
{
    BookNav *bookNav=[[BookNav alloc]init];
    [bookNav setText:[NSString stringWithUTF8String:bookNavPoint->text]];
    if(bookNavPoint->src!=NULL)
    [bookNav setSrc:[NSString stringWithUTF8String:bookNavPoint->src]];
    [bookNav setLevel:1];
    return bookNav;
}

+(BookNav *) loopAddChildBookNavPoint:(BookNavPoint *)bookNavPoint parentBookNav:(BookNav *)bookNav
{
    if(bookNavPoint!=NULL && bookNavPoint !=nil)
    {
        //添加本节点
        BookNav *curNav=[self toBookNavNode:bookNavPoint];
        if([bookNav children]==nil)
        {
            NSMutableArray *childArr=[NSMutableArray new];
            [bookNav setChildren:childArr];
        }
        [curNav setParent:bookNav];
        [curNav setLevel:(bookNav.level+1)];
        [[bookNav children]addObject:curNav];
        
        //添加子节点
        if(bookNavPoint->hasChildren)
        {
            BookNavPoint *childNavPoint=bookNavPoint->children;
             [self loopAddChildBookNavPoint:childNavPoint parentBookNav:curNav];
        }
        
        //添加下个节点
        while(bookNavPoint->hasNext)
        {
            bookNavPoint=bookNavPoint->next;
            BookNav *nextChildNav=[self toBookNavNode:bookNavPoint];
            [[bookNav children] addObject:nextChildNav];
            if(bookNavPoint->hasChildren)
            {
                BookNavPoint *childNavPoint=bookNavPoint->children;
                [self loopAddChildBookNavPoint:childNavPoint parentBookNav:nextChildNav]; 
            }
        }
    }
    return bookNav;
}

+(BookNav *) loadBookNavPoint:(BookNavPoint *) bookNavPoint{
    if(bookNavPoint==nil)
    {
        return nil;
    }
     rootItem = [[BookNav alloc] initWithText:@"菜单" parent:nil];
    
    NSMutableArray *rootChild=[NSMutableArray new];
    [rootItem setChildren:rootChild];
//    BookNav * rootBookNav=[self toBookNavNode:bookNavPoint];
   // [rootChild addObject:rootBookNav];
    [self loopAddChildBookNavPoint:bookNavPoint parentBookNav:rootItem];
//    while (bookNavPoint->hasNext) {
//         [rootChild addObject:[self toBookNavNode:bookNavPoint->next]];
//    }
    return rootItem;
}

+(void) loopFreeBookNavPoint:(BookNavPoint *) bookNavPoint{
    
    while(bookNavPoint!=NULL && bookNavPoint->hasChildren)
    {
        [self loopFreeBookNavPoint:bookNavPoint->children];
    }
    while(bookNavPoint!=NULL &&  bookNavPoint->hasNext)
    {
        [self loopFreeBookNavPoint:bookNavPoint->next];
    }
    if(bookNavPoint!=NULL)
    {
        if(bookNavPoint->pointId!=NULL)
        {
            free(bookNavPoint->pointId);
            bookNavPoint->pointId=NULL;
        }
        if(bookNavPoint->text!=NULL)
        {
        free(bookNavPoint->text);
            bookNavPoint->text=NULL;
        }
          if(bookNavPoint->src!=NULL)
          {
        free(bookNavPoint->src);
              bookNavPoint->src=NULL;
          }
         if(bookNavPoint->playOrder!=NULL)
         {
        free(bookNavPoint->playOrder);
             bookNavPoint->playOrder=NULL;
         }
        bookNavPoint->hasChildren=FALSE;
        bookNavPoint->hasNext=FALSE;
        free(bookNavPoint);
        bookNavPoint=NULL;
    }
}

+(void) freeBookNavPoint:(BookNavPoint *) bookNavPoint{
    if(bookNavPoint==nil || bookNavPoint ==NULL)
    {
        return ;
    }
    [self loopFreeBookNavPoint:bookNavPoint];
}
@end
