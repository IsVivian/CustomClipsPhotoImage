//
//  MyClipsViewController.swift
//  CustomClipsPhotoImage
//
//  Created by sherry on 16/11/25.
//  Copyright © 2016年 sherry. All rights reserved.
//

import UIKit

protocol ImageReshapeDelegate {
    
    func imageReshaperControllerDidCancel(reshaper: MyClipsViewController)
    
    func imageReshaperController(reshaper: MyClipsViewController, didFinishPickingMediaWithInfo image: UIImage)
    
}

class MyClipsViewController: UIViewController, UIScrollViewDelegate {

    //原图片
    var sourceImage: UIImage!
    //宽高比
    var reshapeScale: CGFloat!
    
    var delegate: ImageReshapeDelegate!
    
    //scrollView，拖动照片
    var scrollView: UIScrollView!
    
    var imageView: UIImageView!
    var frameView: UIImageView!
    var shapeView: ClipsView!
    
    //确定按钮
    var selectButton: UIButton!
    //取消按钮
    var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let leftBtn = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: #selector(leftBtnAct))
        
        self.navigationItem.leftBarButtonItem = leftBtn
        
        
        self.configUI()
        
        self.shapeView.shapePath = UIBezierPath(rect: self.frameView.frame)
        self.shapeView.coverColor = UIColor(white: 0, alpha: 0.8)
        self.shapeView.setNeedsDisplay()
        
        self.layoutScrollView()
        
    }
    
    func leftBtnAct() {
    
        self.navigationController?.popViewControllerAnimated(true)
    
    }
    
    //创建视图
    func configUI() {
    
        self.view.backgroundColor = UIColor.blackColor()
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        
        self.frameView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width / self.scale()))
        self.frameView.center = self.view.center
        self.view.addSubview(self.frameView)
        
        var image = UIImage(named: "icon_frame")
        image = image?.resizableImageWithCapInsets(UIEdgeInsetsMake(10, 10, 10, 10), resizingMode: .Stretch)
        self.frameView.image = image
        self.frameView.backgroundColor = UIColor.clearColor()
        
        self.shapeView = ClipsView(frame: self.view.bounds)
        self.shapeView.backgroundColor = UIColor.clearColor()
        self.shapeView.coverColor = UIColor(white: 0, alpha: 0.5)
        self.shapeView.userInteractionEnabled = false
        self.view.addSubview(self.shapeView)
        
        self.cancelButton = UIButton(frame: CGRectMake(15, UIScreen.mainScreen().bounds.size.height-50, 50, 25))
        self.cancelButton.setTitle("取消", forState: .Normal)
        self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.cancelButton.addTarget(self, action: #selector(cancelDidClick), forControlEvents: .TouchUpInside)
        self.view.addSubview(self.cancelButton)
        self.view.bringSubviewToFront(self.cancelButton)
        
        self.selectButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width-50-15, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height))
        self.selectButton.setTitle("确定", forState: .Normal)
        self.selectButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.selectButton.addTarget(self, action: #selector(selectDidClick), forControlEvents: .TouchUpInside)
        self.view.addSubview(self.selectButton)
        self.view.bringSubviewToFront(self.selectButton)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    //创建照片滚动视图
    func layoutScrollView() {
    
        self.imageView = UIImageView(frame: CGRectMake(0, 0, self.sourceImage.size.width, self.sourceImage.size.height))
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.image = self.sourceImage
        
        let imageSize = self.sourceImage.size
        self.scrollView.contentSize = imageSize
        self.scrollView.addSubview(self.imageView)
        
        var scale: CGFloat = 0
        
        //计算图片适配屏幕的size
        let cropBoxSize: CGSize = self.frameView.bounds.size
        
        //以cropBoxSize宽或者高最大的那个为基准
        scale = max(cropBoxSize.width/imageSize.width, cropBoxSize.height/imageSize.height)
        
        //按照比例算出初次展示的尺寸
        let scaledSize = CGSizeMake(floor(imageSize.width * scale), floor(imageSize.height * scale))
        
        //配置scrollView
        self.scrollView.minimumZoomScale = scale
        self.scrollView.maximumZoomScale = 5.0
        
        //初始缩放系数
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        self.scrollView.contentSize = scaledSize
        
        let cropBoxFrame = self.frameView.frame
        
        //调整位置，使其居中
        if cropBoxFrame.size.width < scaledSize.width - CGFloat(FLT_EPSILON) || cropBoxFrame.size.height < scaledSize.height - CGFloat(FLT_EPSILON) {
            
            var offset = CGPointZero
            
            offset.x = -floor((CGRectGetWidth(self.scrollView.frame) - scaledSize.width) * 0.5)
            offset.y = -floor((CGRectGetHeight(self.scrollView.frame) - scaledSize.height) * 0.5)
            
            self.scrollView.contentOffset = offset
            
        }
        
        // 以cropBoxFrame为基准设施 scrollview 的insets 使其与cropBoxFrame 匹配 防止 缩放时突变回顶部
        self.scrollView.contentInset = UIEdgeInsetsMake(CGRectGetMinY(cropBoxFrame), CGRectGetMinX(cropBoxFrame), CGRectGetMaxY(self.view.bounds) - CGRectGetMaxY(cropBoxFrame), CGRectGetMaxX(self.view.bounds) - CGRectGetMaxX(cropBoxFrame))
    
    }
    
    //最后裁剪时图片位置确定
    func imageCropFrame() -> CGRect {
        
        let imageSize = self.imageView!.image!.size
        let contentSize = self.scrollView.contentSize
        let cropBoxFrame = self.frameView.frame
        let contentOffset = self.scrollView.contentOffset
        let edgeInsets = self.scrollView.contentInset
        var frame = CGRectZero
        frame.origin.x = floor((contentOffset.x + edgeInsets.left) * (imageSize.width / contentSize.width))
        frame.origin.x = max(0, frame.origin.x)
        frame.origin.y = floor((contentOffset.y + edgeInsets.top) * (imageSize.height / contentSize.height))
        frame.origin.y = max(0, frame.origin.y)
        frame.size.width = ceil(cropBoxFrame.size.width * (imageSize.width / contentSize.width))
        frame.size.width = min(imageSize.width, frame.size.width)
        frame.size.height = ceil(cropBoxFrame.size.height * (imageSize.height / contentSize.height))
        frame.size.height = min(imageSize.height, frame.size.height)
        
        return frame
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    //lazy load
    func shapeImage() -> UIImage {
    
        return self.imageView.image!.croppedImageWithFrame(self.imageCropFrame())
        
    
    }

    func scale() -> CGFloat {
    
        return self.reshapeScale == 0 ? 1 : self.reshapeScale
    
    }

    //取消按钮
    func cancelDidClick() {
    
        self.delegate.imageReshaperControllerDidCancel(self)
    
    }
    
    //选中按钮
    func selectDidClick() {
    
        self.delegate.imageReshaperController(self, didFinishPickingMediaWithInfo: self.shapeImage())
    
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        
//    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
