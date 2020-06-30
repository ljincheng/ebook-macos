//
//  Book-mark.m
//  book
//
//  Created by ljc on 2018/10/8.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//
#import "Book-mark.h"
#import <objc/runtime.h>

@implementation BookMark

static BookMark *BOOKMARKROOTITEM = nil;

#define IsALeafNode ((id)-1)

- (id)init
{
    if (self = [super init]) {
        _text =nil;
        _src =nil;
        _parent=nil;
        // _children=[[NSMutableArray alloc] init];
        _children=nil;
        _isSpecialGroup=false;
        _isDirectory=false;
        _cannotHide=false;
    }
    
    return self;
}


- (id)initWithText:(NSString *)text parent:(BookMark *)obj {
    if (self = [super init]) {
        self.text=text;
        self.parent = obj;
        self.mark=0;
        self.isSpecialGroup=false;
        //self.children=[[NSMutableArray alloc] init];
        self.children=nil;
        _isDirectory=false;
        _cannotHide=false;
    }
    return self;
}


+ (BookMark *)rootItem {
    if (BOOKMARKROOTITEM == nil)
    {
        
        BOOKMARKROOTITEM = [[BookMark alloc] initWithText:@"菜单" parent:nil];
        [BOOKMARKROOTITEM setChildren:[NSMutableArray new]];
        //  NSMutableArray * topMenuNodelist=[NSMutableArray new];;
        NSData *data=[ @"[{\"text\":\"最近阅读\",\"mark\":-2,\"src\":\"all\"},{\"text\":\"全部\",\"mark\":-1,\"src\":\"all\"},{\"text\":\"科技\", \"children\":[{\"text\":\"编程\",\"mark\":1,\"src\":\"keji1\"}]},{\"text\":\"文学\",\"children\":[{\"text\":\"经管\",\"mark\":2,\"src\":\"keji1\"}]}]" dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *bebejson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //        if(error)
        //            NSLog(@"%@", [error description]);
        for(NSDictionary *arraydict in bebejson)
        {
            BookMark *menu = [[BookMark alloc] init];
            [menu parseDict:arraydict];
            //[topMenuNodelist addObject:menu];
            [[BOOKMARKROOTITEM children]addObject:menu];
        }
        //[rootItem children:_topMenuNodelist];
    }
    return BOOKMARKROOTITEM;
}


- (BookMark *)childAtIndex:(NSInteger)n{
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
                        BookMark *menu=[[BookMark alloc]init];
                        [menu parseDict:(NSDictionary *)dict[keyname][c]];
                        if([self children]==nil)
                        {
                            [self setChildren:[NSMutableArray new]];
                        }
                        [menu setParent:self];
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

@end
