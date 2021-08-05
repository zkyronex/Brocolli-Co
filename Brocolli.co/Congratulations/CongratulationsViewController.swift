//
//  CongratulationsViewController.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import UIKit
import RxSwift
import RxCocoa

protocol CongratulationsRouting {
    func congratulationsDismissed()
}

final class CongratulationsViewController: UIViewController {

    private let router: CongratulationsRouting
    private let disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Success!!!\n🎉 Stay Tuned 😎"
        label.textColor = .white
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setTitle("Back Home", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .primary
        button.layer.cornerRadius = .layout(.corner)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let confettiLayer = CAEmitterLayer()

    init(router: CongratulationsRouting) {
        self.router = router
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
        prepareConfetti()
        view.backgroundColor = .background
        view.addSubview(titleLabel)
        view.addSubview(backButton)

    }

    private func prepareConfetti() {
        confettiLayer.emitterPosition = CGPoint(x: view.center.x, y: -100)

        let cells: [CAEmitterCell] = [UIColor.red, .green, .blue, .cyan, .orange].compactMap {
            guard let image = UIImage(named: "sparkle-piece") else { return nil }

            let cell = CAEmitterCell()
            cell.scale = 0.1
            cell.emissionRange = .pi * 2
            cell.lifetime = 10
            cell.birthRate = 100
            cell.velocity = 150
            cell.color = $0.cgColor
            cell.contents = image.cgImage
            return cell
        }
        confettiLayer.emitterCells = cells

        view.layer.addSublayer(confettiLayer)
    }

    private func prepareConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.layout(.outer)),
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .layout(.outer)),
            backButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -.layout(.outer)),
            backButton.heightAnchor.constraint(equalToConstant: .size(.buttonHeight)),
        ])
    }

    private func prepareBindings() {
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                removeConfetti()
                router.congratulationsDismissed()
            })  
            .disposed(by: disposeBag)
    }

    private func removeConfetti() {
        UIView.animate(withDuration: 0.1) {
            self.confettiLayer.opacity = 0
        } completion: { _ in
            self.confettiLayer.removeFromSuperlayer()
        }
    }
}
