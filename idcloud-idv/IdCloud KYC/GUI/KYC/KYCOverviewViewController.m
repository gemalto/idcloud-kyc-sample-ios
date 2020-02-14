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

#import "KYCOverviewViewController.h"
#import "KYCCommunication.h"

@interface KYCOverviewViewController()

@property (weak, nonatomic) IBOutlet UIImageView    *imagePortrait;
@property (weak, nonatomic) IBOutlet UIImageView    *imagePortraitExtracted;
@property (weak, nonatomic) IBOutlet UIImageView    *imageDocumentFront;
@property (weak, nonatomic) IBOutlet UIImageView    *imageDocumentBack;
@property (weak, nonatomic) IBOutlet UIImageView    *imageStatus;
@property (weak, nonatomic) IBOutlet UILabel        *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel        *labelResultCaption;
@property (weak, nonatomic) IBOutlet UILabel        *labelResultValue;
@property (weak, nonatomic) IBOutlet IdCloudButton  *buttonNext;
@property (weak, nonatomic) IBOutlet UIStackView    *stackResults;

@property (assign, nonatomic) BOOL                  finished;
@end

@implementation KYCOverviewViewController

// MARK: - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    // Load current data.
    KYCManager *manager = [KYCManager sharedInstance];
    [self loadOrHideImage:manager.scannedPortrait view:_imagePortrait];
    [self loadOrHideImage:nil view:_imagePortraitExtracted];
    [self loadOrHideImage:manager.scannedDocFront view:_imageDocumentFront];
    [self loadOrHideImage:manager.scannedDocBack view:_imageDocumentBack];
    
    // Hide result area since we don't have any values yet.
    [self showOrHideResultArea:NO animated:NO];
    
    // This property switch button behaviour.
    _finished = NO;
}

// MARK: - MainViewController

- (void)enableGUI:(BOOL)enabled {
    [super enableGUI:enabled];
    
    [_buttonNext setEnabled:enabled];
}

// MARK: - Private Helpers

- (void)showOrHideResultArea:(BOOL)show animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? .5f : .0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.stackResults.hidden = !show;
        self.stackResults.alpha = show ? 1.f : .0f;
    } completion:nil];
}

- (void)loadOrHideImage:(NSData *)image view:(UIImageView *)view {
    [view setImage:[UIImage imageWithData:image]];
    [view setHidden:!image];
}

- (void)displayResult:(KYCResponse *)response {
    // Check if response was successfull.
    if (![response.document.result isEqualToString:@"SUCCESS"]) {
        [self displayError:response.getMessageReadable response:response];
        return;
    }
    
    // Build user information strings.
    NSMutableString *caption = [NSMutableString new];
    NSMutableString *value = [NSMutableString new];
                
    if (response.document.firstName && response.document.surname) {
        [caption appendFormat:@"%@\n", TRANSLATE(@"STRING_KYC_RESULT_NAME_SURNAME")];
        [value appendFormat:@"%@ %@\n", response.document.firstName, response.document.surname];
    }
    [self appendResultString:caption revValue:value
                     caption:TRANSLATE(@"STRING_KYC_RESULT_GENDER")
                       value:response.document.gender];
    [self appendResultString:caption revValue:value
                     caption:TRANSLATE(@"STRING_KYC_RESULT_NATIONALITY")
                       value:response.document.nationality];
    [self appendResultString:caption revValue:value
                     caption:TRANSLATE(@"STRING_KYC_RESULT_EXOIRY_DATE")
                       value:response.document.expiryDate];
    [self appendResultString:caption revValue:value
                     caption:TRANSLATE(@"STRING_KYC_RESULT_BIRTH_DATE")
                       value:response.document.birthDate];
    [self appendResultString:caption revValue:value
                     caption:TRANSLATE(@"STRING_KYC_RESULT_DOC_NUMBER")
                       value:response.document.documentNumber];
    [self appendResultString:caption revValue:value
                     caption:TRANSLATE(@"STRING_KYC_RESULT_DOC_TYPE")
                       value:response.document.documentType];
    [self appendResultInt:caption revValue:value
                  caption:TRANSLATE(@"STRING_KYC_RESULT_TOTAL_VERIFICATIONS")
                    value:response.document.totalVerifications];

    
    _labelResultCaption.text = caption;
    _labelResultValue.text = value;
    
    // Update status message.
    _labelStatus.text   = response.getMessageReadable;
    _imageStatus.image  = [UIImage imageNamed:@"KYC_Overview_Passed"];
    _imageStatus.tintColor  = [UIColor greenColor];

    // Update extracted portrait.
    [self loadOrHideImage:response.document.portrait view:self.imagePortraitExtracted];
    
    // Animate result part.
    [self showOrHideResultArea:YES animated:YES];
    
    // Update button function
    [_buttonNext setTitle:TRANSLATE(@"STRING_COMMON_DONE") forState:UIControlStateNormal];
    _finished = YES;
}

- (void)displayError:(NSString *) error response:(KYCResponse *)response {
    
    // Append detail information about failed check if available.
    NSMutableString *fullErr = [NSMutableString stringWithString:error];
    if (response && response.document.failedVerifications.count) {
        [fullErr appendString:@"\n"];
        for (KYCFailedVerification *loopVerify in response.document.failedVerifications) {
            [fullErr appendFormat:@"%@, ", loopVerify.name];
        }
        [fullErr deleteCharactersInRange:NSMakeRange([fullErr length] - 2, 2)];
    }
    
    _labelStatus.text       = fullErr;
    _imageStatus.image      = [UIImage imageNamed:@"KYC_Overview_Error"];
    _imageStatus.tintColor  = [UIColor redColor];
    

}

- (void)appendResultString:(NSMutableString *)retCaption
                  revValue:(NSMutableString *)retValue
                   caption:(NSString *)caption
                     value:(NSString *)value {
    if (value && ![value isEqualToString:@"null"]) {
        [retCaption appendFormat:@"%@ \n", caption];
        [retValue appendFormat:@"%@ \n", value];
    }
}

- (void)appendResultInt:(NSMutableString *)retCaption
               revValue:(NSMutableString *)retValue
                caption:(NSString *)caption
                  value:(NSInteger)value {
    [retCaption appendFormat:@"%@ \n", caption];
    [retValue appendFormat:@"%ld \n", (long)value];
}

// MARK: - User Interface

- (IBAction)onButtonPressed:(UIButton *)sender {
    if (_finished) {
        [self onButtonPressedDone];
    } else {
        [self onButtonPressedSubmit];
    }
}

- (void)onButtonPressedDone {
    // Mark document enrollment as finished and switch scene.
    [KYCManager sharedInstance].kycEnrolled = YES;
    [[KYCManager sharedInstance] updateRootViewController];
}

- (void)onButtonPressedSubmit {
    KYCManager *manager = [KYCManager sharedInstance];

    // Display loading status and block UI.
    [self loadingIndicatorShowWithCaption:TRANSLATE(@"STRING_LOADING_SUBMITTING")];
    
    // Send data to server and wait for response.
    __weak __typeof(self) weakSelf = self;
    [KYCCommunication verifyDocumentFront:manager.scannedDocFront
                             documentBack:manager.scannedDocBack
                                   selfie:manager.scannedPortrait
                        completionHandler:^(KYCResponse *response, NSString *error) {
        // UI is already gone.
        if (!weakSelf) {
            return;
        }
        
        // Hide loading indicator and unblock UI.
        [weakSelf loadingIndicatorHide];
        
        if (response) {
            [weakSelf displayResult:response];
        } else {
            // No response? Display error if we have one, otherwise some generict err message.
            if (!error) {
                [weakSelf displayError:@"Failed to get valid response from server." response:nil];
            } else {
                [weakSelf displayError:error.description response:nil];
            }
        }
    }];
}

@end
