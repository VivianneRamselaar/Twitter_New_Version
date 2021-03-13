//
//  HomeViewController.swift
//  Twitter
//
//  Created by Vivianne Bollee on 3/13/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    
    var numOfTweets = 0
    var tweetArray: [NSDictionary] = []
    var myRefreshControl: UIRefreshControl!

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        self.dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loadTweets()
        tableView.rowHeight = 200
        // tableView.rowHeight = UITableView.automaticDimension
        // tableView.estimatedRowHeight = 150
        myRefreshControl = UIRefreshControl()
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.insertSubview(myRefreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets() // you tweet, should auotmatically pop up
    }
    
    @objc func loadTweets(){
        
        numOfTweets = 20
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParam = ["count":numOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParam, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (error) in
            print(error.localizedDescription)
        })
        
    }
    
    func loadMoreTweets(){
        
        numOfTweets = numOfTweets + 20
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParam = ["count":numOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParam, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { (error) in
            print(error.localizedDescription)
        })
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.tweetArray.count {
            loadMoreTweets()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let tweet = self.tweetArray[indexPath.row]
        let user = tweet["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as! String
        cell.tweetContentLabel.text = tweet["text"] as! String
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweetArray.count
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
