//
//  BookToolbar.h
//  mobi
//
//  Created by ljc on 2018/10/18.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookToolbar_h
#define BookToolbar_h

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface BookToolbar:NSToolbar<NSToolbarDelegate>{
    NSString * _title;
}
-(id)init;

@end

#endif /* BookToolbar_h */
