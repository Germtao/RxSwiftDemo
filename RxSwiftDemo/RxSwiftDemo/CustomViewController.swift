//
//  CustomViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2020/4/26.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum TestError: Error {
    case test
}

class CustomViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(leftBtn)
        
        subscribe()
        
        form()
        
        createObservable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        leftBtn.frame = CGRect(x: 20, y: 100, width: 100, height: 30)
    }
    
    lazy var leftBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Rx_Button", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.backgroundColor = .cyan
        button.addTarget(self, action: #selector(leftBtnClicked), for: .touchUpInside)
        return button
    }()
    

    @IBOutlet private weak var button: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var observableLabel: UILabel!
    @IBOutlet weak var observableLabel_1: UILabel!
    @IBOutlet weak var observableLabel_2: UILabel!
    
    @objc private func leftBtnClicked() {
//        print("leftBtnClicked")
        leftBtn.rx.tap // 序列，这里默认的序列是默认是.onTouchUpInside事件
            .subscribe(onNext: { () in
                // 订阅
                print("按钮点击")
            }, onError: { (error) in
                // 当Rxswift的事件链走不通，会回调这个onError，通知错误
                print("错误信息")
            }, onCompleted: {
                // 当Rxswift订阅的所有事件链走完了，会回调这个onCompleted，告知执行完毕，这个和onError是对立互斥的，两者只会发生一个
                print("订阅完成")
            })
            .disposed(by: DisposeBag()) // 销毁
    }
    
    private let disposeBag = DisposeBag()
}

// MARK: - 序列监听有三个步骤：
// 1.创建序列，2订阅序列，3.销毁序列。
// 当创建序列，并订阅了序列后，只要某个事件发送了序列消息，就可以在订阅的闭包里面监听到。
extension CustomViewController {
    private func subscribe() {
        // 1：创建序列
        // 利用函数式编程思想，在create()构造函数中传入一个闭包，这个闭包会被类对象保存起来，
        // 后续每个时间，事件触发的时候会回调这个传入的闭包，这样就像连接了一个链条一样，顺着链条就可找到需要调用的闭包。
        let ob = Observable<Any>.create { (observer) -> Disposable in
            // 3：发送信号
            observer.onNext([1, 2, 3, 4])
            observer.onCompleted()
            
            return Disposables.create()
        }
        
        // 2：订阅信息
        // 当我们订阅了Observable的消息后，只要Observable的事件触发，都会通过OnNext这个闭包告诉我们。
        let _ = ob.subscribe(onNext: { (text) in
            print("订阅到：\(text)")  // 这里会监听到订阅的Observable消息
        }, onError: { (error) in
            print("error：\(error)") // 当发生错误时，会回调这里
        }, onCompleted: {
            print("完成") // 当所有序列执行完毕时，会回调这里
        }) {
            print("销毁")
        }
    }
}

extension CustomViewController {
    private func form() {
        Observable.from(["haha", "T AO", "cc", "wswy", "Rx"])
            .subscribeOn(MainScheduler.instance)
            .filter { (text) -> Bool in
                return text == "T AO"
        }
        .map { (text) -> String in
            return "my name is " + text
        }
        .subscribe(onNext: { [weak self] (text) in
            self?.nicknameLabel.text = text
        })
        .disposed(by: DisposeBag())
    }
}

// MARK: - 可观察的序列Observable， 创建、订阅和销毁
extension CustomViewController {
    private func createObservable() {
        observableInSubscribe()
        observableInBind()
        observableWithAnyObserver()
        observableWithAnyObserverAndBind()
        observableWithBinder()
        
        never()
        empty()
        error()
        just()
        of()
        from()
        range()
        repeatElement()
        generate()
        deferred()
        doOn()
        create()
        timer()
        interval()
    }
    
    /// 在 subscribe 方法中创建Observable
    private func observableInSubscribe() {
        let observable = Observable.of("A", "B", "C")
        
        observable.subscribe(onNext: { (element) in
            print(element)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("completed")
        })
        .disposed(by: disposeBag)
    }
    
    /// 在 bind 方法中创建Observable
    private func observableInBind() {
        // Observable序列（每隔1秒钟发出一个索引数）
        let observable = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        
        observable
            .map { "当前索引：\($0)" }
            .bind { [weak self] text in
                // 收到发出的索引数后显示到label上
                self?.observableLabel.text = text
            }
            .disposed(by: disposeBag)
    }
    
    /// 使用 AnyObserver 创建Observable, AnyObserver 可以用来描叙任意一种观察者
    private func observableWithAnyObserver() {
        // 观察者
        let observer: AnyObserver<String> = AnyObserver { (event) in
            switch event {
            case .next(let text):
                print(text)
            case .error(let error):
                print(error)
            case .completed:
                print("completed")
            }
        }
        
        let observable = Observable.of("D", "E", "F")
        observable
            .subscribe(observer)
            .disposed(by: disposeBag)
    }
    
    /// AnyObserver配合bindTo 方法使用 也可配合 Observable 的数据绑定方法（bindTo）使用
    private func observableWithAnyObserverAndBind() {
        let observer: AnyObserver<String> = AnyObserver { [weak self] (event) in
            switch event {
            case .next(let text):
                self?.observableLabel_1.text = text
            default: break
            }
        }
        
        let observable = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        observable
            .map { "当前索引-1：\($0)"}
            .bind(to: observer)
            .disposed(by: disposeBag)
    }
    
    /// 使用 Binder 创建Observable
    /// 相较于AnyObserver 的大而全，Binder 更专注于特定的场景
    /// 1. 不会处理错误事件 2. 确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
    private func observableWithBinder() {
        // 观察者
        let observer: Binder<String> = Binder(observableLabel_2) { (view, text) in
            view.text = text
        }
        
        let observable = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        observable
            .map { "当前索引：\($0)"}
            .bind(to: observer)
            .disposed(by: disposeBag)
    }
    
    // MARK: - 使用工厂方法创建Observable
    /// never() ：创建一个Never序列，该序列不会发出任何事件，也不会终止
    private func never() {
        let observable = Observable<String>.never()
        observable.subscribe { _ in
            print("This will never be printed")
        }
        .disposed(by: disposeBag)
    }
    
    /// empty(): 创建一个Empty序列，该序列只发出completed事件
    private func empty() {
        Observable<Int>.empty().subscribe { event in
            print("empty: \(event)")
        }
        .disposed(by: disposeBag)
    }
    
    /// error(): 创建一个错误的序列，该序列以’error’事件终止。即创建一个不会发送任何条目并且立即终止错误的Observerable序列
    private func error() {
        Observable<Int>.error(TestError.test)
            .subscribe { print("error: \($0)") }
            .disposed(by: disposeBag)
    }
    
    /// just(): 创建一个Just序列，该序列只包含一个元素
    private func just() {
        Observable.just("just").subscribe { event in
            print("just: \(event)")
        }.disposed(by: disposeBag)
    }
    
    /// of(): 创建一个新的被观察序列的对象，它包含可变数量的元素
    private func of() {
        Observable.of("1", "2", "3", "4").subscribe { event in
            print("of: \(event)")
        }.disposed(by: disposeBag)
    }
    
    /// from(): 通过数组来创建一个被观察序列。从一个序列（如Array/Dictionary/Set）中创建一个Observer
    private func from() {
        Observable.from(["1", "2", "3", "4"])
            .subscribe(onNext: {
                print("from: \($0)")
            }).disposed(by: disposeBag)
    }
    
    /// range(): 在指定范围内生成一个被观察的整数序列，发出事件n次。即创建一个Observable序列，它会发出一系列连续的整数，然后终止
    private func range() {
        Observable.range(start: 1, count: 10)
            .subscribe { print("range: \($0)") }
            .disposed(by: disposeBag)
    }
    
    /// repeatElement(): 生成一个被观察的序列，重复发出指定元素n次
    private func repeatElement() {
        Observable.repeatElement("1")
            .take(3)
            .subscribe(onNext: { print("repeatElement: \($0)") })
            .disposed(by: disposeBag)
    }
    
    /// generate(): 创建一个被观察的序列，只要提供的条件为真，就发出状态值
    private func generate() {
        Observable.generate(initialState: 0,
                            condition: { $0 < 3 },
                            iterate: { $0 + 1 })
            .subscribe(onNext: { print("generate: \($0)") })
            .disposed(by: disposeBag)
    }
    
    /// deferred(): 为每个订阅事件的观察者都创建一个新的被观察的序列。（一对一的关系）
    private func deferred() {
        var count = 1
        let observable = Observable<String>.deferred {
            print("Creating \(count)")
            count += 1
            
            return Observable.create { observer in
                print("Emitting...")
                observer.onNext("1")
                observer.onNext("2")
                observer.onNext("3")
                return Disposables.create()
            }
        }
        
        observable
            .subscribe(onNext: { print("deferred: \($0)")})
            .disposed(by: disposeBag)
        
        observable
            .subscribe(onNext: { print("deferred: \($0)")})
            .disposed(by: disposeBag)
    }
    
    /// doOn(): 在订阅的被观察者的事件执行之前，先执行do后面和要执行的订阅事件对应的方法
    private func doOn() {
        Observable.of("1", "2", "3", "4")
            .do(onNext: { print("Intercepted: ", $0) },
                onError: { print("Intercepted error: ", $0) },
                onCompleted: { print("Completed") })
            .subscribe(onNext: { print("doOn: ", $0) },
                       onCompleted: { print("doOn Completed") })
            .disposed(by: disposeBag)
    }
    
    /// create(): 通过指定的方法实现来自定义一个被观察的序列
    private func create() {
        let myJust = { (element: String) -> Observable<String> in
            return Observable.create { observer in
                observer.on(.next(element))
                observer.on(.completed)
                return Disposables.create()
            }
        }
        
        myJust("1")
            .subscribe { print("create: ", $0) }
            .disposed(by: disposeBag)
    }
    
    /// timer(): 获取计时器Observable序列
    private func timer() {
        // 方式1：5秒种后发出唯一的一个元素0
        let observable_1 = Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance)
        observable_1.subscribe { event in
            print("timer_1: ", event)
        }.disposed(by: disposeBag)
        
        // 方式2：延时5秒种后，每隔1秒钟发出一个元素
        let observable_2 = Observable<Int>.timer(.seconds(5), period: .seconds(1), scheduler: MainScheduler.instance)
        observable_2.subscribe { event in
            print("timer_2: ", event)
        }.disposed(by: disposeBag)
    }
    
    /// interval(): 底层就是封装timer
    private func interval() {
        let observable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        observable.subscribe { event in
            print("interval: ", event)
        }.disposed(by: disposeBag)
    }
}
