/**
 ******************************************************************************
 * @file    NskAlgoSdk.h
 * @author  Algo SDK Team
 * @version V0.1
 * @date    12-May-2015
 * @brief   Algo SDK Objective-C wrapper layer
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; COPYRIGHT(c) NeuroSky Inc. All rights reserved.</center></h2>
 *
 *
 ******************************************************************************
 */

#import <Foundation/Foundation.h>

/* EEG data signal quality definitions */
typedef NS_ENUM(NSInteger, NskAlgoSignalQuality) {
    NskAlgoSignalQualityGood,           /* Signal quality is in good level */
    NskAlgoSignalQualityMedium,         /* Signal quality is in medium level */
    NskAlgoSignalQualityPoor,           /* Signal quality is in poor level */
    NskAlgoSignalQualityNotDetected     /* Sensor signal is not detected */
};

/* SDK state definitions */
typedef NS_ENUM(NSInteger, NskAlgoState) {
    NskAlgoStateInited = 1,             /* Algo SDK initialized */
    NskAlgoStateRunning,                /* Algo SDK is performing analysis (i.e. startProcess() invoked) */
    NskAlgoStateCollectingBaselineData, /* Algo SDK is collecting baseline data */
    NskAlgoStateStop,                   /* Algo SDK stops data analysis/baseline collection */
    NskAlgoStatePause,                  /* Algo SDK pauses data analysis */
    NskAlgoStateUninited,               /* Algo SDK is uninitialized */
    NskAlgoStateAnalysingBulkData       /* Algo SDK is analysing a bulk of EEG data */
};

/* SDK state change reason definitions */
typedef NS_ENUM(NSInteger, NskAlgoReason) {
    NskAlgoReasonConfigChanged = 1,      /* RESERVED: SDK configuration changed */
    NskAlgoReasonUserProfileChanged,     /* RESERVED: Active user profile has been changed */
    NskAlgoReasonUserTrigger,            /* User triggers */
    NskAlgoReasonBaselineExpired,        /* RESERVED: Baseline expired */
    NskAlgoReasonNoBaseline,             /* No baseline data collected yet */
    NskAlgoReasonSignalQuality,          /* Due to signal quality */
    NskAlgoReasonExpired,                /* FOR EVALUATION ONLY: SDK has been expired */
    NskAlgoReasonInternetError,          /* FOR EVALUATION ONLY: internet connection error */
    NskAlgoReasonKeyError                /* FOR EVALUATION ONLY: evaluation license key error */
};

typedef NS_ENUM(NSInteger, NskAlgoF2ProgressLevel) {
    NskAlgoF2ProgressLevelVeryBad = 1,
    NskAlgoF2ProgressLevelBad,
    NskAlgoF2ProgressLevelFlat,
    NskAlgoF2ProgressLevelGood,
    NskAlgoF2ProgressLevelGreat
};

/* EEG algorithm type definitions */
typedef NS_ENUM(NSInteger, NskAlgoEegType) {
    NskAlgoEegTypeAP    = 0x0001,           /* Appreciation */
    NskAlgoEegTypeME    = 0x0002,           /* Mental Effort */
    NskAlgoEegTypeME2   = 0x0004,           /* Mental Effort Secondary Algorithm */
    NskAlgoEegTypeAtt   = 0x0008,           /* Attention */
    NskAlgoEegTypeMed   = 0x0010,           /* Meditation */
    NskAlgoEegTypeF     = 0x0020,           /* Familiarity */
    NskAlgoEegTypeF2    = 0x0040,           /* Familiarity Secondary Algorithm */
    NskAlgoEegTypeBlink = 0x0080,           /* Eye Blink Detection */
    NskAlgoEegTypeCR    = 0x0100,           /* Creativity */
    NskAlgoEegTypeAL    = 0x0200,           /* Alertness */
    NskAlgoEegTypeCP    = 0x0400,           /* Cognitive Preparedness */
    NskAlgoEegTypeBP    = 0x0800,           /* EEG Bandpower */
    NskAlgoEegTypeET    = 0x1000,           /* eTensity */
    NskAlgoEegTypeYY    = 0x2000            /* Yin-Yang */
};

/* EEG data type definitions (data from COMM SDK) */
typedef NS_ENUM(NSInteger, NskAlgoDataType) {
    NskAlgoDataTypeEEG,      /* Raw EEG data */
    NskAlgoDataTypeAtt,      /* Attention data */
    NskAlgoDataTypeMed,      /* Meditation data */
    NskAlgoDataTypePQ,       /* Poor signal quality data */
    NskAlgoDataTypeBulkEEG,  /* Bulk EEG data (must be multiple of 512, i.e. Ns of continuous GOOD EEG data */
};

/* Brain Conditioning Quantification threshold */
typedef NS_ENUM(NSInteger, NskAlgoBCQThreshold) {
    NskAlgoBCQThresholdLight = 0,
    NskAlgoBCQThresholdMedium,
    NskAlgoBCQThresholdHigh
};

/* Brain Conditioning Quantification return type */
typedef NS_ENUM(NSInteger, NskAlgoBCQIndexType) {
    NskAlgoBCQIndexTypeValue = 0,   /* only cr_value/al_value/cp_value is valid */
    NskAlgoBCQIndexTypeValid,       /* only BCQ_valid is valid */
    NskAlgoBCQIndexTypeBoth         /* both cr_value/al_value/cp_value and BCQ_valid are valid */
};

@protocol NskAlgoSdkDelegate <NSObject>

@required
/* notification on SDK state change */
- (void) stateChanged: (NskAlgoState)state reason:(NskAlgoReason)reason;

/* notification on signal quality */
- (void) signalQuality: (NskAlgoSignalQuality)signalQuality;

@optional
/* notification on EEG algorithm index */
- (void) apAlgoIndex: (NSNumber*)ap_index;

- (void) meAlgoIndex: (NSNumber*)abs_me diff_me:(NSNumber*)diff_me max_me:(NSNumber*)max_me min_me:(NSNumber*)min_me;

- (void) me2AlgoIndex: (NSNumber*)total_me me_rate:(NSNumber*)me_rate changing_rate:(NSNumber*)changing_rate;

- (void) fAlgoIndex: (NSNumber*)abs_f diff_f:(NSNumber*)diff_f max_f:(NSNumber*)max_f min_f:(NSNumber*)min_f;

- (void) f2AlgoIndex: (NSNumber*)progress f_degree:(NSNumber*)f_degree;

- (void) attAlgoIndex: (NSNumber*)att_index;

- (void) medAlgoIndex: (NSNumber*)med_index;

- (void) eyeBlinkDetect: (NSNumber*)strength;

- (void) bpAlgoIndex: (NSNumber*)delta theta:(NSNumber*)theta alpha:(NSNumber*)alpha beta:(NSNumber*)beta gamma:(NSNumber*)gamma;

- (void) crAlgoIndex: (NskAlgoBCQIndexType)cr_index_type cr_value:(NSNumber*)cr_value BCQ_valid:(BOOL)BCQ_valid;

- (void) alAlgoIndex: (NskAlgoBCQIndexType)al_index_type al_value:(NSNumber*)al_value BCQ_valid:(BOOL)BCQ_valid;

- (void) cpAlgoIndex: (NskAlgoBCQIndexType)cp_index_type cp_value:(NSNumber*)cp_value BCQ_valid:(BOOL)BCQ_valid;

- (void) etAlgoIndex: (NSNumber*)et_index;

- (void) yyAlgoIndex: (NSNumber*)yy_index;


@end

@interface NskAlgoSdk : NSObject {
    id <NskAlgoSdkDelegate> delegate;
}

@property (retain) id delegate;

+ (id) sharedInstance;

/* set algorithm type(s)
 Return: 0 - Algo SDK is initialized successfully; Otherwise, something wrong on SDK initialization
 */
- (NSInteger) setAlgorithmTypes: (NskAlgoEegType)algoTypes licenseKey:(char*)licenseKey /* Opional for EVALUATION_BUILD */;

/* get algorithm version */
- (NSString*) getAlgoVersion: (NskAlgoEegType)algoType;

/* get SDK version */
- (NSString*) getSdkVersion;

/* set algorithm index output interval
 Note1: Different algorithms will have different output interval (both minimum and maximum).
 Appreciation: min - 1 seconds, max - 5 seconds
 Note2: NskAlgoEegTypeAtt and NskAlgoEegTypeMed cannot be changed. They are always equal 1.
 Note3: For NskAlgoEegTypeCR, NskAlgoEegTypeAL and NskAlgoEegTypeCP, please use setCreativityAlgoConfig, setAlertnessAlgoConfig and setCognitivePreparednessAlgoConfig correspectively
 */
- (BOOL) setAlgoIndexOutputInterval: (NskAlgoEegType)algoType outputInterval:(NSInteger)outputInterval;

/* set BCQ creativity algorithm configuration */
- (BOOL) setCreativityAlgoConfig: (NSInteger)outputInterval threshold:(NskAlgoBCQThreshold)threshold window:(NSInteger)window;

/* set BCQ alertness algorithm configuration */
- (BOOL) setAlertnessAlgoConfig: (NSInteger)outputInterval threshold:(NskAlgoBCQThreshold)threshold window:(NSInteger)window;

/* set BCQ cognitive preparedness algorithm configuration */
- (BOOL) setCognitivePreparednessAlgoConfig: (NSInteger)outputInterval threshold:(NskAlgoBCQThreshold)threshold window:(NSInteger)window;

/* start data analysis */
- (BOOL) startProcess;

/* pause data analysis */
- (BOOL) pauseProcess;

/* stop data analysis */
- (BOOL) stopProcess;

/* EEG raw data stream (from COMM SDK) */
- (BOOL) dataStream: (NskAlgoDataType)type data:(int16_t*)data length:(int32_t)length;

@end
