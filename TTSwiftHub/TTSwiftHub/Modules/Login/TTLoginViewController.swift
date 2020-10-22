//
//  TTLoginViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class TTLoginViewController: TTBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged
            .subscribe(onNext: { [weak self] () in
                self?.loginTextField.placeholder = R.string.localizable.loginLoginTextFieldPlaceholder.key.localized()
                self?.passwordTextField.placeholder = R.string.localizable.loginPasswordTextFieldPlaceholder.key.localized()
                self?.basicLoginButton.titleForNormal = R.string.localizable.loginBasicLoginButtonTitle.key.localized()
                self?.titleLabel.text = R.string.localizable.loginTitleLabelText.key.localized()
                self?.detailLabel.text = R.string.localizable.loginDetailLabelText.key.localized()
                self?.oAuthLoginButton.titleForNormal = R.string.localizable.loginOAuthloginButtonTitle.key.localized()
                self?.segmentedControl.sectionTitles = [TTLoginSegments.oAuth.title, TTLoginSegments.basic.title]
                self?.navigationItem.titleView = self?.segmentedControl
            })
            .disposed(by: rx.disposeBag)
        
        stackView.removeFromSuperview()
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(self.inset * 2)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
        }
        
        themeService.rx
            .bind({ $0.text }, to: titleLabel.rx.textColor)
            .bind({ $0.textGray }, to: detailLabel.rx.textColor)
            .bind({ $0.text }, to: basicLogoImageView.rx.tintColor)
            .bind({ $0.text }, to: oAuthLogoImageView.rx.tintColor)
            .disposed(by: rx.disposeBag)
        
        stackView.addArrangedSubview(basicLoginStackView)
        stackView.addArrangedSubview(oAuthLoginStackView)
        
        bannerView.isHidden = true
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? TTLoginViewModel else { return }
        
        let segmentSelected = Observable.of(segmentedControl.segmentSelection.map { TTLoginSegments(rawValue: $0)! }).merge()
        let input = TTLoginViewModel.Input(
            segmentSelection: segmentSelected.asDriverOnErrorJustComplete(),
            basicLoginTrigger: basicLoginButton.rx.tap.asDriver(),
            oAuthLoginTrigger: oAuthLoginButton.rx.tap.asDriver()
        )
        let output = viewModel.transform(input: input)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)
        
        isLoading.asDriver()
            .drive(onNext: { [weak self] isLoading in
                isLoading ? self?.startAnimating() : self?.stopAnimating()
            })
            .disposed(by: rx.disposeBag)
        
        output.basicLoginButtonEnabled
            .drive(basicLoginButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        _ = loginTextField.rx.textInput <-> viewModel.login
        _ = passwordTextField.rx.textInput <-> viewModel.password
        
        output.hidesBasicLoginView.drive(basicLoginStackView.rx.isHidden).disposed(by: rx.disposeBag)
        output.hidesOAuthLoginView.drive(oAuthLoginStackView.rx.isHidden).disposed(by: rx.disposeBag)
        
        error
            .subscribe(onNext: { [weak self] error in
                var title = ""
                var description = ""
                let image = R.image.icon_toast_warning()
                switch error {
                case .serverError(let response):
                    title = response.message ?? ""
                    description = response.detail()
                }
                self?.view.makeToast(description, title: title, image: image)
            })
            .disposed(by: rx.disposeBag)
    }
    
    lazy var segmentedControl: TTSegmentedControl = {
        let items = [TTLoginSegments.oAuth.title, TTLoginSegments.basic.title]
        let view = TTSegmentedControl(sectionTitles: items)
        view.selectedSegmentIndex = 0
        view.snp.makeConstraints({ make in
            make.width.equalTo(250)
        })
        return view
    }()
    
    lazy var basicLoginStackView: TTStackView = {
        let subviews: [UIView] = [basicLogoImageView, loginTextField, passwordTextField, basicLoginButton]
        let view = TTStackView(arrangedSubviews: subviews)
        return view
    }()
    
    lazy var oAuthLoginStackView: TTStackView = {
        let subviews: [UIView] = [oAuthLogoImageView, titleLabel, detailLabel, oAuthLoginButton]
        let view = TTStackView(arrangedSubviews: subviews)
        return view
    }()
    
    lazy var basicLogoImageView = TTImageView(image: R.image.image_no_result()?.template)
    
    lazy var loginTextField: TTTextField = {
        let view = TTTextField()
        view.textAlignment = .center
        view.keyboardType = .emailAddress
        view.autocapitalizationType = .none
        return view
    }()
    
    lazy var passwordTextField: TTTextField = {
        let view = TTTextField()
        view.textAlignment = .center
        view.isSecureTextEntry = true
        return view
    }()
    
    lazy var basicLoginButton: TTButton = {
        let button = TTButton()
        button.imageForNormal = R.image.icon_button_github()
        button.centerTextAndImage(spacing: inset)
        return button
    }()
    
    lazy var oAuthLogoImageView = TTImageView(image: R.image.image_no_result()?.template)
    
    lazy var titleLabel: TTLabel = {
        let label = TTLabel()
        label.font = label.font.withSize(22)
        label.textAlignment = .center
        return label
    }()
    
    lazy var detailLabel: TTLabel = {
        let label = TTLabel()
        label.font = label.font.withSize(17)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var oAuthLoginButton: TTButton = {
        let button = TTButton()
        button.imageForNormal = R.image.icon_button_github()
        button.centerTextAndImage(spacing: inset)
        return button
    }()
    
    private lazy var scrollView: TTScrollView = {
        let view = TTScrollView()
        self.contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return view
    }()

}
