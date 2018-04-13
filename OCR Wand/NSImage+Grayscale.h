//
//  NSImage+Grayscale.h
//  OCR Wand
//
//  Created by James Fator on 11/26/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface NSImage (Grayscale)
- (NSImage *)grayscaleImageWithAlphaValue:(CGFloat)alphaValue
                          saturationValue:(CGFloat)saturationValue
                          brightnessValue:(CGFloat)brightnessValue
                            contrastValue:(CGFloat)contrastValue;
@end

@implementation NSImage (Grayscale)
- (NSImage *)grayscaleImageWithAlphaValue:(CGFloat)alphaValue
                          saturationValue:(CGFloat)saturationValue
                          brightnessValue:(CGFloat)brightnessValue
                            contrastValue:(CGFloat)contrastValue
{
    NSSize size = [self size];
    NSRect bounds = { NSZeroPoint, size };
    NSImage *tintedImage = [[NSImage alloc] initWithSize:size];
    
    [tintedImage lockFocus];
    
    CIFilter *monochromeFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [monochromeFilter setDefaults];
    [monochromeFilter setValue:[CIImage imageWithData:[self TIFFRepresentation]] forKey:@"inputImage"];
    [monochromeFilter setValue:[CIColor colorWithRed:0 green:0 blue:0 alpha:1] forKey:@"inputColor"];
    [monochromeFilter setValue:[NSNumber numberWithFloat:1] forKey:@"inputIntensity"];
    
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIColorControls"];
    [colorFilter setDefaults];
    [colorFilter setValue:[monochromeFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
    [colorFilter setValue:[NSNumber numberWithFloat:saturationValue]  forKey:@"inputSaturation"];
    [colorFilter setValue:[NSNumber numberWithFloat:brightnessValue] forKey:@"inputBrightness"];
    [colorFilter setValue:[NSNumber numberWithFloat:contrastValue] forKey:@"inputContrast"];
    
    [[colorFilter valueForKey:@"outputImage"] drawAtPoint:NSZeroPoint
                                                 fromRect:bounds
                                                operation:NSCompositeCopy
                                                 fraction:alphaValue];
    
    [tintedImage unlockFocus];
    
    return tintedImage;
}


@end