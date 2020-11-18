//
//  AKToneComplementFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKToneComplementFilterParameter) {
    AKToneComplementFilterParameterHalfPowerPoint,
    AKToneComplementFilterParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createToneComplementFilterDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKToneComplementFilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKToneComplementFilterDSP();

    float halfPowerPointLowerBound = 12.0;
    float halfPowerPointUpperBound = 20000.0;

    float defaultHalfPowerPoint = 1000.0;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
