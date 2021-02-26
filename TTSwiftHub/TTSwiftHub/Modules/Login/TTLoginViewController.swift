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
        
        navigationItem.titleView = segmentedControl
        
        languageChanged
            .subscribe(onNext: { [weak self] () in
                self?.segmentedControl.sectionTitles = [
                    TTLoginSegments.oAuth.title,
                    TTLoginSegments.personal.title,
                    TTLoginSegments.basic.title
                ]
                
                // MARK: - Basic
                self?.loginTextField.placeholder = R.string.localizable.loginLoginTextFieldPlaceholder.key.localized()
                self?.passwordTextField.placeholder = R.string.localizable.loginPasswordTextFieldPlaceholder.key.localized()
                self?.basicLoginButton.titleForNormal = R.string.localizable.loginBasicLoginButtonTitle.key.localized()
                
                // MARK: - Personal
                self?.personalTitleLabel.text = R.string.localizable.loginTitleLabelText.key.localized()
                self?.personalDetailLabel.text = R.string.localizable.loginDetailLabelText.key.localized()
                self?.personalTokenTextField.placeholder = R.string.localizable.loginPersonalTokenTextFieldPlaceholder.key.localized()
                self?.personalLoginButton.titleForNormal = R.string.localizable.loginPersonalLoginButtonTitle.key.localized()
                
                // MARK: - OAuth
                self?.titleLabel.text = R.string.localizable.loginTitleLabelText.key.localized()
                self?.detailLabel.text = R.string.localizable.loginDetailLabelText.key.localized()
                self?.oAuthLoginButton.titleForNormal = R.string.localizable.loginOAuthloginButtonTitle.key.localized()
            })
            .disposed(by: rx.disposeBag)
        
        stackView.removeFromSuperview()
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(inset * 2)
            make.centerX.equalToSuperview()
        }
        
        themeService.rx
            .bind({ $0.text }, to: [titleLabel.rx.textColor, personalTitleLabel.rx.textColor])
            .bind({ $0.textGray }, to: [detailLabel.rx.textColor, personalDetailLabel.rx.textColor])
            .bind({ $0.text }, to: [basicLogoImageView.rx.tintColor, personalLogoImageView.rx.tintColor, oAuthLogoImageView.rx.tintColor])
            .disposed(by: rx.disposeBag)
        
        stackView.addArrangedSubview(basicLoginStackView)
        stackView.addArrangedSubview(personalLoginStackView)
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
            personalLoginTrigger: personalLoginButton.rx.tap.asDriver(),
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
        output.personalLoginButtonEnabled
            .drive(personalLoginButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        // MARK: - <-> 双向绑定
        _ = loginTextField.rx.textInput <-> viewModel.login
        _ = passwordTextField.rx.textInput <-> viewModel.password
        _ = personalTokenTextField.rx.textInput <-> viewModel.personalToken
        
        output.hidesBasicLoginView.drive(basicLoginStackView.rx.isHidden).disposed(by: rx.disposeBag)
        output.hidesPersonalLoginView.drive(personalLoginStackView.rx.isHidden).disposed(by: rx.disposeBag)
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
        let items = [TTLoginSegments.oAuth.title, TTLoginSegments.personal.title, TTLoginSegments.basic.title]
        let view = TTSegmentedControl(sectionTitles: items)
        view.selectedSegmentIndex = 0
        view.snp.makeConstraints({ make in
            make.width.equalTo(300)
        })
        return view
    }()
    
    // MARK: - Basic authentication
    
    lazy var basicLoginStackView: TTStackView = {
        let subviews: [UIView] = [basicLogoImageView, loginTextField, passwordTextField, basicLoginButton]
        let view = TTStackView(arrangedSubviews: subviews)
        view.spacing = inset * 2
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
    
    // MARK: - OAuth authentication
    
    lazy var oAuthLoginStackView: TTStackView = {
        let subviews: [UIView] = [oAuthLogoImageView, titleLabel, detailLabel, oAuthLoginButton]
        let view = TTStackView(arrangedSubviews: subviews)
        view.spacing = inset * 2
        return view
    }()
    
    lazy var oAuthLogoImageView = TTImageView(image: R.image.image_no_result()?.template)
    
    lazy var titleLabel: TTLabel = {
        let label = TTLabel()
        label.font = label.font.withSize(22)
        label.numberOfLines = 0
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
    
    // MARK: - Personal Access Token authentication
    
    lazy var personalLoginStackView: TTStackView = {
//        let subviews: [UIView]
        return <#value#>
    }()
    
    lazy var personalLogoImageView = TTImageView(image: R.image.image_no_result()?.template)
    
    lazy var personalTitleLabel: TTLabel = {
        let label = TTLabel()
        label.font = label.font.withSize(22)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var personalDetailLabel: TTLabel = {
        let label = TTLabel()
        label.font = label.font.withSize(17)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var personalTokenTextField: TTTextField = {
        let textField = TTTextField()
        textField.textAlignment = .center
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    lazy var personalLoginButton: TTButton = {
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
