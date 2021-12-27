//
//  MainFLImagePickerCell.swift
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

class MainFLImagePickerCell: UICollectionViewCell {
    @IBOutlet weak var cover: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var checkHinter: UIView!
    @IBOutlet weak var imgChecked: UIImageView!
    
    /* checked border*/
    var checkBackgroundColor: UIColor?
    var checkBorderColor: UIColor?{
        willSet(color){
            if let color = color {
                checkHinter.layer.borderColor = color.cgColor
            }else{
                checkHinter.layer.borderColor = UIColor.white.withAlphaComponent(0.75).cgColor
            }
        }
    }
    
    /* set photo*/
    var imgAsset: PHAsset?{
        didSet{
            if let imgAsset = imgAsset {
                PHCachingImageManager().requestImage(for: imgAsset,
                                                        targetSize: CGSize(width: 400, height: 400),
                                                        contentMode: .aspectFit,
                                                        options: .none){[self] (image, info) in
                    photoImageView.image = image
                }
            }
        }
    }
    
    /* selected*/
    override var isSelected: Bool{
        didSet{
            cover.isHidden = !isSelected
            imgChecked.isHidden = !isSelected
            checkHinter.backgroundColor = isSelected ? checkBackgroundColor : .clear
        }
    }
}
