//
//  BufferType.swift
//  EEG_OSC
//
//  Created by Allan Frederick on 5/13/22.
//

import Foundation

class BufferType{
    
    // MARK: BUFFER ARRAYS
    var EEG: [[Float]] = [[],[],[],[]] // Tp9, Af7, Af8, Tp10
    var bP_alpha: [Float] = []
    var bP_beta: [Float] = []
    var bP_theta: [Float] = []
    var bP_delta: [Float] = []

    // MARK: EEG RAW DATA
    let fs = 256 // Muse data rate
    // Length of the EEG data buffer (in seconds)
    // This buffer will hold last n seconds of data and be used for processing/calculations
    let EEG_length = 3
    var EEG_maxSamples : Int
    
    // MARK: BAND POWER DATA
    let fs_bandPower = 10 // Bandpower data rate
    // Length of the bandPower data buffer (in seconds)
    // This buffer will hold last n seconds of data and be used for processing/calculations
    let bP_length = 3
    var bP_maxSamples : Int

    
    init(){
        EEG_maxSamples = fs * EEG_length
        bP_maxSamples = fs_bandPower * bP_length
    }
}
