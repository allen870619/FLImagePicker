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

import Photos
import PureLayout
import UIKit

protocol FLImagePickerInterface: AnyObject {
    var style: FLImagePickerStyle? { get set }
    var numsOfRow: CGFloat { get set }
    var maxPick: Int { get set }
    var pixelPerMove: CGFloat { get set }
    var fps: CGFloat { get set }
    var detectionHeight: CGFloat { get set }
}

public class FLImagePicker: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, PHPhotoLibraryChangeObserver {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlow).configureForAutoLayout()
    private lazy var collectionViewFlow = UICollectionViewFlowLayout()
    private lazy var btnFinish = UIButton(type: .system)
    private lazy var btnCancel = UIButton(type: .system)

    // photoKit
    var assetResult: PHFetchResult<PHAsset> = PHFetchResult()
    let imgCacher = PHCachingImageManager()

    // link
//    var imagePicker: FLImagePicker!
    var imagePickerDelegate: FLImagePickerDelegate?
    var imagePickerStyle: FLImagePickerStyle = .init() {
        didSet {
            if isViewLoaded {
                for cell in collectionView.visibleCells {
                    if let cell = cell as? ImageCollectionViewCell {
                        setCellStyle(cell, style: imagePickerStyle)
                    }
                }

                // btn
                btnFinish.setTitleColor(imagePickerStyle.btnColor, for: .normal)
                btnCancel.setTitleColor(imagePickerStyle.btnColor, for: .normal)
            }
        }
    }

    // picker data
    private var numsOfRow: CGFloat = 3 // cells of row
    private var maxPick = 100
    private var fspd: CGFloat = 3 // step of pixel
    private var fps: CGFloat = 120 // refresh speed
    private var detectAreaHeight: CGFloat = 240
    var options = FLImagePickerOptions()

    /* calculate data, no need to change*/
    // pan
    var multiAction = true // reverse from start state
    var startIndexPath: IndexPath?
    var thisSelected: Set<IndexPath> = [] // record single action's cell
    var cvSelCount: Int {
        collectionView.indexPathsForSelectedItems?.count ?? 0
    }

    // auto Scroll
    var panY: CGFloat = 0
    var timer: Timer?

    // windows
    var safeAreaBottom: CGFloat = 0

    // feedback
    var lastSelect = 0
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    let generator = UIImpactFeedbackGenerator(style: .light)

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        initCustomView()

        uiInit()
        dataInit()
    }

    private func setupLayout() {
        [collectionView].forEach { view.addSubview($0) }

        collectionView.autoPinEdgesToSuperviewSafeArea(with: .init(), excludingEdge: .bottom)
        collectionView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func initCustomView() {
        collectionView.collectionViewLayout = collectionViewFlow
    }

    /* ui*/
    private func uiInit() {
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        btnFinish.frame = CGRect(x: 0, y: 0, width: 120, height: 36)
        btnFinish.setTitle(NSLocalizedString("done", comment: "done"), for: .normal)
        btnFinish.setTitleColor(imagePickerStyle.btnColor, for: .normal)
        btnFinish.contentHorizontalAlignment = .right
        btnFinish.addTarget(self, action: #selector(onFinish), for: .touchUpInside)
        let rightCustomView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 36))
        rightCustomView.addSubview(btnFinish)
        let right = UIBarButtonItem(customView: rightCustomView)
        navigationItem.rightBarButtonItem = right

        btnCancel.frame = CGRect(x: 0, y: 0, width: 120, height: 36)
        btnCancel.setTitle(NSLocalizedString("cancel", comment: "cancel"), for: .normal)
        btnCancel.setTitleColor(imagePickerStyle.btnColor, for: .normal)
        btnCancel.contentHorizontalAlignment = .left
        btnCancel.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        let leftCustomView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 36))
        leftCustomView.addSubview(btnCancel)
        let left = UIBarButtonItem(customView: leftCustomView)
        navigationItem.leftBarButtonItem = left

        // prevent drag to dismiss
        isModalInPresentation = true

        // cv setup - numsOfRow + 1
        var width = UIScreen.main.bounds.size.width
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = 704
        }
        let edge = (width - numsOfRow + 1) / numsOfRow
        collectionViewFlow.itemSize = CGSize(width: edge, height: edge)
        collectionViewFlow.minimumLineSpacing = 1
        collectionViewFlow.minimumInteritemSpacing = 1
        //        collectionViewFlow.prepare()  // <-- call prepare before invalidateLayout
        //        collectionViewFlow.invalidateLayout()

        // gesture
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true

        // pan
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panWhenScroll))
        panGesture.addTarget(self, action: #selector(cvPan))
        let ori = (collectionView.gestureRecognizers?.firstIndex(of: collectionView.panGestureRecognizer)) ?? 0
        collectionView.gestureRecognizers?.insert(panGesture, at: ori)

        // tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cvTap))
        collectionView.addGestureRecognizer(tapGesture)

        // long tap
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(cvLongPress))
        longTapGesture.delaysTouchesBegan = false
        collectionView.addGestureRecognizer(longTapGesture)
    }

    func setCellStyle(_ cell: ImageCollectionViewCell, style: FLImagePickerStyle?) {
        cell.coverColor = style?.coverColor
        cell.checkImage = style?.checkImage
        cell.checkBorderColor = style?.checkBorderColor
        cell.checkBackgroundColor = style?.checkBackgroundColor
    }

    // outlet
    @objc func onFinish(_: Any) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.imagePickerDelegate?.flImagePicker(self,
                                                    didFinished: self.getSelectedAssets())
//            self.imagePicker = nil
        }
    }

    @objc func onCancel(_: Any) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.imagePickerDelegate?.flImagePicker(didCancelled: self)
//            self.imagePicker = nil
        }
    }

    /* data*/
    func dataInit() {
        notificationFeedbackGenerator.prepare()

        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            safeAreaBottom = windowScene.windows.first?.safeAreaInsets.bottom ?? 0
        } else {
            safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        }

        // collection view
        collectionView.delegate = self
        collectionView.dataSource = self

        // register to observe any changes in photo library
        PHPhotoLibrary.shared().register(self)

        // album
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if !(status == .authorized || status == .limited) {
                    return
                }
                self.getFetch()
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                if status != .authorized {
                    return
                }
                self.getFetch()
            }
        }
    }

    func updateOptions(_ options: FLImagePickerOptions) {
        numsOfRow = options.numsOfRow
        maxPick = options.maxPick
        fspd = options.ppm
        fps = options.fps
        detectAreaHeight = options.detectAreaHeight
    }

    func getFetch() {
        // fetch assets
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        // get result
        assetResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        // reload
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func getSelectedAssets() -> [PHAsset] {
        var result: [PHAsset] = []
        if let items = collectionView.indexPathsForSelectedItems?.sorted(by: { $0.row < $1.row }) {
            for i in items {
                result.append(assetResult[i.row])
            }
        }
        return result
    }

    // set select item
    func setCellStatus(_ indexPath: IndexPath, status: Bool) {
        if status {
            if cvSelCount < maxPick {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        // update btn total
        let count = cvSelCount
        if count != lastSelect {
            generator.impactOccurred()
            lastSelect = count
        }
        var total = ""
        if count > 0 {
            total = "(\(count))"
        }
        btnFinish.setTitle("\(NSLocalizedString("done", comment: "done"))\(total)", for: .normal)
    }

    // auto scoll timer
    func autoRoll(isStop: Bool = false) {
        if isStop {
            timer?.invalidate()
            timer = nil
        } else {
            if timer != nil {
                return
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1 / fps, repeats: true) { [self] _ in

                if panY > collectionView.frame.maxY - detectAreaHeight { // go down
                    let spd = ((panY - collectionView.frame.maxY + detectAreaHeight) / detectAreaHeight * fspd)
                    if collectionView.frameLayoutGuide.layoutFrame.maxY - safeAreaBottom < collectionView.collectionViewLayout.collectionViewContentSize.height {
                        collectionView.scrollRectToVisible(CGRect(x: 0, y: collectionView.frameLayoutGuide.layoutFrame.maxY - safeAreaBottom, width: 1, height: spd), animated: false)
                    }

                } else if panY < collectionView.frame.minY + detectAreaHeight { // go up
                    let spd = ((collectionView.frame.minY + detectAreaHeight - panY) / detectAreaHeight * fspd)
                    collectionView.scrollRectToVisible(CGRect(x: 0, y: collectionView.frameLayoutGuide.layoutFrame.minY - spd, width: 1, height: spd), animated: false)
                }
            }
        }
    }

    /* objc*/
    // pan func
    @objc func cvPan(pan: UIPanGestureRecognizer) {
        guard let curIndexPath = collectionView.indexPathForItem(at: pan.location(in: collectionView)) else {
            return
        }

        // init and deinit
        if pan.state == .began {
            // if true, then action will be false
            multiAction = !collectionView.cellForItem(at: curIndexPath)!.isSelected

            // self initial
            startIndexPath = curIndexPath
        } else if pan.state == .ended {
            startIndexPath = nil
            thisSelected.removeAll()
        }

        if let startIndexPath = startIndexPath {
            // check need to clear beyond or under indexPath
            var isCross = false
            for i in thisSelected {
                if (curIndexPath.row < startIndexPath.row && i.row > startIndexPath.row) ||
                    (curIndexPath.row > startIndexPath.row && i.row < startIndexPath.row)
                {
                    isCross = true
                    break
                }
            }
            if isCross {
                for i in thisSelected {
                    if i != startIndexPath {
                        setCellStatus(i, status: !multiAction)
                        thisSelected.remove(i)
                    }
                }
            }

            // start pan
            var hasNew = false
            // go down
            if curIndexPath.row >= startIndexPath.row { // down
                for cell in collectionView.visibleCells.sorted(by: {
                    collectionView.indexPath(for: $0)?.row ?? 0 < collectionView.indexPath(for: $1)?.row ?? 1
                }) {
                    if let tIndexPath = collectionView.indexPath(for: cell) {
                        // pan back reset to origin
                        if tIndexPath.row > curIndexPath.row, thisSelected.contains(tIndexPath) {
                            setCellStatus(tIndexPath, status: !multiAction)
                            thisSelected.remove(tIndexPath)
                            hasNew = true
                        }

                        // pan new
                        if tIndexPath.row >= startIndexPath.row, tIndexPath.row <= curIndexPath.row {
                            if cell.isSelected != multiAction, !thisSelected.contains(tIndexPath) {
                                setCellStatus(tIndexPath, status: multiAction)
                                thisSelected.insert(tIndexPath)
                                hasNew = true
                            }
                        }
                    }
                }
            }

            // up
            if curIndexPath.row <= startIndexPath.row {
                for cell in collectionView.visibleCells.sorted(by: {
                    collectionView.indexPath(for: $0)?.row ?? 1 > collectionView.indexPath(for: $1)?.row ?? 0
                }) {
                    if let tIndexPath = collectionView.indexPath(for: cell) {
                        // pan back reset to origin
                        if tIndexPath.row < curIndexPath.row, thisSelected.contains(tIndexPath) {
                            setCellStatus(tIndexPath, status: !multiAction)
                            thisSelected.remove(tIndexPath)
                            hasNew = true
                        }

                        // pan new
                        if tIndexPath.row <= startIndexPath.row, tIndexPath.row >= curIndexPath.row {
                            if cell.isSelected != multiAction, !thisSelected.contains(tIndexPath) {
                                setCellStatus(tIndexPath, status: multiAction)
                                thisSelected.insert(tIndexPath)
                                hasNew = true
                            }
                        }
                    }
                }
            }

            // notify delegate if selected cell has change
            if hasNew, timer != nil || cvSelCount < maxPick {
                var selAssets: [PHAsset] = []
                if let items = collectionView.indexPathsForSelectedItems {
                    for i in items.sorted(by: { $0.row < $1.row }) {
                        selAssets.append(assetResult[i.row])
                    }
                }
                imagePickerDelegate?.flImagePicker(self, multiAssetsChanged: selAssets, isSelected: multiAction)
            }
        }
    }

    @objc func cvTap(_ gesture: UITapGestureRecognizer) {
        if let curIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) {
            if let cell = collectionView.cellForItem(at: curIndexPath) {
                if !(cvSelCount >= maxPick && !cell.isSelected) {
                    setCellStatus(curIndexPath, status: !cell.isSelected)
                    if let data = (cell as! ImageCollectionViewCell).imageAsset {
                        imagePickerDelegate?.flImagePicker(self, singleAssetChanged: data, isSelected: cell.isSelected)
                    }
                    generator.impactOccurred()
                }
            }
        }
    }

    @objc func cvLongPress(_: UILongPressGestureRecognizer) {
        // TODO: photo Preview
        print("\(#function)")
    }

    @objc func panWhenScroll(pan: UIPanGestureRecognizer) {
        let overPick = cvSelCount >= maxPick && multiAction
        panY = pan.location(in: view).y

        if timer == nil {
            if !overPick {
                autoRoll()
            }
        } else {
            if overPick {
                notificationFeedbackGenerator.notificationOccurred(.warning)
                autoRoll(isStop: true)
                imagePickerDelegate?.flImagePicker(self, reachMaxSelected: getSelectedAssets())
            } else if pan.state == .ended {
                autoRoll(isStop: true)
            }
        }
    }

    /* collection delegate*/
    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        assetResult.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = assetResult[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell

        // set default style
        setCellStyle(cell, style: imagePickerStyle)

        // set data
        cell.imageAsset = asset
        cell.isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false
        return cell
    }

    // MARK: - PHPhotoLibraryChangeObserver

    public func photoLibraryDidChange(_: PHChange) {
        getFetch()
    }
}
