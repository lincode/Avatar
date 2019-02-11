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
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
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

  @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
    let topViewController = self.topViewController()
    if let error = error {
      // we got back an error!
      let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
      topViewController?.present(ac, animated: true)
    } else {
      let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
      topViewController?.present(ac, animated: true)
    }
  }

}
