import XCTest
@testable import Buffie

class AtomTests: XCTestCase {
    
    var testCases: [(BinaryEncodable, String)] = [
        (FTYP(), "00000020667479706d703432000000016d7034316d70343269736f6d686c7366"),
        
        (MVHD(), "0000006c6d76686400000000d627cae4d627cae40000ac44000000000001000001000000000000000000000000010000000000000000000000000000000100000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003"),
        
        (TKHD(), "0000005c746b686400000001d627cae4d627cae4000000010000000000000000000000000000000000000000010000000001000000000000000000000000000000010000000000000000000000000000400000000500000002d00000"),
        
        (MDHD(), "000000206d64686400000000d627cae4d627cae40000753000000bbb55c40000"),
        
        (HDLR(), "0000003168646c72000000000000000076696465000000000000000000000000436f7265204d6564696120566964656f00"),
        
        (VMHD(), "00000014766d6864000000010000000000000000"),
        (DREF(), "0000001c6472656600000000000000010000000c75726c2000000001"),
        (DINF(), "0000002464696e660000001c6472656600000000000000010000000c75726c2000000001"),
        (STCO(), "000000107374636f0000000000000000"),
        (STSZ(), "000000147374737a000000000000000000000000"),
        (STSC(), "00000010737473630000000000000000"),
        (STTS(), "00000010737474730000000000000000"),
        (PASP(), "00000010706173700000000100000001"),
        (COLR(), "00000013636f6c726e636c7800010001000100"),
        
        (AVCC(), "0000003261766343014d001fffe1001b274d001f898b602802dd80b5010101ec0c0017700005dc17bdf05001000428ee1f20"),
        
        (AVC1(), "000000ab61766331000000000000000100000000000000000000000000000000050002d0004800000048000000000000000100000000000000000000000000000000000000000000000000000000000000000018ffff0000003261766343014d001fffe1001b274d001f898b602802dd80b5010101ec0c0017700005dc17bdf05001000428ee1f2000000013636f6c726e636c780001000100010000000010706173700000000100000001"),
        
        (TREX(), "0000002074726578000000000000000100000001000000000000000001010000"),
        (MVEX(), "000000286d7665780000002074726578000000000000000100000001000000000000000001010000"),
        
        (MFHD(), "000000106d6668640000000000000001"),
        //(TFHD(), "0000001c746668640002003800000001000003e9000231ae02000000"),
        (TFDT(), "00000014746664740100000000000000000493e0")
    ]
    
    func test_that_we_can_encode_atoms_to_their_proper_binary_representations() {
        
        for testCase in testCases {
            
            let bytes = try? BinaryEncoder.encode(testCase.0)
            XCTAssertNotNil(bytes)
            
            let data    = Data(bytes: bytes!)
            let hexData = data.hexEncodedString()
            
            let errorMessage = "\nExpected: \(testCase.1)\nGot:      \(hexData)"
            XCTAssertEqual(hexData.count, testCase.1.count, errorMessage)
            
        }
        
    }
    
    func test_that_we_can_create_an_esds_properly() {
        

        let config      = MOOVAudioSettings(audioObjectType: .AAC_LC,
                                            samplingFreq: .hz44100,
                                            channelLayout: .frontLeftAndFrontRight)
        
        let esds        = ESDS.from(config)
        let expectedOut = "000000000380808022000000048080801440150018000001f4000001f40005808080021210068080800102"

        let bytes = try? BinaryEncoder.encode(esds)
        XCTAssertNotNil(bytes)
        
        let data    = Data(bytes: bytes!)
        var hexData = data.hexEncodedString()
        hexData.removeFirst(16) // first 8 bytes length of the atom and the esds tag
        
        XCTAssertEqual(hexData.count, expectedOut.count)
        
        let errorMessage = "\nExpected: \(expectedOut)\nGot:      \(hexData)"
        XCTAssertEqual(hexData, expectedOut, errorMessage)
        
        
    }
    
}
