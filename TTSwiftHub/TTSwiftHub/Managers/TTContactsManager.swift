//
//  TTContactsManager.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/20.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Contacts

typealias ContactsHandler = (_ contacts: [CNContact], _ error: NSError?) -> Void

enum TTContactsError: Error {
    case accessDenied
}

class TTContactsManager: NSObject {
    static let `default` = TTContactsManager()
    
    let contactsStore = CNContactStore()
    
    func getContacts(with keyword: String = "") -> Observable<[TTContact]> {
        return Single.create { single in
            switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
            case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
                // 用户已拒绝当前应用访问联系人
                single(.error(TTContactsError.accessDenied))
            case CNAuthorizationStatus.notDetermined:
                // 这种情况意味着第一次提示用户允许联系人
                self.contactsStore.requestAccess(for: CNEntityType.contacts) { (granted, error) in
                    if granted {
                        self.getContacts().subscribe { newContacts in
                            single(.success(newContacts))
                        }
                        .disposed(by: self.rx.disposeBag)
                    } else if let error = error {
                        single(.error(error))
                    }
                }
            case CNAuthorizationStatus.authorized:
                var contactsArray = [CNContact]()
                let contactFetchRequest = CNContactFetchRequest(keysToFetch: self.allowedContactKeys())
                contactFetchRequest.sortOrder = .givenName
                
                do {
                    try self.contactsStore.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) in
                        contactsArray.append(contact)
                    })
                    
                    single(.success(contactsArray.map { TTContact(with: $0) }.filter({ contact -> Bool in
                        if let name = contact.name, !keyword.isEmpty {
                            return name.contains(keyword, caseSensitive: false)
                        }
                        return true
                    })))
                    
                } catch {
                    single(.error(error))
                    logError(error.localizedDescription)
                }
            @unknown default: break
            }
            return Disposables.create {}
        }
        .asObservable()
    }
    
    /// We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
    ///
    /// - Returns: The allowed keys
    func allowedContactKeys() -> [CNKeyDescriptor] {
        return [CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor
        ]
    }
}
