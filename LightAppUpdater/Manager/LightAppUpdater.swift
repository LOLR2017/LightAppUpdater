//
//  TLH_NetWorkManager.swift
//  LightAppUpdater
//
//  Created by 赵文龙 on 2017/9/4.
//  Copyright © 2017年 zhaowenlong. All rights reserved.
//

import UIKit


enum RequestType {
    case Post
}


class LightAppUpdater: NSObject {
    
    public var requestPath:String = "http://192.168.0.251:8080/"
    
    static let shareManager:LightAppUpdater = {
       return LightAppUpdater()
    }()
    
    static let sessionManager:URLSession = {
       let con = URLSessionConfiguration.default
        let session = URLSession.init(configuration: con)
        return session
    }()

    func request_getAppUpdate(_ path:String,params:[String:Any],withMethod method:RequestType,isHandle:Bool, success:@escaping (_ responseData:[String:Any],_ isUpdate:Bool)->Void,failure:@escaping (_ error:Error)->Void) -> Void {
        
        let url = URL.init(string: self.requestPath+path)
        var request = URLRequest.init(url: url!)
        let list = NSMutableArray()
        if params.count > 0 {
            switch method {
            case .Post:
                request.httpMethod = "POST"
            }
            for subDic in params {
                let temStr = "\(subDic.0)=\(subDic.1)"
                list.add(temStr)
            }
            let paramStr = list.componentsJoined(by: "&")
            let paramData = paramStr.data(using: .utf8)
            request.httpBody = paramData
        }
        
        let task = LightAppUpdater.sessionManager.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                    let responseData = try?JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
                    print(response!)
                    print(responseData!)
                
                if isHandle {
                    
                    if responseData?["needUpdate"] as! NSNumber == 1 && responseData?["appStatus"] as! NSNumber == 2 {
                        
                        TLH_HitView.shareHitView.content = responseData?["updateInfo"] as! String
                        if responseData?["lastForce"] as! NSNumber == 1 {
                            TLH_HitView.shareHitView.isForce = true
                        }
                        DispatchQueue.main.async {
                            TLH_HitView.shareHitView.show(nil, inView: nil, success: { (finish) in
                                success(responseData!,finish)
                            })
                        }
                    }
                    
//                    DispatchQueue.main.async {
//                        success(responseData!, false)
//                    }
                    
                }
                else {
                    DispatchQueue.main.async {
                        success(responseData!, false)
                    }
                }
                
            }
            else {
                print(error!)
                failure(error!)
            }
        }
        task.resume()
    }
    
    
}
