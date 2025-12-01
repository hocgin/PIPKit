//
//  UIViewController+Associated.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import UIKit

extension UIViewController {
    
    @available(iOS 15.0, *)
    var pvideoController: AVPPIPKitVideoController? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.pipVideoController) as? AVPPIPKitVideoController }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.pipVideoController,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
}

