import Foundation
import AVFoundation

public enum AudioEncoderError: Error {
    case couldNotInitialize
}

public protocol AudioEncoderDelegate {
    func encoded(audioSample: AudioBufferList)
}

@available (macOS 10.11, iOS 5, *)
public class AudioEncoder {
    
    private var settings: AudioEncoderSettings
    private var delegate: AudioEncoderDelegate

    private var ouputStreamDesc: AudioStreamBasicDescription
    
    private var inputFormat: AVAudioFormat
    private var outputFormat: AVAudioFormat
    private var converter: AVAudioConverter
    private var inBuffer: AVAudioPCMBuffer
    private var outBuffer: AVAudioCompressedBuffer
    private var workBlock: AVAudioConverterInputBlock?
    
    init(_ settings: AudioEncoderSettings, delegate: AudioEncoderDelegate) throws {
        self.settings        = settings
        self.delegate        = delegate
        
        self.inputFormat          = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100.0, channels: 2, interleaved: false)!
        self.ouputStreamDesc      = settings.formatDescription
        self.outputFormat         = try audioFormatFrom(streamDescription: &self.ouputStreamDesc)
        self.converter            = AVAudioConverter(from: self.inputFormat, to: self.outputFormat)!
        self.inBuffer             = AVAudioPCMBuffer(pcmFormat: self.inputFormat, frameCapacity: 1024)!
        self.inBuffer.frameLength = self.inBuffer.frameCapacity
        
        self.outBuffer            = AVAudioCompressedBuffer(format: self.outputFormat,
                                                       packetCapacity: 32,
                                                       maximumPacketSize: self.converter.maximumOutputPacketSize)
        
        self.workBlock = { inNumPackets, outStatus in
            outStatus.pointee = AVAudioConverterInputStatus.haveData
            return self.inBuffer
        }
    }
    
    public func encode(_ sample: CMSampleBuffer) {
        var error: NSError?
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sample,
                                                                nil,
                                                                self.inBuffer.mutableAudioBufferList,
                                                                CMSampleBufferGetNumSamples(sample),
                                                                kCFAllocatorDefault,
                                                                kCFAllocatorDefault,
                                                                0,
                                                                nil)
        let status = self.converter.convert(to: self.outBuffer, error: &error, withInputFrom: self.workBlock!)
        if status != .endOfStream && status != .error {
            self.delegate.encoded(audioSample: self.outBuffer.audioBufferList.pointee)
        }
    }
    
}

func audioFormatFrom(streamDescription: inout AudioStreamBasicDescription) throws -> AVAudioFormat {
    if let format = AVAudioFormat(streamDescription: &streamDescription) { return format }
    else { throw AudioEncoderError.couldNotInitialize }
}

extension AVAudioPCMBuffer {
    
    func toCMSampleBuffer() -> CMSampleBuffer? {
        
        var format: CMFormatDescription? = nil
        
        var status = noErr
        status = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, self.format.streamDescription, 0, nil, 0, nil, nil, &format)
        if status != noErr {
            return nil
        }
        
        var timing = CMSampleTimingInfo(duration: CMTime(value: 1, timescale: Int32(self.format.streamDescription.pointee.mSampleRate)),
                                        presentationTimeStamp: kCMTimeZero,
                                        decodeTimeStamp: kCMTimeInvalid)
        
        var buffer: CMSampleBuffer? = nil
        status = CMSampleBufferCreate(kCFAllocatorDefault, nil, false, nil, nil, format, Int(self.frameLength), 1, &timing, 0, nil, &buffer)
        if status != noErr {
            return nil
        }
        
        status = CMSampleBufferSetDataBufferFromAudioBufferList(buffer!, kCFAllocatorDefault, kCFAllocatorDefault, 0, self.mutableAudioBufferList)
        if status != noErr {
            return nil
        }
        
        return buffer
        
    }
}
