//
//  ViewController.swift
//  TableList
//
//  Created by Administrator on 23/06/19.
//  Copyright © 2019 Ravi. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject]!
    var titleName:String!
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    
    var rowsList: [Rows] = []
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        self.cache = NSCache()
        
        self.refreshCtrl = UIRefreshControl()
        self.refreshCtrl.addTarget(self, action: #selector(ViewController.refreshTableView), for: .valueChanged)
        self.refreshControl = self.refreshCtrl
        
    }
    
    @objc func refreshTableView(){
        
        
        let url:URL! = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json")
        task = session.downloadTask(with: url, completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
            
            if location != nil{
                let data:Data! = try? Data(contentsOf: location!)
                let responseStrInISOLatin = String(data: data!, encoding: String.Encoding.isoLatin1)
                guard let modifiedDataInUTF8Format = responseStrInISOLatin?.data(using: String.Encoding.utf8) else {
                    print("could not convert data to UTF-8 format")
                    return
                }
                do{
                    let jsonDecoder = JSONDecoder()
                    let baseValues = try jsonDecoder.decode(Base.self, from: modifiedDataInUTF8Format)
                    self.rowsList = baseValues.rows ?? []


                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    })
                }catch{
                    print("something went wrong, try again")
                }
            }
        })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowsList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        
        
        cell.textLabel?.text = self.rowsList[indexPath.row].title
        cell.imageView?.image = UIImage(named: "placeholder")
        cell.detailTextLabel?.text = self.rowsList[indexPath.row].description

        
        
        
        if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil){
            // 2
            // Use cache
            print("Cached image used, no need to download it")
            cell.imageView?.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
        }else{
            // 3
            
            if let artworkUrl = self.rowsList[indexPath.row].imageHref
            {
                let url:URL! = URL(string: artworkUrl)
                //            let artworkUrl = dictionary["imageHref"] as! String
                //            let url:URL! = URL(string: artworkUrl)
                task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    if let data = try? Data(contentsOf: url){
                        // 4
                        DispatchQueue.main.async(execute: { () -> Void in
                            // 5
                            // Before we assign the image, check whether the current cell is visible
                            if let updateCell = tableView.cellForRow(at: indexPath) {
                                let img:UIImage! = UIImage(data: data)
                                updateCell.imageView?.image = img
                                self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject)
                            }
                        })
                    }
                })
                task.resume()
            }
            else
            {
                let thumbnaleImageURL = Bundle.main.url(forResource: "placeholder", withExtension: "png")
                let url:URL! = URL(fileURLWithPath: thumbnaleImageURL?.path ?? "placeholder.png")
                //            let artworkUrl = dictionary["imageHref"] as! String
                //            let url:URL! = URL(string: artworkUrl)
                task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    if let data = try? Data(contentsOf: url){
                        // 4
                        DispatchQueue.main.async(execute: { () -> Void in
                            // 5
                            // Before we assign the image, check whether the current cell is visible
                            if let updateCell = tableView.cellForRow(at: indexPath) {
                                let img:UIImage! = UIImage(data: data)
                                updateCell.imageView?.image = img
                                self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject)
                            }
                        })
                    }
                })
                task.resume()
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
    
}



