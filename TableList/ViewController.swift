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
    
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        self.tableData = []
        self.titleName = ""
        self.cache = NSCache()
        
        self.refreshCtrl = UIRefreshControl()
        self.refreshCtrl.addTarget(self, action: #selector(ViewController.refreshTableView), for: .valueChanged)
        self.refreshControl = self.refreshCtrl
        
    }
    
    @objc func refreshTableView(){
        
        //   let url:URL! = URL(string: "https://itunes.apple.com/search?term=flappy&entity=software")
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
                    //  let dic = try JSONSerialization.jsonObject(with: responseStrInISOLatin, options: .mutableLeaves) as AnyObject
                    let dic = try JSONSerialization.jsonObject(with: modifiedDataInUTF8Format)
                    self.tableData = (dic as AnyObject).value(forKey : "rows") as? [AnyObject]
                    self.titleName = (dic as AnyObject).value(forKey: "title") as? String

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
        return self.tableData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        let dictionary = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        
        cell.textLabel!.text = dictionary["title"] as? String
        //  cell.detailTextLabel?.text = "Hi"
        cell.imageView?.image = UIImage(named: "placeholder")
        cell.detailTextLabel?.text = dictionary["description"] as? String
        
       // cell.textLabel?.numberOfLines=0 // line wrap
      //  cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        
        
        if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil){
            // 2
            // Use cache
            print("Cached image used, no need to download it")
            cell.imageView?.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
        }else{
            // 3
            
            if let artworkUrl = dictionary["imageHref"] as? String
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



