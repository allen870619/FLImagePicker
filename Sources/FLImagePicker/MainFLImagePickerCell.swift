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

import Photos
import PureLayout
import UIKit

class MainFLImagePickerCell: UICollectionViewCell {
    private let imageResSize: CGFloat = 400
    private let checkHinterHeight: CGFloat = 20

    private lazy var cover = UIView(forAutoLayout: ())
    private lazy var photoImageView = UIImageView(forAutoLayout: ())
    private lazy var checkHinter = UIView(forAutoLayout: ())
    private lazy var imgChecked = UIImageView(forAutoLayout: ())

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        setupLayout()
        initCustomView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        [photoImageView, cover, checkHinter].forEach { contentView.addSubview($0) }
        [imgChecked].forEach { checkHinter.addSubview($0) }

        cover.autoPinEdgesToSuperviewEdges()
        photoImageView.autoPinEdgesToSuperviewEdges()
        checkHinter.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        checkHinter.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        checkHinter.autoSetDimension(.width, toSize: checkHinterHeight)
        checkHinter.autoConstrainAttribute(.width, to: .height, of: checkHinter)

        imgChecked.autoPinEdgesToSuperviewEdges(with: .init(top: 4, left: 4, bottom: 4, right: 4))
    }

    private func initCustomView() {
        checkHinter.layer.cornerRadius = checkHinterHeight / 2
        checkHinter.layer.borderWidth = 2
        checkHinter.backgroundColor = .systemBackground
    }

    /* checked border*/
    var checkBackgroundColor: UIColor? {
        willSet {
            checkHinter.backgroundColor = isSelected ? newValue : .clear
        }
    }

    var checkBorderColor: UIColor? {
        willSet {
            checkHinter.layer.borderColor = newValue?.cgColor
        }
    }

    var checkImage: UIImage? {
        willSet {
            imgChecked.image = newValue
        }
    }

    var coverColor: UIColor? {
        willSet {
            cover.backgroundColor = newValue
        }
    }

    /* set photo*/
    var imageAsset: PHAsset? {
        didSet {
            guard let imageAsset = imageAsset else { return }

            requireImage(from: imageAsset) { [weak self] image, _ in
                self?.photoImageView.image = image
            }
        }
    }

    private func requireImage(from imageAsset: PHAsset, completion: @escaping (UIImage?, [AnyHashable: Any]?) -> Void) {
        let desireSize = CGSize(width: imageResSize, height: imageResSize)
        PHCachingImageManager().requestImage(for: imageAsset,
                                             targetSize: desireSize,
                                             contentMode: .aspectFit,
                                             options: .none,
                                             resultHandler: completion)
    }

    /* selected*/
    override var isSelected: Bool {
        didSet {
            cover.isHidden = !isSelected
            imgChecked.isHidden = !isSelected
            checkHinter.backgroundColor = isSelected ? checkBackgroundColor : .clear
        }
    }
}
