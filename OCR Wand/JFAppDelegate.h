//
//  JFAppDelegate.h
//  OCR Wand
//
//  Created by James Fator on 11/17/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>
#import <Foundation/Foundation.h>

#import "JFDetectWindow.h"
#import "JFDetectView.h"
#import "RecognitionManager.h"
#import "NSImage+Grayscale.h"
#import "JFPopoverController.h"
#import "StartAtLoginController.h"

@class MASShortcutView;

@interface JFAppDelegate : NSObject <NSApplicationDelegate, DetectViewDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate>
{
    __weak id _constantShortcutMonitor;
    __weak id clickMonitor;
    __weak id releaseMonitor;
    NSUserDefaults *defaults;
    NSImage *aboutIcon;
    NSString *copiedText;
    
    // Status bar
    NSImage *statusImage;
    NSImage *statusImageAlert;
    
    // Startup
    StartAtLoginController *loginController;
}

// About
@property (unsafe_unretained) IBOutlet NSWindow *aboutWindow;
@property (weak) IBOutlet NSImageView *iconView;
- (IBAction)showAbout:(id)sender;

// Preferences
@property (unsafe_unretained) IBOutlet NSWindow *prefWindow;
@property (nonatomic) BOOL startupEnabled;
@property (nonatomic) BOOL soundEffectEnabled;
@property (nonatomic, weak) IBOutlet NSButton *enabledCB;
@property (nonatomic, weak) IBOutlet NSButton *startupCB;
@property (nonatomic, weak) IBOutlet NSButton *soundEffectCB;
- (IBAction)showPreferences:(id)sender;
- (IBAction)toggleStartupCB:(id)sender;
- (IBAction)toggleEnabledCB:(id)sender;
- (IBAction)toggleSoundEffectCB:(id)sender;

// Status menu
@property (nonatomic, assign, getter = newReading) BOOL newReading;
@property (nonatomic) IBOutlet NSMenu *statusMenu;
@property (nonatomic) IBOutlet NSPopover *popover;
@property (nonatomic, strong) JFPopoverController *copiedView;
@property (nonatomic, strong) NSStatusItem *statusItem;

// OCR
@property (nonatomic) JFDetectView *detectView;
@property (nonatomic) JFDetectWindow *detectWindow;
@property (nonatomic) RecognitionManager *tesseract;

// Shortcut
@property (nonatomic) BOOL shortcutEnabled;
@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;

@end
