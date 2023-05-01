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

public struct FLImagePickerStyle {
    /* cell style*/
    /// check hinter
    public var checkBorderColor: UIColor? = FLDefaults.Colors.checkBorderColor
    public var checkBackgroundColor: UIColor? = FLDefaults.Colors.primary
    public var checkImage: UIImage? = FLDefaults.Images.checkImg

    // cover
    public var coverColor: UIColor? = FLDefaults.Colors.coverBackground

    /* button*/
    public var btnColor: UIColor? = FLDefaults.Colors.primary

    public init() {}
}

public enum FLDefaults {
    private static var bundle: Bundle {
        #if !SWIFT_PACKAGE
            return Bundle(for: FLImagePicker.self)
        #else
            return Bundle.module
        #endif
    }

    /* colors*/
    public enum Colors {
        public static var primary: UIColor {
            if let color = UIColor(named: "AccentColor") {
                return color
            } else {
                return .link
            }
        }

        // cell
        public static let coverBackground = UIColor(named: "selectedCover", in: bundle, compatibleWith: nil)?.withAlphaComponent(0.5)

        public static let checkBorderColor = UIColor.white.withAlphaComponent(0.75)
    }

    /* images*/
    public enum Images {
        public static var checkImg: UIImage? {
            if let img = UIImage(named: "done_white_24dp", in: bundle, compatibleWith: .current) {
                return img
            }
            return nil
        }
    }
}
