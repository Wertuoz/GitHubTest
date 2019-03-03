//
//  OnboardingViewController.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 25/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import CoreData

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.borderWidth = newValue > 0 ? 2 : layer.borderWidth
            layer.borderColor = UIColor.flatBlue.cgColor
            layer.masksToBounds = newValue > 0
        }
    }
}

class OnboardingViewController: UIViewController {

    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var nameTf: UITextField!
    
    @IBAction func onSignInBtnClick(_ sender: Any) {
        signIn()
    }
    
    private func signIn() {
        guard let nameText = nameTf.text, nameTf.text!.count > 0 else {
            print("empty text")
            return
        }
        
        guard let passwordText = passwordTf.text, passwordTf.text!.count > 0 else {
            print("empty password")
            return
        }
        
        signinBtn.isEnabled = false
        showActivityIndicator()

        ApiManager.shared.makeInitRequest(login: nameText, password: passwordText) { [unowned self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.hideActivityIndicator()
                    self.signinBtn.isEnabled = true
                    self.showAlertBar(with: "Oops, some error occured", subText: error!.localizedDescription, style: .danger)
                    return
                }

                self.showAlertBar(with: "Login Success", subText: "Hello, \(nameText)!", style: .success)
                
                DispatchQueue.main.asyncAfter(deadline:.now() + 2.0, execute: {
                    self.hideActivityIndicator()
                    self.performSegue(withIdentifier: "LoginToUserPage", sender: self)
                })
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? UserPageViewController else {
            return
        }
        
        destVC.initFromOnboarding = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTf.delegate = self
        nameTf.delegate = self
        signinBtn.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: [.flatMint, .flatBlue])
        nameTf.becomeFirstResponder()
        
        UIView.animate(withDuration: 2) {
            self.signinBtn.alpha = 1
        }
    }
    
    deinit {
        print("deinit")
    }
}

extension OnboardingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(#function)
        if textField == nameTf {
            textField.resignFirstResponder()
            passwordTf.becomeFirstResponder()
        } else if textField == passwordTf {
            self.view.endEditing(true)
            signIn()
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print(#function)
        return true
    }
}

extension OnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
