//
//  LoginViewController.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 12. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate  {
    
    //properties
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var uiViewLogin: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var usernameTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var loginSubView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationBar.barTintColor = UIColor.black
        uiViewLogin.backgroundColor = UIColor.black
        loginSubView.layer.cornerRadius = 10
        
        usernameTextBox.delegate = self
        passwordTextBox.delegate = self
        
        let authentication: Authentication? = PersistService().getObject(key: Authentication.classKey)
        
        if authentication != nil {
            usernameTextBox.text = authentication?.getUsername()
            passwordTextBox.text = authentication?.getPassword()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePress(_ sender: UIButton) {
        let authentication = Authentication(username: usernameTextBox.text!, password: passwordTextBox.text!)
        PersistService().saveObject(object: authentication, saveKey: Authentication.classKey)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        uiViewLogin.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextBox {
            self.passwordTextBox.becomeFirstResponder()
        } else if textField == self.passwordTextBox {
            self.uiViewLogin.endEditing(true)
        }
        
        return true
    }
}
