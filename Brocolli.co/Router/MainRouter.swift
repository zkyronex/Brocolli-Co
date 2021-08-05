//
//  MainRouter.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import UIKit
import RxSwift

final class MainRouter {

    var viewControllers: [UIViewController] = []
    let disposeBag = DisposeBag()
    private lazy var registrationManager = RegistrationManager()

    /// Setup method required to initialise UI hierarchy from window.
    func prepare(with window: UIWindow) {
        let viewController = HomeViewController(router: self, registrationManager: registrationManager)
        window.rootViewController = viewController
        viewControllers.append(viewController)
    }
}

extension MainRouter: HomeRouting {

    func register() {
        let presenter = RegistrationPresenter(
            fetcher: RegistrationFetcher(),
            router: self,
            manager: registrationManager
        )
        let viewController = RegistrationViewController(presenter: presenter, dismissRouter: self)
        viewControllers.last?.present(viewController, animated: true, completion: nil)
        viewControllers.append(viewController)
    }
}

extension MainRouter: RegistrationRouting {

    func registrationComplete() {
        viewControllers.last?.dismiss(animated: true) { [unowned self] in
            presentCongratulations()
        }
    }

    func registrationFailed(message: String) {
        let alertController = UIAlertController(
            title: "Oops",
            message: "We couldn't register you\n\(message)",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        viewControllers.last?.present(alertController, animated: true, completion: nil)
    }

    private func presentCongratulations() {
        let viewController = CongratulationsViewController(router: self)
        viewController.modalPresentationStyle = .fullScreen
        viewControllers.last?.present(viewController, animated: true, completion: nil)
    }
}

extension MainRouter: CongratulationsRouting {

    func congratulationsDismissed() {
        viewControllers.last?.dismiss(animated: true, completion: nil)
    }
}

extension MainRouter: DismissRouting {

    /// Generic implementation to deal with form sheet dismissal
    func viewDismissed() {
        _ = viewControllers.popLast()
    }
}
