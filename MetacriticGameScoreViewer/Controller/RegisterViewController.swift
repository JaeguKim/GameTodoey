import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
     }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            let alert = UIAlertController(title: "Registering...", message: "", preferredStyle: .alert)
            self.present(alert, animated: true)
             
            
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let e = error {
                    print(e.localizedDescription)
                    alert.dismiss(animated: true, completion: nil)
                    let alert = UIAlertController(title: "Failed Registering", message: "", preferredStyle: .alert)
                    self.present(alert, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                else {
                    UserDefaults.standard.set(true, forKey: "isLogIn")
                    UserDefaults.standard.set(email, forKey: "email")
                    alert.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: Const.registerSegue, sender: self)
                }
            }
        }
    }
}
