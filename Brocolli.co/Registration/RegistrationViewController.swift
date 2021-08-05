//
//  RegistrationViewController.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import UIKit
import RxSwift
import RxCocoa

protocol DismissRouting {
    func viewDismissed()
}

final class RegistrationViewController: UIViewController {

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = .layout(.inner)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let registerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = .layout(.inner)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Registration"
        label.textColor = .primary
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tintColor = .primary
        textField.textColor = .secondary
        textField.attributedPlaceholder = NSAttributedString(
            string: "Full Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )

        return textField
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tintColor = .primary
        textField.textColor = .secondary
        textField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return textField
    }()

    private let confirmEmailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tintColor = .primary
        textField.textColor = .secondary
        textField.attributedPlaceholder = NSAttributedString(
            string: "Confirm Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )

        return textField
    }()

    private let sendLabel: UILabel = {
        let label = UILabel()
        label.text = "Give Me Access"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .primary
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let sendButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)
        button.setImage(UIImage(systemName: "arrow.right", withConfiguration: configuration), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = .size(.buttonHeight) / 2

        return button
    }()

    private let presenter: RegistrationPresenting
    private let dismissRouter: DismissRouting
    private let disposeBag = DisposeBag()

    init(presenter: RegistrationPresenting, dismissRouter: DismissRouting) {
        self.presenter = presenter
        self.dismissRouter = dismissRouter
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        dismissRouter.viewDismissed()
    }

    private func prepareView() {
        view.backgroundColor = .white

        view.addSubview(titleLabel)
        view.addSubview(textStackView)
        view.addSubview(registerStackView)

        textStackView.addArrangedSubview(nameTextField)
        textStackView.addArrangedSubview(emailTextField)
        textStackView.addArrangedSubview(confirmEmailTextField)

        registerStackView.addArrangedSubview(sendLabel)
        registerStackView.addArrangedSubview(sendButton)
    }

    private func prepareConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .layout(.outer)),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .layout(.outer)),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -.layout(.outer)),

            textStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .layout(.outer)),
            textStackView.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            textStackView.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),

            nameTextField.heightAnchor.constraint(equalToConstant: .size(.textFieldHeight)),
            emailTextField.heightAnchor.constraint(equalToConstant: .size(.textFieldHeight)),
            confirmEmailTextField.heightAnchor.constraint(equalToConstant: .size(.textFieldHeight)),

            registerStackView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: .layout(.section)),
            registerStackView.leftAnchor.constraint(equalTo: textStackView.leftAnchor),
            registerStackView.rightAnchor.constraint(equalTo: textStackView.rightAnchor),

            sendButton.heightAnchor.constraint(equalToConstant: .size(.buttonHeight)),
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor)
        ])

        prepareBorder(for: nameTextField)
        prepareBorder(for: emailTextField)
        prepareBorder(for: confirmEmailTextField)
    }

    private func prepareBorder(for textField: UITextField) {
        let underline = UIView()
        underline.backgroundColor = .separator
        underline.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(underline)
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leftAnchor.constraint(equalTo: textField.leftAnchor),
            underline.rightAnchor.constraint(equalTo: textField.rightAnchor),
            underline.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
        ])
    }

    private func prepareBindings() {
        presenter.isRegistrationEnabled
            .subscribe(sendButton.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)

        presenter.isRegistrationEnabled
            .map { $0 ? CGFloat(1) : CGFloat(0.3) }
            .subscribe(sendButton.rx.alpha)
            .disposed(by: disposeBag)

        sendButton.rx.tap
            .subscribe(onNext: presenter.register)
            .disposed(by: disposeBag)

        nameTextField.rx.text
            .map { $0 ?? "" }
            .subscribe(presenter.name)
            .disposed(by: disposeBag)

        emailTextField.rx.text
            .map { $0 ?? "" }
            .subscribe(presenter.email)
            .disposed(by: disposeBag)

        confirmEmailTextField.rx.text
            .map { $0 ?? "" }
            .subscribe(presenter.confirmEmail)
            .disposed(by: disposeBag)

        presenter.error
            .subscribe(onNext: { [confirmEmailTextField] error in
                switch error {
                case .emailDoesntMatch:
                    confirmEmailTextField.shake()
                }
            })
            .disposed(by: disposeBag)
    }
}

private extension UITextField {
    func shake() {
        layer.add(ShakeAnimation(), forKey: "shake")
    }
}
