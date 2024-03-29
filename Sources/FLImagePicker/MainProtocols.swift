//
//  MainProtocols.swift
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

import Photos

/* protocols*/
public protocol FLImagePickerDelegate {
    func flImagePicker(_ picker: FLImagePicker, singleAssetChanged imageAsset: PHAsset, isSelected: Bool)

    func flImagePicker(_ picker: FLImagePicker, multiAssetsChanged imageAssets: [PHAsset], isSelected: Bool)

    func flImagePicker(_ picker: FLImagePicker, reachMaxSelected imageAssets: [PHAsset])

    func flImagePicker(_ picker: FLImagePicker, didFinished imageAssets: [PHAsset])

    func flImagePicker(didCancelled picker: FLImagePicker)
}

public extension FLImagePickerDelegate {
    func flImagePicker(_: FLImagePicker, singleAssetChanged _: PHAsset, isSelected _: Bool) {}

    func flImagePicker(_: FLImagePicker, multiAssetsChanged _: [PHAsset], isSelected _: Bool) {}

    func flImagePicker(_: FLImagePicker, reachMaxSelected _: [PHAsset]) {}

    func flImagePicker(didCancelled _: FLImagePicker) {}
}
