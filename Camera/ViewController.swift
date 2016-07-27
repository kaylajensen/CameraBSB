//
//  ViewController.swift
//  Camera
//
//  Created by Kayla Kerney on 7/25/16.
//  Copyright © 2016 Kayla Kerney. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let previewCamera: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.redColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let capturedImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "arrows")
        image.contentMode = .ScaleAspectFit
        return image
    }()
    
    lazy var takePhotoButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTakePhoto), forControlEvents: .TouchUpInside)
        button.setTitle("Take Photo", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(previewCamera)
        view.addSubview(capturedImageView)
        view.addSubview(takePhotoButton)
        
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && (captureSession?.canAddInput(input))! {
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if ((captureSession?.canAddOutput(stillImageOutput)) != nil) {
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                
                previewCamera.layer.addSublayer(previewLayer!)
                
                captureSession?.startRunning()
            }
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer?.frame = previewCamera.bounds
        
    }

    func setupViews() {
        
        previewCamera.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        previewCamera.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        previewCamera.heightAnchor.constraintEqualToConstant(300).active = true
        previewCamera.bottomAnchor.constraintEqualToAnchor(capturedImageView.topAnchor).active = true
        
        capturedImageView.topAnchor.constraintEqualToAnchor(previewCamera.bottomAnchor).active = true
        capturedImageView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        capturedImageView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        capturedImageView.heightAnchor.constraintEqualToConstant(300).active = true
        capturedImageView.bottomAnchor.constraintEqualToAnchor(takePhotoButton.topAnchor).active = true
        
        takePhotoButton.topAnchor.constraintEqualToAnchor(capturedImageView.bottomAnchor).active = true
        takePhotoButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        takePhotoButton.widthAnchor.constraintEqualToConstant(100).active = true
        takePhotoButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor,constant: -20).active = true
        
        
    }
    
    func didTakePhoto() {
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    //self.capturedImage.image = image
                    
                    self.capturedImageView.image = image
                }
            })
        }

    }


}

