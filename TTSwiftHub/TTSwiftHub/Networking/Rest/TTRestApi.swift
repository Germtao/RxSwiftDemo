//
//  TTRestApi.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Moya_ObjectMapper

typealias MoyaError = Moya.MoyaError

enum ApiError: Error {
    case serverError(response: ErrorResponse)
}

class TTRestApi: TTSwiftHubAPI {
    
    let githubProvider: 
    
}
