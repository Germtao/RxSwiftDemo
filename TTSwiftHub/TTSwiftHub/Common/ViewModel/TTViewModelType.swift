//
//  TTViewModelType.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper

protocol TTViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class TTViewModel: NSObject {
    
    let provider: TTSwiftHubAPI
    
    var page = 1
    
    let loading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()
    
    let error = ErrorTracker()
    let parsedError = PublishSubject<ApiError>()
    
    init(provider: TTSwiftHubAPI) {
        self.provider = provider
        super.init()
        
        error.asObservable()
            .map { error -> ApiError? in
                do {
                    let errorResponse = error as? MoyaError
                    if let body = try errorResponse?.response?.mapJSON() as? [String: Any],
                        let errorResponse = Mapper<ErrorResponse>().map(JSON: body) {
                        return ApiError.serverError(response: errorResponse)
                    }
                } catch {
                    logError(error.localizedDescription)
                }
                return nil
            }
            .filterNil()
            .bind(to: parsedError)
            .disposed(by: rx.disposeBag)
        
        error.asDriver()
            .drive(onNext: { error in
                logError("\(error.localizedDescription)")
            })
            .disposed(by: rx.disposeBag)
    }
    
    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }
}
