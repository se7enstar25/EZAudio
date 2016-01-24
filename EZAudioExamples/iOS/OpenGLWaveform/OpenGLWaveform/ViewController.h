//
//  ViewController.h
//  OpenGLWaveform
//
//  Created by Syed Haris Ali on 1/23/16.
//  Copyright © 2016 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// First import the EZAudio header
//
#include <EZAudio/EZAudio.h>

//------------------------------------------------------------------------------
#pragma mark - ViewController
//------------------------------------------------------------------------------

@interface ViewController : UIViewController <EZMicrophoneDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

//
// The CoreGraphics based audio plot
//
@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;

//
// The microphone component
//
@property (nonatomic, strong) EZMicrophone *microphone;

//
// The button at the bottom displaying the currently selected microphone input
//
@property (nonatomic, weak) IBOutlet UIButton *microphoneInputToggleButton;

//
// The microphone input picker view to display the different microphone input sources
//
@property (nonatomic, weak) IBOutlet UIPickerView *microphoneInputPickerView;

//
// The microphone input picker view's top layout constraint (we use this to hide the control)
//
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *microphoneInputPickerViewTopConstraint;

//
// The text label displaying "Microphone On" or "Microphone Off"
//
@property (nonatomic, weak) IBOutlet UILabel *microphoneTextLabel;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

//
// Switches the plot drawing type between a buffer plot (visualizes the current
// stream of audio data from the update function) or a rolling plot (visualizes
// the audio data over time, this is the classic waveform look)
//
- (IBAction)changePlotType:(id)sender;

//
// Toggles the microphone inputs picker view in and out of display.
//
- (IBAction)toggleMicrophonePickerView:(id)sender;

//
// Toggles the microphone on and off. When the microphone is on it will send its
// delegate (aka this view controller) the audio data in various ways (check out
// the EZMicrophoneDelegate documentation for more details);
//
- (IBAction)toggleMicrophone:(id)sender;

@end

