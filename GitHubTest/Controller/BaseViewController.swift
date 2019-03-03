//
//  BaseViewController.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 26/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SVProgressHUD
import CoreData

extension UIViewController {
    
    func saveContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.saveContext()
    }

    func showAlertBar(with text: String, subText: String, style: BannerStyle = .danger) {
        let banner = GrowingNotificationBanner(title: "", subtitle: subText, style: style)
        banner.bannerHeight = 50
        banner.applyStyling(titleTextAlign: NSTextAlignment.center, subtitleTextAlign: NSTextAlignment.center)
        banner.show(on: self)
    }
    
    func showActivityIndicator() {
        SVProgressHUD.show()
    }
    
    func hideActivityIndicator() {
        SVProgressHUD.dismiss()
    }
    
}
