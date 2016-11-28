//
//  MainViewcontroller.swift
//  UpsAndDowns
//
//  Created by Suraya Shivji on 11/27/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SettingsDelegate, TabBarDelegate   {
    
    //MARK: Properties
    var views = [UIView]()
    let items = ["Emotion", "Language", "Tone", "Profile"]
    var viewsAreInitialized = false
    lazy var collectionView: UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv: UICollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (self.view.bounds.height)), collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor.clear
        cv.bounces = false
        cv.isPagingEnabled = true
        cv.isDirectionalLockEnabled = true
        return cv
    }()
    
    lazy var tabBar: TabBar = {
        let tb = TabBar.init(frame: CGRect.init(x: 0, y: 0, width: globalVariables.width, height: 64))
        tb.delegate = self
        return tb
    }()
    
    lazy var settings: Settings = {
        let st = Settings.init(frame: UIScreen.main.bounds)
        st.delegate = self
        return st
    }()
    
    let titleLabel: UILabel = {
        let tl = UILabel.init(frame: CGRect.init(x: 20, y: 10, width: 200, height: 30))
        tl.font = UIFont(name: "BrandonText-Regular", size: 17)
        tl.textColor = UIColor.black
        tl.text = "Home"
        return tl
    }()
    
    
    // MARK: Methods
    func customization()  {
        
        // CollectionView Customization
        self.collectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        self.view.addSubview(self.collectionView)
        
        // NavigationController Customization
//        self.navigationController?.view.backgroundColor = UIColor.green
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationItem.hidesBackButton = true
        
        // NavigationBar color and shadow
        self.navigationController?.navigationBar.barTintColor = ColorPalette.lightGray
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // Title Label
//        self.navigationController?.navigationBar.addSubview(self.titleLabel)
        
        // Tab Bar
        self.view.addSubview(self.tabBar)
        
        // ViewControllers init
        for title in self.items {
            let storyBoard = self.storyboard!
            let vc = storyBoard.instantiateViewController(withIdentifier: title)
            self.addChildViewController(vc)
            vc.view.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height - 44))
            vc.didMove(toParentViewController: self)
            self.views.append(vc.view)
        }
        self.viewsAreInitialized = true
    }
    
    //MARK: Settings
    
    @IBAction func handleMore(_ sender: AnyObject) {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.settings)
            self.settings.animate()
        }
    }
    
    func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
    }
    
    //MARK: Delegates implementation
    func didSelectItem(atIndex: Int) {
        self.collectionView.scrollRectToVisible(CGRect.init(origin: CGPoint.init(x: (self.view.bounds.width * CGFloat(atIndex)), y: 0), size: self.view.bounds.size), animated: true)
    }
    
    func hideSettingsView(status: Bool) {
        if status == true {
            self.settings.removeFromSuperview()
        }
    }
   
    //MARK: View Controller lifecyle
    override func viewDidLoad() {
        
        // set navigation title to current user's first name (from FacebookService)
        self.title = "Temppp"
        self.navigationController?.navigationBar.titleTextAttributes = [
        NSFontAttributeName: UIFont(name: "BrandonText-Regular", size: 21)!
                ]
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        super.viewDidLoad()
        customization()
        didSelectItem(atIndex: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
    }
    
    //MARK: CollectionView DataSources
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.views.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.addSubview(self.views[indexPath.row])
        return cell
    }
    
    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
               return CGSize.init(width: self.view.bounds.width, height: (self.view.bounds.height + 22))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollIndex = Int(round(scrollView.contentOffset.x / self.view.bounds.width))
        self.titleLabel.text = self.items[scrollIndex]
        if self.viewsAreInitialized {
            self.tabBar.whiteView.frame.origin.x = (scrollView.contentOffset.x / 4)
            self.tabBar.highlightItem(atIndex: scrollIndex)
        }
    }
}
