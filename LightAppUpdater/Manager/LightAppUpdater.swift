//
//  TLH_NetWorkManager.swift
//  LightAppUpdater
//
//  Created by 赵文龙 on 2017/9/4.
//  Copyright © 2017年 zhaowenlong. All rights reserved.
//

import UIKit

struct IdentityAndTrust {
    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:AnyObject
}


public enum RequestType {
    case Post
}

open class LightAppUpdater: NSObject,URLSessionDelegate {
    
    public var requestPath:String = "http://192.168.0.251:8080/"
    public var version:Int = 0
    public var PKCS12Data:CFData?
    public var keyPass:String = ""
    public var selfSignedHosts:Array<String>?
    
    open static let shareManager:LightAppUpdater = {
       return LightAppUpdater()
    }()
    
    open static let sessionManager:URLSession = {
       let con = URLSessionConfiguration.default
        let session = URLSession.init(configuration: con, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        
        return session
    }()

    open func request_getAppUpdate(_ path:String,params:[String:Any],withMethod method:RequestType,isHandle:Bool, success:@escaping (_ responseData:[String:Any],_ isUpdate:Bool)->Void,failure:@escaping (_ error:Error)->Void) -> Void {
        
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
                if Int(responseData?["version"] as! NSNumber) == self.version {
                    success(responseData!,false)
                }
                else {
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
                        else {
                            DispatchQueue.main.async {
                                success(responseData!, false)
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            success(responseData!, false)
                        }
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
    
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod
            == NSURLAuthenticationMethodServerTrust
            && self.selfSignedHosts!.contains(challenge.protectionSpace.host) {
            print("服务器认证！")
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        }
            //认证客户端证书
        else if challenge.protectionSpace.authenticationMethod
            == NSURLAuthenticationMethodClientCertificate
        {
            print("客户端证书认证！")
            //获取客户端证书相关信息
            let identityAndTrust:IdentityAndTrust = self.extractIdentity()
            
            let urlCredential:URLCredential = URLCredential(
                identity: identityAndTrust.identityRef,
                certificates: identityAndTrust.certArray as? [AnyObject],
                persistence: URLCredential.Persistence.forSession)
            
            completionHandler(.useCredential, urlCredential)
        }
            // 其它情况（不接受认证）
        else {
            print("其它情况（不接受认证）")
            completionHandler(.cancelAuthenticationChallenge, nil);
        }
    }
    
    //获取客户端证书相关信息
    func extractIdentity() -> IdentityAndTrust {
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
//        let path: String = Bundle.main.path(forResource: "mykey", ofType: "p12")!
//        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : keyPass] //客户端证书密码
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        
        var items : CFArray?
        
        securityError = SecPKCS12Import(PKCS12Data!, options, &items)
        
        if securityError == errSecSuccess {
            let certItems:CFArray = items as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!
                print("\(String(describing: identityPointer))  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"]
                let trustRef:SecTrust = trustPointer as! SecTrust
                print("\(String(describing: trustPointer))  :::: \(trustRef)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"]
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
                                                    trust: trustRef, certArray:  chainPointer!)
            }
        }
        return identityAndTrust;
    }
    
}
