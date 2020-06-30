//
//  BookRead.m
//  book
//
//  Created by ljc on 2018/9/19.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookRead.h"
#import "Book-mobi.h"
#import "Book-epub.h"

@implementation BookRead{
    BookMobi * _bookMobi;
    BookEpub * _bookEpub;
    NSString * _bookPath;
    BookNav * _bookNav;
    size_t _chapterCount;
    int _bookType;
}

- (id) initWithPath:(NSString*)bookPath{
     if((self=[super init])){
         _bookMobi=nil;
         _bookPath=bookPath;
         _bookNav=nil;
         _chapterCount=0;
         _bookType=0;
         if([[bookPath pathExtension] isEqualToString:@"azw3"] || [[bookPath pathExtension] isEqualToString:@"mobi"])
         {
             _bookMobi=[[BookMobi alloc] initWithPath:_bookPath];
             _bookType=2;
         }else if([[bookPath pathExtension] isEqualToString:@"epub"])
         {
             _bookEpub=[[BookEpub alloc]initWithPath:_bookPath];
             _bookType=1;

         }
     }
    return self;
}


-(BookChapter *) chapter:(size_t)index{
  
        if(_bookType==2)
        {
            return [_bookMobi chapter:index];
        }else if(_bookType==1)
        {
            return [_bookEpub chapter:index];
        }
    
    return nil;
}

-(BookChapter *) resource:(NSString *) path{
    
        if(_bookType==2)
        {
            return [_bookMobi resource:path];
        }else if(_bookType==1)
        {
            return [_bookEpub resource:path];
        }
    
    return nil;
}

-(BookNav *) bookNav{
    if(_bookNav)
    {
        return _bookNav;
    }else if(_bookType==2){
            return [_bookMobi bookNav];
        
    }else if(_bookType==1)
    {
        return [_bookEpub bookNav];
    }
     return nil;
}
-(size_t) chapterCount{
    if(_chapterCount>0)
    {
        return _chapterCount;
    }else if(_bookType==2){
        return [_bookMobi chapterCount];
    }else if(_bookType==1)
    {
        return [_bookEpub chapterCount];
    }
    return 0;
}

-(NSString *) title{
    if(_bookType==2)
    {
        return [_bookMobi title];
    }else if(_bookType==1)
    {
        return [_bookEpub title];
    }
    
    return nil;
}

-(NSString *) author{
    if(_bookType==2)
    {
        return [_bookMobi author];
    }else if(_bookType==1)
    {
        return [_bookEpub author];
    }
    return nil;
}

-(NSString *) bookId{
    if(_bookType==2)
    {
        return [_bookMobi bookId];
    }else if(_bookType==1)
    {
        return [_bookEpub bookId];
    }
    return nil;
}
 
-(void)dealloc{
//       if(_bookMobi)
//       {
//           _bookMobi=nil;
//       }
    
}

@end

