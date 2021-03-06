//
//  RecognitionManager.h
//  CocoaApp
//
//  Created by Angus W Hardie on 07/07/2007.
//  Copyright 2007 MalcolmHardie Solutions Ltd. All rights reserved.
//

//Licensed under the Apache License, Version 2.0 (the "License"); 
//you may not use this file except in compliance with the License. 
//You may obtain a copy of the License at 
//
//http://www.apache.org/licenses/LICENSE-2.0 
//
//Unless required by applicable law or agreed to in writing, software 
//distributed under the License is distributed on an "AS IS" BASIS, 
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
//See the License for the specific language governing permissions and limitations under the License. 


#import <Cocoa/Cocoa.h>

#import <Tesseract/baseapi.h>

using namespace tesseract;

@interface RecognitionManager : NSObject {
	IBOutlet id imageView;
	IBOutlet id textView;
	IBOutlet id recognitionWindow;
	
	TessBaseAPI* tess;
	
	IBOutlet id progressView;
	
	id recognitionLock;
}

- (void)deallocRM;
- (IBAction)imageChanged:(id)sender;
- (NSString*)recognizeImage:(NSImage*)uiImage;
- (void)recognize;
@end
