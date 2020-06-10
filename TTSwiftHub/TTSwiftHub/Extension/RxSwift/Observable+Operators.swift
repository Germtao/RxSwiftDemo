//
//  Observable+Operators.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//extension Reactive where Base: UIView {
//    func tap() -> Observable<Void> {
//        return tapge
//    }
//}

protocol OptionalType {
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    var value: Wrapped? {
        return self
    }
}

extension Observable where Element: OptionalType {
    /// 筛出nil
    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { elemet -> Observable<Element.Wrapped> in
            if let value = elemet.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }
    
    func filterNibKeepOptional() -> Observable<Element> {
        return self.filter { element -> Bool in
            return element.value != nil
        }
    }
    
    func replaceNil(with nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
        return flatMap { element -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .just(nilValue)
            }
        }
    }
}

protocol BooleanType {
    var boolValue: Bool { get }
}

extension Bool: BooleanType {
    var boolValue: Bool { return self }
}

// MARK: - 将true映射为false，反之亦然
extension Observable where Element: BooleanType {
    func not() -> Observable<Bool> {
        return map { input in
            return !input.boolValue
        }
    }
}

extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (selfE) -> Bool in
            return value != selfE
        }
    }
}

extension ObservableType where Element == Bool {
    /// 布尔非运算符
    public func not() -> Observable<Bool> {
        return map(!)
    }
}

extension ObservableType {
    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            assertionFailure("Error: \(error)")
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}
