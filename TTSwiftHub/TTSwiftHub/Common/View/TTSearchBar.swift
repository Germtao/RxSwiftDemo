//
//  TTSearchBar.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/25.
//  Copyright © 2021 tTao. All rights reserved.
//

import UIKit

class TTSearchBar: UISearchBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    func makeUI() {
        placeholder = R.string.localizable.commonSearch.key.localized()
        isTranslucent = false
        searchBarStyle = .minimal
        
        themeService.rx
            .bind({ $0.secondary }, to: rx.tintColor)
            .bind({ $0.primaryDark }, to: rx.barTintColor)
            .disposed(by: rx.disposeBag)
        
        if let textField = textField {
            themeService.rx
                .bind({ $0.text }, to: textField.rx.textColor)
                .bind({ $0.keyboardAppearance }, to: textField.rx.keyboardAppearance)
                .disposed(by: rx.disposeBag)
        }
        
        rx.textDidBeginEditing
            .asObservable()
            .subscribe(onNext: { [weak self] () in
                self?.setShowsCancelButton(true, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        rx.textDidEndEditing
            .asObservable()
            .subscribe(onNext: { [weak self] () in
                self?.setShowsCancelButton(false, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        rx.cancelButtonClicked
            .asObservable()
            .subscribe(onNext: { [weak self] () in
                self?.resignFirstResponder()
            })
            .disposed(by: rx.disposeBag)
        
        rx.searchButtonClicked
            .asObservable()
            .subscribe(onNext: { [weak self] () in
                self?.resignFirstResponder()
            })
            .disposed(by: rx.disposeBag)
        
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
}
