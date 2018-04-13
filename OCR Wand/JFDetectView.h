//
//  JFDetectView.h
//  OCR Wand
//
//  Created by James Fator on 11/25/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JFSelectionView.h"

@protocol DetectViewDelegate <NSObject>
- (void)selectedRect:(NSRect)frame withImage:(NSImage*)screen;
@end

@interface JFDetectView : NSView

@property (nonatomic) NSImage *copiedScreen;
@property (nonatomic) JFSelectionView *selectionView;
@property (nonatomic, weak) id<DetectViewDelegate> detectDelegate;

@end
