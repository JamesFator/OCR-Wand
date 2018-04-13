//
//  JFSelectionView.h
//  OCR Wand
//
//  Created by James Fator on 11/25/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JFSelectionView : NSView

@property (nonatomic) BOOL isSelecting;
@property (nonatomic) CGRect selectionFrame;
@property (nonatomic) CGFloat originX;
@property (nonatomic) CGFloat originY;

- (id)initWithPoint:(NSPoint)point;
- (void)updateFrame:(NSPoint)point;

@end
