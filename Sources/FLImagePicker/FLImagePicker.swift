//
//  FLImagePicker.swift
//  FLImagePicker
//
//  Created by Allen Lee on 2021/12/23.
//
//  MIT License
//
//  Copyright (c) 2021 Allen Lee
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Photos

public class FLImagePicker: UINavigationController {
    private let picker = MainFLImagePicker()
    private var pickerStyle = FLImagePickerStyle()
    private var pickerOptions = FLImagePickerOptions(){
        didSet{
            picker.updateOptions(pickerOptions)
        }
    }
    
    /* delegate*/
    public var imageDelegate: FLImagePickerDelegate?{
        set(delegate){
            picker.imagePickerDelegate = delegate
        }
        get{
            return picker.imagePickerDelegate
        }
    }
    
    /* style*/
    public var style: FLImagePickerStyle?{
        set(v){
            if let v = v{
                pickerStyle = v
            }else{
                pickerStyle = FLImagePickerStyle()
            }
            picker.imagePickerStyle = pickerStyle
        }
        get{
            return pickerStyle
        }
    }
    
    /* options*/
    public var numsOfRow: CGFloat? {
        set(v){
            if let v = v{
                pickerOptions.numsOfRow = v
            }else{
                pickerOptions.numsOfRow = pickerOptions.defNumOfRow
            }
        }
        get{
            return pickerOptions.numsOfRow
        }
    }
    
    public var maxPick: Int? {
        set(v){
            if let v = v{
                pickerOptions.maxPick = v
            }else{
                pickerOptions.maxPick = pickerOptions.defMaxPick
            }
        }
        get{
            return pickerOptions.maxPick
        }
    }
    
    /// pixel per moved
    ///
    /// Total moved distance would be ppm * fps
    public var ppm: CGFloat? {
        set(v){
            if let v = v{
                pickerOptions.ppm = v
            }else{
                pickerOptions.ppm = pickerOptions.defPpm
            }
        }
        get{
            return pickerOptions.ppm
        }
    }
    
    /// freq. per second
    public var fps: CGFloat? {
        set(v){
            if let v = v{
                pickerOptions.fps = v
            }else{
                pickerOptions.fps = pickerOptions.defFps
            }
        }
        get{
            return pickerOptions.fps
        }
    }
    
    /// detect area for scroll (extend from top and bottom)
    public var detectAreaHeight: CGFloat? {
        set(v){
            if let v = v{
                pickerOptions.detectAreaHeight = v
            }else{
                pickerOptions.detectAreaHeight = pickerOptions.defDetectAreaHeight
            }
        }
        get{
            return pickerOptions.detectAreaHeight
        }
    }
    
    /* data*/
    var selectedAsset: [PHAsset]{
        get{
            return picker.getSelectedAssets()
        }
    }
    
    /* initialize*/
    public init(){
        super.init(nibName: nil, bundle: nil)
        viewControllers.append(picker)
        picker.imagePickerStyle = pickerStyle
        picker.imagePicker = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal struct FLImagePickerOptions{
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

