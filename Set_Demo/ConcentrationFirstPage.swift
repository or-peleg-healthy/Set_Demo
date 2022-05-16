//
//  ConcentrationFirstPage.swift
//  Set_Demo
//
//  Created by Or Peleg on 16/05/2022.
//

import UIKit

final class ConcentrationFirstPage: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private var lastSegued: ConcentrationViewController?

    @IBAction private func changeTheme(_ sender: UIButton) {
        if let cvc = lastSegued {
            if let themeName = sender.titleLabel?.text {
                let theme = Theme.make(themeName: themeName)
                cvc.emojiChoices = theme
                cvc.theme = theme
                navigationController?.pushViewController(cvc, animated: true)
            }
        } else {
            performSegue(withIdentifier: "Change Screen", sender: sender)
        }
    }

    private var navigationViewDetail: ConcentrationViewController? {
        navigationController?.viewControllers.last as? ConcentrationViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Change Screen" {
            if let themeName = (sender as? UIButton)?.titleLabel?.text {
                let theme = Theme.make(themeName: themeName)
                    if let cvc = segue.destination as? ConcentrationViewController {
                        cvc.emojiChoices = theme
                        cvc.theme = theme
                        lastSegued = cvc
                }
            }
        }
    }
}
