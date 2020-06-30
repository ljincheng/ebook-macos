//
//  BookToolbar.m
//  book
//
//  Created by ljc on 2018/10/18.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookToolbar.h"

@implementation BookToolbar
 
-(id)init{
    self=[super init];
    if(self)
    {
        [self setAllowsUserCustomization:NO];
        [self setAutosavesConfiguration:NO];
        [self setDisplayMode:NSToolbarDisplayModeIconOnly];
        [self setSizeMode:NSToolbarSizeModeSmall];
        self.delegate=self;
    }
    return self;
}
- (void)awakeFromNib {
    //[super awakeFromNib];
          [self setAllowsUserCustomization:NO];
          [self setAutosavesConfiguration:NO];
          [self setDisplayMode:NSToolbarDisplayModeIconOnly];
          [self setSizeMode:NSToolbarSizeModeSmall];
    
}
- (void)mouseDown:(NSEvent *)theEvent {
#pragma unused(theEvent)
    [self setVisible:FALSE];
}
 


@end
