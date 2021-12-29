[![Version](https://img.shields.io/cocoapods/v/FLImagePicker.svg?style=flat)](http://cocoapods.org/pods/FLImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/FLImagePicker.svg?style=flat)](http://cocoapods.org/pods/FLImagePicker)
[![License](https://img.shields.io/github/license/allen870619/FLImagePicker?style=flat)](http://cocoapods.org/pods/FLImagePicker)
[![Date](https://img.shields.io/github/last-commit/allen870619/FLImagePicker?style=flat)](http://cocoapods.org/pods/FLImagePicker)
# FLImagePicker
> A simple image picker supported multiple selection.

![demo](https://user-images.githubusercontent.com/32888552/147620894-f3dbce30-2b8a-47d3-bbac-9acf98f9b67e.gif)

## Features
* Multiple selection
* Gesture supported
* Dark mode
* Easy modification

## Installation

**CocoaPods**

```
pod 'FLImagePicker'
```

## Usage

Basic Usage
```
let picker = FLImagePicker()
picker.imageDelegation = self
present(vc, animated: true, completion: nil)
```

You have to implement **FLImagePickerDelegate** to your viewController.

## Delegation
```
/* triggered by tap */
func flImagePicker(_ picker: FLImagePicker, singleAssetChanged imageAsset: PHAsset, isSelected: Bool)

/* triggered when pan over images, imageAssets show current selected items.*/    
func flImagePicker(_ picker: FLImagePicker, multiAssetsChanged imageAssets: [PHAsset], isSelected: Bool)

/* triggered when reach the maximum of the selection, imageAssets show current selected items.*/
func flImagePicker(_ picker: FLImagePicker, reachMaxSelected imageAssets: [PHAsset])

/* required at implement, call by finish pressed */
func flImagePicker(_ picker: FLImagePicker, didFinished imageAssets: [PHAsset])

/* call by cancel pressed*/
func flImagePicker(didCancelled picker: FLImagePicker)
```

## Get Images
The results of picker are PHAsset format, you can use `PHImageManager` to get UIImage.

You can read [this](https://developer.apple.com/documentation/photokit/phimagemanager#1656241)
and [this](https://developer.apple.com/documentation/photokit/phimagemanager/1616964-requestimage) for more Info.

```
PHImageManager().requestImage(for: PHAsset(),
                                targetSize: PHImageManagerMaximumSize,
                                contentMode: .default,
                                options: nil){ (image, info) in
                                    // ...
                                    // deal with image
                                    // ...
                                }
```

## Options
Settings of FLImagePicker
```
// images
vc.maxPick = 10 // max selection
vc.numsOfRow = 3 // nums of images in each row

// scrolling
/// The max scrolling speed will be fps * ppm
/// ex. If ppm = 3, fps = 120
/// while reaching to max speed, it will be 3 * 120 = 360(pixel/sec)
vc.fps = 120 // update freq. of scrolling (times/ sec)
vc.ppm = 3 // pixels per move. 

// gesture
/// detectAreaHeight will are start from top and bottom.
/// -------------  
/// |     ^     |
/// |     |     |
/// |    200    |
/// |     |     |
/// |     ⌄     |
/// -------------
/// |           |  <- your phone
/// |           |
/// -------------
/// |     ^     |
/// |     |     |
/// |    200    |
/// |     |     |
/// |     ⌄     |
/// -------------
vc.detectAreaHeight = 200 // gesture detection range
```

## Styles
```
// default, create FLImagePickerStyle and set vc'style to it.
var style = FLImagePickerStyle()

/* use FLDefaults to get default value */
// nav btn
style.btnColor = FLDefaults.Colors.primary

// selected cover
style.coverColor = FLDefaults.Colors.coverBackground

// check hinter
style.checkImage = FLDefaults.Images.checkImg
style.checkBorderColor = FLDefaults.Colors.checkBorderColor
style.checkBackgroundColor = FLDefaults.Colors.primary


vc.style = style
```

Add `done` and `cancel` to your Localizable.strings for Nav Btn Localization.

## Knowing Issue
* Multi-selection won't be trigger if finger stop moving while scrolling (need to shake a little bit.)

## Next feature
* Photo preview

## Author
[Allen Lee](https://github.com/allen870619)

## License
This project is under [MIT License](https://github.com/allen870619/FLImagePicker/blob/master/LICENSE).

