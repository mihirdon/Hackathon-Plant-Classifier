//
//  ViewController.swift
//  Hackathon1
//
//  Created by Mihir Dontamsetti on 6/25/22.
//

import UIKit
import AVFoundation
import CoreML
import Vision


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    struct Prediction {
        let classification: String
    }

    let captureSession = AVCaptureSession()
    var previewView: PreviewView!
    
    var capDevice:AVCaptureDevice!
    var bestDeviceOutput:AVCaptureVideoDataOutput!
    var photoTaken = false
    var imagePrediction : String?
    
    override func viewDidLoad() {
            super.viewDidLoad()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepCam()
    }
    
    
    // Selects the device that fits the type we want, if there are none it will error out
    func selectBestDevice() -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        let devices = discoverySession.devices
        guard !devices.isEmpty else {fatalError("Sorry you do not have any available devices.")} //if there are no cameras error
        return devices.first! // choose the best camera
    }
    
    func initSession() {
        captureSession.beginConfiguration()
        
        let bestDevice = selectBestDevice() //makes sure we have the camera we want
        guard
            let bestDeviceInput = try? AVCaptureDeviceInput(device: bestDevice),
            captureSession.canAddInput(bestDeviceInput)                          //make sure we can add input to the cap session
            else {return}
        captureSession.addInput(bestDeviceInput)
        

        //let bestDevOutput = AVCaptureVideoDataOutput()
        //guard captureSession.canAddOutput(bestDevOutput) else {return} //make sure we can add output
        self.bestDeviceOutput = AVCaptureVideoDataOutput()
        self.bestDeviceOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
        captureSession.addOutput(bestDeviceOutput)
        captureSession.sessionPreset = .photo //we want photos
        
        captureSession.commitConfiguration()
    }
    
    
    // Does all the work necessary for ensuring all the qualifications we want in a camera
    func prepCam() {
        initSession()
        self.previewView = PreviewView()
        self.previewView.videoPreviewLayer.session = self.captureSession
        self.view.layer.addSublayer(self.previewView.videoPreviewLayer)
        self.previewView.videoPreviewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
        
        
        let queue = DispatchQueue(label: "Mihir-Dontamsetti.hackathon1.kkljedf.captureQueue")
        bestDeviceOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
            photoTaken = true
            print("got here 2")
    }
        
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if photoTaken {
            photoTaken = false
            
            
                
                DispatchQueue.main.async {
                    if let uiImage = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                        let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
                        
                        photoVC.takenPhoto = uiImage
                        photoVC.imagePrediction = self.imagePrediction!
                        
                        self.present(photoVC, animated: true, completion: {
                        })
                    
                }
            }
        }
    }
        
        
    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
                
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
                
            if let image = context.createCGImage(ciImage, from: imageRect) {
                do {
                    try handleCoreModel(image: image)
                }
                catch {return nil}
                
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
                
        }
            
        return nil
    }
    
    func handleCoreModel (image: CGImage) throws {
        guard let model = try? VNCoreMLModel(for: Hackathon_ML_Classifier().model) else {return}
        let handler = VNImageRequestHandler(cgImage: image, orientation: .right)
        let modelRequest = VNCoreMLRequest(model: model, completionHandler: visionRequestHandler)
        
        let requests: [VNRequest] = [modelRequest]
        try handler.perform(requests)
    }
    
    
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            print("Error Occurred when unpacking results")
            return
        }
        
        guard let topResult = results.first else {return}
        let resultText = "\(topResult.identifier)"
        self.imagePrediction = resultText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

