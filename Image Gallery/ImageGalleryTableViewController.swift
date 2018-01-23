//
//  ImageGalleryTableViewController.swift
//  Image Gallery
//
//  Created by Kyle Cross on 1/16/18.
//  Copyright © 2018 Kyle Cross. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    
    // MARK: - Model
    
    var imageGalleries: [ImageGallery] = [ImageGallery(images: nil, name: "Untitled 1")]
    var deletedImageGalleries: [ImageGallery] = []
    
    // MARK: - Target/Action

    @IBAction func addImageGallery(_ sender: UIBarButtonItem) {
        let galleryName = "Untitled"
        var uniqueNumber = 1
        
        while imageGalleries.contains(where: { $0.name == ("\(galleryName) \(uniqueNumber)") })
        || deletedImageGalleries.contains(where: { $0.name == ("\(galleryName) \(uniqueNumber)") }) {
            uniqueNumber += 1
        }
        
        imageGalleries += [ImageGallery(images: nil, name: ("\(galleryName) \(uniqueNumber)"))]
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition(rawValue: 0)!)
        splitViewController?.delegate = self
    
        if let vc = splitViewController?.viewControllers[1] as? ImageGalleryViewController {
            vc.imageGallery = imageGalleries[0]
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return imageGalleries.count
        case 1:
            return deletedImageGalleries.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Recently Deleted"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGalleryCell", for: indexPath)
        if let imageGalleryCell = cell as? ImageGalleryTableViewCell {
            if indexPath.section == 0 {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapResponse))
                tapGesture.numberOfTapsRequired = 2
                imageGalleryCell.addGestureRecognizer(tapGesture)
                imageGalleryCell.textField.text = imageGalleries[indexPath.row].name
                return cell
            } else if indexPath.section == 1 {
                imageGalleryCell.textField.text = deletedImageGalleries[indexPath.row].name
                return cell
            }
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0, editingStyle == .delete {
            // Delete the row from the data source

            tableView.performBatchUpdates({
                let deletedImageGallery = imageGalleries.remove(at: indexPath.row)
                deletedImageGalleries.append(deletedImageGallery)
                tableView.moveRow(at: indexPath, to: IndexPath(row: deletedImageGalleries.count-1, section: 1))
            })
            
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let action = UIContextualAction(style: .normal, title: "Undelete", handler: { (thisAction, actionButton, completion) in
                tableView.performBatchUpdates({
                    let undeletedImageGallery = self.deletedImageGalleries.remove(at: indexPath.row)
                    self.imageGalleries.append(undeletedImageGallery)
                    tableView.moveRow(at: indexPath, to: IndexPath(row: self.imageGalleries.count-1, section: 0))
                })
            })
            return UISwipeActionsConfiguration(actions: [action])
        }
        return nil
    }
    
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Gestures

    @objc private func doubleTapResponse(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let textField = (sender.view as? ImageGalleryTableViewCell)?.textField {
                textField.isEnabled = true
            }
        }
    }
}
