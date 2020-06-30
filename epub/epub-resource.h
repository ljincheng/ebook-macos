//
//  epub-resource.h
//  mobi
//
//  Created by ljc on 2018/11/12.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef epub_resource_h
#define epub_resource_h

#import <Foundation/Foundation.h>


@interface  EpubResource : NSObject
@property (nonatomic, copy) NSString * resId;
@property (nonatomic, copy) NSString * mime;
@property (nonatomic, copy) NSString * href;
@property (nonatomic)  NSData * data;

@end


#endif /* epub_resource_h */
