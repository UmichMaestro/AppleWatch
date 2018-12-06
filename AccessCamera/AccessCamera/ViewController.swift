//
//  ViewController.swift
//  openCamera
//
//  Created by Veck on 2017/1/5.
//  Copyright © 2017年 Sanity. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    @IBOutlet weak var camera: NSView!
    
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        camera.layer = CALayer()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.low))
        
        // Get all audio and video devices on this machine
        let devices = AVCaptureDevice.devices()
        
        // Find the FaceTime HD camera object
        for device in devices {
            print(device)
            
            // Camera object found and assign it to captureDevice
            if ((device as AnyObject).hasMediaType(AVMediaType.video)) {
                print(device)
                captureDevice = device as? AVCaptureDevice
            }
        }
        
        
        if captureDevice != nil {
            
            do {
                print("add sublayer")
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!))
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
                //CATransform3DMakeScale(-1, 1, 1)

                previewLayer?.frame = (self.camera.layer?.frame)!
                
                
                previewLayer!.transform = CATransform3DScale((previewLayer?.transform)!, -1, 1, 1)
                
                // Add previewLayer into custom view
                self.camera.layer?.addSublayer(previewLayer!)
                
                // Start camera
                captureSession.startRunning()
                
            } catch {
                print(AVCaptureSessionErrorKey.description)
            }
        }
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVCaptureSessionPreset(_ input: AVCaptureSession.Preset) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
