//
//  Pig.swift
//  Avatar
//
//  Created by GUO Lin on 2019/2/11.
//  Copyright © 2019 xiaobei. All rights reserved.
//
import ARKit
import SceneKit

class Pig: SCNNode {

  // Set up brow
  private var neutralBrowY: Float = 0
  private lazy var browNode = childNode(withName: "brow",
                                        recursively: true)!

  // Set up right eye
  private var neutralRightEyeX: Float = 0
  private var neutralRightEyeY: Float = 0
  private lazy var eyeRightNode = childNode(withName: "eyeRight",
                                            recursively: true)!
  private lazy var pupilRightNode = childNode(withName: "pupilRight",
                                              recursively: true)!

  // Set up left eye
  private var neutralLeftEyeX: Float = 0
  private var neutralLeftEyeY: Float = 0
  private lazy var eyeLeftNode = childNode(withName: "eyeLeft",
                                           recursively: true)!
  private lazy var pupilLeftNode = childNode(withName: "pupilLeft",
                                             recursively: true)!

  // Get size of pupils
  private lazy var pupilWidth: Float = {
    let (min, max) = pupilRightNode.boundingBox
    return max.x - min.x
  }()
  private lazy var pupilHeight: Float = {
    let (min, max) = pupilRightNode.boundingBox
    return max.y - min.y
  }()

  // Set up mouth
  private var neutralMouthY: Float = 0
  private lazy var mouthNode = childNode(withName: "mouth",
                                         recursively: true)!

  // Get size of mouth
  private lazy var mouthHeight: Float = {
    let (min, max) = mouthNode.boundingBox
    return max.y - min.y
  }()


  override init() {

    super.init()

    guard let url = Bundle.main.url(forResource: "pig",
                                    withExtension: "scn",
                                    subdirectory: "art.scnassets")
      else {
        fatalError("Missing resource")
    }

    let node = SCNReferenceNode(url: url)!
    node.load()

    addChildNode(node)

    // Set Baselines
    neutralBrowY = browNode.position.y
    neutralRightEyeX = pupilRightNode.position.x
    neutralRightEyeY = pupilRightNode.position.y
    neutralLeftEyeX = pupilLeftNode.position.x
    neutralLeftEyeY = pupilLeftNode.position.y
    neutralMouthY = mouthNode.position.y
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }

  func update(withFaceAnchor anchor: ARFaceAnchor) {
    let anchorTransform = SCNMatrix4(anchor.transform)
    let rotatedTransform = SCNMatrix4Rotate(anchorTransform, -.pi/2, 0, 0, 1)
    transform = rotatedTransform
    blendShapes = anchor.blendShapes
  }

  var blendShapes: [ARFaceAnchor.BlendShapeLocation: Any] = [:] {
    didSet {
      guard

        // Brow
        let browInnerUp = blendShapes[.browInnerUp] as? Float,

        // Right eye
        let eyeLookInRight = blendShapes[.eyeLookInRight] as? Float,
        let eyeLookOutRight = blendShapes[.eyeLookOutRight] as? Float,
        let eyeLookUpRight = blendShapes[.eyeLookUpRight] as? Float,
        let eyeLookDownRight = blendShapes[.eyeLookDownRight] as? Float,
        let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,

        // Left eye blink
        let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,

        // Left eye
        let eyeLookInLeft = blendShapes[.eyeLookInLeft] as? Float,
        let eyeLookOutLeft = blendShapes[.eyeLookOutLeft] as? Float,
        let eyeLookUpLeft = blendShapes[.eyeLookUpLeft] as? Float,
        let eyeLookDownLeft = blendShapes[.eyeLookDownLeft] as? Float,

        // Mouth
        let mouthOpen = blendShapes[.jawOpen] as? Float

        else { return }

      // Brow
      let browHeight = (browNode.boundingBox.max.y - browNode.boundingBox.min.y)
      browNode.position.y = neutralBrowY + browHeight * browInnerUp

      // Right eye look
      let rightPupilPos = SCNVector3(x: (neutralRightEyeX - pupilWidth) * (eyeLookInRight - eyeLookOutRight), y: (neutralRightEyeY - pupilHeight) * (eyeLookUpRight - eyeLookDownRight), z: pupilRightNode.position.z)
      pupilRightNode.position = rightPupilPos

      // Right eye blink
      eyeRightNode.scale.y = 1 - eyeBlinkRight

      // Left Eye
      let leftPupilPos = SCNVector3(x: (neutralLeftEyeX - pupilWidth) * (eyeLookOutLeft - eyeLookInLeft), y: (neutralLeftEyeY - pupilHeight) * (eyeLookUpLeft - eyeLookDownLeft), z: pupilLeftNode.position.z)
      pupilLeftNode.position = leftPupilPos

      // Left eye blink
      eyeLeftNode.scale.y = 1 - eyeBlinkLeft

      // Mouth
      mouthNode.position.y = neutralMouthY - mouthHeight * mouthOpen
    }
  }
}
