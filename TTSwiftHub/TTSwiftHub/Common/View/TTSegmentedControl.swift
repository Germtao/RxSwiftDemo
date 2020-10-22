//
//  TTSegmentedControl.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/16.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HMSegmentedControl

class TTSegmentedControl: HMSegmentedControl {
    
    let segmentSelection = BehaviorRelay<Int>(value: 0)
    
    init() {
        super.init(sectionTitles: [])
        makeUI()
    }
    
    override init(sectionTitles sectiontitles: [String]) {
        super.init(sectionTitles: sectiontitles)
        makeUI()
    }
    
    override init(sectionImages: [UIImage]!, sectionSelectedImages: [UIImage]!) {
        super.init(sectionImages: sectionImages, sectionSelectedImages: sectionSelectedImages)
        makeUI()
    }
    
    override init(sectionImages: [UIImage]!, sectionSelectedImages: [UIImage]!, titlesForSections sectiontitles: [String]!) {
        super.init(sectionImages: sectionImages, sectionSelectedImages: sectionSelectedImages, titlesForSections: sectiontitles)
        makeUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    func makeUI() {
        themeService.attrsStream.subscribe(onNext: { [weak self] theme in
            self?.backgroundColor = theme.primary
            self?.selectionIndicatorColor = theme.secondary
            let font = UIFont.systemFont(ofSize: 11)
            self?.titleTextAttributes = [NSAttributedString.Key.font: font,
                                         NSAttributedString.Key.foregroundColor: theme.text]
            self?.selectedTitleTextAttributes = [NSAttributedString.Key.font: font,
                                                 NSAttributedString.Key.foregroundColor: theme.secondary]
            self?.updateUI()
        }).disposed(by: rx.disposeBag)
        
        cornerRadius = Configs.BaseDimensions.cornerRadius
        imagePosition = .aboveText
        selectionStyle = .box
        selectionIndicatorLocation = .down
        selectionIndicatorBoxOpacity = 0
        selectionIndicatorHeight = 2.0
        segmentEdgeInset = UIEdgeInsets(inset: inset)
        indexChangeBlock = { [weak self] index in
            self?.segmentSelection.accept(index)
        }
        snp.makeConstraints { (make) in
            make.height.equalTo(Configs.BaseDimensions.segmentedControlHeight)
        }
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
}
