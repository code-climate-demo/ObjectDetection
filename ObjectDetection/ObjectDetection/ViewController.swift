//
//  ViewController.swift
//  ObjectDetection
//
//  Created by Akhlaq Ahmad on 04/04/2019.
//  Copyright © 2019 fayvoInternation. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController {
    
    //Declaring capture session
    let captureSession = AVCaptureSession()
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set session preset
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else{
            return
        }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewlayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewlayer)
        previewlayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self , queue: DispatchQueue(label: "videoQue"))
        captureSession.addOutput(dataOutput)
        
        
        //        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: <#T##[VNImageOption : Any]#>)
    }
    
    
}
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Camera was able to capture frame", Date())
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
            return }
        
        //get model
        guard let resNetModel = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        
        let requestCoreML = VNCoreMLRequest(model: resNetModel) { (finishedReq, err) in
            //cehck error
            
            //            print(finishedReq.results)
            
            DispatchQueue.main.async {
                if err == nil{
                    guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
                    
                    guard let firstObservation = results.first else { return }
                    self.textLabel.text = String(format: "This may be %.2f%% %@", firstObservation.confidence, firstObservation.identifier)
                    //                    Self.textLabel.text = "\(firstObservation.identifier , firstObservation.confidence)"
                }
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([requestCoreML])
    }
}
