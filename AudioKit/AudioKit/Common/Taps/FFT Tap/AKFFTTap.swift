//
//  AKFFTTap.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// FFT Calculation for any node
open class AKFFTTap: NSObject, EZAudioFFTDelegate {

    public let fftSize: AKSettings.BufferLength
    internal var bufferSize: UInt32 { fftSize.samplesCount }
    internal var fft: EZAudioFFT?

    /// Array of FFT data
    @objc open var fftData: [Double]

    /// Initialze the FFT calculation on a given node
    ///
    /// - parameters:
    ///   - input: Node on whose output the FFT will be computed
    ///   - fftSize: The sample size of the FFT buffer
    ///
    @objc public init(_ input: AKNode, fftSize: AKSettings.BufferLength = .veryLong) {
        self.fftSize = fftSize
        self.fftData = [Double](zeros: Int(self.fftSize.samplesCount / 2))
        super.init()
        fft = EZAudioFFT(maximumBufferSize: vDSP_Length(bufferSize),
                         sampleRate: Float(AKSettings.sampleRate),
                         delegate: self)
        input.avAudioUnitOrNode.installTap(
            onBus: 0,
            bufferSize: bufferSize,
            format: AKSettings.audioFormat) { [weak self] (buffer, _) -> Void in
                guard let strongSelf = self else {
                    AKLog("Unable to create strong reference to self")
                    return
                }
                buffer.frameLength = strongSelf.bufferSize
                let offset = Int(buffer.frameCapacity - buffer.frameLength)
                if let tail = buffer.floatChannelData?[0], let existingFFT = strongSelf.fft {
                    existingFFT.computeFFT(withBuffer: &tail[offset],
                                           withBufferSize: strongSelf.bufferSize)
                }
        }
    }

    /// Callback function for FFT computation
    @objc open func fft(_ fft: EZAudioFFT!,
                        updatedWithFFTData fftData: UnsafeMutablePointer<Float>,
                        bufferSize: vDSP_Length) {
        DispatchQueue.main.async { () -> Void in
            for i in 0..<512 {
                self.fftData[i] = Double(fftData[i])
            }
        }
    }
}
