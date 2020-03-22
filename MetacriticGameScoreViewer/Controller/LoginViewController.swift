import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            let alert = UIAlertController(title: "Loggin in...", message: "", preferredStyle: .alert)
            self.present(alert, animated: true)
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let e = error {
                    print(e.localizedDescription)
                    alert.dismiss(animated: true, completion: nil)
                    let alert = UIAlertController(title: "Failed logging in", message: "", preferredStyle: .alert)
                    self.present(alert, animated: true) {
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                           alert.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    alert.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: Const.loginSegue, sender: self)
                }
            }
        }
    }
    
}
