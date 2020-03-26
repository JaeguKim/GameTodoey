import UIKit

class LibraryViewController: UIViewController {

    @IBOutlet weak var libraryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        libraryTableView.delegate = self
    }
   
    @IBAction func plusBtnPressed(_ sender: UIBarButtonItem) {
        
    }
}

//MARK: - UITableViewDataSource
extension LibraryViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}

//MARK: - UITableViewDelegate
extension LibraryViewController : UITableViewDelegate {
    
}
