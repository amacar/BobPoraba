//
//  ViewController.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 7. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // properties
    @IBOutlet weak var usageTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var uiViewUsage: UIView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var alertView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var usageData = [UsageProperty]()
    let cellReuseIdentifier = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        usageTableView.delegate = self
        usageTableView.dataSource = self
        usageTableView.alwaysBounceVertical = false
        usageTableView.allowsSelection = false
        usageTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        navigationBar.barTintColor = UIColor.black
        uiViewUsage.backgroundColor = UIColor.black
        dateTimeLabel.backgroundColor = UIColor.black
        alertView.layer.cornerRadius = 10
        
        let dateTime: DateTime? = PersistService().getObject(key: DateTime.classKey)
        if dateTime != nil {
            dateTimeLabel.text = dateTime!.toString()
        }
        
        let oldUsageData: [UsageProperty]? = PersistService().getObject(key: UsageProperty.classKey)
        if oldUsageData != nil {
            usageData = oldUsageData!
        } else {
            uiViewUsage.bringSubview(toFront: alertView)
        }
        
        //fetch usage when open
        self.fetchUsage(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usageData.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UsagePropertyViewCell = self.usageTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! UsagePropertyViewCell
        
        // set the text from the data model
        cell.labelKey?.text = self.usageData[indexPath.row].getLabel()
        cell.labelValue?.text = self.usageData[indexPath.row].getValue()
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor.yellow
        } else {
            cell.backgroundColor = UIColor.black
            cell.labelKey.textColor = UIColor.white
            cell.labelValue.textColor = UIColor.white
        }
        
        return cell
    }
    
    // event handlers
    @IBAction func fetchUsage(_ sender: UIButton?) {
        
        let authentication: Authentication? = PersistService().getObject(key: Authentication.classKey)
        
        if authentication != nil {
            let username = authentication?.getUsername()
            let password = authentication?.getPassword()
            
            //show loader
            DispatchQueue.main.async{
                self.showLoader()
            }
            
            FetchService().getUsage(username: username!, password: password!) {(usage) -> Void in
                
                let parseService = ParseService()
                
                // parse and save usage
                do {
                    try self.usageData = parseService.parseUsage(content: usage)
                    PersistService().saveObject(object: self.usageData, saveKey: UsageProperty.classKey)
                    
                    //remove alert
                    if self.alertView != nil && self.alertView.isDescendant(of: self.uiViewUsage) {
                        self.alertView.removeFromSuperview()
                    }

                    //hide loader
                    self.hideLoader()
                   
                    //set and save last refresh
                    let dateTime = DateTime(datetime: Date())
                    PersistService().saveObject(object: dateTime, saveKey: DateTime.classKey)
                    self.dateTimeLabel.text = dateTime.toString()
                } catch {
                    //hide loader, show error
                    self.hideLoader()
                    self.showErrorMessage()
                }
                
                DispatchQueue.main.async{
                    self.usageTableView.reloadData()
                }
            }
        }
    }
    
    private func showLoader() {
        let alert = UIAlertController(title: nil, message: "Prosim počakajte...", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func hideLoader() {
        dismiss(animated: false, completion: nil)
    }
    
    private func showErrorMessage() {
        let alert = UIAlertController(title: "Opozorilo", message: "Napaka pri pridobivanju podatkov o porabi! Preverite prijavne podatke in poskusite ponovno.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "V redu", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

