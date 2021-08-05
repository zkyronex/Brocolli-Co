//
//  RegistrationPresenter.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import Foundation
import RxSwift

protocol RegistrationRouting {
    func registrationComplete()
    func registrationFailed(message: String)
}

protocol RegistrationFetching {
    func register(registration: Registration) -> Single<Registration>
}

protocol RegistrationPresenting {

    var name: AnyObserver<String> { get }
    var email: AnyObserver<String> { get }
    var confirmEmail: AnyObserver<String> { get }
    var isRegistrationEnabled: Observable<Bool> { get }
    var error: Observable<RegistrationPresenter.Error> { get }
    func register()
}

final class RegistrationPresenter: RegistrationPresenting {

    enum Error {
        case emailDoesntMatch
    }

    private let fetcher: RegistrationFetching
    private let router: RegistrationRouting
    private let manager: RegistrationManaging

    private let nameSubject = BehaviorSubject<String>(value: "")
    private let emailSubject = BehaviorSubject<String>(value: "")
    private let confirmEmailSubject = BehaviorSubject<String>(value: "")
    private let errorSubject = PublishSubject<RegistrationPresenter.Error>()
    private let disposeBag = DisposeBag()

    init(fetcher: RegistrationFetching, router: RegistrationRouting, manager: RegistrationManaging) {
        self.fetcher = fetcher
        self.router = router
        self.manager = manager
    }

    var isRegistrationEnabled: Observable<Bool> {
        let nameValid = nameSubject.map { $0.count >= 3 }
        let emailValid = emailSubject.map { $0.isValidEmail }
        let confirmEmailValid = confirmEmailSubject.map { !$0.isEmpty }
        return .combineLatest(nameValid, emailValid, confirmEmailValid) { $0 && $1 && $2 }.distinctUntilChanged()
    }

    var name: AnyObserver<String> {
        nameSubject.asObserver()
    }

    var email: AnyObserver<String> {
        emailSubject.asObserver()
    }

    var confirmEmail: AnyObserver<String> {
        confirmEmailSubject.asObserver()
    }

    var error: Observable<Error> {
        errorSubject
    }

    func register() {
        // Perform registration so long as emails match
        let emailsMatch = Observable.combineLatest(emailSubject, confirmEmailSubject) { $0 == $1 }
        let nameAndEmail = Observable.combineLatest(nameSubject, emailSubject)
        Observable.just(())
            .withLatestFrom(emailsMatch)
            .filter { $0 }
            .withLatestFrom(nameAndEmail)
            .map(Registration.init)
            .flatMap(fetcher.register)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [manager, router] in
                    manager.register($0)
                    router.registrationComplete()
                },
                onError: { [router] error in
                    switch error as? RegistrationError {
                    case let .server(message):
                        router.registrationFailed(message: message)
                    default:
                        router.registrationFailed(message: "Please try again.")
                    }
                }
            )
            .disposed(by: disposeBag)

        // Display error
        Observable.just(())
            .withLatestFrom(emailsMatch)
            .filter { !$0 }
            .subscribe(onNext: { [errorSubject] _ in
                errorSubject.onNext(.emailDoesntMatch)
            })
            .disposed(by: disposeBag)
    }
}

extension String {

    // Lifted from https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
    fileprivate var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}
