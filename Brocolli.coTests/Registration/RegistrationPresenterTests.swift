//
//  RegistrationPresenterTests.swift
//  Brocolli.coTests
//
//  Created by Jason Chan on 6/8/21.
//

import RxSwift
import RxTest
import XCTest
@testable import Brocolli_co

private class Fetcher: RegistrationFetching {

    var registered: Registration?
    func register(registration: Registration) -> Single<Registration> {
        registered = registration
        return .just(registration)
    }
}

private class Router: RegistrationRouting {
    var completed = false
    func registrationComplete() {
        completed = true
    }

    var failedMessage: String?
    func registrationFailed(message: String) {
        failedMessage = message
    }
}

private class Manager: RegistrationManaging {

    var registration: Observable<String?> {
        .never()
    }

    var registered = false
    func register(_ registration: Registration) {
        registered = true
    }

    var deregistered = false
    func deregister() {
        deregistered = true
    }
}

final class RegistrationPresenterTests: XCTestCase {

    func testRegistration() throws {
        let scheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()

        let fetcher = Fetcher()
        let router = Router()
        let manager = Manager()
        let presenter = RegistrationPresenter(fetcher: fetcher, router: router, manager: manager)

        let isRegistrationEnabledObserver = scheduler.createObserver(Bool.self)
        presenter.isRegistrationEnabled.subscribe(isRegistrationEnabledObserver).disposed(by: disposeBag)
        XCTAssert(isRegistrationEnabledObserver.events.compactMap { $0.value.element } == [false])

        presenter.name.onNext("U")
        XCTAssert(isRegistrationEnabledObserver.events.compactMap { $0.value.element } == [false])

        presenter.email.onNext("user@email.com")
        XCTAssert(isRegistrationEnabledObserver.events.compactMap { $0.value.element } == [false])

        presenter.confirmEmail.onNext("user@email.com")
        XCTAssert(isRegistrationEnabledObserver.events.compactMap { $0.value.element } == [false])

        presenter.name.onNext("User")
        XCTAssertEqual(isRegistrationEnabledObserver.events.compactMap { $0.value.element }, [false, true])

        presenter.register()
        XCTAssertEqual(fetcher.registered?.name, "User")
        XCTAssertEqual(fetcher.registered?.email, "user@email.com")

        XCTAssertTrue(router.completed)
        XCTAssertTrue(manager.registered)
    }

    func testError() throws {
        let scheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()

        let fetcher = Fetcher()
        let router = Router()
        let manager = Manager()
        let presenter = RegistrationPresenter(fetcher: fetcher, router: router, manager: manager)

        let errorObserver = scheduler.createObserver(RegistrationPresenter.Error.self)
        presenter.error.subscribe(errorObserver).disposed(by: disposeBag)
        XCTAssertEqual(errorObserver.events.compactMap { $0.value.element }, [])

        presenter.email.onNext("user@email.com")
        presenter.confirmEmail.onNext("another@email.com")
        presenter.register()

        XCTAssertEqual(errorObserver.events.compactMap { $0.value.element }, [.emailDoesntMatch])
    }
}
