//
//  ViewController.swift
//  tagalong
//
//  Created by Camron Godbout on 2/10/15.
//  Copyright (c) 2015 Camron Godbout. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Foundation
import MobileCoreServices

class ViewController: UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    let locationManager = CLLocationManager()
    
    
    var data: NSMutableData = NSMutableData()
    var urlString: String = "http://tagalongapp.co/api/media/?format=json"
    
    var captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var imageView : UIImageView?
    
    let devices = AVCaptureDevice.devices()
    //true = front false = back
    //we start front so start false
    var cameraSide : Bool = false
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var frontCameraButton: UIButton!
    @IBOutlet weak var closePreviewButton: UIButton!
    @IBOutlet weak var sendOffButton: UIButton!
    
    var stillImageOutput = AVCaptureStillImageOutput()
    
    var movieFileOutput = AVCaptureMovieFileOutput()
    var imageData: NSData!
    var movieData: NSData!
    
    //if we find a device
    var captureDevice : AVCaptureDevice?
    
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var audio : AVCaptureDevice!
    
    var image : UIImage?
    
    /********************************************************************************************
    * getApi(sender: AnyObject)
    * test function that monitors button click to go and run the send request code.
    *
    */
    @IBAction func getAPI(sender: AnyObject) {
        //self.sendRequest()
    }
    
    
    override func viewDidLoad() {
        println("did load")
        
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
        //camera code begin
                captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
                for device in devices
                {
                    if (device.hasMediaType(AVMediaTypeVideo)){
        
                        if device.position == AVCaptureDevicePosition.Back
                        {
                              backCamera = device as! AVCaptureDevice
                        }
                        if device.position == AVCaptureDevicePosition.Front
                        {
                            frontCamera = device as! AVCaptureDevice
                        }
                    }
                    if device.hasMediaType(AVMediaTypeAudio)
                    {
                        audio = device as! AVCaptureDevice
                    }
                }
                if backCamera != nil {
                        println("Capture device found")
                        beginSession()
                }
            //camera code end
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /********************************************************************************************
    * locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    * reverse geocodes the location of the placemarker and calls the display location info method
    *
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil)
            {
                println("Error:" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0
            {
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
            }else{
                println("ERROR WITH DATA")
            }
        })
    }
    
    /********************************************************************************************
    * displayLocationInfo(placemark: CLPlacemark)
    * stops locationManager and prints out the relevant info of the placemark
    *
    */
    func displayLocationInfo(placemark: CLPlacemark)
    {
        self.locationManager.stopUpdatingLocation()
        
        println(placemark.locality)
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)
    }
    
    /********************************************************************************************
    * locationManager
    * handles errors
    *
    */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        println("Error:" + error.localizedDescription)
    }
    
    
    
    /********************************************************************************************
    * sendRequest()
    * gets the request from the api and grabs the video urls to download
    *
    */
    func sendRequest()
    {
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            var err: NSError?
            
            // var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            //let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as NSDictionary
            let json = JSON(data: data)
            for (key: String, subJson: JSON) in json{
                if key == "objects"
                {
                    let vidurl = subJson[0]["mediafile"]
                    println(vidurl)
                }
            }
        }
        
        task.resume()
    }
    
    
    /********************************************************************************************
    * configureDevice()
    *  configures the camera
    *
    */
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
        
    }
    
    /********************************************************************************************
    *  beginSession()
    *  begins capture session
    *
    */
    func beginSession()
    {
        var err: NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: backCamera, error: &err))
        if err != nil{
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(takePhotoButton)
        self.view.bringSubviewToFront(frontCameraButton)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
        
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
    }
    
    
    /********************************************************************************************
    *  shotPress()
    *  When the take photo button is clicked. We take pictures.
    *
    */
    @IBAction func shotPress(sender: UIButton) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        if let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection)
                { (imageDataSampleBuffer, error) -> Void in
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    if self.cameraSide == true
                    {
                        let flipimage = CIImage(data: imageData)
                        self.image = UIImage(CIImage: flipimage, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)
                    }
                    else
                    {
                        self.image = UIImage(data: imageData)
                    }
                    self.imageView = UIImageView(image: self.image)
                    let bounds: CGRect = UIScreen.mainScreen().bounds
                    let width:CGFloat = bounds.size.width
                    let height:CGFloat = bounds.size.height
                    self.imageView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    self.view.addSubview(self.imageView!)
                    self.closePreviewButton.hidden = false
                    self.closePreviewButton.enabled = true
                    self.view.bringSubviewToFront(self.closePreviewButton)
                    self.frontCameraButton.enabled = false
                    self.takePhotoButton.enabled = false
                    self.sendOffButton.hidden = false
                    self.sendOffButton.enabled = true
                    self.imageData = imageData
            }}
        }
        
    }
    
    /********************************************************************************************
    *  recordVideo()
    *  when the camera button is held down you record the video
    *
    */
    @IBAction func recordVideo(sender: UIButton)
    {
        //stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecH264]
        //if captureSession.canAddOutput(stillImageOutput
        
    }
    
    
    /*******************************************************************************************
    * override preferStatusBarHidden()
    * Hides the top status bar from camera preview.
    *
    */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /*******************************************************************************************
    * switchToFrontCamera
    * changes the view to the front camera
    *
    */
    @IBAction func switchCamera(sender: UIButton) {
        
        if cameraSide == false
        {
            cameraSide = true
            //            let backCameraImage : UIImage? = UIImage(contentsOfFile: "ic_camera_rear.png")
            //            frontCameraButton.setImage(UIImage(contentsOfFile: "ic_camera_rear.png"), forState: UIControlState.Normal)
            //            view.addSubview(frontCameraButton)
        }
        else
        {
            cameraSide = false
            //            //let backCameraImage : UIImage? = UIImage(contentsOfFile: "ic_camera_front.png")
            //            frontCameraButton.setImage(UIImage(contentsOfFile: "ic_camera_front.png"), forState: UIControlState.Normal)
            //            view.addSubview(frontCameraButton)
        }
        var err : NSError? = nil
        captureSession.removeInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        if err != nil{
            println(err?.localizedDescription)
        }
        captureSession.stopRunning()
        for device in devices
        {
            if (device.hasMediaType(AVMediaTypeVideo)){
                
                //check position and get back camera. obviously have to get front soon
                if device.position == AVCaptureDevicePosition.Front && cameraSide == true
                {
                    self.captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginAfterSwitchSession()
                    }
                } else if device.position == AVCaptureDevicePosition.Back && cameraSide == false
                {
                    self.captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginAfterSwitchSession()
                    }
                }
            }
        }
        
    }
    
    /*******************************************************************************************
    * beginAfterSwitchSession
    * starts up the camera that is being switched to.
    *
    */
    func beginAfterSwitchSession()
    {
        
        var err: NSError? = nil
        
        let inp : AVCaptureInput = captureSession.inputs[0] as! AVCaptureInput
        
        captureSession.removeInput(inp)
        
        if (captureSession.canAddInput(AVCaptureDeviceInput(device: captureDevice, error: &err)))
        {
            println("we can add it")
            captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        }
        else
        {
            println("cry")
        }
        
        if err != nil{
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = nil
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        self.view.bringSubviewToFront(takePhotoButton)
        self.view.bringSubviewToFront(frontCameraButton)
        captureSession.startRunning()
    }
    
    
    /*******************************************************************************************
    * closeOutPreview
    * enables the other buttons and closes out of the image view.
    *
    */
    @IBAction func closeOutPreview(sender: UIButton) {
        println("button clicked")
        imageView?.removeFromSuperview()
        imageView = nil
        closePreviewButton.enabled = false
        closePreviewButton.hidden = true
        sendOffButton.enabled = false
        sendOffButton.hidden = true
        takePhotoButton.enabled = true
        frontCameraButton.enabled = true
        
    }

    @IBAction func sendOffToServer(sender: UIButton) {
        
    }
    
    
}

