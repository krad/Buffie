struct MOOV: BinaryEncodable {
    
    let type: Atom = .moov
    
    var movieHeaderAtom: [MVHD] = [MVHD()]
    var tracks: [TRAK] = [TRAK()]
    
    var mediaFragmentInfo: [MVEX] = [MVEX()]
    
}