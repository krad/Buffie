// The handler reference atom specifies the media handler component that is to be used to interpret the media’s data.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_031.gif

struct HDLR: BinaryEncodable {
    
    var type: Atom = .hdlr
    
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    // This is supposed to be either media or data, but the Apple HLS tools sets it to zero for some reason
    var componentType: UInt32 = 0
    var componentSubtype: AtomDataType = .video
    var componentManufacturer: UInt32 = 0
    var componentFlags: UInt32 = 0
    var componentFlagMask: UInt32 = 0
    
    var componentName: String = "Core Media Video\0"
    
}

enum HDLRComponentType: String, BinaryEncodable {
    case mediaHandler = "mhlr"
    case dataHandler  = "dhlr"
}
