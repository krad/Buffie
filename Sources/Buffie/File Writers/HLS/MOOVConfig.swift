import CoreMedia

struct MOOVConfig {
    
    var videoSettings: MOOVVideoSettings?
    var audioSettings: MOOVAudioSettings?
    
    init() { }
    
}

struct MOOVVideoSettings {
    
    var sps: [UInt8]
    var pps: [UInt8]
    var width: UInt32
    var height: UInt32
    var timescale: UInt32 = 30000
    
    init(_ format: CMFormatDescription) {
        let paramSet = getVideoFormatDescriptionData(format)
        self.sps = paramSet.first!
        self.pps = paramSet.last!
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(format)
        self.width     = UInt32(dimensions.width)
        self.height    = UInt32(dimensions.height)
    }
    
}

struct MOOVAudioSettings {
    
    var channels: UInt32   = 2
    var sampleRate: UInt32 = 44100
    var sampleSize: UInt16 = 16
    var audioObjectType: AudioObjectType
    var samplingFreq: SamplingFrequency
    var channelLayout: ChannelConfiguration
    
    init(audioObjectType: AudioObjectType,
         samplingFreq: SamplingFrequency,
         channelLayout: ChannelConfiguration)
    {
        self.audioObjectType = audioObjectType
        self.samplingFreq    = samplingFreq
        self.channelLayout   = channelLayout
    }
    
    init(_ sample: AudioSample) {
        self.channels   = sample.channels
        self.sampleSize = sample.sampleSize
        self.sampleRate = UInt32(sample.sampleRate)
        
        self.audioObjectType = sample.audioObjectType
        self.samplingFreq    = sample.samplingFreq
        self.channelLayout   = sample.channelConfig
    }
    
}



