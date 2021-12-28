//
//  ViewController.swift
//  FLImagePickerDemo
//
//  Created by Lee Yen Lin on 2021/12/24.
//

import UIKit
import FLImagePicker
import Photos

class ViewController: UIViewController, FLImagePickerDelegate {
    // delegate
    func flImagePicker(didCancelled picker: FLImagePicker) {
        print("cancel")
    }
    
    func flImagePicker(_ picker: FLImagePicker, didFinished imageAssets: [PHAsset]) {
        print(imageAssets)
    }
    
    func flImagePicker(_ picker: FLImagePicker, singleAssetChanged imageAsset: PHAsset, isSelected: Bool) {
        print("\(#function) \(imageAsset) \(isSelected)")
    }
    
    func flImagePicker(_ picker: FLImagePicker, multiAssetsChanged imageAssets: [PHAsset], isSelected: Bool) {
        print("\(#function) \(imageAssets.count) \(isSelected)")
    }
    
    // demo
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 36))
        btn.setTitle("picker", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
        btn.center = view.center
        view.addSubview(btn)
    }
    
    @objc func btnPressed(_ sender: Any){
        let vc = FLImagePicker()
        vc.imageDelegate = self
        
        //  style
//        var style = FLImagePickerStyle()
//        style.checkImage = UIImage(named: "test")
//        style.checkBorderColor = .red
//        style.checkBackgroundColor = .brown
//        style.btnColor = .green
//        style.coverColor = .green
//        vc.style = style
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(3)){
//            style.checkImage = .FLDefaults.checkImg
//            style.checkBorderColor = .FLDefaults.checkBorderColor
//            style.checkBackgroundColor = .FLDefaults.primary
//            style.btnColor = .FLDefaults.primary
//            style.coverColor = .FLDefaults.coverBackground
//            vc.style = style
//        }
        
        // optional settings
//        vc.maxPick = 10
//        vc.fps = 120
//        vc.detectAreaHeight = 200
//        vc.numsOfRow = 3
//        vc.ppm = 3
        self.present(vc, animated: true, completion: nil)
    }
}
