//
//  TTTrendingGithubAPI.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/19.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import Moya

enum TTTrendingGithubAPI {
    case trendingRepositories(language: String, since: String)
    case trendingDevelopers(language: String, since: String)
    case languages
}

extension TTTrendingGithubAPI: TargetType, TTProductAPIType {
    var baseURL: URL {
        return Configs.Network.trendingGithubBaseUrl.url!
    }
    
    var path: String {
        switch self {
        case .trendingRepositories: return "/repositories"
        case .trendingDevelopers: return "/developers"
        case .languages: return "/languages"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        var dataUrl: URL?
        switch self {
        case .trendingRepositories: dataUrl = R.file.repositoryTrendingsJson()
        case .trendingDevelopers: dataUrl = R.file.userTrendingsJson()
        case .languages: dataUrl = R.file.languagesJson()
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
        var params: [String: Any] = [:]
        switch self {
        case .trendingDevelopers(let language, let since),
             .trendingRepositories(let language, let since):
            params["language"] = language
            params["since"] = since
        default: break
        }
        return params
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
}
