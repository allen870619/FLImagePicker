# FLImagePicker
> A simple image picker supported multiple selection.

## Features
* Multiple selection
* Gesture supported
* Dark mode
* Easy modified

## Installation

**CocoaPods**

```
pod 'FLImagePicker'
```

**Swift Package**

Coming soon.

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

/* require at implement, call by pressing finish */
func flImagePicker(_ picker: FLImagePicker, didFinished imageAssets: [PHAsset])

/* call by pressing cancel */
func flImagePicker(didCancelled picker: FLImagePicker)
```

## Options
Settings of FLImagePicker
```
// images
vc.maxPick = 10 // max of selection
vc.numsOfRow = 3 // rows of images

// scrolling
/// The max scrolling speed will be fps*ppm
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

// nav btn
style.btnColor = .FLDefaults.primary

// selected cover
style.coverColor = .FLDefaults.coverBackground

// check hinter
style.checkImage = .FLDefaults.checkImg
style.checkBorderColor = .FLDefaults.checkBorderColor
style.checkBackgroundColor = .FLDefaults.primary


vc.style = style
```

Add `done` and `cancel` to your Localizable.strings for Nav Btn Localization.

## Knowing Issue
* Multi-selection won't be trigger if finger stop moving while scrolling (need to shake a little bit.)

## Next feature
* Photo preview

## License
This project is under [MIT License](https://github.com/allen870619/FLImagePicker/blob/master/LICENSE).
