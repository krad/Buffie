import XCTest
import AVFoundation
@testable import Buffie

class FragmentedMP4WriterTests: XCTestCase {
    
    class SimpleReader: AVReader {
        
        var callback: (CMSampleBuffer) -> Void
        init(callback: @escaping (CMSampleBuffer) -> Void) {
            self.callback = callback
        }
        
        override func got(_ sample: CMSampleBuffer, type: SampleType) {
            super.got(sample, type: type)
            if type == .video {
                self.callback(sample)
            }
        }
        
    }
    
    func xtest_experiment() {
        
        let writer = try? FragmentedMP4Writer()
        XCTAssertNotNil(writer)
        
        let reader = SimpleReader() { sample in
            writer?.got(sample)
        }
        
        let camera = try? Camera(.back, reader: reader, controlDelegate: nil)
        XCTAssertNotNil(camera)
        
        camera?.start()
        
        let e = self.expectation(description: "Blah")
        
        self.wait(for: [e], timeout: 10)
        
    }
    
    func test_that_we_can_parse_nalus_from_byte_array() {
        
        let iterator = NALUStreamIterator(streamBytes: compressedFrame, currentIdx: 0)
        
        var results: [NALU] = []
        
        for nalu in iterator {
            results.append(nalu)
        }
        
        XCTAssert(results.count > 0)
        
        print(results)
        
    }
    
}
