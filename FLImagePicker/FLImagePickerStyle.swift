//
//  FLImagePickerStyle.swift
//  FLImagePicker
//
//  Created by Allen Lee on 2021/12/28.
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

public struct FLImagePickerStyle{
    /* cell style*/
    /// check hinter
    public var checkImage: UIImage? = .FLDefaults.checkImg
    public var checkBorderColor: UIColor? = .FLDefaults.checkBorderColor{
        didSet{
            if checkBorderColor == nil{
                checkBorderColor = .FLDefaults.checkBorderColor
            }
        }
    }
    public var checkBackgroundColor: UIColor? = .FLDefaults.primary
    
    // cover
    public var coverColor: UIColor? = .FLDefaults.coverBackground
    
    /* button*/
    public var btnColor: UIColor? = .FLDefaults.primary
    
    public init(){}
}

extension UIColor{
    public struct FLDefaults{
        public static var primary: UIColor{
            get{
                if let color = UIColor(named: "AccentColor"){
                    return color
                }else{
                    return .link
                }
            }
        }
        
        // cell
        public static let coverBackground = UIColor(named: "selectedCover", in: Bundle(for: FLImagePicker.self), compatibleWith: nil)?.withAlphaComponent(0.5)
        
        public static let checkBorderColor = UIColor.white.withAlphaComponent(0.75)
    }
}

extension UIImage{
    public struct FLDefaults{
        public static var checkImg: UIImage?{
            get{
                if let path = Bundle(for: FLImagePicker.self).path(forResource: "done_white_24dp", ofType: "png"){
                    return UIImage(contentsOfFile: path)
                }
                return nil
            }
        }
    }
}
