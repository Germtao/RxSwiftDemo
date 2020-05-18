//
//  TTEventsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/18.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum TTEventSegments: Int {
    case received, performed
    
    var title: String {
        switch self {
        case .received: return R.string.localizable.eventsReceivedSegmentTitle.key.localized()
        case .performed: return R.string.localizable.eventsPerformedSegmentTitle.key.localized()
        }
    }
}

enum TTEventsModel {
    case repository(repository: TTRepository)
    case user(user: TTUser)
}

class TTEventsViewModel: TTViewModel { //TTViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let segmentSelection: Observable<TTEventSegments>
//        let selection: Driver<>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let imageUrl: Driver<URL?>
//        let items: BehaviorRelay<[]>
//        let userSelected: Driver<TTUser
//        let repositorySelected: Driver<TTre
        
    }
    
//    func transform(input: Input) -> Output {
//        
//    }
}
