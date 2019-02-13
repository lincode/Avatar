//
//  CapturePhotoUtils.swift
//  Avatar
//
//  Created by GUO Lin on 2019/2/11.
//  Copyright © 2019 xiaobei. All rights reserved.
//

import UIKit

class CapturePhotoUtils: NSObject {

  static var sharedInstance: CapturePhotoUtils {
    return CapturePhotoUtils()
  }

  func image(with view: UIView) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }

  func saveImageToPhotoAlbum(image: UIImage) {
  }

  func topViewController() -> UIViewController? {
    if var topViewController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topViewController.presentedViewController {
        topViewController = presentedViewController
      }
      return topViewController
    }
    return nil
  }

}
