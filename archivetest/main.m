//
//  main.m
//  archivetest
//
//  Created by ljc on 2018/11/7.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
int main(int argc, const char * argv[]) {
#pragma unused(argc,argv)
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
*/

#import "epub.h"

int main(int argc, const char * argv[]) {
    #pragma unused(argc,argv)
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        char * testFile="/url/local/workspace/ebook/out/3001860_Beginning.iOS.5.Development.Exploring.the.iOS.SDK.Dec.2011.epub";
        EpubDoc *doc=[[EpubDoc alloc] initWithPath:testFile];
        //EpubArchive *epubArchive=[[EpubArchive alloc]initWithPath:testFile];
        //NSString * rootfile= [doc contentBase];
       // NSLog(@"rootFile=%@\n",rootfile);
        NSMutableArray *spine=[doc spine];
        NSMutableDictionary *res=[doc resource];
        NSUInteger i=0;
        NSUInteger count=[spine count];
        for(;i<count;i++)
        {
           NSString *resid= [spine objectAtIndex:i];
           EpubResource *epubRes=  [res objectForKey:resid];
            NSLog(@"resid=%@,mine=%@,href=%@\n",resid,[epubRes mime],[epubRes href]);
            NSLog(@"data=%@\n",[doc read:[epubRes href]]);
            
            
        }
       // char * content=[epubArchive readEntry:rootfile];
         //NSLog(@"rootFile content=%s\n",content);
    }
}
