//
//  TTTableViewCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TTTableViewCell: UITableViewCell {
    
    var cellDisposeBag = DisposeBag()
    
    var isSelection = false
    var selectionColor: UIColor? {
        didSet {
            setSelected(isSelected, animated: true)
        }
    }
    
    lazy var containerView: TTView = {
        let view = TTView()
        view.backgroundColor = .clear
        view.cornerRadius = Configs.BaseDimensions.cornerRadius
        self.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: self.inset * 2, vertical: self.inset))
        })
        return view
    }()
    
    lazy var stackView: TTStackView = {
        let subviews: [UIView] = []
        let view = TTStackView(arrangedSubviews: subviews)
        view.axis = .horizontal
        view.alignment = .center
        self.containerView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().inset(inset)
        })
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        backgroundColor = selected ? selectionColor : .clear
    }
    
    func makeUI() {
        layer.masksToBounds = true
        selectionStyle = .none
        backgroundColor = .clear
        
        themeService.rx
            .bind({ $0.primary }, to: rx.selectionColor)
            .bind({ $0.primary }, to: containerView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }

}

extension Reactive where Base: TTTableViewCell {
    var selectionColor: Binder<UIColor?> {
        return Binder(self.base) { (view, color) in
            view.selectionColor = color
        }
    }
}
