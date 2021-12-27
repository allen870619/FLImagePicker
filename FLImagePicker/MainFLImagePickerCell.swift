//
//  MainFLImagePickerCell.swift
//  FLImagePicker
//
//  Created by Lee Yen Lin on 2021/12/23.
//

import UIKit
import Photos

class MainFLImagePickerCell: UICollectionViewCell {
    @IBOutlet weak var cover: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var checkHinter: UIView!
    @IBOutlet weak var imgChecked: UIImageView!
    
    let selectedColor = UIColor.init(red: 51/255, green: 120/255, blue: 246/255, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imagePath = Bundle(for: MainFLImagePickerCell.self).path(forResource: "done_white_24dp", ofType: "png")
        if let imagePath = imagePath {
            imgChecked.image = UIImage(contentsOfFile: imagePath)
        }
    }
    
    var imgAsset: PHAsset?{
        didSet{
            if let imgAsset = imgAsset {
                PHCachingImageManager().requestImage(for: imgAsset,
                                                        targetSize: CGSize(width: 400, height: 400),
                                                        contentMode: .aspectFit,
                                                        options: .none){[self] (image, info) in
                    photoImageView.image = image
                    photoImageView.contentMode = .scaleAspectFill
                }
            }
        }
    }
    
    func setSelected(isSelect: Bool){
        cover.isHidden = !isSelect
        imgChecked.isHidden = !isSelect
        if isSelect{
            checkHinter.backgroundColor = selectedColor
        }else{
            checkHinter.backgroundColor = .clear
        }
        checkHinter.layer.borderColor = UIColor.white.withAlphaComponent(0.75).cgColor
    }
    
    override var isSelected: Bool{
        didSet{
            cover.isHidden = !isSelected
            imgChecked.isHidden = !isSelected
            if isSelected{
                checkHinter.backgroundColor = selectedColor
                
            }else{
                checkHinter.backgroundColor = .clear
            }
        }
    }
}
