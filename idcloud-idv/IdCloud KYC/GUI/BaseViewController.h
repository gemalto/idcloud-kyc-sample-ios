/*
 MIT License
 
 Copyright (c) 2020 Thales DIS
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
 rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
 Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 IMPORTANT: This source code is intended to serve training information purposes only.
 Please make sure to review our IdCloud documentation, including security guidelines.
 */

#import "IdCloudLoadingIndicator.h"
#import "IdCloudIncomingMessage.h"
#import "IdCloudNotification.h"

// Transition style for switching to overlay view controllers like transaction sign or settings.
static const UIModalTransitionStyle C_TRANSITION_STYLE = UIModalTransitionStyleCoverVertical;

@interface BaseViewController : IdCloudAutorotationVC

// MARK: - Loading Indicator

/**
 Display overlay loading indicatior.
 
 @param caption Message displayed inside indicator
 */
- (void)loadingIndicatorShowWithCaption:(NSString *)caption;

/**
 Hide loading indicator.
 */
- (void)loadingIndicatorHide;


// MARK: - Dialogs

- (void)displayOnCancelDialog:(NSString *)caption
                      message:(NSString *)message
                     okButton:(NSString *)okButton
                 cancelButton:(NSString *)cancelButton
            completionHandler:(void (^)(BOOL))handler;

// MARK: - Common Helpers

/**
 Reaload all GUI information as well as enable/disable elements.
 */
- (void)reloadGUI;

/**
 Enable or disable all user interaction elements.
 */
- (void)enableGUI:(BOOL)enabled;

/**
 Whenever is some overlay currently displayed.

 @return YES if loading indicator / incomming message or any other overlay is visible on screen.
 */
- (BOOL)overlayViewVisible;

@end
