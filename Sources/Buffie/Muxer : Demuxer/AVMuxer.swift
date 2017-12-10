import Foundation
import CoreMedia

public struct AVMuxerSettings {
    var videoSettings: VideoEncoderSettings
    
    public init() {
        self.videoSettings = VideoEncoderSettings()
    }
}

public protocol AVMuxerDelegate {
    func got(paramSet: [[UInt8]])
    func muxed(data: [UInt8])
}

public class AVMuxer: AVReader {
    
    public static let streamDelimeter: [UInt8] = [0x0, 0x0, 0x0, 0x1]
    public static let paramSetMarker: UInt8    = 0x70

    fileprivate var delegate: AVMuxerDelegate?
    internal var videoEncoder: VideoEncoder?
    internal var parameterSetData: [[UInt8]]? {
        didSet {
            if let params = parameterSetData {
                self.delegate?.got(paramSet: params)
            }
        }
    }
    
    private override init() {
        super.init()        
    }
    
    public convenience init(settings: AVMuxerSettings = AVMuxerSettings(), delegate: AVMuxerDelegate) throws {
        self.init()
        self.delegate     = delegate
        self.videoEncoder = try VideoEncoder(settings.videoSettings, delegate: self)
    }

    public override func got(_ sample: CMSampleBuffer, type: SampleType) {
        switch type {
        case .video: self.videoEncoder?.encode(sample)
        case .audio: _ = 0 + 0
        }
    }
    
}

extension AVMuxer: VideoEncoderDelegate {
    public func encoded(videoSample: CMSampleBuffer) {
        
        if self.parameterSetData == nil {
            self.parameterSetData = getVideoFormatDescriptionData(videoSample)
        }
        
        if let bytes = bytes(from: videoSample) {
            let packet: [UInt8] =  [SampleType.video.rawValue] + bytes
            self.delegate?.muxed(data: packet)
        }
    }
}

/// Converts a CMSampleBuffer to an array of unsigned 8 bit integers
///
/// - Parameter sample: CMSampleBuffer
/// - Returns: Array of unsigned 8 bit integers
public func bytes(from sample: CMSampleBuffer) -> [UInt8]? {
    if let dataBuffer = CMSampleBufferGetDataBuffer(sample) {
        var bufferLength: Int = 0
        var bufferDataPointer: UnsafeMutablePointer<Int8>? = nil
        CMBlockBufferGetDataPointer(dataBuffer, 0, nil, &bufferLength, &bufferDataPointer)
        
        var nalu = [UInt8](repeating: 0, count: bufferLength)
        CMBlockBufferCopyDataBytes(dataBuffer, 0, bufferLength, &nalu)
        return nalu
    }
    
    return nil
}


/// Converts an AudioBufferList to an array of unsigned 8 bit integers
///
/// - Parameter audioBufferList: AudioBufferList with buffers of audio
/// - Returns: Array of unsigned 8 bit integers
internal func bytes(from audioBufferList: AudioBufferList) -> [UInt8]? {
    var result: [UInt8] = []
    
    var shallowBuffer = audioBufferList
    let buffers = UnsafeBufferPointer<AudioBuffer>(start: &shallowBuffer.mBuffers, count: Int(audioBufferList.mNumberBuffers))
    for buffer in buffers {
        if let framePtr = buffer.mData?.assumingMemoryBound(to: UInt8.self) {
            let frameArray = Array(UnsafeBufferPointer(start: framePtr, count: Int(buffer.mDataByteSize)))
            result         = result + frameArray
        }
    }
    
    if result.count > 0 {
        return result
    }
    
    return nil
}


/// Get's the SPS & PPS data from an h264 sample
///
/// - Parameter buffer: CMSampleBuffer of h264 data
/// - Returns: Data representing SPS and PPS bytes
public func getVideoFormatDescriptionData(_ buffer: CMSampleBuffer) -> [[UInt8]] {
    var results: [[UInt8]] = []
    
    if let description = getFormatDescription(buffer) {
        results = getVideoFormatDescriptionData(description)
    }
    
    return results
}

public func getVideoFormatDescriptionData(_ format: CMFormatDescription) -> [[UInt8]] {
    var results: [[UInt8]] = []

    var numberOfParamSets: size_t = 0
    CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, nil, nil, &numberOfParamSets, nil)
    
    for idx in 0..<numberOfParamSets {
        var params: UnsafePointer<UInt8>? = nil
        var paramsLength: size_t         = 0
        var headerLength: Int32          = 4
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, idx, &params, &paramsLength, nil, &headerLength)
        
        let bufferPointer   = UnsafeBufferPointer(start: params, count: paramsLength)
        let paramsUnwrapped = Array(bufferPointer)
        
        let result: [UInt8] =  paramsUnwrapped
        results.append(result)
    }
    
    return results
}


/// Get the format description from a sample buffer
///
/// - Parameter buffer: CMSampleBuffer we're interested in
/// - Returns: CMFormatDescription describing the contents of the sample buffer
public func getFormatDescription(_ buffer: CMSampleBuffer) -> CMFormatDescription? {
    if let description = CMSampleBufferGetFormatDescription(buffer) {
        return description
    }
    return nil
}
