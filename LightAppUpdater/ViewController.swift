//
//  ViewController.swift
//  LightAppUpdater
//
//  Created by 赵文龙 on 2017/9/4.
//  Copyright © 2017年 zhaowenlong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        TLH_NetWorkManager.shareManager.request_getAppUpdate("update/app/getVersion", params: ["appUnique":"com.tlh.QXTSimple","platform":"ios","version":"10"], withMethod: .Post,isHandle:true, success: { (responseData,isUpdate) in
            
            if isUpdate {
                
            }
            else {
                
            }
        
        }) { (error) in
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

