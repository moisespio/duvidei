//
//  CameraViewController.swift
//  Duvidei
//
//  Created by Matheus Frozzi Alberton on 25/07/15.
//  Copyright (c) 2015 Moisés Pio. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class CameraViewController: UIViewController {
    @IBOutlet weak var snapButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var previewView: CameraPreview!

    var sessionQueue : dispatch_queue_t?
    var session : AVCaptureSession?
    var videoDeviceInput : AVCaptureDeviceInput?
    var videoDevice : AVCaptureDevice?
    var movieFileOutput : AVCaptureMovieFileOutput?
    var stillImageOutput : AVCaptureStillImageOutput?
    var backgroundRecordingId : UIBackgroundTaskIdentifier?
    var deviceAuthorized : Bool?
    var flashMode : Int = 0
    var imageTaked : UIImage?
    
    var sessionRunningAndDeviceAuthorized : Bool {
        get {
            return ((self.session?.running)! && (self.deviceAuthorized != nil))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        Create the AV Session!
        var session : AVCaptureSession = AVCaptureSession()
        self.session = session
        self.previewView.session = session
        self.previewView.session!.sessionPreset = AVCaptureSessionPresetPhoto
        
        self.checkForAuthorizationStatus()
        
        //        It's not safe to mutate an AVCaptureSession from multiple threads at the same time. Here, we're creating a sessionQueue so that the main thread is not blocked when AVCaptureSetting.startRunning is called.
        var queue : dispatch_queue_t = dispatch_queue_create("sesion queue", DISPATCH_QUEUE_SERIAL);
        self.sessionQueue = queue
        
        dispatch_async(queue, { () -> Void in
            self.backgroundRecordingId = UIBackgroundTaskInvalid
            var error : NSError?
            
            var videoDevice : AVCaptureDevice = CameraViewController.deviceWithMediaTypeAndPosition(AVMediaTypeVideo, position: AVCaptureDevicePosition.Back)
            var videoDeviceInput : AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error) as! AVCaptureDeviceInput
            
            if ((error) != nil) {
                println("Error executing videoDevice")
            }
            
            self.session?.beginConfiguration()
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                self.videoDevice = videoDeviceInput.device
            }
            
            var stillImageOutput : AVCaptureStillImageOutput = AVCaptureStillImageOutput()
            
            if session.canAddOutput(stillImageOutput) {
                stillImageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                session.addOutput(stillImageOutput)
                self.stillImageOutput = stillImageOutput
            }
            self.session?.commitConfiguration()
            
            //            TODO: Optional here, dispatch another thread to set up camera controls
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(self.sessionQueue!, { () -> Void in
            self.addNotificationObservers()
            self.session!.startRunning()
        })
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        dispatch_async(self.sessionQueue!, { () -> Void in
            self.session!.stopRunning()
            self.removeNotificationObservers()
        })
        super.viewDidDisappear(animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //    MARK: Actions
    @IBAction func takeStillImage(sender: AnyObject) {
        dispatch_async(self.sessionQueue!, { () -> Void in
            var layer : AVCaptureVideoPreviewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
            self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = layer.connection.videoOrientation
            
            println(self.flashMode)
            if(self.flashMode == 0) {
                CameraViewController.setFlashMode(AVCaptureFlashMode.Auto, device: self.videoDevice!)
            } else if(self.flashMode == 1) {
                CameraViewController.setFlashMode(AVCaptureFlashMode.On, device: self.videoDevice!)
            } else if(self.flashMode == 2) {
                CameraViewController.setFlashMode(AVCaptureFlashMode.Off, device: self.videoDevice!)
            }
            
            //            Capture the image
            self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (imageDataSampleBuffer, error) -> Void in
                if ((imageDataSampleBuffer) != nil) {
                    var imageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    var image : UIImage = UIImage(data: imageData)!
                    self.imageTaked = image
                    self.performSegueWithIdentifier("takePhoto", sender: nil)
                }
            })
        })
    }
    
    @IBAction func flipCamera(sender: AnyObject) {
        self.snapButton.enabled = false
        self.flipButton.enabled = false
        
        dispatch_async(self.sessionQueue!, { () -> Void in
            var currentVideoDevice : AVCaptureDevice = self.videoDevice!
            var preferredPosition : AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified
            var currentPosition : AVCaptureDevicePosition = currentVideoDevice.position
            
            switch (currentPosition)
            {
            case AVCaptureDevicePosition.Unspecified:
                preferredPosition = AVCaptureDevicePosition.Back
                break;
            case AVCaptureDevicePosition.Back:
                preferredPosition = AVCaptureDevicePosition.Front
                break;
            case AVCaptureDevicePosition.Front:
                preferredPosition = AVCaptureDevicePosition.Back
                break;
            }
            
            var newVideoDevice : AVCaptureDevice = CameraViewController.deviceWithMediaTypeAndPosition(AVMediaTypeVideo, position: preferredPosition)
            var newVideoDeviceInput : AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(newVideoDevice, error: nil) as! AVCaptureDeviceInput
            
            self.session!.beginConfiguration()
            
            self.session!.removeInput(self.videoDeviceInput)
            
            if self.session!.canAddInput(newVideoDeviceInput) {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: currentVideoDevice)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChance", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: newVideoDevice)
                
                self.session!.addInput(newVideoDeviceInput)
                self.videoDeviceInput = newVideoDeviceInput
                self.videoDevice = newVideoDeviceInput.device
            } else {
                self.session!.addInput(self.videoDeviceInput)
            }
            self.session!.commitConfiguration()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.snapButton.enabled = true
                self.flipButton.enabled = true
                //                TODO: Implement Video features for iOS 8 (e.g. white bal, ISO, etc)
            })
            
        })
    }
    
    @IBAction func changeFlashMode(sender: AnyObject) {
        var urlImage : String?
        
        if(self.flashMode == 2) {
            self.flashMode = 0
        } else if(self.flashMode == 0) {
            self.flashMode = 1
        } else if(self.flashMode == 1) {
            self.flashMode = 2
        }
    }
    
    func cropPhoto() {
        UIGraphicsBeginImageContext(self.previewView.frame.size)
        let context : CGContextRef = UIGraphicsGetCurrentContext()
        let image : CGImageRef = CGBitmapContextCreateImage(context)
        let width = Double(CGImageGetWidth(image));
        let height = Double(CGImageGetHeight(image));
        
        //         CGRectMake((screenWidth / 2) - (size / 2), 30, size, size)
        let frame = CGRect(x: Double(0), y: Double(0), width: width, height: height)
        
        let cropped_img = CGImageCreateWithImageInRect(image, frame);
        let img = UIImage(CGImage: cropped_img)
    }
    
    //    MARK: Device Configuration
    class func setFlashMode(flashMode: AVCaptureFlashMode, device: AVCaptureDevice) {
        if device.flashAvailable && device.isFlashModeSupported(flashMode) {
            var error : NSError?
            if device.lockForConfiguration(&error) {
                device.flashMode = flashMode
                device.unlockForConfiguration()
            } else {
                println("Error turning on flash")
            }
        }
    }
    
    func focus(focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(self.sessionQueue!, { () -> Void in
            var device : AVCaptureDevice = self.videoDevice!
            var error : NSError?
            if device.lockForConfiguration(&error) {
                if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusMode = focusMode
                    device.focusPointOfInterest = point
                }
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposureMode = exposureMode
                    device.exposurePointOfInterest = point
                }
                device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } else {
                println("Error setting focus")
            }
        })
    }
    
    //    MARK : Utilities
    class func deviceWithMediaTypeAndPosition(mediaType: NSString, position: AVCaptureDevicePosition) -> AVCaptureDevice {
        var devices : NSArray = AVCaptureDevice.devicesWithMediaType(mediaType as String)
        var captureDevice : AVCaptureDevice = devices.firstObject as! AVCaptureDevice
        
        for device in devices {
            let device = device as! AVCaptureDevice
            if device.position == position {
                captureDevice = device
                break
            }
        }
        return captureDevice
    }
    
    func checkForAuthorizationStatus() {
        var mediaType : NSString = AVMediaTypeVideo;
        AVCaptureDevice .requestAccessForMediaType(mediaType as String, completionHandler: { (granted) -> Void in
            if (granted) {
                self.deviceAuthorized = true
            } else {
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    UIAlertView(title: "Ops!", message: "Flockr doesn't have permission to use the camera!", delegate: self, cancelButtonTitle: "OK").show()
                    self.deviceAuthorized = false
                })
            }
        })
    }
    
    //    MARK: Observers :)
    func subjectAreaDidChange(notification: NSNotification) {
        var devicePoint : CGPoint = CGPoint(x: 0.5, y: 0.5)
        self.focus(AVCaptureFocusMode.ContinuousAutoFocus, exposureMode: AVCaptureExposureMode.ContinuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)
        
    }
    
    func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDevice)
    }
    
    func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDevice)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "takePhoto" {
//            let childViewController = segue.destinationViewController as! PhotoViewController
//            childViewController.image = self.imageTaked
//        }
//    }
}