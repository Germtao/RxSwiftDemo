//
//  TTBranchCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
//import R

class TTBranchCellViewModel: TTDefaultTableViewCellViewModel {
    let branch: TTBranch
    
    init(branch: TTBranch) {
        self.branch = branch
        super.init()
        title.accept(branch.name)
        image.accept(R.image.icon_cell_git_branch()?.template)
    }
}
