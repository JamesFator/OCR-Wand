//
//  main.m
//  OCR Wand Helper
//
//  Created by James Fator on 12/21/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[])
{
    NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    NSString *binaryPath = [[NSBundle bundleWithPath:appPath] executablePath];
    [[NSWorkspace sharedWorkspace] launchApplication:binaryPath];
}
