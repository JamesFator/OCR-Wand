//
//  JFPopoverController.m
//  OCR Wand
//
//  Created by James Fator on 12/11/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import "JFPopoverController.h"

@implementation JFPopoverController

// setText sets the NSTextFields string value
- (void)setText:(NSString*)string
{
    [_recognizedText setStringValue:string];
}

// getText returns the NSTextFields string value
- (NSString*)getText
{
    return _recognizedText.stringValue;
}

@end
