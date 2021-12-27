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
    func didFinished(_ imageAssets: [PHAsset]) {
        print(imageAssets)
    }
    
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
        
//        // style
//        var style = FLImagePickerStyle()
//        style.checkBorderColor = .red
//        style.checkBackgroundColor = .orange
//        style.imgChecked = UIImage(named: "test")
//        style.checkBorderColor = nil
//        vc.style = style
//        
//        // optional settings
//        vc.maxPick = 100
//        vc.fps = 120
//        vc.detectAreaHeight = 240
//        vc.numsOfRow = 3
//        vc.ppm = 5
        self.present(vc, animated: true, completion: nil)
    }
}
