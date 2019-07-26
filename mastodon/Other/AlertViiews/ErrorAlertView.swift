//
//  ErrorView.swift
//  mastodon
//
//  Created by Barrett Breshears on 7/22/19.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import UIKit
import SwiftMessages

class ErrorAlertView: MessageView {

    class func instanceFromNib() -> ErrorAlertView {
        return UINib(nibName: "ErrorAlertView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ErrorAlertView
    }
    
}
