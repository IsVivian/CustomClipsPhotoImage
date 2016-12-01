//
//  ViewController.swift
//  CustomClipsPhotoImage
//
//  Created by sherry on 16/11/25.
//  Copyright © 2016年 sherry. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageReshapeDelegate {

    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func selectImage(sender: AnyObject) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let action1 = UIAlertAction(title: "拍照", style: .Default) { (sheet) in
            
            self.openCamera()
            
        }
        
        let action2 = UIAlertAction(title: "从相册中选择", style: .Default) { (sheet) in
            self.openPhotos()
        }
        
        let action3 = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
        
    }
    
    //打开相册
    func openPhotos() {
        
        let pickerC = UIImagePickerController()
        
        //类型
        pickerC.sourceType = .PhotoLibrary
        
        pickerC.modalTransitionStyle = .CoverVertical
        
        //代理
        pickerC.delegate = self
        
        pickerC.allowsEditing = false
        
        //推出
        self.presentViewController(pickerC, animated: true, completion: nil)
        
        
    }
    
    //打开相机
    func openCamera() {
        
        let pickerC = UIImagePickerController()
        
        pickerC.delegate = self
        
        pickerC.modalTransitionStyle = .CoverVertical
        
        pickerC.allowsEditing = false
        
        let mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickerC.sourceType)
        pickerC.mediaTypes = mediaTypes!
        
        //设置摄像头是否可用---前置
        let isCamera: Bool = UIImagePickerController.isCameraDeviceAvailable(.Front)
        
        if !isCamera {
            print("没有摄像头")
            return
        }
        
        //设置类型是相机
        pickerC.sourceType = .Camera
        
        //推出
        self.presentViewController(pickerC, animated: true, completion: nil)
        
    }
    
    //图片选中后调用
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if !picker.allowsEditing {
            
            let img = info["UIImagePickerControllerOriginalImage"] as? UIImage
            self.image.image = img
            
            let clipsVC = MyClipsViewController()
            clipsVC.sourceImage = img!
            clipsVC.reshapeScale = 16.0/9.0
            clipsVC.delegate = self
            
            picker.pushViewController(clipsVC, animated: true)
            
        }
        
    }
    
    //确定图片
    func imageReshaperController(reshaper: MyClipsViewController, didFinishPickingMediaWithInfo image: UIImage) {
        self.image.image = image
        
        reshaper.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //取消
    func imageReshaperControllerDidCancel(reshaper: MyClipsViewController) {
        reshaper.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func turnImageWithInfo(info: [String: AnyObject]) -> UIImage {
    var image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        //类型为 UIImagePickerControllerOriginalImage 时调整图片角度
    let type = (info[UIImagePickerControllerMediaType] as! String)
    if (type == "public.image") {
        let imageOrientation = image.imageOrientation
        if imageOrientation != .Up {
            // 原始图片可以根据照相时的角度来显示，但 UIImage无法判定，于是出现获取的图片会向左转90度的现象。
            UIGraphicsBeginImageContext(image.size)
            image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    return image
}
    
    //压缩图片
    func imageWithImageSimple(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImg
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

