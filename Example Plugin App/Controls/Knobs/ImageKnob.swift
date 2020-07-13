//
//  ImageKnob.swift
//  UniversalKnob
//
//  Created by Matthew Fecher on 10/19/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit

@IBDesignable
public class ImageKnob: MIDIKnob {
    
    @IBInspectable open var totalFrames: Int = 0 {
        didSet {
            createImageArray()
        }
    }

    @IBInspectable open var imageName: String = "knob02_" {
        didSet {
            createImageArray()
        }
    }
    
    var imageView = UIImageView()
    var imageArray = [UIImage]()

    var currentFrame: Int {
      return Int(Double(knobValue) * Double(totalFrames-1))
    }

    public override func layoutSubviews() {
      super.layoutSubviews()
      imageView.frame = CGRect(
        x: 0,
        y: 0,
        width: self.bounds.width,
        height: self.bounds.height)
    }

    public override func draw(_ rect: CGRect) {
      super.draw(rect)
      if imageArray.indices.contains(currentFrame) {
        imageView.image = imageArray[currentFrame]
      }
  }
  
    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
      createImageArray()
      addSubview(imageView)
    }

    // Create Image Array
    func createImageArray() {
        guard totalFrames > 0 else { return }
        imageArray.removeAll()
        for i in 1...totalFrames {
            guard let image = UIImage(
                named: "\(imageName)\(i)",
                in: Bundle(for: type(of: self)),
                compatibleWith: traitCollection)
                else { continue }
            imageArray.append(image)
        }
        imageView.image = UIImage(named: "\(imageName)\(currentFrame)")
    }
}
