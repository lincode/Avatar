//
//  CaptureViewController.swift
//  Avatar
//
//  Created by GUO Lin on 2019/2/11.
//  Copyright © 2019 xiaobei. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import KYShutterButton
import AKPickerView
import SceneKitVideoRecorder
import Photos

class CaptureViewController: UIViewController {

  @IBOutlet var selfieSceneView: ARSCNView!
  @IBOutlet var avatarSceneView: ARSCNView!

  @IBOutlet var captureButton: KYShutterButton!

  let titles = ["视频", "照片", "表情包"]
  @IBOutlet var captureModePicker: AKPickerView!

  var recorder: SceneKitVideoRecorder?

  var avatar: Pig!

  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    setupSelfieSceneView()
    setupAvatarSceneView()
    setupRecorder(sceneView: avatarSceneView)
    setupCaptureButton()
    setupCaptureModePicker()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let configuration = ARFaceTrackingConfiguration()
    configuration.worldAlignment = .camera
    selfieSceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    selfieSceneView.session.pause()
  }

  @objc
  func didTapButton(_ sender: KYShutterButton) {
    switch sender.buttonState {
    case .normal:
      sender.buttonState = .recording
      self.recorder?.startWriting().onSuccess {
        print("Recording Started")
      }
    case .recording:
      sender.buttonState = .normal
      self.recorder?.finishWriting().onSuccess { [weak self] url in
        print("Recording Finished", url)
        self?.checkAuthorizationAndPresentActivityController(toShare: url, using: self!)
      }
    }
  }

  //MARK: - ViewController configuration
  override var shouldAutorotate: Bool {
    return true
  }
    
  override var prefersStatusBarHidden: Bool {
    return true
  }
    
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
        return .allButUpsideDown
    } else {
        return .all
    }
  }
}

private extension CaptureViewController {

  func setupSelfieSceneView() {

    selfieSceneView.delegate = self
    selfieSceneView.session.delegate = self
  }

  func setupAvatarSceneView() {

    let scene = SCNScene()

    avatar = Pig()
    scene.rootNode.addChildNode(avatar)

    avatarSceneView.defaultCameraController.pointOfView?.position = SCNVector3(x: 0, y: 0, z: 15)
    avatarSceneView.scene = scene
    avatarSceneView.allowsCameraControl = true
    avatarSceneView.scene.background.contents = UIColor.lightGray

    // Improve the performance
    if let camera = avatarSceneView.pointOfView?.camera {
      camera.wantsHDR = false
      camera.wantsExposureAdaptation = false
      camera.exposureOffset = -1
      camera.minimumExposure = -1
    }
  }

  func setupCaptureButton() {
    captureButton.arcColor = UIColor.black
    captureButton.buttonColor = UIColor.red
    captureButton.addTarget(self,
                            action: #selector(didTapButton(_:)),
                            for: .touchUpInside)
  }

  func setupCaptureModePicker() {
    captureModePicker.delegate = self
    captureModePicker.dataSource = self

    captureModePicker.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
    captureModePicker.highlightedFont = UIFont(name: "HelveticaNeue", size: 16)!
    captureModePicker.pickerViewStyle = .styleFlat
    captureModePicker.interitemSpacing = 20
    captureModePicker.isMaskDisabled = false
    captureModePicker.reloadData()
  }

  func setupRecorder(sceneView: ARSCNView) {

    var options = SceneKitVideoRecorder.Options.default
    options.videoSize = avatarSceneView.frame.size
    options.timeScale = 100
    recorder = try! SceneKitVideoRecorder(withARSCNView: sceneView, options: options)
  }

  private func checkAuthorizationAndPresentActivityController(toShare data: Any, using presenter: UIViewController) {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
      let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
      activityViewController.excludedActivityTypes = [.addToReadingList, .openInIBooks, .print]
      presenter.present(activityViewController, animated: true, completion: nil)
    case .restricted, .denied:
      let libraryRestrictedAlert = UIAlertController(title: "Photos access denied",
                                                     message: "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.",
                                                     preferredStyle: .alert)
      libraryRestrictedAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
      presenter.present(libraryRestrictedAlert, animated: true, completion: nil)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
        if authorizationStatus == .authorized {
          let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
          activityViewController.excludedActivityTypes = [.addToReadingList, .openInIBooks, .print]
          presenter.present(activityViewController, animated: true, completion: nil)
        }
      })
    }
  }

}

//MARK: - ARSCNViewDelegate
extension CaptureViewController: ARSCNViewDelegate, ARSessionDelegate {

  func session(_ session: ARSession, didFailWithError error: Error) {
    print("** didFailWithError")
  }

  func sessionWasInterrupted(_ session: ARSession) {
    print("** sessionWasInterrupted")
  }

  func sessionInterruptionEnded(_ session: ARSession) {
    print("** sessionInterruptionEnded")
  }

  func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    guard anchors.count > 0, let faceAnchor = anchors[0] as? ARFaceAnchor else { return }
    avatar.update(withFaceAnchor: faceAnchor)
  }

}

//MARK: - AKPickerViewDataSource
extension CaptureViewController: AKPickerViewDataSource {

  func numberOfItems(in pickerView: AKPickerView!) -> UInt {
    return UInt(titles.count)
  }

  func pickerView(_ pickerView: AKPickerView!, titleForItem item: Int) -> String! {
    return titles[item]
  }

}

//MARK: - AKPickerViewDelegate
extension CaptureViewController: AKPickerViewDelegate {

  func setCaptureButtonVideoMode() {
    captureButton.arcColor = UIColor.black
    captureButton.buttonColor = UIColor.red
  }

  func setCaptureButtonPhotoMode() {
    captureButton.arcColor = UIColor.black
    captureButton.buttonColor = UIColor.black
  }

  func setCaptureButtonEmojiMode() {
    captureButton.arcColor = UIColor.black
    captureButton.buttonColor = UIColor.lightGray
  }

  func pickerView(_ pickerView: AKPickerView!, didSelectItem item: Int) {
    if item == 0 {
      setCaptureButtonVideoMode()
    } else if item == 1 {
      setCaptureButtonPhotoMode()
    } else if item == 2 {
      setCaptureButtonEmojiMode()
    }
  }
}
