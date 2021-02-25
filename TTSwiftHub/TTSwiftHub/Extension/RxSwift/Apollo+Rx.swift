//
//  Apollo+Rx.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/25.
//  Copyright © 2021 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Apollo

enum RxApolloError: Error {
    case graphQLErrors([GraphQLError])
}

extension ApolloClient: ReactiveCompatible {}

extension Reactive where Base: ApolloClient {
    func fetch<Query: GraphQLQuery>(query: Query,
                                    cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                    queue: DispatchQueue = .main) -> Single<Query.Data> {
        return Single.create { [weak base] (single) -> Disposable in
            let cancellableToken = base?.fetch(query: query, cachePolicy: cachePolicy, context: nil, queue: queue, resultHandler: { (result) in
                switch result {
                case .success(let graphResultQL):
                    if let data = graphResultQL.data {
                        single(.success(data))
                    } else if let errors = graphResultQL.errors {
                        // GraphQL errors
                        single(.error(RxApolloError.graphQLErrors(errors)))
                    }
                case .failure(let error):
                    // Network or response format errors
                    single(.error(error))
                }
            })
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
    
    func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = .main) -> Single<Query.Data> {
        return Single.create { [weak base] (single) -> Disposable in
            let cancellableToken = base?.watch(query: query, cachePolicy: cachePolicy, queue: queue, resultHandler: { (result) in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        single(.success(data))
                    } else if let errors = graphQLResult.errors {
                        // GraphQL errors
                        single(.error(RxApolloError.graphQLErrors(errors)))
                    }
                case .failure(let error):
                    // Network or response format errors
                    single(.error(error))
                }
            })
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
    
    func perform<Mutation: GraphQLMutation>(mutation: Mutation, queue: DispatchQueue = .main) -> Single<Mutation.Data> {
        return Single.create { [weak base] (single) -> Disposable in
            let cancellableToken = base?.perform(mutation: mutation, context: nil, queue: queue, resultHandler: { (result) in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        single(.success(data))
                    } else if let errors = graphQLResult.errors {
                        single(.error(RxApolloError.graphQLErrors(errors)))
                    }
                case .failure(let error):
                    single(.error(error))
                }
            })
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}
