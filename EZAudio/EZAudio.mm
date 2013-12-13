//
//  SHAAudio.m
//  SHAAudio
//
//  Created by Syed Haris Ali on 11/21/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "EZAudio.h"

@implementation EZAudio

#pragma mark - Utility
void CheckResult(OSStatus result, const char *operation)
{
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}

+(void)checkResult:(OSStatus)result
         operation:(const char *)operation {
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}

+(float)MAP:(float)value
    leftMin:(float)leftMin
    leftMax:(float)leftMax
   rightMin:(float)rightMin
   rightMax:(float)rightMax {
  float leftSpan    = leftMax  - leftMin;
  float rightSpan   = rightMax - rightMin;
  float valueScaled = ( value  - leftMin ) / leftSpan;
  return rightMin + (valueScaled * rightSpan);
}

+(void)printASBD:(AudioStreamBasicDescription)asbd {
  char formatIDString[5];
  UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
  bcopy (&formatID, formatIDString, 4);
  formatIDString[4] = '\0';
  NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
  NSLog (@"  Format ID:           %10s",    formatIDString);
  NSLog (@"  Format Flags:        %10X",    (unsigned int)asbd.mFormatFlags);
  NSLog (@"  Bytes per Packet:    %10d",    (unsigned int)asbd.mBytesPerPacket);
  NSLog (@"  Frames per Packet:   %10d",    (unsigned int)asbd.mFramesPerPacket);
  NSLog (@"  Bytes per Frame:     %10d",    (unsigned int)asbd.mBytesPerFrame);
  NSLog (@"  Channels per Frame:  %10d",    (unsigned int)asbd.mChannelsPerFrame);
  NSLog (@"  Bits per Channel:    %10d",    (unsigned int)asbd.mBitsPerChannel);
}

+(float)RMS:(float *)buffer
     length:(int)bufferSize {
  float sum = 0.0;
  for(int i = 0; i < bufferSize; i++)
    sum += buffer[i] * buffer[i];
  return sqrtf( sum / bufferSize );
}

+(void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd
                              numberOfChannels:(UInt32)nChannels
                                   interleaved:(BOOL)interleaved {
  asbd.mFormatID = kAudioFormatLinearPCM;
  int sampleSize = ((UInt32)sizeof(AudioSampleType));
  asbd.mFormatFlags = kAudioFormatFlagsCanonical;
  asbd.mBitsPerChannel = 8 * sampleSize;
  asbd.mChannelsPerFrame = nChannels;
  asbd.mFramesPerPacket = 1;
  if (interleaved)
    asbd.mBytesPerPacket = asbd.mBytesPerFrame = nChannels * sampleSize;
  else {
    asbd.mBytesPerPacket = asbd.mBytesPerFrame = sampleSize;
    asbd.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
  }
}

@end