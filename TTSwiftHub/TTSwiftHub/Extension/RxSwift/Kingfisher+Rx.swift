//
//  Kingfisher+Rx.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/16.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

extension Reactive where Base: UIImageView {
    public var imageURL: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil)
    }
    
    public func imageURL(withPlaceholder placeholder: UIImage?, options: KingfisherOptionsInfo? = []) -> Binder<URL?> {
        return Binder(self.base) { (imageView, url) in
            imageView.kf.setImage(with: url,
                                  placeholder: placeholder,
                                  options: options,
                                  progressBlock: nil) { result in }
        }
    }
}

extension ImageCache: ReactiveCompatible {}

extension Reactive where Base: ImageCache {
    /// 检索缓存大小
    func retrieveCacheSize() -> Observable<Int> {
        return Single.create { single -> Disposable in
            self.base.calculateDiskStorageSize { result in
                do {
                    single(.success(Int(try result.get())))
                } catch {
                    single(.error(error))
                }
            }
            return Disposables.create()
        }.asObservable()
    }
    
    /// 清空缓存
    public func clearCache() -> Observable<Void> {
        return Single.create { single -> Disposable in
            self.base.clearMemoryCache()
            self.base.clearDiskCache {
                single(.success(()))
            }
            return Disposables.create()
        }.asObservable()
    }
}
