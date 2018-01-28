//
//  ImageGalleryTableViewController.swift
//  Image Gallery
//
//  Created by Kyle Cross on 1/16/18.
//  Copyright © 2018 Kyle Cross. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UIViewController {
    
    // MARK: - Model
    
    var imageGalleries: [ImageGallery] = [ImageGallery(name: "Untitled 1")]
    var deletedImageGalleries: [ImageGallery] = []
    
    
    // MARK: - Target/Action

    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    @IBAction func addImageGallery(_ sender: UIBarButtonItem) {
        let galleryName = "Untitled"
        var uniqueNumber = 1
        
        while imageGalleries.contains(where: { $0.name == ("\(galleryName) \(uniqueNumber)") })
        || deletedImageGalleries.contains(where: { $0.name == ("\(galleryName) \(uniqueNumber)") }) {
            uniqueNumber += 1
        }
        
        imageGalleries += [ImageGallery(name: ("\(galleryName) \(uniqueNumber)"))]
        tableView.reloadData()
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition(rawValue: 0)!)
        
        if let vc = splitViewController?.viewControllers[1].contents as? ImageGalleryViewController  {
            vc.imageGallery = imageGalleries[0]
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
   
    
    // MARK: - Navigation
    
    private var indexPathRowForSegue: Int?
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if indexPath.section == 0 {
                indexPathRowForSegue = indexPath.row
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGallery" {
            if let vc = segue.destination.contents as? ImageGalleryViewController {
                let index = indexPathRowForSegue ?? 0
                vc.imageGallery = imageGalleries[index]
            }
            indexPathRowForSegue = nil
        }
       
    }
}


// MARK: - UITableViewDataSource

extension ImageGalleryTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return imageGalleries.count
        case 1:
            return deletedImageGalleries.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Recently Deleted"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGalleryCell", for: indexPath)
        if let imageGalleryCell = cell as? ImageGalleryTableViewCell {
            if indexPath.section == 0 {
                imageGalleryCell.textField.text = imageGalleries[indexPath.row].name
                return cell
            } else if indexPath.section == 1 {
                imageGalleryCell.textField.text = deletedImageGalleries[indexPath.row].name
                return cell
            }
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0, editingStyle == .delete {
            tableView.performBatchUpdates({
                let deletedImageGallery = imageGalleries.remove(at: indexPath.row)
                deletedImageGalleries.append(deletedImageGallery)
                tableView.moveRow(at: indexPath, to: IndexPath(row: deletedImageGalleries.count-1, section: 1))
            })
            
        }
    }
}


// MARK: UITableViewDelegate

extension ImageGalleryTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) as? ImageGalleryTableViewCell {
            cell.textField.resignFirstResponder()
            cell.textField.isUserInteractionEnabled = false
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let action = UIContextualAction(style: .normal, title: "Undelete", handler: { (thisAction, actionButton, completion) in
                tableView.performBatchUpdates({
                    let undeletedImageGallery = self.deletedImageGalleries.remove(at: indexPath.row)
                    self.imageGalleries.append(undeletedImageGallery)
                    tableView.moveRow(at: indexPath, to: IndexPath(row: self.imageGalleries.count-1, section: 0))
                    tableView.reloadData()
                })
            })
            return UISwipeActionsConfiguration(actions: [action])
        }
        return nil
    }
}
