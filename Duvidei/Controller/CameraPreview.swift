//
//  CameraPreview.swift
//  Duvidei
//
//  Created by Matheus Frozzi Alberton on 25/07/15.
//  Copyright (c) 2015 Moisés Pio. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreview: UIView {
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var session : AVCaptureSession? {
        get {
            var layer : AVCaptureVideoPreviewLayer = self.layer as! AVCaptureVideoPreviewLayer
            var bounds = self.layer.bounds
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.bounds = bounds
            layer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
            return layer.session
        }
        set {
            var layer : AVCaptureVideoPreviewLayer = self.layer as! AVCaptureVideoPreviewLayer
            var bounds = self.layer.bounds
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.bounds = bounds
            layer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
            layer.session = newValue
        }
    }
}