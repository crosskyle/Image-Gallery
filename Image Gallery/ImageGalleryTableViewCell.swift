//
//  ImageGalleryTableViewCell.swift
//  Image Gallery
//
//  Created by Kyle Cross on 1/16/18.
//  Copyright © 2018 Kyle Cross. All rights reserved.
//

import UIKit

protocol EditTextDelegate {
    func textFieldDidChange(at index: Int, to name: String)
}

class ImageGalleryTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: ImageGalleryTableViewController?

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            textField.clearsOnBeginEditing = false
            textField.isUserInteractionEnabled = false
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapResponse))
            tapGestureRecognizer.numberOfTapsRequired = 2
            self.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc private func doubleTapResponse(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            textField.isUserInteractionEnabled = true
            textField.becomeFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isUserInteractionEnabled = false
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tableView = self.superview as? UITableView {
            if let indexPath = tableView.indexPath(for: self) {
                delegate?.textFieldDidChange(at: indexPath.row, to: self.textField.text ?? "")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
