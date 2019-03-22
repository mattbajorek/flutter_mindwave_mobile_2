#import "FlutterMindWaveMobile2Plugin.h"
#import <AlgoSdk/NskAlgoSdk.h>
#import "MWMDevice.h"

@interface FlutterMindWaveMobile2Plugin ()
@property(nonatomic, retain) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, retain) FlutterMethodChannel* connectionChannel;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* attentionChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* bandPowerChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* eyeBlinkChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* meditationChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* signalQualityChannelStreamHandler;
@property(nonatomic) BOOL bleFlag;
@property(nonatomic) BOOL hasLicenseKey;
@property(nonatomic, retain) NskAlgoSdk* nskAlgoSdk;
@property(nonatomic, retain) MWMDelegateHandler* mwmDelegateHandler;
@property(nonatomic, retain) MWMDevice *mwmDevice;
@end

@implementation FlutterMindWaveMobile2Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
  FlutterMethodChannel* connectionChannel = [FlutterMethodChannel
                                             methodChannelWithName:NAMESPACE @"/connection"
                                             binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2Plugin* instance = [[FlutterMindWaveMobile2Plugin alloc] init];
  instance.connectionChannel = connectionChannel;
    
  // Set up attention channel
  FlutterEventChannel* attentionChannel = [FlutterEventChannel
                                           eventChannelWithName:NAMESPACE @"/attention"
                                           binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* attentionChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.attentionChannelStreamHandler = attentionChannelStreamHandler;
  [attentionChannel setStreamHandler:attentionChannelStreamHandler];
    
  // Set up bandPower channel
  FlutterEventChannel* bandPowerChannel = [FlutterEventChannel
                                           eventChannelWithName:NAMESPACE @"/bandPower"
                                           binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* bandPowerChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.bandPowerChannelStreamHandler = bandPowerChannelStreamHandler;
  [bandPowerChannel setStreamHandler:bandPowerChannelStreamHandler];
    
  // Set up eyeBlink channel
  FlutterEventChannel* eyeBlinkChannel = [FlutterEventChannel
                                          eventChannelWithName:NAMESPACE @"/eyeBlink"
                                          binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* eyeBlinkChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.eyeBlinkChannelStreamHandler = eyeBlinkChannelStreamHandler;
  [eyeBlinkChannel setStreamHandler:eyeBlinkChannelStreamHandler];
  
  // Set up meditation channel
  FlutterEventChannel* meditationChannel = [FlutterEventChannel
                                            eventChannelWithName:NAMESPACE @"/meditation"
                                            binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* meditationChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.meditationChannelStreamHandler = meditationChannelStreamHandler;
  [meditationChannel setStreamHandler:meditationChannelStreamHandler];
  
  // Set up signalQuality channel
  FlutterEventChannel* signalQualityChannel = [FlutterEventChannel
                                               eventChannelWithName:NAMESPACE @"/signalQuality"
                                               binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* signalQualityChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.signalQualityChannelStreamHandler = signalQualityChannelStreamHandler;
  [signalQualityChannel setStreamHandler:signalQualityChannelStreamHandler];
  
  // Set up Algo SDK
  NskAlgoSdk* nskAlgoSdk = [NskAlgoSdk sharedInstance];
  instance.nskAlgoSdk = nskAlgoSdk;
  NskAlgoSdkDelegateHandler* nskAlgoSdkDelegateHandler = [[NskAlgoSdkDelegateHandler alloc]
                                                          initWithVariables: connectionChannel
                                                          attentionChannelStreamHandler: attentionChannelStreamHandler
                                                          bandPowerChannelStreamHandler: bandPowerChannelStreamHandler
                                                          eyeBlinkChannelStreamHandler: eyeBlinkChannelStreamHandler
                                                          meditationChannelStreamHandler: meditationChannelStreamHandler
                                                          signalQualityChannelStreamHandler: signalQualityChannelStreamHandler];
  [nskAlgoSdk setDelegate:nskAlgoSdkDelegateHandler];
    
  // Set up MWMdevice
  MWMDevice* mwmDevice = [MWMDevice sharedInstance];
  MWMDelegateHandler* mwmDelegateHandler = [[MWMDelegateHandler alloc]
                                            initWithVariables: connectionChannel
                                            bleFlag: instance.bleFlag
                                            hasLicenseKey: instance.hasLicenseKey
                                            nskAlgoSdk: nskAlgoSdk
                                            attentionChannelStreamHandler: attentionChannelStreamHandler
                                            eyeBlinkChannelStreamHandler: eyeBlinkChannelStreamHandler
                                            meditationChannelStreamHandler: meditationChannelStreamHandler
                                            signalQualityChannelStreamHandler: signalQualityChannelStreamHandler];
  instance.mwmDelegateHandler = mwmDelegateHandler;
  [mwmDevice setDelegate:mwmDelegateHandler];
  instance.mwmDevice = mwmDevice;
    
  [registrar addMethodCallDelegate:instance channel:connectionChannel];
}

// Handle flutter method calls
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  @try {
    if ([@"connect" isEqualToString:call.method]) {
      NSDictionary* dict = [call arguments];
      NSString* deviceId = [dict objectForKey:@"deviceId"];
      if ([deviceId containsString:@":"]) {
        _bleFlag = NO;
      }
      else{
        _bleFlag = YES;
      }
      // If license key then set algo
      NSString* licenseKey = [dict objectForKey:@"licenseKey"];
      if (![licenseKey isEqual:[NSNull null]]) {
        _hasLicenseKey = YES;
        const char* licenseKeyChars = [licenseKey UTF8String];
        [_nskAlgoSdk setAlgorithmTypes: NskAlgoDataTypeAtt|NskAlgoEegTypeMed|NskAlgoEegTypeBP|NskAlgoEegTypeBlink licenseKey: (char*)licenseKeyChars];
        [_nskAlgoSdk startProcess];
      }
      [_mwmDevice connectDevice:deviceId];
      result(nil);
    } else if ([@"disconnect" isEqualToString:call.method]) {
      [_mwmDevice disconnectDevice];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  } @catch(NSException *exception) {
    result([FlutterError errorWithCode:exception.name
                               message:exception.reason
                               details:exception.description]);
  }
}

@end

@implementation FlutterMindWaveMobile2StreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  self.sink = eventSink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  self.sink = nil;
  return nil;
}

@end

@interface NskAlgoSdkDelegateHandler ()
@property(nonatomic, retain) FlutterMethodChannel* _connectionChannel;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _attentionChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _bandPowerChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _eyeBlinkChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _meditationChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _signalQualityChannelStreamHandler;
@end

@implementation NskAlgoSdkDelegateHandler

-(id)initWithVariables: (FlutterMethodChannel*) connectionChannel
                        attentionChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) attentionChannelStreamHandler
                        bandPowerChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) bandPowerChannelStreamHandler
                        eyeBlinkChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eyeBlinkChannelStreamHandler
                        meditationChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) meditationChannelStreamHandler
                        signalQualityChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) signalQualityChannelStreamHandler {
  self = [super init];
  if (self) {
    self._connectionChannel = connectionChannel;
    self._attentionChannelStreamHandler = attentionChannelStreamHandler;
    self._bandPowerChannelStreamHandler = bandPowerChannelStreamHandler;
    self._eyeBlinkChannelStreamHandler = eyeBlinkChannelStreamHandler;
    self._meditationChannelStreamHandler = meditationChannelStreamHandler;
    self._signalQualityChannelStreamHandler = signalQualityChannelStreamHandler;
  }
  return self;
}

- (void)stateChanged:(NskAlgoState)state reason:(NskAlgoReason)reason {
  NSMutableString* stateStr = [[NSMutableString alloc] init];
  [stateStr setString:@""];
  [stateStr appendString:@"SDK State: "];
  switch (state) {
    case NskAlgoStateCollectingBaselineData:
      [stateStr appendString:@"Collecting baseline"];
      break;
    case NskAlgoStateAnalysingBulkData:
      [stateStr appendString:@"Analysing Bulk Data"];
      break;
    case NskAlgoStateInited:
      [stateStr appendString:@"Inited"];
      break;
    case NskAlgoStatePause:
      [stateStr appendString:@"Pause"];
      break;
    case NskAlgoStateRunning:
      [stateStr appendString:@"Running"];
      break;
    case NskAlgoStateStop:
      [stateStr appendString:@"Stop"];
      break;
    case NskAlgoStateUninited:
      [stateStr appendString:@"Uninit"];
      break;
  }
  switch (reason) {
    case NskAlgoReasonBaselineExpired:
      [stateStr appendString:@" | Baseline expired"];
      break;
    case NskAlgoReasonConfigChanged:
      [stateStr appendString:@" | Config changed"];
      break;
    case NskAlgoReasonNoBaseline:
      [stateStr appendString:@" | No Baseline"];
      break;
    case NskAlgoReasonSignalQuality:
      [stateStr appendString:@" | Signal quality"];
      break;
    case NskAlgoReasonUserProfileChanged:
      [stateStr appendString:@" | User profile changed"];
      break;
    case NskAlgoReasonUserTrigger:
      [stateStr appendString:@" | By user"];
      break;
    case NskAlgoReasonExpired:
      [stateStr appendString:@" | NskAlgoReasonExpired"];
      break;
    case NskAlgoReasonInternetError:
      [stateStr appendString:@" | NskAlgoReasonInternetError"];
      break;
    case NskAlgoReasonKeyError:
      [stateStr appendString:@" | NskAlgoReasonKeyError"];
      break;
  }
  printf("%s", [stateStr UTF8String]);
  printf("\n");
}

- (void)attAlgoIndex:(NSNumber *)att_index {
  if(self._attentionChannelStreamHandler.sink != nil) {
    self._attentionChannelStreamHandler.sink(att_index);
  }
}

- (void)bpAlgoIndex:(NSNumber *)delta theta:(NSNumber *)theta alpha:(NSNumber *)alpha beta:(NSNumber *)beta gamma:(NSNumber *)gamma {
  if(self._bandPowerChannelStreamHandler.sink != nil) {
    NSDictionary* bandPowerData = @{
                                    @"delta": delta,
                                    @"theta": theta,
                                    @"alpha": alpha,
                                    @"beta": beta,
                                    @"gamma": gamma,
                                    };
    NSError* err;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:bandPowerData options:0 error:&err];
    NSString* jsonBandPowerDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    self._bandPowerChannelStreamHandler.sink(jsonBandPowerDataString);
  }
}

- (void)eyeBlinkDetect:(NSNumber *)strength {
  if(self._eyeBlinkChannelStreamHandler.sink != nil) {
    self._eyeBlinkChannelStreamHandler.sink(strength);
  }
}

- (void)medAlgoIndex:(NSNumber *)med_index {
  if(self._meditationChannelStreamHandler.sink != nil) {
    self._meditationChannelStreamHandler.sink(med_index);
  }
}

- (void)signalQuality:(NskAlgoSignalQuality)signalQuality {
  NSMutableString* signalStr = [[NSMutableString alloc] init];
  [signalStr setString:@""];
  [signalStr appendString:@"Signal quailty: "];
  switch (signalQuality) {
    case NskAlgoSignalQualityGood:
      [signalStr appendString:@"Good"];
      break;
    case NskAlgoSignalQualityMedium:
      [signalStr appendString:@"Medium"];
      break;
    case NskAlgoSignalQualityNotDetected:
      [signalStr appendString:@"Not detected"];
      break;
    case NskAlgoSignalQualityPoor:
      [signalStr appendString:@"Poor"];
      break;
  }
  printf("%s", [signalStr UTF8String]);
  printf("\n");
}

@end

@interface MWMDelegateHandler ()
@property(nonatomic, retain) FlutterMethodChannel* _connectionChannel;
@property(nonatomic) BOOL _bleFlag;
@property(nonatomic) BOOL _hasLicenseKey;
@property(nonatomic, retain) NskAlgoSdk* _nskAlgoSdk;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _attentionChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _eyeBlinkChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _meditationChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _signalQualityChannelStreamHandler;
@end

@implementation MWMDelegateHandler

-(id)initWithVariables: (FlutterMethodChannel*) connectionChannel
                        bleFlag: (BOOL) bleFlag
                        hasLicenseKey: (BOOL) hasLicenseKey
                        nskAlgoSdk: (NskAlgoSdk*) nskAlgoSdk
                        attentionChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) attentionChannelStreamHandler
                        eyeBlinkChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eyeBlinkChannelStreamHandler
                        meditationChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) meditationChannelStreamHandler
                        signalQualityChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) signalQualityChannelStreamHandler {
  self = [super init];
  if (self) {
    self._connectionChannel = connectionChannel;
    self._bleFlag = bleFlag;
    self._hasLicenseKey = hasLicenseKey;
    self._nskAlgoSdk = nskAlgoSdk;
    self._attentionChannelStreamHandler = attentionChannelStreamHandler;
    self._eyeBlinkChannelStreamHandler = eyeBlinkChannelStreamHandler;
    self._meditationChannelStreamHandler = meditationChannelStreamHandler;
    self._signalQualityChannelStreamHandler = signalQualityChannelStreamHandler;
  }
  return self;
}

- (void)didConnect {
  [self._connectionChannel invokeMethod:@"connected" arguments: nil];
}

- (void)didDisconnect {
  [self._connectionChannel invokeMethod:@"disconnected" arguments: nil];
}

// Raw sample data
-(void)eegSample:(int) sample {
  int16_t eeg_data[1];
  eeg_data[0] = (int16_t)sample;
  // Feed-in EEG data to the EEG Algo SDK
  [self._nskAlgoSdk dataStream:NskAlgoDataTypeEEG data:eeg_data length:1];
  // MWM plus case:  BLE sample rate 256;  so double it!
  if (self._bleFlag) {
    [self._nskAlgoSdk dataStream:NskAlgoDataTypeEEG data:eeg_data length:1];
  }
};

// Emotional Sense call back
-(void)eSense:(int)poorSignal Attention:(int)attention Meditation:(int)meditation {
  if (self._hasLicenseKey) {
    int16_t poor_signal[1];
    poor_signal[0] = (int16_t)poorSignal;
    //Feed-in EEG data to the EEG Algo SDK
    [self._nskAlgoSdk dataStream:NskAlgoDataTypePQ data:poor_signal length:1];
    
    int16_t attention_input[1];
    attention_input[0] = (int16_t)attention;
    //Feed-in EEG data to the EEG Algo SDK
    [self._nskAlgoSdk dataStream:NskAlgoDataTypeAtt data:attention_input length:1];
    
    int16_t meditation_input[1];
    meditation_input[0] = (int16_t)meditation;
    //Feed-in EEG data to the EEG Algo SDK
    [self._nskAlgoSdk dataStream:NskAlgoDataTypeMed data:meditation_input length:1];
  } else {
    if(self._meditationChannelStreamHandler.sink != nil) {
      self._meditationChannelStreamHandler.sink([NSNumber numberWithInt:poorSignal]);
    }
    if(self._attentionChannelStreamHandler.sink != nil) {
      self._attentionChannelStreamHandler.sink([NSNumber numberWithInt:attention]);
    }
    if(self._meditationChannelStreamHandler.sink != nil) {
      self._meditationChannelStreamHandler.sink([NSNumber numberWithInt:meditation]);
    }
  }
}

-(void)eegBlink:(int) blinkValue {
  if (!self._hasLicenseKey) {
    if(self._eyeBlinkChannelStreamHandler.sink != nil) {
      self._eyeBlinkChannelStreamHandler.sink([NSNumber numberWithInt:blinkValue]);
    }
  }
}

@end
