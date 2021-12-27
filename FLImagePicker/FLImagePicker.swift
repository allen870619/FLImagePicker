//
//  FLImagePicker.swift
//  FLImagePicker
//
//  Created by Lee Yen Lin on 2021/12/23.
//

import UIKit
import Photos

public class FLImagePicker: UINavigationController {
    let picker = MainFLImagePicker()
    private var pickerOptions = FLImagePickerOptions()
    
    // delegate
    public var imageDelegate: FLImagePickerDelegate?{
        set(delegate){
            picker.imagePickerDelegate = delegate
        }
        get{
            return picker.imagePickerDelegate
        }
    }
    
    public init(){
        super.init(nibName: nil, bundle: nil)
        viewControllers.append(picker)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* options*/
    public var numsOfRow: CGFloat{
        set(v){
            pickerOptions.numsOfRow = v
            picker.updateOptions(pickerOptions)
        }
        get{
            return pickerOptions.numsOfRow
        }
    }
    
    public var maxPick: Int{
        set(v){
            pickerOptions.maxPick = v
            picker.updateOptions(pickerOptions)
        }
        get{
            return pickerOptions.maxPick
        }
    }
    
    /// pixel per moved
    ///
    /// Total moved distance would be ppm * fps
    public var ppm: CGFloat{
        set(v){
            pickerOptions.ppm = v
            picker.updateOptions(pickerOptions)
        }
        get{
            return pickerOptions.ppm
        }
    }
    
    /// freq. per second
    public var fps: CGFloat{
        set(v){
            pickerOptions.fps = v
            picker.updateOptions(pickerOptions)
        }
        get{
            return pickerOptions.fps
        }
    }
    
    /// detect area for scroll (extend from top and bottom)
    ///
    /// -------------
    /// |     ^     |
    /// |     |     |
    /// |    240    |
    /// |     |     |
    /// |     ⌄     |
    /// -------------
    /// |           |
    /// |           |
    /// |           |
    /// -------------
    /// |     ^     |
    /// |     |     |
    /// |    240    |
    /// |     |     |
    /// |     ⌄     |
    /// -------------
    public var detectAreaHeight: CGFloat{
        set(v){
            pickerOptions.detectAreaHeight = v
            picker.updateOptions(pickerOptions)
        }
        get{
            return pickerOptions.detectAreaHeight
        }
    }
}

struct FLImagePickerOptions{
    var numsOfRow: CGFloat = 3 // cells of row
    var maxPick = 100
    var ppm: CGFloat = 3 // (pps, pixel per step)
    var fps: CGFloat = 120 // update speed
    var detectAreaHeight: CGFloat = 240
}

public protocol FLImagePickerDelegate{
    func didFinished(_ imageAssets: [PHAsset])
}
