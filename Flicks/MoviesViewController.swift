//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Diana Fisher on 9/12/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import AFNetworking
import NVActivityIndicatorView
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    
    // create an optional to hold the movies dictionary
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var endpoint: String!
    let apiKey:String = "9c8b8a24a248fed2e25eb1f8d2f29d13"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set up the table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // set the networkErrorView hidden initially
        networkErrorView.isHidden = true
        
        // initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        
        // bind refreshControlAction as the target for our refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_refreshControl:)), for: UIControlEvents.valueChanged)
        
        // add the refresh control to the table view
        tableView.refreshControl = refreshControl
        
        // make the network request
        self.requestData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Network Request
    
    func requestData() {
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // print("https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        
        if let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        {
            let request = URLRequest(url: url)
            // Display HUD right before the request is made
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let task : URLSessionDataTask = session.dataTask(
                with: request as URLRequest,
                completionHandler: { (data, response, error) in
                    
                    // Hide HUD once the network request comes back (must be done on main UI thread)
                    DispatchQueue.main.async(execute: {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    })
                    
                    if let data = data {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options:[]) as? NSDictionary {
                            print("responseDictionary: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            // reload our table view
                            self.tableView.reloadData()
                            
                            DispatchQueue.main.async {
                                // update the refreshControl
                                self.refreshControl.endRefreshing()
                            }                            
                        }
                    } else if let error = error {
                        print("Error: \(error)")
                        DispatchQueue.main.async {
                            // show the network error view
                            self.networkErrorView.isHidden = false
                        }
                    }
            });
            task.resume()
        } else {
            // url is nil
            print("url is nil!")
        }
        
    }
    
    // MARK: - UIRefreshControl action
    
    func refreshControlAction(_refreshControl: UIRefreshControl) {
        // make the network request
        requestData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // If movies is not nil, then assign it to movies
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        // use if let to safely set the image view from the poster_path
        if let posterPath = movie["poster_path"] as? String {
            // posterPath is now guaranteed to not be nil.
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl! as URL)
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
         
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies?[indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
    }
    

}
