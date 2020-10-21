//
//  TTContentsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTContentsViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let selection: Driver<TTContentCellViewModel>
        let openInWebSelection: Observable<Void>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let items: BehaviorRelay<[TTContentCellViewModel]>
        let openContents: Driver<TTContentsViewModel>
        let openUrl: Driver<URL?>
        
    }
}
