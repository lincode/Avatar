//
//  CapturedPhotoViewController.swift
//  Avatar
//
//  Created by GUO Lin on 2019/2/13.
//  Copyright © 2019 xiaobei. All rights reserved.
//

import UIKit

class CapturedPhotoViewController: UIViewController {

  @IBOutlet var imageView: UIImageView?
  @IBOutlet var backButton: UIButton!
  @IBOutlet var shareButton: UIButton!
  @IBOutlet var downloadButton: UIButton!

  var image: UIImage?

  override func viewDidLoad() {
    super.viewDidLoad()

    if let image = image {
      let width = image.size.width
      imageView?.frame.size = CGSize(width: width, height: width)
      imageView?.image = image

    }

    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    downloadButton.addTarget(self, action: #selector(download), for: .touchUpInside)
    shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
  }

  //MARK: - Actions
  @objc
  func back() {
    dismiss(animated: false, completion: nil)
  }

  @objc
  func download() {
    if let image = image {
      UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
  }

  @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      let ac = UIAlertController(title: "下载失败!", message: error.localizedDescription, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
      present(ac, animated: true)
    } else {
      let originalY = self.downloadButton.frame.origin.y
      UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut,
                     animations: {
                      self.downloadButton.frame.origin.y = originalY + 40
                     },
                     completion: { finished in
                       if finished {
                         self.downloadButton.imageView?.image = UIImage(named: "confirm")
                         DispatchQueue.main.asyncAfter(deadline: (.now() + 0.5), execute: {
                           self.dismiss(animated: false, completion: nil)
                         })
                      }
                     })
    }
  }

  @objc
  func share() {
    if let image = image {
      let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
      activityViewController.excludedActivityTypes = [.addToReadingList, .openInIBooks, .print, .mail, .copyToPasteboard, .assignToContact, .airDrop, .markupAsPDF]
      self.present(activityViewController, animated: true, completion: nil)
    }
  }



}
