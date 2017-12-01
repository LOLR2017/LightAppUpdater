//
//  TLH_HitView.swift
//  LightAppUpdater
//
//  Created by 赵文龙 on 2017/9/5.
//  Copyright © 2017年 zhaowenlong. All rights reserved.
//

import UIKit

public typealias resultBlock = (_ isUpdate:Bool) -> Void

open class TLH_HitView: UIView {

    public var block:resultBlock?
    public var image:UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    public var title:String = "发现新版本" {
        didSet {
            titleLabel?.text = title
        }
    }
    public var imageView:UIImageView?
    public var backView:UIView?
    public var titleLabel:UILabel?
    public var contentLabel:UILabel?
    public var cancelButton:UIButton?
    public var finishButton:UIButton?
    public var firstLineView:UIView?
    public var secondLineView:UIView?
    
    public var content:String = ""
    public var isForce:Bool = false
    
    open static let shareHitView:TLH_HitView = {
        let view = TLH_HitView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(cancelClick))
        view.addGestureRecognizer(tap)
        
       return view
    }()
    
    open func show(_ view:UIView?,inView superView:UIView?,success:@escaping resultBlock) -> Void {
        block = success
        var contentView = view
        var sView = superView
        if view == nil {
            contentView = self.createContentView()
        }
        if superView == nil {
            sView = UIApplication.shared.keyWindow
        }
        contentView?.frame.origin.y = (self.frame.height-(contentView?.frame.height)!)/2
        for view in self.subviews {
            view.removeFromSuperview()
        }
        self.addSubview(contentView!)
        sView?.addSubview(self)
    }
    
    func createContentView() -> UIView {
        if backView == nil {
            backView = UIView.init(frame: CGRect.init(x: self.frame.width/2-131, y: self.frame.height/2-150, width: 262, height: 300))
            backView?.backgroundColor = UIColor.white
            backView?.layer.cornerRadius = 4
            backView?.layer.masksToBounds = true
            backView?.isUserInteractionEnabled = true
            
            imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: (backView?.frame.width)!, height: 110));
            imageView?.image = image
            backView?.addSubview(imageView!)
            
            titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 20, width: (backView?.frame.width)!, height: 20))
            titleLabel?.text = title
            titleLabel?.textAlignment = .center
            titleLabel?.textColor = UIColor.init(red: 64/255.0, green: 147/255.0, blue: 239/255.0, alpha: 1.0)
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            backView?.addSubview(titleLabel!)
            
            contentLabel = UILabel.init(frame: CGRect.init(x: 30, y: (imageView?.frame.maxY)!, width: (backView?.frame.width)!-60, height: 20))
            contentLabel?.textColor = UIColor.black
            contentLabel?.font = UIFont.systemFont(ofSize: 15)
            contentLabel?.numberOfLines = 0
            contentLabel?.text = content
            contentLabel?.sizeToFit()
            backView?.addSubview(contentLabel!)
            
            backView?.frame = CGRect.init(x:self.frame.width/2-131, y: self.frame.height/2-150, width: 262, height: (contentLabel?.frame.maxY)!+70)
            
            
            
            cancelButton = UIButton.init(type: .custom)
            cancelButton?.frame = CGRect.init(x: 0, y: (backView?.frame.height)!-40, width: (backView?.frame.width)!/2, height: 40)
            cancelButton?.setTitle("暂不升级", for: .normal)
            cancelButton?.setTitleColor(UIColor.gray, for: .normal)
            cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            cancelButton?.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
            backView?.addSubview(cancelButton!)
            
            finishButton = UIButton.init(type: .custom)
            finishButton?.frame = CGRect.init(x: (backView?.frame.width)!/2, y: (backView?.frame.height)!-40, width: (backView?.frame.width)!/2, height: 40)
            finishButton?.backgroundColor = UIColor.init(red: 64/255.0, green: 147/255.0, blue: 239/255.0, alpha: 1.0)
            finishButton?.setTitle("现在升级", for: .normal)
            finishButton?.setTitleColor(UIColor.white, for: .normal)
            finishButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            finishButton?.addTarget(self, action: #selector(finishClick), for: .touchUpInside)
            backView?.addSubview(finishButton!)
            
            firstLineView = UIView.init(frame: CGRect.init(x: 0, y: (backView?.frame.height)!-40, width: (backView?.frame.width)!, height: 1/UIScreen.main.scale))
            firstLineView?.backgroundColor = titleLabel?.textColor
            backView?.addSubview(firstLineView!)
            
            secondLineView = UIView.init(frame: CGRect.init(x: (backView?.frame.width)!/2, y: (backView?.frame.height)!-40, width: 1/UIScreen.main.scale, height: 40))
            secondLineView?.backgroundColor = titleLabel?.textColor
            backView?.addSubview(secondLineView!)
            
            
            if isForce {
                finishButton?.frame = CGRect.init(x: 0, y: (backView?.frame.height)!-40, width: (backView?.frame.width)!, height: 40)
                secondLineView?.isHidden = true
            }
            
            
        }
        return backView!
    }
    
    func finishClick() -> Void {
        if block != nil {
            block!(true)
        }
        self.removeFromSuperview()
    }
    
    func cancelClick() -> Void {
        self.removeFromSuperview()
        if block != nil {
            block!(false)
        }
    }
    
}
