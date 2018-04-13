//
//  JFSelectionView.m
//  OCR Wand
//
//  Created by James Fator on 11/25/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import "JFSelectionView.h"

@implementation JFSelectionView

/**
 * initWithFrame will set the origin frame to start with.
 * @param point - current mouse location
 */
- (id)initWithPoint:(NSPoint)point
{
    // Frame at just the mouse location
    CGRect frame = NSMakeRect(point.x, point.y, 0, 0);
    self = [super initWithFrame:frame];
    if (self) {
        // Initial frame
        _selectionFrame = frame;
        _originX = frame.origin.x;
        _originY = frame.origin.y;
        _isSelecting = YES;
        [self setFrame:_selectionFrame];
    }
    return self;
}

/**
 * drawRect will set a blue background with 25% alpha to signify the
 *   selected segment.
 * @param dirtyRect - view rect bounds
 */
- (void)drawRect:(NSRect)dirtyRect
{
    if ( _isSelecting ) {
        // If we're selecting, draw overlay
        [[[NSColor blueColor] colorWithAlphaComponent:0.25] setFill];
        NSRectFill(dirtyRect);
    }
	[super drawRect:dirtyRect];
}

/**
 * updateFrame will take the new mouse location and update
 *   the selection frame.
 * @param point - current mouse location
 */
- (void)updateFrame:(NSPoint)point
{
    // Set frame for selection window
    if ( point.y < _originY ) {
        _selectionFrame.origin.y = point.y;
        _selectionFrame.size.height = _originY - point.y;
    } else {
        _selectionFrame.origin.y = _originY;
        _selectionFrame.size.height = point.y - _originY;
    }
    if ( point.x < _originX ) {
        _selectionFrame.origin.x = point.x;
        _selectionFrame.size.width = _originX - point.x;
    } else {
        _selectionFrame.origin.x = _originX;
        _selectionFrame.size.width = point.x - _originX;
    }
    [self setFrame:_selectionFrame];
}

@end
