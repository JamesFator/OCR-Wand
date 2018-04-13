//
//  JFDetectView.m
//  OCR Wand
//
//  Created by James Fator on 11/25/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import "JFDetectView.h"

@implementation JFDetectView

#pragma mark Drawing Events

/**
 * drawRect will set a blue background with 25% alpha to signify the
 *   selected segment.
 * @param dirtyRect - view rect bounds
 */
- (void)drawRect:(NSRect)dirtyRect
{
    // Draw screen copy
    [_copiedScreen drawAtPoint:NSZeroPoint fromRect:NSZeroRect
                     operation:NSCompositeSourceOver fraction:1.0];
    // Draw overlay
    [[[NSColor grayColor] colorWithAlphaComponent:0.25] setFill];
    NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
	[super drawRect:dirtyRect];
}

// Set the background
- (void)setCopiedScreen:(NSImage *)copiedScreen
{
    _copiedScreen = copiedScreen;
    if ( _copiedScreen ) {
        [self setWantsLayer:YES];
        [[self layer] setContents:_copiedScreen];
    } else {
        [self setWantsLayer:NO];
        [[self layer] setContents:nil];
    }
}

#pragma mark - Mouse events

/** mouseDown is called when the left mouse button is clicked */
- (void)mouseDown:(NSEvent *)theEvent
{
    // Create the selection view with the current mouse location
    _selectionView = [[JFSelectionView alloc] initWithPoint:[NSEvent mouseLocation]];
    
    // Add the selection view to our view
    [self addSubview:_selectionView];
}

/** mouseDragged is called when the mouse is dragged */
- (void)mouseDragged:(NSEvent *)theEvent
{
    if ( [_selectionView isSelecting] ) {
        // Update the mouse location
        [_selectionView updateFrame:[NSEvent mouseLocation]];
        // Draw the crosshairs
        [[self window] invalidateCursorRectsForView:self];
    }
}

/** mouseUp is called when the left mouse button is released */
- (void)mouseUp:(NSEvent *)theEvent
{
    if ( [_selectionView isSelecting] ) {
        // Remove the selection view and call the delegate method
        [_selectionView setIsSelecting:NO];
        [_selectionView removeFromSuperview];
        [_detectDelegate selectedRect:[_selectionView selectionFrame]
                            withImage:_copiedScreen];
        _selectionView = nil;
        _copiedScreen = nil;
    }
}

/**
 * resetCursorRects will change the mouse to the crosshair icon
 *   only when the mouse is in the view.
 */
- (void)resetCursorRects
{
    // Set the crosshair cursor
    NSCursor *cursor = [NSCursor crosshairCursor];
    [self addCursorRect:[self frame] cursor:cursor];
    [cursor setOnMouseEntered:YES];
    
    // Make the detect view the first responder
    [self.window makeFirstResponder:self];
}

#pragma mark - Keyboard methods

- (void)keyDown:(NSEvent *)theEvent
{
    switch([theEvent keyCode]) {
        case 53: // esc
            NSLog(@"ESC");
            [_selectionView setIsSelecting:NO];
            [_selectionView removeFromSuperview];
            _selectionView = nil;
            [_detectDelegate selectedRect:NSMakeRect(0, 0, 0, 0) withImage:_copiedScreen];
            _copiedScreen = nil;
            break;
        default:
            [super keyDown:theEvent];
    }
}

@end
