//
//  MoviesViewController.swift
//  movieviewer
//
//  Created by Bishal Gautam on 1/10/16.
//  Copyright © 2016 Bishal Gautam. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity


class MoviesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
     var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var endpoint: String!
    
    
    override func viewDidAppear(animated: Bool) {
           // EZLoadingActivity.show("Loading...", disableUI: true)
             EZLoadingActivity.showWithDelay("Loading...", disableUI: false, seconds:2 )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                         self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            EZLoadingActivity.hide(success: true, animated: true)
                    }
                } else
                 {
                            EZLoadingActivity.hide(success: false, animated: true)
                 }
                
        });
            task.resume()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
            
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            
            if let movies = movies{
            return movies.count
            }
            else {
            return 0
            }
            
            
        }
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            
           
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
            
            /*if(cell.selected)
            {
                cell.backgroundColor = UIColor.redColor()
                
            }
            else
            {*/
                 cell.backgroundColor = UIColor.grayColor()
            //}
            // cell.textLabel.backgroundColor = UIColor.blackColor() 
            
             //cell color
            
             //cell.selectionStyle = .Blue
            
            //cell background 
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.blueColor()
            cell.selectedBackgroundView = backgroundView
            
            let movie = movies![indexPath.row]
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            
            if let posterPath = movie["poster_path"] as? String{
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath
            )
            cell.posterLabel.setImageWithURL(imageUrl!)
            }
            
            //print("row\(indexPath.row)")
            return cell
        
            
        }// Default is 1 if not implemented
        
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
       override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath =  tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.movie = movie
        print("prepare for segue")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
