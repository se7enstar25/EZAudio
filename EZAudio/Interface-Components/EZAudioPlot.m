//
//  EZAudioPlot.m
//  SHAAudioExampleOSX
//
//  Created by Syed Haris Ali on 9/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "EZAudioPlot.h"

#import "../EZAudio.h"

#define kCircularBufferSizeTemp 512

@interface EZAudioPlot () {
  BOOL             _hasData;
  TPCircularBuffer _historyBuffer;
  
  CGPoint *_sampleData;
  UInt32  _sampleLength;
}
@end

@implementation EZAudioPlot
@synthesize backgroundColor = _backgroundColor;
@synthesize color           = _color;
@synthesize gain            = _gain;
@synthesize plotType        = _plotType;
@synthesize shouldFill      = _shouldFill;
@synthesize shouldMirror    = _shouldMirror;

#pragma mark - Initialization
-(id)init {
  self = [super init];
  if(self){
    [self initPlot];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self){
    [self initPlot];
  }
  return self;
}

#if TARGET_OS_IPHONE
-(id)initWithFrame:(CGRect)frameRect {
#elif TARGET_OS_MAC
  -(id)initWithFrame:(NSRect)frameRect {
#endif
    self = [super initWithFrame:frameRect];
    if(self){
      [self initPlot];
    }
    return self;
  }
  
-(void)initPlot {
#if TARGET_OS_IPHONE
  self.backgroundColor = [UIColor blackColor];
  self.color           = [UIColor colorWithHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
#elif TARGET_OS_MAC
  self.backgroundColor = [NSColor blackColor];
  self.color           = [NSColor colorWithCalibratedHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
#endif
  self.gain            = 1.0;
  self.plotType        = EZPlotTypeRolling;
  self.shouldMirror    = NO;
  self.shouldFill      = NO;
}
  
#pragma mark - Setters
#if TARGET_OS_IPHONE
-(void)setBackgroundColor:(UIColor *)backgroundColor {
  _backgroundColor = backgroundColor;
  [self setNeedsDisplay];
}
#elif TARGET_OS_MAC
-(void)setBackgroundColor:(NSColor *)backgroundColor {
  _backgroundColor = backgroundColor;
  [self setNeedsDisplay:YES];
}
#endif
  
#if TARGET_OS_IPHONE
-(void)setColor:(UIColor *)color {
  _color = color;
  [self setNeedsDisplay];
}
#elif TARGET_OS_MAC
-(void)setColor:(NSColor *)color {
  _color = color;
  [self setNeedsDisplay:YES];
}
#endif
  
-(void)setGain:(float)gain {
  _gain = gain;
#if TARGET_OS_IPHONE
  [self setNeedsDisplay];
#elif TARGET_OS_MAC
  [self setNeedsDisplay:YES];
#endif
}

-(void)setPlotType:(EZPlotType)plotType {
  _plotType = plotType;
#if TARGET_OS_IPHONE
  [self setNeedsDisplay];
#elif TARGET_OS_MAC
  [self setNeedsDisplay:YES];
#endif
}

-(void)setShouldFill:(BOOL)shouldFill {
  _shouldFill = shouldFill;
#if TARGET_OS_IPHONE
  [self setNeedsDisplay];
#elif TARGET_OS_MAC
  [self setNeedsDisplay:YES];
#endif
}

-(void)setShouldMirror:(BOOL)shouldMirror {
  _shouldMirror = shouldMirror;
#if TARGET_OS_IPHONE
  [self setNeedsDisplay];
#elif TARGET_OS_MAC
  [self setNeedsDisplay:YES];
#endif
}
  
#pragma mark - Get Data
- (void)_setSampleData:(float *)the_sampleData
                length:(int)length {
  if( _sampleData != nil ){
    free(_sampleData);
  }
  
  _sampleData   = (CGPoint *)calloc(sizeof(CGPoint),length);
  _sampleLength = length;
  
  for(int i = 0; i < length; i++) {
    the_sampleData[i] = i == 0 || i == length - 1 ? 0 : the_sampleData[i];
    _sampleData[i]    = CGPointMake(i,the_sampleData[i] * _gain);
  }
    
#if TARGET_OS_IPHONE
  [self setNeedsDisplay];
#elif TARGET_OS_MAC
  [self setNeedsDisplay:YES];
#endif
}
  
#pragma mark - Update
-(void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize {
  if( _plotType == EZPlotTypeRolling ){
    
    // Initialize the circular buffer
    !_hasData ? TPCircularBufferInit(&_historyBuffer,kCircularBufferSizeTemp) : 0;
    _hasData = YES;
    
    // Initialize
    _sampleLength = bufferSize;
    
    // Copy into the circular buffer
    float rmsValue = [EZAudio RMS:buffer length:bufferSize];
    float snapshot[1];
    snapshot[0] = rmsValue;
    //  self.rmsLabel.text = [NSString stringWithFormat:@"RMS: %.4f",rmsValue];
    BOOL result = TPCircularBufferProduceBytes(&_historyBuffer,
                                               snapshot,
                                               sizeof(snapshot));
    if(result){
      // Populate the graph
      int32_t availableBytes;
      float *cBuf = TPCircularBufferTail(&_historyBuffer,&availableBytes);
      for(int i = 0; i < kCircularBufferSizeTemp; i++) {
        if( availableBytes == kCircularBufferSizeTemp*sizeof(float) ){
          cBuf[i] = 0.0f;
        }
      }
      [self _setSampleData:cBuf
                    length:kCircularBufferSizeTemp];
      if( availableBytes == kCircularBufferSizeTemp*sizeof(float) ){
        TPCircularBufferConsume(&_historyBuffer,kCircularBufferSizeTemp*sizeof(float));
      }
    }
    else {
      NSLog(@"Failed to copy bytes to circular buffer 1");
    }
    
  }
  else if( _plotType == EZPlotTypeBuffer ){
    
    [self _setSampleData:buffer
                  length:bufferSize];
    
  }
  else {
    
    // Unknown plot type
    
  }
}
  
#pragma mark - Drawing
  
#if TARGET_OS_IPHONE
- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGRect frame = self.bounds;
#elif TARGET_OS_MAC
  - (void)drawRect:(NSRect)dirtyRect
  {
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef ctx = (CGContextRef) [nsGraphicsContext graphicsPort];
    NSRect frame = self.bounds;
#endif
    
    // Set the background color
    [self.backgroundColor set];
    
#if TARGET_OS_IPHONE
    UIRectFill(frame);
#elif TARGET_OS_MAC
    NSRectFill(frame);
#endif
    
    // Set the line color
    [self.color set];
    
    if(_sampleLength > 0) {
      CGMutablePathRef halfPath = CGPathCreateMutable();
      CGPathAddLines(halfPath,
                     NULL,
                     _sampleData,
                     _sampleLength);
      
      CGMutablePathRef path = CGPathCreateMutable();
      
      double xscale = (frame.size.width) / (float)_sampleLength;
      double halfHeight = floor( frame.size.height / 2.0 );
      
      // iOS drawing origin is flipped by default so make sure we account for that
      int deviceOriginFlipped = 1;
#if TARGET_OS_IPHONE
      deviceOriginFlipped = -1;
#elif TARGET_OS_MAC
      deviceOriginFlipped = 1;
#endif
      
      CGAffineTransform xf = CGAffineTransformIdentity;
      xf = CGAffineTransformTranslate( xf, frame.origin.x , halfHeight + frame.origin.y );
      xf = CGAffineTransformScale( xf, xscale, deviceOriginFlipped*halfHeight );
      CGPathAddPath( path, &xf, halfPath );
      
      if( self.shouldMirror ){
        xf = CGAffineTransformIdentity;
        xf = CGAffineTransformTranslate( xf, frame.origin.x , halfHeight + frame.origin.y);
        xf = CGAffineTransformScale( xf, xscale, -deviceOriginFlipped*(halfHeight));
        CGPathAddPath( path, &xf, halfPath );
      }
      CGPathRelease( halfPath );
      
      // Now, path contains the full waveform path.
      CGContextAddPath(ctx, path);
      
      // Make this color customizable
      if( self.shouldFill ){
        CGContextFillPath(ctx);
      }
      else {
        CGContextStrokePath(ctx);
      }
      CGPathRelease(path);
    }
    
#if TARGET_OS_IPHONE
    CGContextRestoreGState(ctx);
#elif TARGET_OS_MAC
    [[NSGraphicsContext currentContext] restoreGraphicsState];
#endif
  }
    
-(void)dealloc {
  free(_sampleData);
}

@end
