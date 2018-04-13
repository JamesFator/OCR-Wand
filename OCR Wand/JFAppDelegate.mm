//
//  JFAppDelegate.m
//  OCR Wand
//
//  Created by James Fator on 11/17/13.
//  Copyright (c) 2013 JamesFator. All rights reserved.
//

#import "JFAppDelegate.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"

NSString *const JFHasRunBefore = @"JFHasRun";
NSString *const JFPreferenceKeyShortcut = @"JFShortcut";
NSString *const JFPreferenceKeyShortcutEnabled = @"JFShortcutEnabled";
NSString *const JFPreferenceKeySoundEnabled = @"JFSoundEnabled";
NSString *const JFHelperPath = @"Contents/Library/LoginItems/OCR Wand Helper.app";

@implementation JFAppDelegate

/**
 * applicationDidFinishLaunching is called when the application launches
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Launch the login controller
    loginController = [[StartAtLoginController alloc] init];
    [loginController setBundle:[NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:JFHelperPath]]];
    
    defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasRun = [defaults boolForKey:JFHasRunBefore];
    if ( !hasRun ) {
        // If this is the first time launching, configure the defaults
        // Shift + Alt + Command + C is the default key
        MASShortcut *defaultShortcut = [MASShortcut shortcutWithKeyCode:0x8
                                                          modifierFlags:NSCommandKeyMask|NSShiftKeyMask|NSAlternateKeyMask];
        [MASShortcut setGlobalShortcut:defaultShortcut forUserDefaultsKey:JFPreferenceKeyShortcut];
        
        // Set the default preferences
        [defaults setBool:YES forKey:JFPreferenceKeyShortcutEnabled];
        [defaults setBool:NO forKey:JFPreferenceKeySoundEnabled];
        [defaults synchronize];
        
        // Add this app as a login item
        if ( ![loginController startAtLogin] )
            [loginController setStartAtLogin: YES];
        
        // Set the key so we don't run again
        [defaults setBool:YES forKey:JFHasRunBefore];
    }
    
    // Configure the saved preferences
    [self loadPreferences];
    
    // Set the notification center delegate
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // Shortcut view will follow and modify user preferences automatically
    self.shortcutView.associatedUserDefaultsKey = JFPreferenceKeyShortcut;
    
    // Register the shortcut
    [self resetShortcutRegistration];
    
    // Load tesseract
    _tesseract = [[RecognitionManager alloc] init];
    
    // Set up the status bar item
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusImage = [NSImage imageNamed:@"OCRWandStatusIcon"];
    [statusImage setTemplate:YES];
    statusImageAlert = [NSImage imageNamed:@"OCRWandStatusIconAlert"];
    [statusImageAlert setTemplate:YES];
    [_statusItem setImage:statusImage];
    
    // Flash a launch message
    [_statusItem setTitle:@"OCR Wand ."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2.0];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Remove the launch message
            [_statusItem setTitle:@""];
        });
    });
    
    [_statusItem setMenu:_statusMenu];
    [_statusMenu setDelegate:self];
    [_statusItem setToolTip:@"OCR Wand Running"];
    [_statusItem setHighlightMode:YES];
    _newReading = NO;
}

#pragma mark - Preferences

/**
 * showAbout will load the about window and bring it to the front.
 */
- (IBAction)showAbout:(id)sender
{
    // Bring the about window to the front
    [_aboutWindow orderFrontRegardless];
    [_aboutWindow makeKeyWindow];
    
    if ( !aboutIcon )
        aboutIcon = [NSImage imageNamed:@"OCRWandDisplay"];
    [_iconView setImage:aboutIcon];
}

/**
 * loadPreferences will grab the preferences from the user defaults
 */
- (void)loadPreferences
{
    _shortcutEnabled = [defaults boolForKey:JFPreferenceKeyShortcutEnabled];
    _startupEnabled = [loginController startAtLogin];
    _soundEffectEnabled = [defaults boolForKey:JFPreferenceKeySoundEnabled];
    
    [defaults setBool:_shortcutEnabled forKey:JFPreferenceKeyShortcutEnabled];
    [defaults setBool:_soundEffectEnabled forKey:JFPreferenceKeySoundEnabled];
    [defaults synchronize];
}

/**
 * showPreferences will load the preferences window and bring it to the front.
 */
- (IBAction)showPreferences:(id)sender
{
    // Bring the preferences window to the front
    [_prefWindow orderFrontRegardless];
    [_prefWindow makeKeyWindow];
    
    // Set the checkbox states
    [_enabledCB setState:[[NSNumber numberWithBool:_shortcutEnabled] integerValue]];
    [_startupCB setState:[[NSNumber numberWithBool:_startupEnabled] integerValue]];
    [_soundEffectCB setState:[[NSNumber numberWithBool:_soundEffectEnabled] integerValue]];
}

/**
 * toggleEnabledCB will change the enabled check box
 */
- (IBAction)toggleEnabledCB:(id)sender
{
    // Toggle and save preferences
    _shortcutEnabled = !_shortcutEnabled;
    [defaults setBool:_shortcutEnabled forKey:JFPreferenceKeyShortcutEnabled];
    [defaults synchronize];
    [self resetShortcutRegistration];
}

/**
 * toggleStartupCB will change the startup check box
 */
- (IBAction)toggleStartupCB:(id)sender
{
    // Toggle and save preferences
    _startupEnabled = [_startupCB state];
    
    if ( _startupEnabled ) {
        if ( ![loginController startAtLogin] )
            [loginController setStartAtLogin: YES];
        if (![loginController startAtLogin])
            NSLog(@"Register error");
    } else {
        if ( [loginController startAtLogin] )
            [loginController setStartAtLogin:NO];
        if ([loginController startAtLogin])
            NSLog(@"Error");
    }
}

/**
 * toggleSoundEffectCB will change the sound effect check box
 */
- (IBAction)toggleSoundEffectCB:(id)sender
{
    // Toggle and save preferences
    _soundEffectEnabled = !_soundEffectEnabled;
    [defaults setBool:_soundEffectEnabled forKey:JFPreferenceKeySoundEnabled];
    [defaults synchronize];
}

#pragma mark - Shortcut

/**
 * resetShortcutRegistration is called to register the shortcut key
 *   and manage the processing after the key is pressed.
 */
- (void)resetShortcutRegistration
{
    if ( _shortcutEnabled ) {
        // Register the shortcut
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:JFPreferenceKeyShortcut handler:^{
            // Set the detect view as the full screen
            _detectView = [[JFDetectView alloc] initWithFrame:[[NSScreen mainScreen] frame]];
            [_detectView setDetectDelegate:self];
            
            // Add the view to the window
            NSRect rect = [NSWindow contentRectForFrameRect:[[NSScreen mainScreen] frame]
                                                  styleMask:NSBorderlessWindowMask];
            
            // ###########################
            NSDictionary* screenDictionary = [[NSScreen mainScreen] deviceDescription];
            NSNumber* screenID = [screenDictionary objectForKey:@"NSScreenNumber"];
            CGDirectDisplayID aID = [screenID unsignedIntValue];
            NSRect frame = [[NSScreen mainScreen] frame];
            CGImageRef grabbedRef = CGDisplayCreateImageForRect(aID, NSRectToCGRect(frame));
            __block NSImage *image = [[NSImage alloc] initWithCGImage:grabbedRef size:frame.size];
            [image lockFocus];
            [image unlockFocus];
            if (grabbedRef)
                CGImageRelease(grabbedRef);
            // ###########################
            
            _detectWindow = [[JFDetectWindow alloc] initWithContentRect:rect
                                                              styleMask:NSBorderlessWindowMask
                                                                backing:NSBackingStoreBuffered
                                                                  defer:false];
            [_detectWindow setOpaque:NO];
            [_detectWindow setBackgroundColor:[[NSColor grayColor] colorWithAlphaComponent:0.0]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Set the detect view as the main view
                [_detectView setCopiedScreen:image];
                [_detectWindow setContentView:_detectView];
                // Make the window the key and order it to the front
                [_detectWindow orderFrontRegardless];
                [_detectWindow makeKeyWindow];
                // Bring the application to the front
                [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            });
        }];
    } else {
        // Unregister the shortcut
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:JFPreferenceKeyShortcut];
    }
}

#pragma mark - DetectView delegate

/**
 * selectedRect is called when the detect view has grabbed a boundry.
 * @param frame - the bound to process
 * @param screen - the image that was initially copied
 */
- (void)selectedRect:(NSRect)frame withImage:(NSImage*)screen
{
    [self endSelecting];
    if ( frame.size.width != 0 && frame.size.height != 0 ) {
        // Valid frame
        
        // Increase size by 400%
        NSSize newSize;
        newSize.height = frame.size.height * 4.0;
        newSize.width = frame.size.width * 4.0;
        
        NSRect newRect;
        newRect.origin = NSMakePoint(0, 0);
        newRect.size = newSize;
        
        // Convert the image
        NSImage *image = [[NSImage alloc] initWithSize:newSize];
        [image lockFocus];
        [screen drawInRect:newRect fromRect:frame operation:NSCompositeCopy fraction:1.0];
        [image unlockFocus];
        
        // End selection view
        [self endSelecting];
        
        // Read the image
        NSString *read = [[_tesseract recognizeImage:image]
                          stringByTrimmingCharactersInSet:[NSCharacterSet
                                                           whitespaceAndNewlineCharacterSet]];
        NSLog(@"String read: %@", read);
        
        // Remove spaces and new lines and test for any data
        NSString *testString = [read stringByReplacingOccurrencesOfString:@" "
                                                               withString:@""];
        testString = [testString stringByReplacingOccurrencesOfString:@"\n"
                                                           withString:@""];
        
        if ( [testString length] > 0 ) {
            // Put the contents in the clipboard
            [[NSPasteboard generalPasteboard] clearContents];
            [[NSPasteboard generalPasteboard] setString:read forType:NSStringPboardType];
            
            // Open a notification
            [self showNotificationAlert:read];
        } else {
            // Failed read, alert the user
            [self showNotificationAlert:@"Recognition failed!"];
        }
    }
}

/**
 * endSelecting closes out of the detect window && views.
 */
- (void)endSelecting
{
    // Remove the detect view
    [_detectView removeFromSuperview];
    [_detectView setCopiedScreen:nil];
    _detectView = nil;
    // Remove the detect window
    [_detectWindow orderOut:self];
    _detectWindow = nil;
}

#pragma mark - Notification

/**
 * showNotificationAlert will display the copied text to the user.
 * @param textRead - string recognized by tesseract
 */
- (void)showNotificationAlert:(NSString*)textRead
{
    // Play a sound if enabled
    if ( _soundEffectEnabled ) {
        if ( [textRead isEqualToString:@"Recognition failed!"] ) {
            // If bad read, two beeps
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSBeep();
                [NSThread sleepForTimeInterval:0.2];
                NSBeep();
            });
        } else {
            NSBeep();
        }
    }
    if ( !_newReading ) {
        [_statusItem setImage:statusImageAlert];
        _newReading = YES;
        if ( !_copiedView ) {
            NSMenuItem *copiedMenu = [[NSMenuItem alloc] init];
            _copiedView = [[JFPopoverController alloc] init];
            [copiedMenu setView:_copiedView.view];
            [_statusMenu insertItem:copiedMenu atIndex:0];
            [_statusMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
        }
    }
    // Set the new text
    copiedText = textRead;
    [_copiedView setText:copiedText];
}

/**
 * menuWillOpen is called when the status icon is selected.
 * We will use this to set the icon back to the standard.
 */
- (void)menuWillOpen:(NSMenu *)menu
{
    if ( _newReading ) {
        [_statusItem setImage:statusImage];
        _newReading = NO;
    }
    
    // Bring the application to the front
    NSApplication *thisApp = [NSApplication sharedApplication];
    if ( ![thisApp isActive] ) {
        [thisApp activateIgnoringOtherApps:YES];
        // Close the window and reopen until active
        [_statusMenu cancelTracking];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:0.1];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Highlight the StatusItem manually
//                [[_statusItem button] highlight:YES];
                // Make the window the key and order it to the front
                [_statusItem popUpStatusItemMenu:_statusMenu];
            });
        });
    }
    // Otherwise, allow the menu to open
}

/**
 * menuDidClose is called when the status menu is closed.
 * We will use this to edit the clipboard.
 */
- (void)menuDidClose:(NSMenu *)menu
{
    // If editing did occur
    NSString *textValue = [_copiedView getText];
    if ( ![textValue isEqualToString:copiedText] ) {
        // Save the new string to the clipboard
        copiedText = textValue;
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:copiedText forType:NSStringPboardType];
    }
    
    // Disable any manual highlighting
//    [[_statusItem button] highlight:NO];
}

@end
