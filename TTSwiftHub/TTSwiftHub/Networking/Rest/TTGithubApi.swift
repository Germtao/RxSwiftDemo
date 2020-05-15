//
//  TTGithubApi.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import Moya

enum TTGithubAPI {
    case download(url: URL, fileName: String?)
    
    // MARK: - Authentication is optional
    
    
    // MARK: - Authentication is required
    
}

extension TTGithubAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .download(let url, _): return url
//        default: return Configs.Network.githubBaseUrl.url!
        }
    }
    
    var path: String {
        switch self {
        case .download: return ""
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        var dataUrl: URL?
        switch self {
        case .download: break
        }
        
        guard let url = dataUrl, let data = try? Data(contentsOf: url) else { return Data() }
        return data
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
