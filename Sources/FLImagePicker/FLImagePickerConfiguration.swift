//
//  File.swift
//
//
//  Created by Allen Lee on 2023/5/1.
//

import Foundation

struct FLImagePickerOptions {
    var numsOfRow: CGFloat = 3 // cells of row
    var maxPick = 100
    var ppm: CGFloat = 3 // (pps, pixel per step)
    var fps: CGFloat = 120 // update speed
    var detectAreaHeight: CGFloat = 200

    // default
    let defNumOfRow = CGFloat(3)
    let defMaxPick = 100
    let defPpm = CGFloat(3)
    let defFps = CGFloat(120)
    let defDetectAreaHeight = CGFloat(200)
}
