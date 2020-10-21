//
//  TTContactCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTContactCellViewModel: TTDefaultTableViewCellViewModel {
    let contact: TTContact
    
    init(contact: TTContact) {
        self.contact = contact
        super.init()
        
        title.accept(contact.name)
        
        let info = contact.phones + contact.emails
        detail.accept(info.joined(separator: ", "))
        
        image.accept(UIImage(data: contact.imageData ?? Data()) ?? R.image.icon_cell_contact_no_image()?.template)
    }
}
