//
//  CapturePhotoUtils.swift
//  Avatar
//
//  Created by GUO Lin on 2019/2/11.
//  Copyright © 2019 xiaobei. All rights reserved.
//

import UIKit

class CapturePhotoUtils {

  static var sharedInstance: CapturePhotoUtils {
    return CapturePhotoUtils()
  }

  func image(with view: UIView) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
    defer { UIGraphicsEndImageContext() }
    if let context = UIGraphicsGetCurrentContext() {
      view.layer.render(in: context)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      return image
    }
    return nil
  }

  func saveImageToPhotoAlbum() {
    
  }

}
