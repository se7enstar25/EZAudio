//
//  EZOutput.h
//  EZAudio
//
//  Created by Syed Haris Ali on 12/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
#import <AudioUnit/AudioUnit.h>
#endif
@class EZOutput;

/**
 The EZOutputDataSource (required for the EZOutput) specifies a receiver to provide audio data when the EZOutput is started.
 */
@protocol EZOutputDataSource <NSObject>

@required
///-----------------------------------------------------------
/// @name Pulling The Audio Data
///-----------------------------------------------------------

/**
 Called anytime the EZOutput needs audio data to play. This function expects you to allocate a chunk of memory for an AudioBufferList (see EZAudio function `audioBufferList`) and will try to free it on a seperate thread (see EZAudio function `freeBufferList:`) when it is done to prevent leaking since this is expected to be the end of the road for the audio signal. If the EZOutputDataSource receives a nil or NULL AudioBufferList then the EZOutput component will output silence.
 @param output     The instance of the EZOutput that asked for the data.
 @param frames     The amount of frames as a UInt32 that output will need to properly fill its output buffer.
 @param bufferSize The pointer to the bufferSize the dataSource is expected to set. For instance, if the bufferSize ended up being 512 you'd say *bufferSize = 512.
 @return A pointer to the AudioBufferList structure holding the audio data. If nil or NULL, will output silence.
 */
-(AudioBufferList*)  output:(EZOutput*)output
  needsBufferListWithFrames:(UInt32)frames
             withBufferSize:(UInt32*)bufferSize;

@end

/**
 The EZOutput component provides a generic output to glue all the other EZAudio components together and push whatever sound you've created to the default output device (think opposite of the microphone). The EZOutputDataSource provides the required AudioBufferList needed to populate the output buffer.
 */
@interface EZOutput : NSObject

#pragma mark - Properties
/**
 The EZOutputDataSource that provides the required AudioBufferList to the output callback function
 */
@property (nonatomic,assign) id<EZOutputDataSource>outputDataSource;

#pragma mark - Initializers
///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Creates a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @return A newly created instance of the EZOutput class.
 */
-(id)initWithDataSource:(id<EZOutputDataSource>)dataSource;

#pragma mark - Class Initializers
///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class method to create a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @return A newly created instance of the EZOutput class.
 */
+(EZOutput*)outputWithDataSource:(id<EZOutputDataSource>)dataSource;

#pragma mark - Singleton
///-----------------------------------------------------------
/// @name Shared Instance
///-----------------------------------------------------------

/**
 Creates a shared instance of the EZOutput (one app will usually only need one output and share the role of the EZOutputDataSource).
 @return The shared instance of the EZOutput class.
 */
+(EZOutput*)sharedOutput;

#pragma mark - Events
///-----------------------------------------------------------
/// @name Starting/Stopping The Output
///-----------------------------------------------------------

/**
 Starts pulling audio data from the EZOutputDataSource to the default device output.
 */
-(void)startPlayback;

/**
 Stops pulling audio data from the EZOutputDataSource to the default device output.
 */
-(void)stopPlayback;

#pragma mark - Getters
///-----------------------------------------------------------
/// @name Getting The State Of The Output
///-----------------------------------------------------------

/**
 Provides a flag indicating whether the EZOutput is pulling audio data from the EZOutputDataSource for playback.
 @return YES if the EZOutput is pulling audio data to the output device, NO if it is stopped
 */
-(BOOL)isPlaying;

@end
