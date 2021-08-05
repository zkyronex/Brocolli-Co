//
//  RegistrationManager.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import Foundation
import RxSwift
import RxRelay

protocol RegistrationManaging {

    var registration: Observable<String?> { get }

    func register(_ registration: Registration)
    func deregister()
}

final class RegistrationManager: RegistrationManaging {

    private lazy var registrationRelay = BehaviorRelay<String?>(value: store.string(forKey: key))
    private let key = "registrationEmail"
    private var store: UserDefaults { UserDefaults.standard }

    var registration: Observable<String?> {
        registrationRelay.asObservable()
    }

    func register(_ registration: Registration) {
        store.setValue(registration.email, forKey: key)
        registrationRelay.accept(registration.email)
    }

    func deregister() {
        store.setValue(nil, forKey: key)
        registrationRelay.accept(nil)
    }
}
