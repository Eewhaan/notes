//
//  DetailViewController.swift
//  challenge7
//
//  Created by Ivan Pavic on 20.2.22..
//

import UIKit

protocol DataSharingDelegateProtocol: AnyObject {
    func sendDataToTableView (myData: Note)
    
}

class DetailViewController: UIViewController {
    
    weak var delegate: DataSharingDelegateProtocol?
    @IBOutlet var textView: UITextView!
    var selectedNote: String?
    var selectedBody: String?

    override func viewDidLoad() {
                
        super.viewDidLoad()
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 18)]
        
        let navigationLabel = UILabel()
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha: 0.2)
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset = CGSize(width: 1, height: 2)
        let navTitle = NSMutableAttributedString(string: selectedNote ?? "Unknown name", attributes: [
            NSAttributedString.Key.shadow : shadow,
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 22) as Any
        ])
        navigationLabel.attributedText = navTitle
        self.navigationItem.titleView = navigationLabel
        
        
        let newBackButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backAction))
        newBackButton.tintColor = UIColor.black
        newBackButton.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        newBackButton.setTitleTextAttributes(attributes as [NSAttributedString.Key: Any], for: .highlighted)
        navigationController?.navigationBar.topItem?.backBarButtonItem = newBackButton
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        doneButton.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        doneButton.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .highlighted)
        navigationItem.rightBarButtonItem = doneButton
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        textView.text = selectedBody
        
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        textView.scrollIndicatorInsets = textView.contentInset
        let range = textView.selectedRange
        textView.scrollRangeToVisible(range)
    }
    
    @objc func done() {
        if delegate != nil {
            guard let noteBody = self.textView.text else {return}
            guard let noteTitle = self.selectedNote else {return}
            let newNote = Note(noteTitle: noteTitle, noteBody: noteBody)
            delegate?.sendDataToTableView(myData: newNote)
            backAction()
        }
    }
}
