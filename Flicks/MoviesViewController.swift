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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // create an optional to hold the movies dictionary
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var segmentedControl: UISegmentedControl!
    var endpoint: String!
    var navTitle: String!
    let apiKey:String = "9c8b8a24a248fed2e25eb1f8d2f29d13"
    
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set up the table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        
        // set the networkErrorView hidden initially
        networkErrorView.isHidden = true
        
        // initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        
        // set the background color and tint of the refresh control
        refreshControl.backgroundColor = UIColor.black
        refreshControl.tintColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1.0)
        
        // bind refreshControlAction as the target for our refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        // create a segmented control to switch between table and grid layout
        segmentedControl = UISegmentedControl(items:["Table", "Grid"])
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(selectedSegmentDidChange(_:)), for: UIControlEvents.valueChanged)
        
        // add the segmented control to the navigation bar
        let segmentedButton = UIBarButtonItem(customView: segmentedControl)
        navigationItem.rightBarButtonItem = segmentedButton
        
        navigationItem.title = navTitle
        
        // add the refresh control to the table view
        tableView.refreshControl = refreshControl
        
        tableView.isHidden = false
        collectionView.isHidden = true
        
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
            
            // hide the network error view
            self.networkErrorView.isHidden = true
            
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
                            
                            //print("responseDictionary: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            // reload our table view
                            self.tableView.reloadData()
                            
                            // reload colleciton view
                            self.collectionView.reloadData()
                            
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
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        // make the network request
        requestData()
    }
    
    // MARK: - UISegmentedControl action
    
    func selectedSegmentDidChange(_ segmentedControl: UISegmentedControl) {
        let selectedIndex = segmentedControl.selectedSegmentIndex
                
        if (selectedIndex == 0) {
            // show the table view
            tableView.isHidden = false
            collectionView.isHidden = true
        } else {
            // show the collection view
            tableView.isHidden = true
            collectionView.isHidden = false
        }
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
        
        loadPosterImage(for: cell.posterView, indexPath: indexPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
                 
        return cell
    }
    
    // MARK: - Utils
    
    // Loads low resolution poster image first and then switches to the high resolution version
    func loadPosterImage(for imageView: UIImageView, indexPath: IndexPath) {
        let movie = movies![indexPath.row]
        
        let lowResBaseUrl = "http://image.tmdb.org/t/p/w154"
        let baseUrl = "http://image.tmdb.org/t/p/w500"

        if let posterPath = movie["poster_path"] as? String {
            // posterPath is now guaranteed to not be nil.
            
            let lowResUrl = NSURL(string: lowResBaseUrl + posterPath)
            let highResUrl = NSURL(string: baseUrl + posterPath)
            
            let highResImageRequest = NSURLRequest(url: highResUrl! as URL)
            let lowResImageRequest = NSURLRequest(url: lowResUrl! as URL)
            
            imageView.setImageWith(
                    lowResImageRequest as URLRequest,
                    placeholderImage: nil,
                    success: { (lowResImageRequest, lowResImageResponse, lowResImage) in
                        
                        imageView.alpha = 0
                        imageView.image = lowResImage
                        
                        UIView.animate(withDuration: 0.3, animations: { 
                            imageView.alpha = 1.0
                        }, completion: { (success) in
                            imageView.setImageWith(
                                highResImageRequest as URLRequest,
                                placeholderImage: lowResImage,
                                success: { (highResImageRequest, highResImageResponse, highResImage) in
                                    imageView.image = highResImage
                                
                            }, failure: { (request, response, error) in
                                print("Error: \(error)")
                            })
                        })
                        
                }, failure: { (request, response, error) in
                    // log error message
                    print("Error: \(error)")
                })
            
            
        }
        

    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var movie: NSDictionary!
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            movie = movies?[indexPath!.row]
        } else {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)
            movie = movies?[indexPath!.row]
        }
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }
}

extension MoviesViewController: UICollectionViewDataSource {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath)  as! MovieCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        
        loadPosterImage(for: cell.posterImage, indexPath: indexPath)

        return cell
    }
}

