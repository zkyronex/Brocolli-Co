//
//  HomeViewController.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import UIKit
import RxSwift
import RxCocoa

protocol HomeRouting {
    func register()
}

final class HomeViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "brocolli"))
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Brocolli & Co."
        label.textColor = .white
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Request an Invitation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .primary
        button.layer.cornerRadius = .layout(.corner)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let cancelRegistionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel Invitation", for: .normal)
        button.setTitleColor(.secondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let router: HomeRouting
    private let registrationManager: RegistrationManaging
    private let disposeBag = DisposeBag()

    init(router: HomeRouting, registrationManager: RegistrationManaging) {
        self.router = router
        self.registrationManager = registrationManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
        prepareConstraints()
        prepareBindings()
    }

    private func prepareView() {
        view.backgroundColor = .background
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(registerButton)
        view.addSubview(cancelRegistionButton)
    }

    private func prepareConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .layout(.outer)),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .layout(.inner)),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -.layout(.inner)),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .layout(.outer)),
            descriptionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),

            registerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.layout(.outer)),
            registerButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .layout(.outer)),
            registerButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -.layout(.outer)),
            registerButton.heightAnchor.constraint(equalToConstant: .size(.buttonHeight)),

            cancelRegistionButton.topAnchor.constraint(equalTo: registerButton.topAnchor),
            cancelRegistionButton.bottomAnchor.constraint(equalTo: registerButton.bottomAnchor),
            cancelRegistionButton.leadingAnchor.constraint(equalTo: registerButton.leadingAnchor),
            cancelRegistionButton.trailingAnchor.constraint(equalTo: registerButton.trailingAnchor),
        ])
    }

    private func prepareBindings() {
        registerButton.rx.tap
            .subscribe(onNext: { [router] in
                router.register()
            })
            .disposed(by: disposeBag)

        let isRegistered = registrationManager.registration.map { $0 != nil }

        isRegistered
            .subscribe(registerButton.rx.isHidden)
            .disposed(by: disposeBag)

        isRegistered
            .map { !$0 }
            .subscribe(cancelRegistionButton.rx.isHidden)
            .disposed(by: disposeBag)

        registrationManager.registration
            .map {
                if let email = $0 {
                    return "You have successfully registered \(email)"
                } else {
                    return "This service is in closed beta for people who have requested an invite."
                }
            }
            .subscribe(descriptionLabel.rx.text)
            .disposed(by: disposeBag)

        cancelRegistionButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                confirmCancel()
            })
            .disposed(by: disposeBag)
    }

    private func confirmCancel() {
        let alertController = UIAlertController(
            title: "Are you sure?",
            message: nil,
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(
            title: "Cancel Invitation",
            style: .destructive,
            handler: { _ in
                self.registrationManager.deregister()
                self.showCancelledAlert()
            }
        )
        alertController.addAction(cancelAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    private func showCancelledAlert() {
        let alertController = UIAlertController(
            title: "Invitation Successfully Cancelled",
            message: "You will not be notified when the Beta is out.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

