//
//  JFPopoverController.h
//  OCR Wand
//
//  Created by James Fator on 12/11/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JFPopoverController : NSViewController

@property (weak) IBOutlet NSTextField *recognizedText;

- (void)setText:(NSString*)string;
- (NSString*)getText;

@end
