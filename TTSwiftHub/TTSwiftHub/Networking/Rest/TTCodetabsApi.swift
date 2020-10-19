//
//  TTCodetabsApi.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/19.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import Moya

enum TTCodetabsApi {
    case numberOfLines(fullname: String)
}

extension TTCodetabsApi: TargetType, TTProductAPIType {
    var baseURL: URL {
        return Configs.Network.codetabsBaseUrl.url!
    }
    
    var path: String {
        return "/loc"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        var dataUrl: URL?
        switch self {
        case .numberOfLines:
            dataUrl = R.file.repositoryNumberOfLinesJson()
        }
        
        if let url = dataUrl, let data = try? Data(contentsOf: url) {
            return data
        }
        
        return Data()
    }
    
    var task: Task {
        if let parameters = parameters {
            return .requestParameters(parameters: parameters, encoding: parameterEncoding)
        }
        
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var addXAuth: Bool {
        return false
    }
    
    var parameters: [String: Any]? {
        var paras: [String: Any] = [:]
        switch self {
        case .numberOfLines(let fullname):
            paras["github"] = fullname
        }
        
        return paras
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
}
