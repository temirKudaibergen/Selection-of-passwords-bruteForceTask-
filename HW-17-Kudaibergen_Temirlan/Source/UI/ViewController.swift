//
//  ViewController.swift
//  HW-17-Kudaibergen_Temirlan
//
//  Created by Темирлан Кудайберген on 20.04.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
    }
    private var isGeneratePasswordButtonPressed = false
    private var isStopGeneratePasswordButtonPressed = false
    private let queue = DispatchQueue.global(qos: .background)
    
    // MARK: UI
    
    private lazy var textFieldPassword: UITextField = {
        var textFieldPassword = UITextField()
        textFieldPassword.placeholder = "Пароль"
        textFieldPassword.textAlignment = .center
        textFieldPassword.isSecureTextEntry = true
        textFieldPassword.backgroundColor = .lightGray
        textFieldPassword.layer.cornerRadius = 15
        return textFieldPassword
    }()
    
    private lazy var label: UILabel = {
        var label = UILabel()
        label.text = "****"
        label.textColor = .link
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.clipsToBounds = true
        label.layer.cornerRadius = 15
        return label
    }()
    
    private lazy var colorChangeButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .link
        button.layer.cornerRadius = 15
        button.setTitle("Сменить тему", for: .normal)
        button.addTarget(self, action: #selector(colorChangeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var generatePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сгенерировать пароль", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(generatePasswordButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopGeneratePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Остановить", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(stopGeneratePasswordButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //    MARK: Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
    }
    
    //    MARK: Setup
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(textFieldPassword)
        view.addSubview(label)
        view.addSubview(generatePasswordButton)
        view.addSubview(stopGeneratePasswordButton)
        view.addSubview(colorChangeButton)
    }
    
    private func setupLayout() {
        textFieldPassword.snp.makeConstraints{
            $0.centerX.equalTo(view)
            $0.centerY.equalTo(view).offset(-50)
            $0.width.equalTo(300)
            $0.height.equalTo(40)
        }
        label.snp.makeConstraints{
            $0.top.equalTo(textFieldPassword.snp.bottom).offset(15)
            $0.centerX.equalTo(view)
            $0.height.equalTo(40)
        }
        generatePasswordButton.snp.makeConstraints{
            $0.top.equalTo(label.snp.bottom).offset(15)
            $0.centerX.equalTo(view)
            $0.width.equalTo(200)
            $0.height.equalTo(40)
        }
        stopGeneratePasswordButton.snp.makeConstraints{
            $0.top.equalTo(generatePasswordButton.snp.bottom).offset(15)
            $0.centerX.equalTo(view)
            $0.width.equalTo(200)
            $0.height.equalTo(40)
        }
        colorChangeButton.snp.makeConstraints{
            $0.centerX.equalTo(view)
            $0.centerY.equalTo(view.snp.bottom).offset(-70)
            $0.width.equalTo(200)
            $0.height.equalTo(40)
        }
    }
    
    // MARK: Actions
    
    @objc private func generatePasswordButtonPressed() {
        isGeneratePasswordButtonPressed = true
        isStopGeneratePasswordButtonPressed = false
        textFieldPassword.isSecureTextEntry = true
        bruteForce(passwordToUnlock: textFieldPassword.text ?? "")
    }
    
    @objc private func colorChangeButtonPressed() {
        isBlack.toggle()
    }
    
    @objc private func stopGeneratePasswordButtonPressed() {
        isStopGeneratePasswordButtonPressed = !isStopGeneratePasswordButtonPressed
    }
    
    func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character)) ?? 0
    }
    
    func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index]): Character("")
    }
    
    func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var result = string
        
        if result.count <= 0 {
            result.append(characterAt(index: 0, array))
        }
        else {
            result.replace(at: result.count - 1,
                           with: characterAt(index: (indexOf(character: result.last ?? "-", array) + 1) % array.count, array))
            
            if indexOf(character: result.last ?? "-", array) == 0 {
                result = String(generateBruteForce(String(result.dropLast()), fromArray: array)) + String(result.last ?? "-")
            }
        }
        return result
    }
    
    private func bruteForce(passwordToUnlock: String) {
        let allowedCharacters: [String] = String().printable.map { String($0) }
        var password: String = ""
        
        queue.async {
            if self.isGeneratePasswordButtonPressed {
                while password != passwordToUnlock && !self.isStopGeneratePasswordButtonPressed {
                    self.isGeneratePasswordButtonPressed = false
                    password = self.generateBruteForce(password, fromArray: allowedCharacters)
                    DispatchQueue.main.async {
                        self.label.text = password
                    }
                }
            }
            
            DispatchQueue.main.async {
                if password == passwordToUnlock {
                    let alert = UIAlertController(title: "Пароль успешно введен",
                                                  message: "Пароль: \(passwordToUnlock)",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Неправильный пароль",
                                                  message: "Пароль: \(passwordToUnlock) не взломан",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                }
                self.textFieldPassword.isSecureTextEntry = true
            }
        }
    }
}

