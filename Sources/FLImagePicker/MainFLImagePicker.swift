//
//  MainFLImagePicker.swift
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

internal class MainFLImagePicker: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet weak var mainCV: UICollectionView!
    @IBOutlet weak var cvFlow: UICollectionViewFlowLayout!
    var btnFinish: UIButton!
    var btnCancel: UIButton!
    
    // photoKit
    var assetResult: PHFetchResult<PHAsset> = PHFetchResult()
    let imgCacher = PHCachingImageManager()
    
    // link
    var imagePicker: FLImagePicker!
    var imagePickerDelegate: FLImagePickerDelegate?
    var imagePickerStyle: FLImagePickerStyle?{
        didSet{
            if isViewLoaded{
                for cell in mainCV.visibleCells{
                    if let cell = cell as? MainFLImagePickerCell{
                        setCellStyle(cell, style: imagePickerStyle)
                    }
                }
                
                // btn
                btnFinish.setTitleColor(imagePickerStyle?.btnColor ?? .link, for: .normal)
                btnCancel.setTitleColor(imagePickerStyle?.btnColor ?? .link, for: .normal)
            }
        }
    }
    
    // picker data
    private var numsOfRow: CGFloat = 3 // cells of row
    private var maxPick = 100
    private var fspd: CGFloat = 3 // step of pixel
    private var fps: CGFloat = 120 // update speed
    private var detectAreaHeight: CGFloat = 240
    
    /* calculate data, no need to change*/
    // pan
    var multiAction = true // reverse from start state
    var startIndexPath : IndexPath?
    var thisSelected: Set<IndexPath> = [] // record single action's cell
    var cvSelCount: Int{
        get{
            return mainCV.indexPathsForSelectedItems?.count ?? 0
        }
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
    
    /* initialize*/
    init(){
        #if !SPM
        super.init(nibName: "MainFLImagePicker", bundle: Bundle(for: MainFLImagePicker.self))
        #else
        super.init(nibName: "MainFLImagePicker", bundle: .module)
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiInit()
        dataInit()
    }
    
    /* ui*/
    func uiInit(){
        var uib: UINib!
        #if !SPM
        uib = UINib(nibName: "MainFLImagePickerCell", bundle: Bundle(for: MainFLImagePickerCell.self))
        #else
        uib = UINib(nibName: "MainFLImagePickerCell", bundle: .module)
        #endif
        mainCV.register(uib, forCellWithReuseIdentifier: "FLImgCell")
        
        btnFinish = UIButton(type: .system)
        btnFinish.frame = CGRect(x: 0, y: 0, width: 120, height: 36)
        btnFinish.setTitle(NSLocalizedString("done", comment: "done"), for: .normal)
        btnFinish.setTitleColor(imagePickerStyle?.btnColor, for: .normal)
        btnFinish.contentHorizontalAlignment = .right
        btnFinish.addTarget(self, action: #selector(onFinish), for: .touchUpInside)
        let rightCustomView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 36))
        rightCustomView.addSubview(btnFinish)
        let right = UIBarButtonItem(customView: rightCustomView)
        navigationItem.rightBarButtonItem = right
        
        btnCancel = UIButton(type: .system)
        btnCancel.frame = CGRect(x: 0, y: 0, width: 120, height: 36)
        btnCancel.setTitle(NSLocalizedString("cancel", comment: "cancel"), for: .normal)
        btnCancel.setTitleColor(imagePickerStyle?.btnColor, for: .normal)
        btnCancel.contentHorizontalAlignment = .left
        btnCancel.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        let leftCustomView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 36))
        leftCustomView.addSubview(btnCancel)
        let left = UIBarButtonItem(customView: leftCustomView)
        navigationItem.leftBarButtonItem = left
        
        // prevent drag to dismiss
        isModalInPresentation = true
        
        // cv setup - numsOfRow + 1
        let edge = (UIScreen.main.bounds.width - numsOfRow + 1) / numsOfRow
        cvFlow.itemSize = CGSize(width: edge, height: edge)
        cvFlow.minimumLineSpacing = 1
        cvFlow.minimumInteritemSpacing = 1
        //        cvFlow.prepare()  // <-- call prepare before invalidateLayout
        //        cvFlow.invalidateLayout()
        
        // gesture
        mainCV.allowsMultipleSelection = true
        mainCV.allowsSelection = true
        
        // pan
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panWhenScroll))
        panGesture.addTarget(self, action: #selector(cvPan))
        let ori = (mainCV.gestureRecognizers?.firstIndex(of: mainCV.panGestureRecognizer)) ?? 0
        mainCV.gestureRecognizers?.insert(panGesture, at: ori)
        
        // tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cvTap))
        mainCV.addGestureRecognizer(tapGesture)
        
        // long tap
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(cvLongPress))
        longTapGesture.delaysTouchesBegan = false
        mainCV.addGestureRecognizer(longTapGesture)
    }
    
    func setCellStyle(_ cell: MainFLImagePickerCell, style: FLImagePickerStyle?){
        cell.coverColor = style?.coverColor
        cell.checkImage = style?.checkImage
        cell.checkBorderColor = style?.checkBorderColor
        cell.checkBackgroundColor = style?.checkBackgroundColor
    }
    
    // outlet
    @objc func onFinish(_ sender: Any) {
        dismiss(animated: true){[self] in
            imagePickerDelegate?.flImagePicker(imagePicker, didFinished: getSelectedAssets())
            imagePicker = nil
        }
    }
    
    @objc func onCancel(_ sender: Any) {
        dismiss(animated: true){[self] in
            imagePickerDelegate?.flImagePicker(didCancelled: imagePicker)
            imagePicker = nil
        }
    }
    
    /* data*/
    func dataInit(){
        notificationFeedbackGenerator.prepare()
        
        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            safeAreaBottom = windowScene.windows.first?.safeAreaInsets.bottom ?? 0
        } else {
            safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        }
        
        // collection view
        mainCV.delegate = self
        mainCV.dataSource = self
        
        // album
        if #available(iOS 14, *){
            PHPhotoLibrary.requestAuthorization(for: .readWrite){status in
                if status != .authorized{
                    return
                }
                self.getFetch()
            }
        }else{
            PHPhotoLibrary.requestAuthorization(){status in
                if status != .authorized{
                    return
                }
                self.getFetch()
            }
        }
    }
    
    func updateOptions(_ options: FLImagePickerOptions){
        numsOfRow = options.numsOfRow
        maxPick = options.maxPick
        fspd = options.ppm
        fps = options.fps
        detectAreaHeight = options.detectAreaHeight
    }
    
    func getFetch(){
        // fetch assets
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // get result
        assetResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // reload
        DispatchQueue.main.async {
            self.mainCV.reloadData()
        }
    }
    
    func getSelectedAssets() -> [PHAsset]{
        var result: [PHAsset] = []
        if let items = mainCV.indexPathsForSelectedItems?.sorted(by: {$0.row < $1.row}){
            for i in items{
                result.append(assetResult[i.row])
            }
        }
        return result
    }
    
    // set select item
    func setCellStatus(_ indexPath: IndexPath, status: Bool){
        if status{
            if cvSelCount < maxPick{
                mainCV.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        }else{
            mainCV.deselectItem(at: indexPath, animated: true)
        }
        
        // update btn total
        let count = cvSelCount
        if count != lastSelect{
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
    func autoRoll(isStop: Bool = false){
        if isStop{
            timer?.invalidate()
            timer = nil
        }else{
            if timer != nil{
                return
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1 / fps, repeats: true){[self] _ in
                
                if panY > mainCV.frame.maxY - detectAreaHeight{ // go down
                    let spd = ((panY - mainCV.frame.maxY + detectAreaHeight) / detectAreaHeight * fspd)
                    if mainCV.frameLayoutGuide.layoutFrame.maxY - safeAreaBottom < mainCV.collectionViewLayout.collectionViewContentSize.height{
                        mainCV.scrollRectToVisible(CGRect(x: 0, y: mainCV.frameLayoutGuide.layoutFrame.maxY - safeAreaBottom, width: 1, height: spd), animated: false)
                    }
                    
                }else if panY < mainCV.frame.minY + detectAreaHeight{ // go up
                    let spd = ((mainCV.frame.minY + detectAreaHeight - panY) / detectAreaHeight * fspd)
                    mainCV.scrollRectToVisible(CGRect(x: 0, y: mainCV.frameLayoutGuide.layoutFrame.minY - spd, width: 1, height: spd), animated: false)
                }
            }
        }
    }
    
    /* objc*/
    // pan func
    @objc func cvPan(pan: UIPanGestureRecognizer){
        guard let curIndexPath = mainCV.indexPathForItem(at: pan.location(in: mainCV)) else{
            return
        }
        
        // init and deinit
        if pan.state == .began{
            // if true, then action will be false
            multiAction = !mainCV.cellForItem(at: curIndexPath)!.isSelected
            
            // self initial
            startIndexPath = curIndexPath
        }else if pan.state == .ended{
            startIndexPath = nil
            thisSelected.removeAll()
        }
        
        if let startIndexPath = startIndexPath {
            // check need to clear beyond or under indexPath
            var isCross = false
            for i in thisSelected{
                if (curIndexPath.row < startIndexPath.row && i.row > startIndexPath.row) ||
                    (curIndexPath.row > startIndexPath.row && i.row < startIndexPath.row) {
                    isCross = true
                    break
                }
            }
            if isCross{
                for i in thisSelected{
                    if i != startIndexPath{
                        setCellStatus(i, status: !multiAction)
                        thisSelected.remove(i)
                    }
                }
            }
            
            // start pan
            var hasNew = false
            // go down
            if curIndexPath.row >= startIndexPath.row{ // down
                for cell in mainCV.visibleCells.sorted(by: {
                    return mainCV.indexPath(for: $0)?.row ?? 0 < mainCV.indexPath(for: $1)?.row ?? 1
                }){
                    if let tIndexPath = mainCV.indexPath(for: cell){
                        // pan back reset to origin
                        if tIndexPath.row > curIndexPath.row && thisSelected.contains(tIndexPath){
                            setCellStatus(tIndexPath, status: !multiAction)
                            thisSelected.remove(tIndexPath)
                            hasNew = true
                        }
                        
                        // pan new
                        if tIndexPath.row >= startIndexPath.row && tIndexPath.row <= curIndexPath.row {
                            if cell.isSelected != multiAction  && !thisSelected.contains(tIndexPath){
                                setCellStatus(tIndexPath, status: multiAction)
                                thisSelected.insert(tIndexPath)
                                hasNew = true
                            }
                        }
                    }
                }
            }
            
            // up
            if curIndexPath.row <= startIndexPath.row{
                for cell in mainCV.visibleCells.sorted(by: {
                    mainCV.indexPath(for: $0)?.row ?? 1 > mainCV.indexPath(for: $1)?.row ?? 0
                }){
                    if let tIndexPath = mainCV.indexPath(for: cell){
                        // pan back reset to origin
                        if tIndexPath.row < curIndexPath.row && thisSelected.contains(tIndexPath){
                            setCellStatus(tIndexPath, status: !multiAction)
                            thisSelected.remove(tIndexPath)
                            hasNew = true
                        }
                        
                        // pan new
                        if tIndexPath.row <= startIndexPath.row && tIndexPath.row >= curIndexPath.row{
                            if cell.isSelected != multiAction && !thisSelected.contains(tIndexPath){
                                setCellStatus(tIndexPath, status: multiAction)
                                thisSelected.insert(tIndexPath)
                                hasNew = true
                            }
                        }
                    }
                }
            }
            
            // notify delegate if selected cell has change
            if hasNew && (timer != nil || cvSelCount < maxPick){
                var selAssets: [PHAsset] = []
                if let items = mainCV.indexPathsForSelectedItems{
                    for i in items.sorted(by: {$0.row < $1.row}){
                        selAssets.append(assetResult[i.row])
                    }
                }
                imagePickerDelegate?.flImagePicker(imagePicker, multiAssetsChanged: selAssets, isSelected: multiAction)
            }
        }
    }
    
    @objc func cvTap(_ gesture: UITapGestureRecognizer){
        if let curIndexPath = mainCV.indexPathForItem(at: gesture.location(in: mainCV)) {
            if let cell = mainCV.cellForItem(at: curIndexPath){
                if !(cvSelCount >= maxPick && !cell.isSelected){
                    setCellStatus(curIndexPath, status: !cell.isSelected)
                    if let data = (cell as! MainFLImagePickerCell).imgAsset{
                        imagePickerDelegate?.flImagePicker(imagePicker, singleAssetChanged: data, isSelected: cell.isSelected)
                    }
                    generator.impactOccurred()
                }
            }
        }
    }
    
    @objc func cvLongPress(_ gesture: UILongPressGestureRecognizer){
        // TODO: photo Preview
        print("\(#function)")
    }
    
    @objc func panWhenScroll(pan: UIPanGestureRecognizer){
        let overPick = cvSelCount >= maxPick && multiAction
        panY = pan.location(in: view).y
        
        if timer == nil{
            if !overPick{
                autoRoll()
            }
        }else{
            if overPick{
                notificationFeedbackGenerator.notificationOccurred(.warning)
                autoRoll(isStop: true)
                imagePickerDelegate?.flImagePicker(imagePicker, reachMaxSelected: getSelectedAssets())
            }else if pan.state == .ended{
                autoRoll(isStop: true)
            }
        }
    }
    
    /* collection delegate*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assetResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = assetResult[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FLImgCell", for: indexPath) as! MainFLImagePickerCell
        
        // set default style
        setCellStyle(cell, style: imagePickerStyle)
        
        // set data
        cell.imgAsset = asset
        cell.isSelected = mainCV.indexPathsForSelectedItems?.contains(indexPath) ?? false
        return cell
    }
}
