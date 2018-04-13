//
//  JFDetectWindow.m
//  OCR Wand
//
//  Created by James Fator on 11/25/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import "JFDetectWindow.h"

@implementation JFDetectWindow

/**
 * canBecomeKeyWindow overrides the super method and allows us
 *   to make the boarderless window the key immediately.
 */
- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
