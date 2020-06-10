//
//  TTRepositoryViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/9.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTRepositoryViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let imageSelection: Observable<Void>
        let openInWebSelection: Observable<Void>
        let watchersSelection: Observable<Void>
        let starsSelection: Observable<Void>
        let forksSelection: Observable<Void>
//        let selection: Driver<RepositorySectionItem>
        let starSelection: Observable<Void>
    }
    
    struct Output {
//        let items: Observable<[RepositorySection]>
        let name: Driver<String>
        let description: Driver<String>
        let imageUrl: Driver<URL?>
        let starring: Driver<Bool>
        let hidesStarButton: Driver<Bool>
        let watchersCount: Driver<Int>
        let starsCount: Driver<Int>
        let forksCount: Driver<Int>
//        let imageSelected: Driver<TTUserViewModel>
        let openInWebSelected: Driver<URL>
        let repositoriesSelected: Driver<TTRepositoriesViewModel>
//        let usersSelected: Driver<UsersViewModel>
//        let selectedEvent: Driver<RepositorySectionItem>
    }
    
    func transform(input: Input) -> Output {
        return Output
    }
}
