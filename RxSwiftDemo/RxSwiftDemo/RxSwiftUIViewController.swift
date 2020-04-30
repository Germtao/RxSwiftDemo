//
//  RxSwiftUIViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2020/4/29.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxSwiftUIViewController: UIViewController {
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let backItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backItem
        
        setupUILabel()
        setupUIButton()
        setupUISwitch()
        setupSegmentedControl()
        setupUITextField()
        setupUITextView()
        setupUITableView()
        setupUISliderAndUIStepper()
    }
    
    @objc private func back() {
        dismiss(animated: true)
    }
}

// MARK: - UILabel
extension RxSwiftUIViewController {
    private func setupUILabel() {
        let label_1 = UILabel(frame: CGRect(x: 20, y: 100, width: 150, height: 30))
        view.addSubview(label_1)
        
        let label_2 = UILabel(frame: CGRect(x: label_1.frame.maxX + 20, y: label_1.frame.minY, width: 150, height: 30))
        label_2.textColor = .red
        view.addSubview(label_2)
        
        // 创建一个计时器（每0.1秒发送一个索引数）
        let timer = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance)
        
        // map: 转换闭包应用于可观察序列发出的元素，并返回转换后的元素的新可观察序列
        timer
            .map {
                String(format: "%0.2d:%0.2d.%0.1d", ($0 / 600) % 600, ($0 % 600) / 10, $0 % 10)
            }
            .bind(to: label_1.rx.text)
            .disposed(by: disposeBag)
        
        timer.map(formatTimeInterval(_:))
            .bind(to: label_2.rx.attributedText)
            .disposed(by: disposeBag)
    }
    
    /// 将数字转成对应的富文本
    private func formatTimeInterval(_ ms: Int) -> NSMutableAttributedString {
        let text = String(format: "%0.2d:%0.2d.%0.1d", (ms / 600) % 600, (ms % 600) / 10, ms % 10)
        
        let attriStr = NSMutableAttributedString(string: text)
        
        attriStr.addAttribute(NSAttributedString.Key.font,
                              value: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
                              range: NSMakeRange(0, 5))
        attriStr.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: UIColor.white,
                              range: NSMakeRange(0, 5))
        attriStr.addAttribute(NSAttributedString.Key.backgroundColor,
                              value: UIColor.orange,
                              range: NSMakeRange(0, 5))
        return attriStr
    }
}

// MARK: - UIButton
extension RxSwiftUIViewController {
    private func setupUIButton() {
        let button = UIButton(frame: CGRect(x: 20, y: 150, width: 100, height: 40))
        button.setTitle("按钮响应1", for: .normal)
        button.setTitleColor(.black, for: .normal)
        view.addSubview(button)
        
        button.rx.tap
            .subscribe(onNext: { print("按钮1被点击") })
            .disposed(by: disposeBag)
        
        let button2 = UIButton(frame: CGRect(x: 20, y: button.frame.maxY + 20, width: 100, height: 40))
        button2.setTitle("按钮响应2", for: .normal)
        button2.setTitleColor(.white, for: .normal)
        button2.backgroundColor = .orange
        view.addSubview(button2)
        
        button2.rx.tap
            .bind { print("按钮响应-2") }
            .disposed(by: disposeBag)
        
        let button3 = UIButton(frame: CGRect(x: button.frame.maxX, y: button.frame.minY, width: 100, height: 40))
        button3.setTitle("计数", for: .normal)
        button3.setTitleColor(.black, for: .normal)
        button3.backgroundColor = .cyan
        view.addSubview(button3)
        
        let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        timer
            .map { "计数 \($0)" }
            .bind(to: button3.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        let button4 = UIButton(frame: CGRect(x: button.frame.maxX, y: button3.frame.maxY + 20, width: 100, height: 40))
        button4.setTitle("计数", for: .normal)
        button4.setTitleColor(.black, for: .normal)
        button4.backgroundColor = .red
        button4.titleLabel?.adjustsFontSizeToFitWidth = true
        view.addSubview(button4)
        
        timer
            .map(formatTimeInterval(_:))
            .bind(to: button4.rx.attributedTitle(for: .normal))
            .disposed(by: disposeBag)
        
        let button5 = UIButton(frame: CGRect(x: button4.frame.maxX + 10, y: button4.frame.minY, width: 100, height: 40))
        button5.setTitle("颜色变换", for: .normal)
        button5.setTitleColor(.white, for: .normal)
        button5.backgroundColor = .gray
        view.addSubview(button5)
        
        timer.map {
            let bgColor = $0%2 == 0 ? UIColor.black : .gray
            return bgColor
        }
        .bind(to: button5.rx.backgroundColor)
        .disposed(by: disposeBag)
    }
}

// MARK: - UISwitch
extension RxSwiftUIViewController {
    private func setupUISwitch() {
        let switch1 = UISwitch(frame: CGRect(x: 20, y: 270, width: 80, height: 30))
        switch1.isOn = false
        view.addSubview(switch1)
        
        switch1.rx.isOn.asObservable()
            .subscribe(onNext: { print("switch: \($0)") })
            .disposed(by: disposeBag)
        
        let button = UIButton(frame: CGRect(x: switch1.frame.maxX + 20, y: switch1.frame.minY, width: 80, height: 30))
        button.setTitle("可点击", for: .normal)
        button.setTitle("不可点击", for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.backgroundColor = .purple
        view.addSubview(button)
        
        switch1.rx.isOn
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
        
        let activity = UIActivityIndicatorView(style: .large)
        activity.frame = CGRect(x: button.frame.maxX + 20, y: button.frame.minY, width: 30, height: 30)
        activity.hidesWhenStopped = true
        view.addSubview(activity)
        
        switch1.rx.value
            .bind(to: activity.rx.isAnimating)
            .disposed(by: disposeBag)
        
        switch1.rx.value
            .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
    }
}

// MARK: - UISegmentedControl
extension RxSwiftUIViewController {
    private func setupSegmentedControl() {
        let titles = ["1", "2", "3"]
        let segmented = UISegmentedControl(items: titles)
        segmented.frame = CGRect(x: 20, y: 320, width: 200, height: 30)
        segmented.selectedSegmentIndex = 0
        view.addSubview(segmented)
        
        let label = UILabel(frame: CGRect(x: segmented.frame.maxX + 20, y: segmented.frame.minY, width: 50, height: 20))
        label.textColor = .black
        view.addSubview(label)
        
        // 创建一个当前需要显示的图片的可观察序列
        let showTitleObservable: Observable<String> =
            segmented.rx.selectedSegmentIndex.asObservable().map { titles[$0] }
        
        // 把需要显示的text绑定到 label 上
        showTitleObservable
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}

extension RxSwiftUIViewController {
    private func setupUITextField() {
        // 输入框
        let inputTF = UITextField(frame: CGRect(x: 20, y: 370, width: 100, height: 30))
        inputTF.borderStyle = .roundedRect
        inputTF.placeholder = "输入"
        view.addSubview(inputTF)
        
        // 输出框
        let outputTF = UITextField(frame: CGRect(x: 20, y: inputTF.frame.maxY + 10, width: 100, height: 30))
        outputTF.borderStyle = .roundedRect
        outputTF.placeholder = "输出"
        view.addSubview(outputTF)
        
        let label = UILabel(frame: CGRect(x: inputTF.frame.maxX + 10, y: inputTF.frame.minY, width: 100, height: 30))
        view.addSubview(label)
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: outputTF.frame.maxX + 10, y: outputTF.frame.minY, width: 80, height: 30)
        button.setTitle("提交", for: .normal)
        view.addSubview(button)
        
        // 当文本框内容改变
        let input =
            inputTF.rx.text.orEmpty
                .asDriver() // 将普通序列转换为 Driver
                .throttle(.milliseconds(300)) // 在主线程中操作，0.3秒内值若多次改变，取最后一次
        
        // 内容绑定到输出框
        input
            .drive(outputTF.rx.text)
            .disposed(by: disposeBag)
        
        // 内容绑定到文本标签中
        input
            .map { "当前字数：\($0.count)" }
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        
        // 根据内容字数决定按钮是否可用
        input
            .map { $0.count > 5 }
            .drive(button.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

// MARK: - UITextView
extension RxSwiftUIViewController {
    private func setupUITextView() {
        let textView = UITextView(frame: CGRect(x: 20, y: 450, width: 200, height: 100))
        textView.text = "UITextView"
        view.addSubview(textView)
        
        // 开始编辑
        textView.rx.didBeginEditing
            .subscribe(onNext: { print("开始编辑") })
            .disposed(by: disposeBag)
        
        // 结束编辑
        textView.rx.didEndEditing
            .subscribe(onNext: { print("结束编辑") })
            .disposed(by: disposeBag)
        
        // 内容发生变化响应
        textView.rx.didChange
            .subscribe(onNext: { print("内容发生变化 ", $0) })
            .disposed(by: disposeBag)
        
        // 选中部分发生变化
        textView.rx.didChangeSelection
            .subscribe(onNext: { print("选中部分发生变化 ", $0) })
            .disposed(by: disposeBag)
    }
}

extension RxSwiftUIViewController {
    private func setupUITableView() {
        let button_1 = UIButton(type: .system)
        button_1.frame = CGRect(x: 20, y: 570, width: 100, height: 30)
        button_1.setTitle("传统方式", for: .normal)
        button_1.setTitleColor(.white, for: .normal)
        button_1.setTitleColor(.lightGray, for: .highlighted)
        button_1.backgroundColor = .cyan
        view.addSubview(button_1)
        
        let button_2 = UIButton(type: .system)
        button_2.frame = CGRect(x: button_1.frame.maxX + 20, y: button_1.frame.minY, width: 100, height: 30)
        button_2.setTitle("RxSwift方式", for: .normal)
        button_2.setTitleColor(.white, for: .normal)
        button_2.setTitleColor(.lightGray, for: .highlighted)
        button_2.backgroundColor = .cyan
        view.addSubview(button_2)
        
        button_1.rx.tap.subscribe(onNext: {
            self.presentTableVc(false)
        })
        .disposed(by: disposeBag)
        
        button_2.rx.tap.subscribe(onNext: {
            self.presentTableVc(true)
        })
        .disposed(by: disposeBag)
    }
    
    private func presentTableVc(_ isRx: Bool) {
        let rxVc = RxSwiftTableViewController(isRx: isRx)
        present(rxVc, animated: true)
    }
}

// MARK: - UISlider & UIStepper
extension RxSwiftUIViewController {
    private func setupUISliderAndUIStepper() {
        let slider = UISlider(frame: CGRect(x: 20, y: 620, width: 150, height: 20))
        slider.value = 0.5
        slider.minimumValue = 0.1
        view.addSubview(slider)
        
        let stepper = UIStepper(frame: CGRect(x: slider.frame.maxX + 20, y: 620, width: 150, height: 20))
        view.addSubview(stepper)
        
        let label = UILabel(frame: CGRect(x: stepper.frame.maxX + 10, y: slider.frame.minY, width: 100, height: 20))
        view.addSubview(label)
        
        slider.rx.value
            .asObservable()
            .subscribe(onNext: { print("slider value: \($0)")})
            .disposed(by: disposeBag)
        
        stepper.rx.value
            .asObservable()
            .subscribe(onNext: { print("stepper value: \($0)") })
            .disposed(by: disposeBag)
        
        slider.rx.value
            .map { Double($0) }
            .bind(to: stepper.rx.stepValue)
            .disposed(by: disposeBag)
        
        stepper.rx.value
            .map { "\($0)" }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}
