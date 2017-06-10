//
//  ViewController.swift
//  LiveCoreML
//
//  Created by Peter Leung on 10/6/2017.
//  Copyright © 2017 winandmac Media. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    let stillImageOutput = AVCaptureStillImageOutput()
    var captureDevice:AVCaptureDevice?

    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        beginSession()
    }
    
    
    @IBAction func tapToRecognise(_ sender: Any) {
        
        if let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {
            
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer!) {
                    
                    if let cameraImage = UIImage(data: imageData) {
                        
                        self.makePredictions(image: cameraImage)
                    }
                }
            })
        }
    }
    
    func beginSession() {
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!))
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        self.cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = self.cameraView.layer.frame
        captureSession.startRunning()
        print("Camera Running")
    }
    
    func makePredictions(image: UIImage) {
        do {
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(model: model, completionHandler: displayPredictions)
            let handler = VNImageRequestHandler(cgImage: image.cgImage!)
            try handler.perform([request])
        } catch {
            
        }
    }
    
    func displayPredictions(request: VNRequest, error: Error?) {
        // Make sure we have a result
        guard let results = request.results as? [VNClassificationObservation]
            else { fatalError("Bad prediction") }
        
        print(results[0].identifier)
        // Sort results by confidence
        // results.sorted(by: {$0.confidence > $1.confidence})
        
        // Show prediction results
        //topGuess.text = "\(results[0].identifier) - \(results[0].confidence * 100)%"
    }


}

