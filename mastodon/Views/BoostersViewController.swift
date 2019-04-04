//
//  BoostersViewController.swift
//  mastodon
//
//  Created by Shihab Mehboob on 26/09/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SJFluidSegmentedControl
import StatusAlert

class BoostersViewController: UIViewController, SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var ai = NVActivityIndicatorView(frame: CGRect(x:0,y:0,width:0,height:0), type: .circleStrokeSpin, color: Colours.tabSelected)
    var segmentedControl: SJFluidSegmentedControl!
    var tableView = UITableView()
    var tableView2 = UITableView()
    var currentIndex = 0
    var profileStatus = ""
    var statusLiked: [Account] = []
    var statusBoosted: [Account] = []
    var doItOnce = true
    
    @objc func load() {
        DispatchQueue.main.async {
            self.loadLoadLoad()
        }
    }
    
    @objc func search() {
        let controller = DetailViewController()
        controller.mainStatus.append(StoreStruct.statusSearch[StoreStruct.searchIndex])
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.ai.startAnimating()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if (UserDefaults.standard.object(forKey: "segsize") == nil) || (UserDefaults.standard.object(forKey: "segsize") as! Int == 0) {} else {
            springWithDelay(duration: 0.4, delay: 0, animations: {
                self.segmentedControl.alpha = 0
            })
        }
    }
    
    @objc func changeSeg() {
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        var newoff = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                offset = 88
                newoff = 45
            case 2436, 1792:
                offset = 88
                newoff = 45
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
                newoff = 24
            }
        }
        
        if (UserDefaults.standard.object(forKey: "segsize") == nil) || (UserDefaults.standard.object(forKey: "segsize") as! Int == 0) {
            segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: CGFloat(20), y: CGFloat(offset + 5), width: CGFloat(self.view.bounds.width - 40), height: CGFloat(40)))
            segmentedControl.dataSource = self
            if (UserDefaults.standard.object(forKey: "segstyle") == nil) || (UserDefaults.standard.object(forKey: "segstyle") as! Int == 0) {
                segmentedControl.shapeStyle = .roundedRect
            } else {
                segmentedControl.shapeStyle = .liquid
            }
            segmentedControl.textFont = .systemFont(ofSize: 16, weight: .heavy)
            segmentedControl.cornerRadius = 12
            segmentedControl.shadowsEnabled = false
            segmentedControl.transitionStyle = .slide
            segmentedControl.delegate = self
            view.addSubview(segmentedControl)
            
            self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "cellf")
            self.tableView.frame = CGRect(x: 0, y: Int(offset + 60), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 65)
            self.tableView.alpha = 1
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundColor = Colours.white
            self.tableView.separatorColor = Colours.cellQuote
            self.tableView.layer.masksToBounds = true
            self.tableView.estimatedRowHeight = 89
            self.tableView.rowHeight = UITableView.automaticDimension
            self.view.addSubview(self.tableView)
            
            self.tableView2.register(FollowersCell.self, forCellReuseIdentifier: "cellf2")
            self.tableView2.frame = CGRect(x: 0, y: Int(offset + 60), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 65)
            self.tableView2.alpha = 1
            self.tableView2.delegate = self
            self.tableView2.dataSource = self
            self.tableView2.separatorStyle = .singleLine
            self.tableView2.backgroundColor = Colours.white
            self.tableView2.separatorColor = Colours.cellQuote
            self.tableView2.layer.masksToBounds = true
            self.tableView2.estimatedRowHeight = 89
            self.tableView2.rowHeight = UITableView.automaticDimension
            self.tableView2.alpha = 0
            self.view.addSubview(self.tableView2)
        } else {
            if UIApplication.shared.isSplitOrSlideOver {
                segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: CGFloat(self.view.bounds.width/2 - 120), y: CGFloat(30), width: CGFloat(240), height: CGFloat(40)))
            } else {
                segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: CGFloat(self.view.bounds.width/2 - 120), y: CGFloat(newoff), width: CGFloat(240), height: CGFloat(40)))
            }
            segmentedControl.dataSource = self
            if (UserDefaults.standard.object(forKey: "segstyle") == nil) || (UserDefaults.standard.object(forKey: "segstyle") as! Int == 0) {
                segmentedControl.shapeStyle = .roundedRect
            } else {
                segmentedControl.shapeStyle = .liquid
            }
            segmentedControl.textFont = .systemFont(ofSize: 16, weight: .heavy)
            segmentedControl.cornerRadius = 12
            segmentedControl.shadowsEnabled = false
            segmentedControl.transitionStyle = .slide
            segmentedControl.delegate = self
            self.navigationController?.view.addSubview(segmentedControl)
            
            self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "cellf")
            self.tableView.frame = CGRect(x: 0, y: Int(offset + 10), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 15)
            self.tableView.alpha = 1
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundColor = Colours.white
            self.tableView.separatorColor = Colours.cellQuote
            self.tableView.layer.masksToBounds = true
            self.tableView.estimatedRowHeight = 89
            self.tableView.rowHeight = UITableView.automaticDimension
            self.view.addSubview(self.tableView)
            
            self.tableView2.register(FollowersCell.self, forCellReuseIdentifier: "cellf2")
            self.tableView2.frame = CGRect(x: 0, y: Int(offset + 10), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 15)
            self.tableView2.alpha = 1
            self.tableView2.delegate = self
            self.tableView2.dataSource = self
            self.tableView2.separatorStyle = .singleLine
            self.tableView2.backgroundColor = Colours.white
            self.tableView2.separatorColor = Colours.cellQuote
            self.tableView2.layer.masksToBounds = true
            self.tableView2.estimatedRowHeight = 89
            self.tableView2.rowHeight = UITableView.automaticDimension
            self.tableView2.alpha = 0
            self.view.addSubview(self.tableView2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.search), name: NSNotification.Name(rawValue: "search"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.load), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeSeg), name: NSNotification.Name(rawValue: "changeSeg"), object: nil)
        
        self.ai.frame = CGRect(x: self.view.bounds.width/2 - 20, y: self.view.bounds.height/2, width: 40, height: 40)
        self.view.backgroundColor = Colours.white
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        var newoff = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                offset = 88
                newoff = 45
            case 2436, 1792:
                offset = 88
                newoff = 45
            default:
                offset = 64
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
                newoff = 24
            }
        }
        
        if (UserDefaults.standard.object(forKey: "segsize") == nil) || (UserDefaults.standard.object(forKey: "segsize") as! Int == 0) {
            segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: CGFloat(20), y: CGFloat(offset + 5), width: CGFloat(self.view.bounds.width - 40), height: CGFloat(40)))
            segmentedControl.dataSource = self
            if (UserDefaults.standard.object(forKey: "segstyle") == nil) || (UserDefaults.standard.object(forKey: "segstyle") as! Int == 0) {
                segmentedControl.shapeStyle = .roundedRect
            } else {
                segmentedControl.shapeStyle = .liquid
            }
            segmentedControl.textFont = .systemFont(ofSize: 16, weight: .heavy)
            segmentedControl.cornerRadius = 12
            segmentedControl.shadowsEnabled = false
            segmentedControl.transitionStyle = .slide
            segmentedControl.delegate = self
            view.addSubview(segmentedControl)
            
            self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "cellf")
            self.tableView.frame = CGRect(x: 0, y: Int(offset + 60), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 65)
            self.tableView.alpha = 1
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundColor = Colours.white
            self.tableView.separatorColor = Colours.cellQuote
            self.tableView.layer.masksToBounds = true
            self.tableView.estimatedRowHeight = 89
            self.tableView.rowHeight = UITableView.automaticDimension
            self.view.addSubview(self.tableView)
            
            self.tableView2.register(FollowersCell.self, forCellReuseIdentifier: "cellf2")
            self.tableView2.frame = CGRect(x: 0, y: Int(offset + 60), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 65)
            self.tableView2.alpha = 1
            self.tableView2.delegate = self
            self.tableView2.dataSource = self
            self.tableView2.separatorStyle = .singleLine
            self.tableView2.backgroundColor = Colours.white
            self.tableView2.separatorColor = Colours.cellQuote
            self.tableView2.layer.masksToBounds = true
            self.tableView2.estimatedRowHeight = 89
            self.tableView2.rowHeight = UITableView.automaticDimension
            self.tableView2.alpha = 0
            self.view.addSubview(self.tableView2)
        } else {
            if UIApplication.shared.isSplitOrSlideOver {
                segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: CGFloat(self.view.bounds.width/2 - 120), y: CGFloat(30), width: CGFloat(240), height: CGFloat(40)))
            } else {
                segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: CGFloat(self.view.bounds.width/2 - 120), y: CGFloat(newoff), width: CGFloat(240), height: CGFloat(40)))
            }
            segmentedControl.dataSource = self
            if (UserDefaults.standard.object(forKey: "segstyle") == nil) || (UserDefaults.standard.object(forKey: "segstyle") as! Int == 0) {
                segmentedControl.shapeStyle = .roundedRect
            } else {
                segmentedControl.shapeStyle = .liquid
            }
            segmentedControl.textFont = .systemFont(ofSize: 16, weight: .heavy)
            segmentedControl.cornerRadius = 12
            segmentedControl.shadowsEnabled = false
            segmentedControl.transitionStyle = .slide
            segmentedControl.delegate = self
            self.navigationController?.view.addSubview(segmentedControl)
            
            self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "cellf")
            self.tableView.frame = CGRect(x: 0, y: Int(offset + 10), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 15)
            self.tableView.alpha = 1
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundColor = Colours.white
            self.tableView.separatorColor = Colours.cellQuote
            self.tableView.layer.masksToBounds = true
            self.tableView.estimatedRowHeight = 89
            self.tableView.rowHeight = UITableView.automaticDimension
            self.view.addSubview(self.tableView)
            
            self.tableView2.register(FollowersCell.self, forCellReuseIdentifier: "cellf2")
            self.tableView2.frame = CGRect(x: 0, y: Int(offset + 10), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 15)
            self.tableView2.alpha = 1
            self.tableView2.delegate = self
            self.tableView2.dataSource = self
            self.tableView2.separatorStyle = .singleLine
            self.tableView2.backgroundColor = Colours.white
            self.tableView2.separatorColor = Colours.cellQuote
            self.tableView2.layer.masksToBounds = true
            self.tableView2.estimatedRowHeight = 89
            self.tableView2.rowHeight = UITableView.automaticDimension
            self.tableView2.alpha = 0
            self.view.addSubview(self.tableView2)
        }
        
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        
        self.loadLoadLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        var newoff = 45
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                offset = 88
                newoff = 45
            case 2436, 1792:
                offset = 88
                newoff = 45
            default:
                offset = 64
                newoff = 24
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch (deviceIdiom) {
        case .pad:
            
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            segmentedControl.heightAnchor.constraint(equalToConstant: CGFloat(40)).isActive = true
            if (UserDefaults.standard.object(forKey: "segsize") == nil) || (UserDefaults.standard.object(forKey: "segsize") as! Int == 0) {
                self.segmentedControl.widthAnchor.constraint(equalToConstant: CGFloat(self.view.bounds.width - 40)).isActive = true
                self.segmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(offset + 5)).isActive = true
            } else {
                self.segmentedControl.widthAnchor.constraint(equalToConstant: CGFloat(240)).isActive = true
                self.segmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(30)).isActive = true
            }
            
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        default:
            print("nothing")
        }
        
        springWithDelay(duration: 0.4, delay: 0, animations: {
            self.segmentedControl.alpha = 1
        })
        
        if StoreStruct.historyBool {
            self.changeSeg()
        }
        
        StoreStruct.historyBool = false
        
        print("testboost \(self.statusBoosted.first?.displayName)")
        
        StoreStruct.currentPage = 90
    }
    
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 2
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 {
            return "\(statusLiked.count) Likes".localized
        } else {
            return "\(statusBoosted.count) Boosts".localized
        }
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        if (UserDefaults.standard.object(forKey: "seghue1") == nil) || (UserDefaults.standard.object(forKey: "seghue1") as! Int == 0) {
            return [Colours.tabSelected, Colours.tabSelected]
        } else {
            return [Colours.grayLight2, Colours.grayLight2]
        }
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        if (UserDefaults.standard.object(forKey: "seghue1") == nil) || (UserDefaults.standard.object(forKey: "seghue1") as! Int == 0) {
            return [Colours.tabSelected, Colours.tabSelected]
        } else {
            return [Colours.grayLight2, Colours.grayLight2]
        }
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didChangeFromSegmentAtIndex fromIndex: Int, toSegmentAtIndex toIndex: Int) {
        
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        if toIndex == 0 {
            self.currentIndex = 0
            self.tableView.alpha = 1
            self.tableView2.alpha = 0
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        if toIndex == 1 {
            self.currentIndex = 1
            self.tableView.alpha = 0
            self.tableView2.alpha = 1
            DispatchQueue.main.async {
                self.tableView2.reloadData()
            }
        }
    }
    
    
    // Table stuff
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.statusLiked.count
        } else {
            return self.statusBoosted.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            
            if self.statusLiked.count == 0 {
                self.fetchFollows()
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellf", for: indexPath) as! FollowersCell
                cell.backgroundColor = Colours.white
                let bgColorView = UIView()
                bgColorView.backgroundColor = Colours.white
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                
                if indexPath.row == self.statusLiked.count - 6 {
                    self.fetchFollows()
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellf", for: indexPath) as! FollowersCell
                cell.configure(self.statusLiked[indexPath.row])
                cell.profileImageView.tag = indexPath.row
                cell.profileImageView.addTarget(self, action: #selector(self.didTouchProfile), for: .touchUpInside)
                cell.backgroundColor = Colours.white
                cell.userName.textColor = Colours.black
                cell.userTag.textColor = Colours.black
                cell.toot.textColor = Colours.black.withAlphaComponent(0.6)
                let bgColorView = UIView()
                bgColorView.backgroundColor = Colours.white
                cell.selectedBackgroundView = bgColorView
                return cell
                
            }
        } else {
            
            if self.statusBoosted.count == 0 {
                self.fetchFollowers()
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellf2", for: indexPath) as! FollowersCell
                cell.backgroundColor = Colours.white
                let bgColorView = UIView()
                bgColorView.backgroundColor = Colours.white
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                
                if indexPath.row == self.statusBoosted.count - 6 {
                    self.fetchFollowers()
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellf2", for: indexPath) as! FollowersCell
                cell.configure(self.statusBoosted[indexPath.row])
                cell.profileImageView.tag = indexPath.row
                cell.profileImageView.addTarget(self, action: #selector(self.didTouchProfile), for: .touchUpInside)
                cell.backgroundColor = Colours.white
                cell.userName.textColor = Colours.black
                cell.userTag.textColor = Colours.black
                cell.toot.textColor = Colours.black.withAlphaComponent(0.6)
                let bgColorView = UIView()
                bgColorView.backgroundColor = Colours.white
                cell.selectedBackgroundView = bgColorView
                return cell
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = ThirdViewController()
        controller.fromOtherUser = true
        if self.currentIndex == 0 {
            controller.userIDtoUse = self.statusLiked[indexPath.row].id
        } else {
            controller.userIDtoUse = self.statusBoosted[indexPath.row].id
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func didTouchProfile(sender: UIButton) {
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
    
    var lastThing = ""
    func fetchFollows() {
        let request = Statuses.favouritedBy(id: self.profileStatus, range: .max(id: self.statusLiked.last?.id ?? "", limit: nil))
        StoreStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty || self.lastThing == stat.first?.id ?? "" {} else {
                    self.lastThing = stat.first?.id ?? ""
                    self.statusLiked = self.statusLiked + stat
                    self.statusLiked = self.statusLiked.removeDuplicates()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    var lastThing2 = ""
    func fetchFollowers() {
        let request = Statuses.rebloggedBy(id: self.profileStatus, range: .max(id: self.statusBoosted.last?.id ?? "", limit: nil))
        StoreStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty || self.lastThing2 == stat.first?.id ?? "" {} else {
                    self.lastThing2 = stat.first?.id ?? ""
                    self.statusBoosted = self.statusBoosted + stat
                    self.statusBoosted = self.statusBoosted.removeDuplicates()
                    DispatchQueue.main.async {
                        self.tableView2.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    
    func loadLoadLoad() {
        if (UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) {
            Colours.white = UIColor.white
            Colours.grayDark = UIColor(red: 40/250, green: 40/250, blue: 40/250, alpha: 1.0)
            Colours.grayDark2 = UIColor(red: 110/250, green: 113/250, blue: 121/250, alpha: 1.0)
            Colours.cellNorm = Colours.white
            Colours.cellQuote = UIColor(red: 243/255.0, green: 242/255.0, blue: 246/255.0, alpha: 1.0)
            Colours.cellSelected = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            Colours.tabUnselected = UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 1.0)
            Colours.blackUsual = UIColor(red: 40/255.0, green: 40/255.0, blue: 40/255.0, alpha: 1.0)
            Colours.cellOwn = UIColor(red: 243/255.0, green: 242/255.0, blue: 246/255.0, alpha: 1.0)
            Colours.cellAlternative = UIColor(red: 243/255.0, green: 242/255.0, blue: 246/255.0, alpha: 1.0)
            Colours.black = UIColor.black
            UIApplication.shared.statusBarStyle = .default
        } else if (UserDefaults.standard.object(forKey: "theme") != nil && UserDefaults.standard.object(forKey: "theme") as! Int == 1) {
            Colours.white = UIColor(red: 46/255.0, green: 46/255.0, blue: 52/255.0, alpha: 1.0)
            Colours.grayDark = UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0)
            Colours.grayDark2 = UIColor.white
            Colours.cellNorm = Colours.white
            Colours.cellQuote = UIColor(red: 33/255.0, green: 33/255.0, blue: 43/255.0, alpha: 1.0)
            Colours.cellSelected = UIColor(red: 34/255.0, green: 34/255.0, blue: 44/255.0, alpha: 1.0)
            Colours.tabUnselected = UIColor(red: 80/255.0, green: 80/255.0, blue: 90/255.0, alpha: 1.0)
            Colours.blackUsual = UIColor(red: 70/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            Colours.cellOwn = UIColor(red: 55/255.0, green: 55/255.0, blue: 65/255.0, alpha: 1.0)
            Colours.cellAlternative = UIColor(red: 20/255.0, green: 20/255.0, blue: 30/255.0, alpha: 1.0)
            Colours.black = UIColor.white
            UIApplication.shared.statusBarStyle = .lightContent
        } else if (UserDefaults.standard.object(forKey: "theme") != nil && UserDefaults.standard.object(forKey: "theme") as! Int == 2) {
            Colours.white = UIColor(red: 36/255.0, green: 33/255.0, blue: 37/255.0, alpha: 1.0)
            Colours.grayDark = UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0)
            Colours.grayDark2 = UIColor.white
            Colours.cellNorm = Colours.white
            Colours.cellQuote = UIColor(red: 33/255.0, green: 33/255.0, blue: 43/255.0, alpha: 1.0)
            Colours.cellSelected = UIColor(red: 34/255.0, green: 34/255.0, blue: 44/255.0, alpha: 1.0)
            Colours.tabUnselected = UIColor(red: 80/255.0, green: 80/255.0, blue: 90/255.0, alpha: 1.0)
            Colours.blackUsual = UIColor(red: 70/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            Colours.cellOwn = UIColor(red: 55/255.0, green: 55/255.0, blue: 65/255.0, alpha: 1.0)
            Colours.cellAlternative = UIColor(red: 20/255.0, green: 20/255.0, blue: 30/255.0, alpha: 1.0)
            Colours.black = UIColor.white
            UIApplication.shared.statusBarStyle = .lightContent
        } else if (UserDefaults.standard.object(forKey: "theme") != nil && UserDefaults.standard.object(forKey: "theme") as! Int == 4) {
            Colours.white = UIColor(red: 41/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
            Colours.grayDark = UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0)
            Colours.grayDark2 = UIColor.white
            Colours.cellNorm = Colours.white
            Colours.cellQuote = UIColor(red: 20/255.0, green: 20/255.0, blue: 29/255.0, alpha: 1.0)
            Colours.cellSelected = UIColor(red: 34/255.0, green: 34/255.0, blue: 44/255.0, alpha: 1.0)
            Colours.tabUnselected = UIColor(red: 80/255.0, green: 80/255.0, blue: 90/255.0, alpha: 1.0)
            Colours.blackUsual = UIColor(red: 70/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            Colours.cellOwn = UIColor(red: 55/255.0, green: 55/255.0, blue: 65/255.0, alpha: 1.0)
            Colours.cellAlternative = UIColor(red: 20/255.0, green: 20/255.0, blue: 30/255.0, alpha: 1.0)
            Colours.black = UIColor.white
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            Colours.white = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
            Colours.grayDark = UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0)
            Colours.grayDark2 = UIColor.white
            Colours.cellNorm = Colours.white
            Colours.cellQuote = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
            Colours.cellSelected = UIColor(red: 34/255.0, green: 34/255.0, blue: 44/255.0, alpha: 1.0)
            Colours.tabUnselected = UIColor(red: 70/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            Colours.blackUsual = UIColor(red: 70/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            Colours.cellOwn = UIColor(red: 10/255.0, green: 10/255.0, blue: 20/255.0, alpha: 1.0)
            Colours.cellAlternative = UIColor(red: 20/255.0, green: 20/255.0, blue: 30/255.0, alpha: 1.0)
            Colours.black = UIColor.white
            UIApplication.shared.statusBarStyle = .lightContent
        }
        
        self.view.backgroundColor = Colours.white
        if (UserDefaults.standard.object(forKey: "systemText") == nil) || (UserDefaults.standard.object(forKey: "systemText") as! Int == 0) {
            Colours.fontSize1 = CGFloat(UIFont.systemFontSize)
            Colours.fontSize3 = CGFloat(UIFont.systemFontSize)
        } else {
            if (UserDefaults.standard.object(forKey: "fontSize") == nil) {
                Colours.fontSize0 = 14
                Colours.fontSize2 = 10
                Colours.fontSize1 = 14
                Colours.fontSize3 = 10
            } else if (UserDefaults.standard.object(forKey: "fontSize") as! Int == 0) {
                Colours.fontSize0 = 12
                Colours.fontSize2 = 8
                Colours.fontSize1 = 12
                Colours.fontSize3 = 8
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 1) {
                Colours.fontSize0 = 13
                Colours.fontSize2 = 9
                Colours.fontSize1 = 13
                Colours.fontSize3 = 9
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 2) {
                Colours.fontSize0 = 14
                Colours.fontSize2 = 10
                Colours.fontSize1 = 14
                Colours.fontSize3 = 10
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 3) {
                Colours.fontSize0 = 15
                Colours.fontSize2 = 11
                Colours.fontSize1 = 15
                Colours.fontSize3 = 11
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 4) {
                Colours.fontSize0 = 16
                Colours.fontSize2 = 12
                Colours.fontSize1 = 16
                Colours.fontSize3 = 12
            } else if (UserDefaults.standard.object(forKey: "fontSize") != nil && UserDefaults.standard.object(forKey: "fontSize") as! Int == 5) {
                Colours.fontSize0 = 17
                Colours.fontSize2 = 13
                Colours.fontSize1 = 17
                Colours.fontSize3 = 13
            } else {
                Colours.fontSize0 = 18
                Colours.fontSize2 = 14
                Colours.fontSize1 = 18
                Colours.fontSize3 = 14
            }
        }
        
        self.tableView.backgroundColor = Colours.white
        self.tableView.separatorColor = Colours.cellQuote
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
        //        var customStyle = VolumeBarStyle.likeInstagram
        //        customStyle.trackTintColor = Colours.cellQuote
        //        customStyle.progressTintColor = Colours.grayDark
        //        customStyle.backgroundColor = Colours.cellNorm
        //        volumeBar.style = customStyle
        //        volumeBar.start()
        //
        //        self.missingView.image = UIImage(named: "missing")?.maskWithColor(color: Colours.tabUnselected)
        //
        //        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Colours.grayDark]
        //        self.collectionView.backgroundColor = Colours.white
        //        self.removeTabbarItemsText()
    }
    
    
}

