//
//  Configs.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import UIKit

@_exported import SnapKit
@_exported import NSObject_Rx
@_exported import DZNEmptyDataSet
@_exported import RxSwiftExt
@_exported import Hero

struct Configs {
    struct BaseDimensions {
        static let inset: CGFloat = 10
    }
    
    struct UserDefaultsKeys {
        static let bannersEnabled = "BannersEnabled"
    }
}
