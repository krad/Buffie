import CoreMedia

struct TRAF: BinarySizedEncodable {
    
    let type: Atom = .traf
    
    var trackFragmentHeader: [TFHD] = [TFHD()]
    var trackDecodeAtom: [TFDT] = [TFDT()]
    var trackRun: [TRUN] = [TRUN()]
    
    static func from(_ samples:[Sample],
                     config: MOOVConfig) -> [TRAF]
    {
        var trackFragments: [TRAF] = []
        
        if let _ = config.videoSettings {
            print("+==== VIDEO")
            let videoSamples = samples.filter { $0.type == .video } as! [VideoSample]

            if let sample = videoSamples.first {
                var traf                 = TRAF()
                traf.trackFragmentHeader = [TFHD.from(sample: sample)]
                
                let duration             = videoSamples.reduce(0) { cnt, sample in cnt + sample.duration.value }
                traf.trackDecodeAtom     = [TFDT.from(decode: UInt64(sample.decode.value),
                                                      duration: UInt64(duration))]
                
                traf.trackRun            = [TRUN.from(samples: videoSamples)]

                trackFragments.append(traf)
            }
        }

        if let _ = config.audioSettings {
            print("+==== AUDIO")
            let audioSamples = samples.filter { $0.type == .audio } as! [AudioSample]

            if let sample = audioSamples.first {
                
                let size = audioSamples.reduce(0) { cnt, sample in cnt + sample.size }
                
                var traf                 = TRAF()
                traf.trackFragmentHeader = [TFHD.from(sample: sample)]
                traf.trackDecodeAtom     = [TFDT.from(size: size, sampleRate: sample.sampleRate)]
                traf.trackRun            = [TRUN.from(samples: audioSamples)]
                trackFragments.append(traf)
            }
        }
        
        return trackFragments
    }
    
}