//
//  SecondViewController.swift
//  mastodon
//
//  Created by Shihab Mehboob on 18/09/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SJFluidSegmentedControl
import SafariServices
import StatusAlert
import SAConfettiView
import ReactiveSSE
import ReactiveSwift
import OneSignal
import AVKit
import AVFoundation

class SecondViewController: UIViewController, SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, SKPhotoBrowserDelegate, UIViewControllerPreviewingDelegate, OSSubscriptionObserver {
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        print("state changed")
    }
    
    var newUpdatesB1 = UIButton()
    var newUpdatesB2 = UIButton()
    var countcount1 = 0
    var countcount2 = 0
    
    var blurEffectViewMain = UIView()
    var blurEffect0 = UIBlurEffect()
    var blurEffectView0 = UIVisualEffectView()
    var hMod: [Notificationt] = []
    var fMod: [Notificationt] = []
    var nsocket: WebSocket!
    var ai = NVActivityIndicatorView(frame: CGRect(x:0,y:0,width:0,height:0), type: .circleStrokeSpin, color: Colours.tabSelected)
    var safariVC: SFSafariViewController?
    var segmentedControl: SJFluidSegmentedControl!
    var tableView = UITableView()
    var tableView2 = UITableView()
    var refreshControl = UIRefreshControl()
    var currentIndex = 1
    var doOnce = false
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if self.currentIndex == 1 {
            
            guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return nil }
            let detailVC = DetailViewController()
            if self.currentIndex == 0 {
                if indexPath.section == 0 {
                    return nil
                } else {
                    if StoreStruct.notifications[indexPath.row].type == .follow {
                        let controller = ThirdViewController()
                        
                        if StoreStruct.notifications[indexPath.row].account.username == StoreStruct.currentUser.username {} else {
                            controller.fromOtherUser = true
                        }
                        controller.userIDtoUse = StoreStruct.notifications[indexPath.row].account.id
                        controller.isPeeking = true
                        previewingContext.sourceRect = cell.frame
                        return controller
                    } else {
                        detailVC.mainStatus.append(StoreStruct.notifications[indexPath.row].status!)
                    }
                }
            } else {
                detailVC.mainStatus.append(StoreStruct.notificationsMentions[indexPath.row].status!)
            }
            detailVC.isPeeking = true
            previewingContext.sourceRect = cell.frame
            return detailVC
            
        } else {
            
            guard let indexPath = self.tableView2.indexPathForRow(at: location) else { return nil }
            guard let cell = self.tableView2.cellForRow(at: indexPath) else { return nil }
            let detailVC = DetailViewController()
            if self.currentIndex == 0 {
                if indexPath.section == 0 {
                    return nil
                } else {
                    if StoreStruct.notifications[indexPath.row].type == .follow {
                        let controller = ThirdViewController()
                        
                        if StoreStruct.notifications[indexPath.row].account.username == StoreStruct.currentUser.username {} else {
                            controller.fromOtherUser = true
                        }
                        controller.userIDtoUse = StoreStruct.notifications[indexPath.row].account.id
                        controller.isPeeking = true
                        previewingContext.sourceRect = cell.frame
                        return controller
                    } else {
                        detailVC.mainStatus.append(StoreStruct.notifications[indexPath.row].status!)
                    }
                }
            } else {
                detailVC.mainStatus.append(StoreStruct.notificationsMentions[indexPath.row].status!)
            }
            detailVC.isPeeking = true
            previewingContext.sourceRect = cell.frame
            return detailVC
            
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    @objc func scrollTop2() {
        
        if self.currentIndex == 1 {
            
            DispatchQueue.main.async {
                if StoreStruct.notifications.count > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
            
        } else {
            
            
            DispatchQueue.main.async {
                if StoreStruct.notifications.count > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView2.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
            
            
        }
    }
    
    @objc func load() {
        DispatchQueue.main.async {
            self.loadLoadLoad()
        }
    }
    
    @objc func loadNewest() {
        if self.currentIndex == 1 {
            if self.tableView.contentOffset.y == 0 {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            }
        } else {
            if self.tableView2.contentOffset.y == 0 {
            DispatchQueue.main.async {
                self.tableView2.reloadData()
            }
            }
        }
    }
    
    @objc func search() {
        let controller = DetailViewController()
        controller.mainStatus.append(StoreStruct.statusSearch[StoreStruct.searchIndex])
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func searchUser() {
        let controller = ThirdViewController()
        controller.fromOtherUser = true
        controller.userIDtoUse = StoreStruct.statusSearchUser[StoreStruct.searchIndex].id
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @objc func goLists() {
        DispatchQueue.main.async {
            let controller = ListViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    @objc func goInstance() {
        let request = Timelines.public(local: true, range: .max(id: StoreStruct.newInstanceTags.last?.id ?? "", limit: 5000))
        let testClient = Client(
            baseURL: "https://\(StoreStruct.shared.currentInstance.instanceText)",
            accessToken: StoreStruct.shared.currentInstance.accessToken ?? ""
        )
        testClient.run(request) { (statuses) in
            if let stat = (statuses.value) {
                StoreStruct.newInstanceTags = stat
                DispatchQueue.main.async {
                    let controller = InstanceViewController()
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    
    @objc func goMembers() {
        let request = Lists.accounts(id: StoreStruct.allListRelID)
        StoreStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    let controller = ListMembersViewController()
                    controller.currentTagTitle = "List Members".localized
                    controller.currentTags = stat
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    @objc func confettiCreate() {
        let confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView.isUserInteractionEnabled = true
        self.view.addSubview(confettiView)
        confettiView.intensity = 0.9
        confettiView.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            confettiView.stopConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                confettiView.removeFromSuperview()
            }
        }
    }
    
    @objc func confettiCreateRe() {
        let confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView.isUserInteractionEnabled = true
        self.view.addSubview(confettiView)
        confettiView.intensity = 0.9
        confettiView.colors = [UIColor(red: 89/250, green: 207/250, blue: 99/250, alpha: 1.0), UIColor(red: 84/250, green: 202/250, blue: 94/250, alpha: 1.0), UIColor(red: 79/250, green: 97/250, blue: 89/250, alpha: 1.0)]
        confettiView.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            confettiView.stopConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                confettiView.removeFromSuperview()
            }
        }
    }
    
    @objc func confettiCreateLi() {
        let confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView.isUserInteractionEnabled = true
        self.view.addSubview(confettiView)
        confettiView.intensity = 0.9
        confettiView.colors = [UIColor(red: 255/250, green: 177/250, blue: 61/250, alpha: 1.0), UIColor(red: 250/250, green: 172/250, blue: 56/250, alpha: 1.0), UIColor(red: 245/250, green: 168/250, blue: 51/250, alpha: 1.0)]
        confettiView.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            confettiView.stopConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                confettiView.removeFromSuperview()
            }
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
                newoff = 24
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        segmentedControl.removeFromSuperview()
        tableView.removeFromSuperview()
        tableView2.removeFromSuperview()
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
            
            self.tableView.register(GraphCell.self, forCellReuseIdentifier: "cellG")
            self.tableView.register(NotificationCell.self, forCellReuseIdentifier: "cell3")
            self.tableView.register(NotificationCellImage.self, forCellReuseIdentifier: "cell4")
            self.tableView.frame = CGRect(x: 0, y: Int(offset + 60), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset)
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
            
            self.tableView2.register(GraphCell.self, forCellReuseIdentifier: "cellG02")
            self.tableView2.register(NotificationCell.self, forCellReuseIdentifier: "cell302")
            self.tableView2.register(NotificationCellImage.self, forCellReuseIdentifier: "cell402")
            self.tableView2.frame = CGRect(x: 0, y: Int(offset + 60), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset)
            self.tableView2.alpha = 0
            self.tableView2.delegate = self
            self.tableView2.dataSource = self
            self.tableView2.separatorStyle = .singleLine
            self.tableView2.backgroundColor = Colours.white
            self.tableView2.separatorColor = Colours.cellQuote
            self.tableView2.layer.masksToBounds = true
            self.tableView2.estimatedRowHeight = 89
            self.tableView2.rowHeight = UITableView.automaticDimension
            self.view.addSubview(self.tableView2)
            self.loadLoadLoad()
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
            
            self.tableView.register(GraphCell.self, forCellReuseIdentifier: "cellG")
            self.tableView.register(NotificationCell.self, forCellReuseIdentifier: "cell3")
            self.tableView.register(NotificationCellImage.self, forCellReuseIdentifier: "cell4")
            self.tableView.frame = CGRect(x: 0, y: Int(offset + 10), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset + 5)
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
            
            self.tableView2.register(GraphCell.self, forCellReuseIdentifier: "cellG02")
            self.tableView2.register(NotificationCell.self, forCellReuseIdentifier: "cell302")
            self.tableView2.register(NotificationCellImage.self, forCellReuseIdentifier: "cell402")
            self.tableView2.frame = CGRect(x: 0, y: Int(offset + 10), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset + 5)
            self.tableView2.alpha = 0
            self.tableView2.delegate = self
            self.tableView2.dataSource = self
            self.tableView2.separatorStyle = .singleLine
            self.tableView2.backgroundColor = Colours.white
            self.tableView2.separatorColor = Colours.cellQuote
            self.tableView2.layer.masksToBounds = true
            self.tableView2.estimatedRowHeight = 89
            self.tableView2.rowHeight = UITableView.automaticDimension
            self.view.addSubview(self.tableView2)
            self.loadLoadLoad()
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.ai.startAnimating()
        
        
        if (UserDefaults.standard.object(forKey: "biometricsnot") == nil) || (UserDefaults.standard.object(forKey: "biometricsnot") as! Int == 0) {} else {
            self.biometricAuthenticationClicked(self)
        }
    }
    
    
    
    
    
    
    func biometricAuthenticationClicked(_ sender: Any) {
        
        let win = UIApplication.shared.keyWindow
        blurEffectViewMain.frame = UIScreen.main.bounds
        blurEffectViewMain.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        UIApplication.shared.keyWindow?.addSubview(blurEffectViewMain)
        
        blurEffect0 = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView0 = UIVisualEffectView(effect: blurEffect0)
        blurEffectView0.frame = UIScreen.main.bounds
        blurEffectView0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        UIApplication.shared.keyWindow?.addSubview(blurEffectView0)
        
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", success: {
            
            self.blurEffectViewMain.removeFromSuperview()
            self.blurEffectView0.removeFromSuperview()
            
        }, failure: { [weak self] (error) in
            self?.showPasscodeAuthentication(message: "Error")
        })
    }
    func showPasscodeAuthentication(message: String) {
        BioMetricAuthenticator.authenticateWithPasscode(reason: message, success: {
            
            self.blurEffectViewMain.removeFromSuperview()
            self.blurEffectView0.removeFromSuperview()
            
        }) { (error) in
            print(error.message())
            self.biometricAuthenticationClicked(self)
        }
    }
    
    
    
    
    @objc func touchList() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "touchList"), object: nil)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.currentIndex == 0 {
            UserDefaults.standard.set(self.tableView2.contentOffset.y, forKey: "savedRowNotif")
        } else {
            UserDefaults.standard.set(self.tableView.contentOffset.y, forKey: "savedRowMent")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.goMembers), name: NSNotification.Name(rawValue: "goMembers2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goLists), name: NSNotification.Name(rawValue: "goLists2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goInstance), name: NSNotification.Name(rawValue: "goInstance2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.search), name: NSNotification.Name(rawValue: "search2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.searchUser), name: NSNotification.Name(rawValue: "searchUser2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.load), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop2), name: NSNotification.Name(rawValue: "scrollTop2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadNewest), name: NSNotification.Name(rawValue: "loadNewest"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeSeg), name: NSNotification.Name(rawValue: "changeSeg"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.segTheme), name: NSNotification.Name(rawValue: "segTheme"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startStream), name: NSNotification.Name(rawValue: "startStream"), object: nil)
        
        self.view.backgroundColor = Colours.white
        
        
        var settingsButton = MNGExpandedTouchAreaButton()
        settingsButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: 15, y: 47, width: 32, height: 32)))
        settingsButton.setImage(UIImage(named: "list")?.maskWithColor(color: Colours.grayLight2), for: .normal)
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        settingsButton.adjustsImageWhenHighlighted = false
        settingsButton.addTarget(self, action: #selector(self.touchList), for: .touchUpInside)
        
        let done = UIBarButtonItem.init(customView: settingsButton)
        self.navigationItem.setLeftBarButton(done, animated: false)
        
        
        
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
            
            self.tableView.register(GraphCell.self, forCellReuseIdentifier: "cellG")
            self.tableView.register(NotificationCell.self, forCellReuseIdentifier: "cell3")
            self.tableView.register(NotificationCellImage.self, forCellReuseIdentifier: "cell4")
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
            
            self.tableView2.register(GraphCell.self, forCellReuseIdentifier: "cellG02")
            self.tableView2.register(NotificationCell.self, forCellReuseIdentifier: "cell302")
            self.tableView2.register(NotificationCellImage.self, forCellReuseIdentifier: "cell402")
            self.tableView2.frame = CGRect(x: 0, y: Int(offset + 60), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 65)
            self.tableView2.alpha = 0
            self.tableView2.delegate = self
            self.tableView2.dataSource = self
            self.tableView2.separatorStyle = .singleLine
            self.tableView2.backgroundColor = Colours.white
            self.tableView2.separatorColor = Colours.cellQuote
            self.tableView2.layer.masksToBounds = true
            self.tableView2.estimatedRowHeight = 89
            self.tableView2.rowHeight = UITableView.automaticDimension
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
            
            self.tableView.register(GraphCell.self, forCellReuseIdentifier: "cellG")
            self.tableView.register(NotificationCell.self, forCellReuseIdentifier: "cell3")
            self.tableView.register(NotificationCellImage.self, forCellReuseIdentifier: "cell4")
            self.tableView.frame = CGRect(x: 0, y: Int(offset + 10), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset + 5)
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
            
            self.tableView2.register(GraphCell.self, forCellReuseIdentifier: "cellG02")
            self.tableView2.register(NotificationCell.self, forCellReuseIdentifier: "cell302")
            self.tableView2.register(NotificationCellImage.self, forCellReuseIdentifier: "cell402")
            self.tableView2.frame = CGRect(x: 0, y: Int(offset + 10), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset + 5)
            self.tableView2.alpha = 0
            self.tableView2.delegate = self
            self.tableView2.dataSource = self
            self.tableView2.separatorStyle = .singleLine
            self.tableView2.backgroundColor = Colours.white
            self.tableView2.separatorColor = Colours.cellQuote
            self.tableView2.layer.masksToBounds = true
            self.tableView2.estimatedRowHeight = 89
            self.tableView2.rowHeight = UITableView.automaticDimension
            self.view.addSubview(self.tableView2)
        }
        
        
        refreshControl.addTarget(self, action: #selector(refreshCont), for: .valueChanged)
        //self.tableView.addSubview(refreshControl)
        
        tableView.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                let selection = UISelectionFeedbackGenerator()
                selection.selectionChanged()
            }
            self?.refreshCont()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        tableView2.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                let selection = UISelectionFeedbackGenerator()
                selection.selectionChanged()
            }
            self?.refreshCont()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.tableView2.cr.endHeaderRefresh()
            })
        }
        //tableView.cr.beginHeaderRefresh()
        
        
        self.ai = NVActivityIndicatorView(frame: CGRect(x: self.view.bounds.width/2 - 20, y: self.view.bounds.height/2, width: 40, height: 40), type: .circleStrokeSpin, color: Colours.tabSelected)
        self.view.addSubview(self.ai)
        self.loadLoadLoad()
        
        
        if StoreStruct.notifications.isEmpty {
            let request = Notifications.all(range: .default)
            StoreStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    StoreStruct.notifications = stat
                    
                    StoreStruct.notificationsMentions = []
                    
                    StoreStruct.notificationsMentions = StoreStruct.notifications.filter({ (test) -> Bool in
                        test.type == .mention
                    })
                    
                    
                    DispatchQueue.main.async {
                        StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.sorted(by: { $0.createdAt > $1.createdAt })
                        StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
                        
                        self.ai.alpha = 0
                        self.ai.removeFromSuperview()
                        
                        self.tableView.reloadData()
                        self.tableView2.reloadData()
                        
                    }
                    
//                    for x in stat {
//                        if x.type == .mention {
//                            StoreStruct.notificationsMentions.append(x)
//                            DispatchQueue.main.async {
//                                StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.sorted(by: { $0.createdAt > $1.createdAt })
//                                StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
//
//                                self.ai.alpha = 0
//                                self.ai.removeFromSuperview()
//
//                                self.tableView.reloadData()
//                                self.tableView2.reloadData()
//
//                            }
//                        }
//                    }
                    
                }
            }
        } else {
            StoreStruct.notificationsMentions = []
            
            
            StoreStruct.notificationsMentions = StoreStruct.notifications.filter({ (test) -> Bool in
                test.type == .mention
            })
            
            
            DispatchQueue.main.async {
                StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.sorted(by: { $0.createdAt > $1.createdAt })
                StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
                
                self.ai.alpha = 0
                self.ai.removeFromSuperview()
                
                self.tableView.reloadData()
                self.tableView2.reloadData()
                
            }
            
            
//            for x in StoreStruct.notifications {
//                if x.type == .mention {
//                    StoreStruct.notificationsMentions.append(x)
//                    DispatchQueue.main.async {
//                        StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.sorted(by: { $0.createdAt > $1.createdAt })
//                        StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
//
//                        self.ai.alpha = 0
//                        self.ai.removeFromSuperview()
//
//                        self.tableView.reloadData()
//                        self.tableView2.reloadData()
//
//                    }
//                }
//            }
        }
        
        
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: self.tableView)
            registerForPreviewing(with: self, sourceView: self.tableView2)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        StoreStruct.currentPage = 1
//        self.tableView.reloadData()
//        self.tableView2.reloadData()
        
        springWithDelay(duration: 0.4, delay: 0, animations: {
            self.segmentedControl.alpha = 1
            //            self.tableView.alpha = 1
        })
        
        
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
        
        //bh4
        var newSize = offset + 65
        if (UserDefaults.standard.object(forKey: "segsize") == nil) || (UserDefaults.standard.object(forKey: "segsize") as! Int == 0) {
            newSize = offset + 65
        } else {
            newSize = offset + 15
        }
        
        self.newUpdatesB1.frame = CGRect(x: CGFloat(self.view.bounds.width - 42), y: CGFloat(newSize), width: CGFloat(56), height: CGFloat(30))
        self.newUpdatesB1.backgroundColor = Colours.grayLight19
        self.newUpdatesB1.layer.cornerRadius = 10
        self.newUpdatesB1.setTitleColor(UIColor.white, for: .normal)
        self.newUpdatesB1.setTitle("", for: .normal)
        self.newUpdatesB1.alpha = 0
        self.view.addSubview(self.newUpdatesB1)
        
        self.newUpdatesB2.frame = CGRect(x: CGFloat(self.view.bounds.width - 42), y: CGFloat(newSize), width: CGFloat(56), height: CGFloat(30))
        self.newUpdatesB2.backgroundColor = Colours.grayLight19
        self.newUpdatesB2.layer.cornerRadius = 10
        self.newUpdatesB2.setTitleColor(UIColor.white, for: .normal)
        self.newUpdatesB2.setTitle("", for: .normal)
        self.newUpdatesB2.alpha = 0
        self.view.addSubview(self.newUpdatesB2)
        
        
        
        if (UserDefaults.standard.object(forKey: "streamToggle") == nil) || (UserDefaults.standard.object(forKey: "streamToggle") as! Int == 0) {
        self.streamDataNoti()
        }
        
        OneSignal.add(self as OSSubscriptionObserver)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
    }
    
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.currentIndex == 1 {
            
            
            
            let indexPath1 = IndexPath(row: self.countcount1 - 1, section: 0)
            if self.tableView.indexPathsForVisibleRows?.contains(indexPath1) ?? false {
                if self.countcount1 == 0 {
                    springWithDelay(duration: 0.4, delay: 0, animations: {
                        self.newUpdatesB1.frame.origin.x = CGFloat(self.view.bounds.width - 42)
//                        self.newUpdatesB1.transform = CGAffineTransform(translationX: 0, y: 0)
                        springWithDelay(duration: 0.5, delay: 0, animations: {
                            self.newUpdatesB1.alpha = 0
                            self.newUpdatesB1.frame.origin.x = CGFloat(self.view.bounds.width + 78)
//                            self.newUpdatesB1.transform = CGAffineTransform(translationX: 120, y: 0)
                        })
                        self.countcount1 = 0
                    })
                } else {
                    self.countcount1 = self.countcount1 - 1
                    if self.countcount1 == 0 {
                        springWithDelay(duration: 0.4, delay: 0, animations: {
                            self.newUpdatesB1.frame.origin.x = CGFloat(self.view.bounds.width - 42)
//                            self.newUpdatesB1.transform = CGAffineTransform(translationX: 0, y: 0)
                            springWithDelay(duration: 0.5, delay: 0, animations: {
                                self.newUpdatesB1.alpha = 0
                                self.newUpdatesB1.frame.origin.x = CGFloat(self.view.bounds.width + 78)
//                                self.newUpdatesB1.transform = CGAffineTransform(translationX: 120, y: 0)
                            })
                            self.countcount1 = 0
                        })
                    }
                }
                self.newUpdatesB1.setTitle("\(self.countcount1)  ", for: .normal)
            }
            if (scrollView.contentOffset.y == 0) {
                springWithDelay(duration: 0.4, delay: 0, animations: {
                    self.newUpdatesB1.frame.origin.x = CGFloat(self.view.bounds.width - 42)
//                    self.newUpdatesB1.transform = CGAffineTransform(translationX: 0, y: 0)
                    springWithDelay(duration: 0.5, delay: 0, animations: {
                        self.newUpdatesB1.alpha = 0
                        self.newUpdatesB1.frame.origin.x = CGFloat(self.view.bounds.width + 78)
//                        self.newUpdatesB1.transform = CGAffineTransform(translationX: 120, y: 0)
                    })
                    self.countcount1 = 0
                })
            }
            
        } else {
            
            
            
            let indexPath1 = IndexPath(row: self.countcount2 - 1, section: 1)
            if self.tableView2.indexPathsForVisibleRows?.contains(indexPath1) ?? false {
                if self.countcount2 == 0 {
                    springWithDelay(duration: 0.4, delay: 0, animations: {
                        self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width - 42)
//                        self.newUpdatesB2.transform = CGAffineTransform(translationX: 0, y: 0)
                        springWithDelay(duration: 0.5, delay: 0, animations: {
                            self.newUpdatesB2.alpha = 0
                            self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width + 78)
//                            self.newUpdatesB2.transform = CGAffineTransform(translationX: 120, y: 0)
                        })
                        self.countcount2 = 0
                    })
                } else {
                    self.countcount2 = self.countcount2 - 1
                    if self.countcount2 == 0 {
                        springWithDelay(duration: 0.4, delay: 0, animations: {
                            self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width - 42)
//                            self.newUpdatesB2.transform = CGAffineTransform(translationX: 0, y: 0)
                            springWithDelay(duration: 0.5, delay: 0, animations: {
                                self.newUpdatesB2.alpha = 0
                                self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width + 78)
//                                self.newUpdatesB2.transform = CGAffineTransform(translationX: 120, y: 0)
                            })
                            self.countcount2 = 0
                        })
                    }
                }
                self.newUpdatesB2.setTitle("\(self.countcount2)  ", for: .normal)
            }
            if (scrollView.contentOffset.y == 0) {
                springWithDelay(duration: 0.4, delay: 0, animations: {
                    self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width - 42)
//                    self.newUpdatesB2.transform = CGAffineTransform(translationX: 0, y: 0)
                    springWithDelay(duration: 0.5, delay: 0, animations: {
                        self.newUpdatesB2.alpha = 0
                        self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width + 78)
//                        self.newUpdatesB2.transform = CGAffineTransform(translationX: 120, y: 0)
                    })
                    self.countcount2 = 0
                })
            }
            
        }
    }
    
    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y == 0 {
//            if self.currentIndex == 1 {
//                
//                //                if self.tableView.contentOffset.y == 0 {
//                //                    StoreStruct.statusesHome = self.hMod.reversed() + StoreStruct.statusesHome
//                //                    StoreStruct.statusesHome = StoreStruct.statusesHome.removeDuplicates()
//                //                    self.tableView.reloadData()
//                //                    self.hMod = []
//                //                }
//            } else {
//                
//                if self.tableView2.contentOffset.y == 0 {
//                    StoreStruct.notifications = self.hMod.reversed() + StoreStruct.notifications
//                    StoreStruct.notifications = StoreStruct.notifications.removeDuplicates()
//                    self.tableView2.reloadData()
//                    self.hMod = []
//                }
//            }
//        }
//    }
    
    
    @objc func startStream() {
        self.streamDataNoti()
    }
    
    
    
    func streamDataNoti() {
        
        if (UserDefaults.standard.object(forKey: "streamToggle") == nil) || (UserDefaults.standard.object(forKey: "streamToggle") as! Int == 0) {
            
            var sss = StoreStruct.client.baseURL.replacingOccurrences(of: "https", with: "wss")
            sss = sss.replacingOccurrences(of: "http", with: "wss")
            nsocket = WebSocket(url: URL(string: "\(sss)/api/v1/streaming/user?access_token=\(StoreStruct.shared.currentInstance.accessToken)&stream=user")!)
            nsocket.onConnect = {
                print("websocket is connected")
            }
            //websocketDidDisconnect
            nsocket.onDisconnect = { (error: Error?) in
                print("websocket is disconnected")
            }
            //websocketDidReceiveMessage
            nsocket.onText = { (text: String) in
                print("got some text: \(text)")
                
                let data0 = text.data(using: .utf8)!
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data0, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    let re = jsonResult?["payload"]
                    if jsonResult?["event"] as? String == "notification" {
                        let te = SSEvent.init(type: "notification", data: re as! String)
                        let data = te.data.data(using: .utf8)!
                        guard let model = try? Notificationt.decode(data: data) else {
                            return
                        }
                        self.hMod.append(model)
                        StoreStruct.notifications = self.hMod.reversed() + StoreStruct.notifications
                        StoreStruct.notifications = StoreStruct.notifications.removeDuplicates()
                        DispatchQueue.main.async {
                            //self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                            if self.currentIndex == 0 {
                                if self.tableView2.contentOffset.y == 0 {
                                    
                                    if (UserDefaults.standard.object(forKey: "posset") == nil) || (UserDefaults.standard.object(forKey: "posset") as! Int == 0) {
                                    self.newUpdatesB2.setTitle("\(self.hMod.count)  ", for: .normal)
//                                    self.newUpdatesB2.transform = CGAffineTransform(translationX: 120, y: 0)
                                    self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width + 78)
                                    springWithDelay(duration: 0.5, delay: 0, animations: {
                                        self.newUpdatesB2.alpha = 1
//                                        self.newUpdatesB2.transform = CGAffineTransform(translationX: 0, y: 0)
                                        self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width - 42)
                                    })
                                    self.countcount2 = self.hMod.count
                                    
                                    UIView.setAnimationsEnabled(false)
                                    self.tableView2.reloadData()
                                    self.refreshControl.endRefreshing()
                                    self.tableView2.scrollToRow(at: IndexPath(row: self.hMod.count, section: 1), at: .top, animated: false)
                                    UIView.setAnimationsEnabled(true)
                                        
                                    } else {
                                        
                                        self.tableView2.reloadData()
                                        self.refreshControl.endRefreshing()
                                    }
                                    
                                    self.hMod = []
                                }
                            }
                        }
                        
                        
                        if model.type == .mention {
                            self.fMod.append(model)
                            DispatchQueue.main.async {
                                if self.currentIndex == 1 {
                                    if self.tableView.contentOffset.y == 0 {
                                        StoreStruct.notificationsMentions = self.fMod.reversed() + StoreStruct.notificationsMentions
                                        StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
                                        
                                        if (UserDefaults.standard.object(forKey: "posset") == nil) || (UserDefaults.standard.object(forKey: "posset") as! Int == 0) {
                                        self.newUpdatesB1.setTitle("\(self.fMod.count)  ", for: .normal)
//                                        self.newUpdatesB1.transform = CGAffineTransform(translationX: 120, y: 0)
                                        self.newUpdatesB1.frame.origin.x = CGFloat(self.view.bounds.width + 78)
                                        springWithDelay(duration: 0.5, delay: 0, animations: {
                                            self.newUpdatesB1.alpha = 1
//                                            self.newUpdatesB1.transform = CGAffineTransform(translationX: 0, y: 0)
                                            self.newUpdatesB1.frame.origin.x = CGFloat(self.view.bounds.width - 42)
                                        })
                                        self.countcount1 = self.fMod.count
                                        
                                        UIView.setAnimationsEnabled(false)
                                        self.tableView.reloadData()
                                        self.refreshControl.endRefreshing()
                                        self.tableView.scrollToRow(at: IndexPath(row: self.fMod.count, section: 0), at: .top, animated: false)
                                        UIView.setAnimationsEnabled(true)
                                            
                                        } else {
                                            
                                            self.tableView.reloadData()
                                            self.refreshControl.endRefreshing()
                                        }
                                        
                                        self.fMod = []
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("failfail")
                    return
                }
            }
            //websocketDidReceiveData
            nsocket.onData = { (data: Data) in
                print("got some data: \(data.count)")
            }
            nsocket.connect()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        DispatchQueue.main.async {
            self.ai.alpha = 0
            self.ai.removeFromSuperview()
        }
        if (UserDefaults.standard.object(forKey: "segsize") == nil) || (UserDefaults.standard.object(forKey: "segsize") as! Int == 0) {} else {
            springWithDelay(duration: 0.4, delay: 0, animations: {
                self.segmentedControl.alpha = 0
                //            self.tableView.alpha = 0
            })
        }
        if self.currentIndex == 0 {
            UserDefaults.standard.set(self.tableView2.contentOffset.y, forKey: "savedRowNotif")
        } else {
            UserDefaults.standard.set(self.tableView.contentOffset.y, forKey: "savedRowMent")
        }
    }
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 2
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 {
            return "Mentions".localized
        } else {
            return "Activity".localized
        }
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        return [Colours.tabSelected, Colours.tabSelected]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        return [Colours.tabSelected, Colours.tabSelected]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didChangeFromSegmentAtIndex fromIndex: Int, toSegmentAtIndex toIndex: Int) {
        //backh2
        DispatchQueue.main.async {
            self.ai.alpha = 0
            self.ai.removeFromSuperview()
        }
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        if toIndex == 0 {
            
            if self.countcount1 == 0 {
                self.newUpdatesB1.alpha = 0
                self.newUpdatesB2.alpha = 0
            } else {
                self.newUpdatesB1.alpha = 1
                self.newUpdatesB2.alpha = 0
            }
            
            self.currentIndex = 1
            //self.tableView.reloadData()
            self.tableView.alpha = 1
            self.tableView2.alpha = 0
            
            
            self.tableView.reloadData()
            if StoreStruct.notifications.isEmpty {
                let request = Notifications.all(range: .default)
                StoreStruct.client.run(request) { (statuses) in
                    if let stat = (statuses.value) {
                        StoreStruct.notifications = stat
                        
                        StoreStruct.notificationsMentions = []
                        
                        
                        StoreStruct.notificationsMentions = StoreStruct.notifications.filter({ (test) -> Bool in
                            test.type == .mention
                        })
                        
                        
                        DispatchQueue.main.async {
                            StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.sorted(by: { $0.createdAt > $1.createdAt })
                            StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
                            
                            self.ai.alpha = 0
                            self.ai.removeFromSuperview()
                            
                            self.tableView.reloadData()
                            self.tableView2.reloadData()
                            
                        }
                        
                        
                        
//                        for x in stat {
//                            if x.type == .mention {
//                                StoreStruct.notificationsMentions.append(x)
//                                DispatchQueue.main.async {
//                                    StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.sorted(by: { $0.createdAt > $1.createdAt })
//                                    StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
//
//                                    self.ai.alpha = 0
//                                    self.ai.removeFromSuperview()
//
//                                    self.tableView.reloadData()
//                                }
//                            }
//                        }
                        
                    }
                }
            } else {
                
            }
            
            
        }
        if toIndex == 1 {
            
            if self.countcount2 == 0 {
                self.newUpdatesB1.alpha = 0
                self.newUpdatesB2.alpha = 0
            } else {
                self.newUpdatesB1.alpha = 0
                self.newUpdatesB2.alpha = 1
            }
            
            self.currentIndex = 0
            //self.tableView2.reloadData()
            self.tableView.alpha = 0
            self.tableView2.alpha = 1
            
            
            if StoreStruct.notifications.isEmpty {
                let request = Notifications.all(range: .default)
                StoreStruct.client.run(request) { (statuses) in
                    if let stat = (statuses.value) {
                        StoreStruct.notifications = stat
                        self.tableView2.reloadData()
                        
                    }
                }
            } else {
                self.tableView2.reloadData()
            }
            
            
        }
    }
    
    
    
    
    
    
    
    // Table stuff
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.currentIndex == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentIndex == 0 {
            if section == 0 {
                return 1
            } else {
                return StoreStruct.notifications.count
            }
        } else {
            return StoreStruct.notificationsMentions.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.currentIndex == 0 && indexPath.section == 0 {
            //return 220
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView2 {
            
            if indexPath.section == 0 {
                
                // make graph in cell
                
                let cell = tableView2.dequeueReusableCell(withIdentifier: "cellG02", for: indexPath) as! GraphCell
                //                let data: [Double] = [Double(20), Double(50), Double(12), Double(25), Double(15), Double(5), Double(21)]
                //                let labels = ["S", "M", "T", "W", "T", "F", "S"]
                //                cell.configure(data: data, labels: labels)
                //                cell.backgroundColor = Colours.white
                //                cell.graphView.fillGradientEndColor = Colours.white
                //                cell.graphView.dataPointLabelColor = Colours.black.withAlphaComponent(0.6)
                let bgColorView = UIView()
                bgColorView.backgroundColor = Colours.white
                cell.selectedBackgroundView = bgColorView
                return cell
                
                
            } else {
                
                
                
                
                if StoreStruct.notifications.count == 0 || indexPath.row >= StoreStruct.notifications.count {
                    
                    self.ai.stopAnimating()
                    self.ai.removeFromSuperview()
                    
                    let cell = tableView2.dequeueReusableCell(withIdentifier: "cell302", for: indexPath) as! NotificationCell
                    cell.backgroundColor = Colours.white
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = Colours.white
                    cell.selectedBackgroundView = bgColorView
                    return cell
                } else {
                    
                    
                    if indexPath.row == StoreStruct.notifications.count - 14 {
                        self.fetchMoreNotifications()
                    }
                    
                    
                    if let hasStatus = StoreStruct.notifications[indexPath.row].status {
                        
                        if hasStatus.mediaAttachments.isEmpty || (UserDefaults.standard.object(forKey: "sensitiveToggle") != nil) && (UserDefaults.standard.object(forKey: "sensitiveToggle") as? Int == 1) {
                            let cell = tableView2.dequeueReusableCell(withIdentifier: "cell302", for: indexPath) as! NotificationCell
                            cell.delegate = self
                            cell.configure(StoreStruct.notifications[indexPath.row])
                            cell.profileImageView.tag = indexPath.row
                            cell.profileImageView.addTarget(self, action: #selector(self.didTouchProfile), for: .touchUpInside)
                            cell.backgroundColor = Colours.white
                            //cell.userName.textColor = Colours.black
                            //cell.userTag.textColor = Colours.black.withAlphaComponent(0.6)
                            //cell.date.textColor = Colours.black.withAlphaComponent(0.6)
                            //cell.toot.textColor = Colours.black
                            cell.typeImage.backgroundColor = Colours.white
                            cell.toot.handleMentionTap { (string) in
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let selection = UISelectionFeedbackGenerator()
                                    selection.selectionChanged()
                                }
                                
                                var newString = string
                                for z2 in StoreStruct.notifications[indexPath.row].status!.mentions {
                                    if z2.acct.contains(string) {
                                        newString = z2.acct
                                    }
                                }
                                
                                
                                let controller = ThirdViewController()
                                if newString == StoreStruct.currentUser.username {} else {
                                    controller.fromOtherUser = true
                                }
                                let request = Accounts.search(query: newString)
                                StoreStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        if stat.count > 0 {
                                            controller.userIDtoUse = stat[0].id
                                            DispatchQueue.main.async {
                                                self.navigationController?.pushViewController(controller, animated: true)
                                            }
                                        }
                                    }
                                }
                            }
                            cell.toot.handleURLTap { (url) in
                                // safari
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let selection = UISelectionFeedbackGenerator()
                                    selection.selectionChanged()
                                }
                                if url.absoluteString.hasPrefix(".") {
                                    let z = URL(string: String(url.absoluteString.dropFirst()))!
                                    self.safariVC = SFSafariViewController(url: z)
                                    self.safariVC?.preferredBarTintColor = Colours.white
                                    self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                    self.present(self.safariVC!, animated: true, completion: nil)
                                } else {
                                    self.safariVC = SFSafariViewController(url: url)
                                    self.safariVC?.preferredBarTintColor = Colours.white
                                    self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                    self.present(self.safariVC!, animated: true, completion: nil)
                                }
                            }
                            cell.toot.handleHashtagTap { (string) in
                                // hash
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let selection = UISelectionFeedbackGenerator()
                                    selection.selectionChanged()
                                }
                                let controller = HashtagViewController()
                                controller.currentTagTitle = string
                                let request = Timelines.tag(string)
                                StoreStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        controller.currentTags = stat
                                        DispatchQueue.main.async {
                                            self.navigationController?.pushViewController(controller, animated: true)
                                        }
                                    }
                                }
                            }
                            let bgColorView = UIView()
                            bgColorView.backgroundColor = Colours.white
                            cell.selectedBackgroundView = bgColorView
                            return cell
                        } else {
                            let cell = tableView2.dequeueReusableCell(withIdentifier: "cell402", for: indexPath) as! NotificationCellImage
                            cell.delegate = self
                            cell.configure(StoreStruct.notifications[indexPath.row])
                            cell.profileImageView.tag = indexPath.row
                            cell.profileImageView.addTarget(self, action: #selector(self.didTouchProfile), for: .touchUpInside)
                            cell.mainImageView.addTarget(self, action: #selector(self.tappedImage(_:)), for: .touchUpInside)
                            cell.mainImageView.tag = indexPath.row
                            cell.backgroundColor = Colours.white
                            //cell.userName.textColor = Colours.black
                            //cell.userTag.textColor = Colours.black.withAlphaComponent(0.6)
                            //cell.date.textColor = Colours.black.withAlphaComponent(0.6)
                            //cell.toot.textColor = Colours.black
                            cell.typeImage.backgroundColor = Colours.white
                            cell.mainImageView.backgroundColor = Colours.white
                            cell.mainImageViewBG.backgroundColor = Colours.white
                            cell.toot.handleMentionTap { (string) in
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let selection = UISelectionFeedbackGenerator()
                                    selection.selectionChanged()
                                }
                                
                                var newString = string
                                for z2 in StoreStruct.notifications[indexPath.row].status!.mentions {
                                    if z2.acct.contains(string) {
                                        newString = z2.acct
                                    }
                                }
                                
                                
                                let controller = ThirdViewController()
                                if newString == StoreStruct.currentUser.username {} else {
                                    controller.fromOtherUser = true
                                }
                                let request = Accounts.search(query: newString)
                                StoreStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        if stat.count > 0 {
                                            controller.userIDtoUse = stat[0].id
                                            DispatchQueue.main.async {
                                                self.navigationController?.pushViewController(controller, animated: true)
                                            }
                                        }
                                    }
                                }
                            }
                            cell.toot.handleURLTap { (url) in
                                // safari
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let selection = UISelectionFeedbackGenerator()
                                    selection.selectionChanged()
                                }
                                if url.absoluteString.hasPrefix(".") {
                                    let z = URL(string: String(url.absoluteString.dropFirst()))!
                                    self.safariVC = SFSafariViewController(url: z)
                                    self.safariVC?.preferredBarTintColor = Colours.white
                                    self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                    self.present(self.safariVC!, animated: true, completion: nil)
                                } else {
                                    self.safariVC = SFSafariViewController(url: url)
                                    self.safariVC?.preferredBarTintColor = Colours.white
                                    self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                    self.present(self.safariVC!, animated: true, completion: nil)
                                }
                            }
                            cell.toot.handleHashtagTap { (string) in
                                // hash
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let selection = UISelectionFeedbackGenerator()
                                    selection.selectionChanged()
                                }
                                let controller = HashtagViewController()
                                controller.currentTagTitle = string
                                let request = Timelines.tag(string)
                                StoreStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        controller.currentTags = stat
                                        DispatchQueue.main.async {
                                            self.navigationController?.pushViewController(controller, animated: true)
                                        }
                                    }
                                }
                            }
                            let bgColorView = UIView()
                            bgColorView.backgroundColor = Colours.white
                            cell.selectedBackgroundView = bgColorView
                            return cell
                        }
                        
                        
                        
                    } else {
                        
                        let cell = tableView2.dequeueReusableCell(withIdentifier: "cell302", for: indexPath) as! NotificationCell
                        cell.delegate = self
                        cell.configure(StoreStruct.notifications[indexPath.row])
                        cell.backgroundColor = Colours.white
                        //cell.userName.textColor = Colours.black
                        //cell.userTag.textColor = Colours.black.withAlphaComponent(0.6)
                        //cell.date.textColor = Colours.black.withAlphaComponent(0.6)
                        //cell.toot.textColor = Colours.black
                        cell.typeImage.backgroundColor = Colours.white
                        cell.toot.handleMentionTap { (string) in
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            
                            var newString = string
                            for z2 in StoreStruct.notifications[indexPath.row].status!.mentions {
                                if z2.acct.contains(string) {
                                    newString = z2.acct
                                }
                            }
                            
                            
                            let controller = ThirdViewController()
                            if newString == StoreStruct.currentUser.username {} else {
                                controller.fromOtherUser = true
                            }
                            let request = Accounts.search(query: newString)
                            StoreStruct.client.run(request) { (statuses) in
                                if let stat = (statuses.value) {
                                    if stat.count > 0 {
                                        controller.userIDtoUse = stat[0].id
                                        DispatchQueue.main.async {
                                            self.navigationController?.pushViewController(controller, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                        cell.toot.handleURLTap { (url) in
                            // safari
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            if url.absoluteString.hasPrefix(".") {
                                let z = URL(string: String(url.absoluteString.dropFirst()))!
                                self.safariVC = SFSafariViewController(url: z)
                                self.safariVC?.preferredBarTintColor = Colours.white
                                self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                self.present(self.safariVC!, animated: true, completion: nil)
                            } else {
                                self.safariVC = SFSafariViewController(url: url)
                                self.safariVC?.preferredBarTintColor = Colours.white
                                self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                self.present(self.safariVC!, animated: true, completion: nil)
                            }
                        }
                        cell.toot.handleHashtagTap { (string) in
                            // hash
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            let controller = HashtagViewController()
                            controller.currentTagTitle = string
                            let request = Timelines.tag(string)
                            StoreStruct.client.run(request) { (statuses) in
                                if let stat = (statuses.value) {
                                    controller.currentTags = stat
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                            }
                        }
                        let bgColorView = UIView()
                        bgColorView.backgroundColor = Colours.white
                        cell.selectedBackgroundView = bgColorView
                        return cell
                    }
                }
                
            }
            
        } else {
            
            
            
            
            if StoreStruct.notificationsMentions.count == 0 || indexPath.row >= StoreStruct.notificationsMentions.count {
                
                self.ai.stopAnimating()
                self.ai.removeFromSuperview()
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! NotificationCell
                cell.backgroundColor = Colours.white
                let bgColorView = UIView()
                bgColorView.backgroundColor = Colours.white
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                
                
                if indexPath.row == StoreStruct.notificationsMentions.count - 14 {
                    self.fetchMoreNotifications()
                }
                if indexPath.row < 7 && self.doOnce == false {
                    self.doOnce = true
                    self.fetchMoreNotifications()
                }
                
                if let hasStatus = StoreStruct.notificationsMentions[indexPath.row].status {
                    
                    if hasStatus.mediaAttachments.isEmpty || (UserDefaults.standard.object(forKey: "sensitiveToggle") != nil) && (UserDefaults.standard.object(forKey: "sensitiveToggle") as? Int == 1) {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! NotificationCell
                        cell.delegate = self
                        cell.configure(StoreStruct.notificationsMentions[indexPath.row])
                        cell.profileImageView.tag = indexPath.row
                        cell.profileImageView.addTarget(self, action: #selector(self.didTouchProfile), for: .touchUpInside)
                        cell.backgroundColor = Colours.white
                        //cell.userName.textColor = Colours.black
                        //cell.userTag.textColor = Colours.black.withAlphaComponent(0.6)
                        //cell.date.textColor = Colours.black.withAlphaComponent(0.6)
                        //cell.toot.textColor = Colours.black
                        cell.typeImage.backgroundColor = Colours.white
                        cell.toot.handleMentionTap { (string) in
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            
                            var newString = string
                            for z2 in StoreStruct.notificationsMentions[indexPath.row].status!.mentions {
                                if z2.acct.contains(string) {
                                    newString = z2.acct
                                }
                            }
                            
                            
                            let controller = ThirdViewController()
                            if newString == StoreStruct.currentUser.username {} else {
                                controller.fromOtherUser = true
                            }
                            let request = Accounts.search(query: newString)
                            StoreStruct.client.run(request) { (statuses) in
                                if let stat = (statuses.value) {
                                    if stat.count > 0 {
                                        controller.userIDtoUse = stat[0].id
                                        DispatchQueue.main.async {
                                            self.navigationController?.pushViewController(controller, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                        cell.toot.handleURLTap { (url) in
                            // safari
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            if url.absoluteString.hasPrefix(".") {
                                let z = URL(string: String(url.absoluteString.dropFirst()))!
                                self.safariVC = SFSafariViewController(url: z)
                                self.safariVC?.preferredBarTintColor = Colours.white
                                self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                self.present(self.safariVC!, animated: true, completion: nil)
                            } else {
                                self.safariVC = SFSafariViewController(url: url)
                                self.safariVC?.preferredBarTintColor = Colours.white
                                self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                self.present(self.safariVC!, animated: true, completion: nil)
                            }
                        }
                        cell.toot.handleHashtagTap { (string) in
                            // hash
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            let controller = HashtagViewController()
                            controller.currentTagTitle = string
                            let request = Timelines.tag(string)
                            StoreStruct.client.run(request) { (statuses) in
                                if let stat = (statuses.value) {
                                    controller.currentTags = stat
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                            }
                        }
                        let bgColorView = UIView()
                        bgColorView.backgroundColor = Colours.white
                        cell.selectedBackgroundView = bgColorView
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! NotificationCellImage
                        cell.delegate = self
                        cell.configure(StoreStruct.notificationsMentions[indexPath.row])
                        cell.profileImageView.tag = indexPath.row
                        cell.profileImageView.addTarget(self, action: #selector(self.didTouchProfile), for: .touchUpInside)
                        cell.mainImageView.addTarget(self, action: #selector(self.tappedImage(_:)), for: .touchUpInside)
                        cell.mainImageView.tag = indexPath.row
                        cell.backgroundColor = Colours.white
                        //cell.userName.textColor = Colours.black
                        //cell.userTag.textColor = Colours.black.withAlphaComponent(0.6)
                        //cell.date.textColor = Colours.black.withAlphaComponent(0.6)
                        //cell.toot.textColor = Colours.black
                        cell.typeImage.backgroundColor = Colours.white
                        cell.mainImageView.backgroundColor = Colours.white
                        cell.mainImageViewBG.backgroundColor = Colours.white
                        cell.toot.handleMentionTap { (string) in
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            
                            var newString = string
                            for z2 in StoreStruct.notificationsMentions[indexPath.row].status!.mentions {
                                if z2.acct.contains(string) {
                                    newString = z2.acct
                                }
                            }
                            
                            
                            let controller = ThirdViewController()
                            if newString == StoreStruct.currentUser.username {} else {
                                controller.fromOtherUser = true
                            }
                            let request = Accounts.search(query: newString)
                            StoreStruct.client.run(request) { (statuses) in
                                if let stat = (statuses.value) {
                                    if stat.count > 0 {
                                        controller.userIDtoUse = stat[0].id
                                        DispatchQueue.main.async {
                                            self.navigationController?.pushViewController(controller, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                        cell.toot.handleURLTap { (url) in
                            // safari
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            if url.absoluteString.hasPrefix(".") {
                                let z = URL(string: String(url.absoluteString.dropFirst()))!
                                self.safariVC = SFSafariViewController(url: z)
                                self.safariVC?.preferredBarTintColor = Colours.white
                                self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                self.present(self.safariVC!, animated: true, completion: nil)
                            } else {
                                self.safariVC = SFSafariViewController(url: url)
                                self.safariVC?.preferredBarTintColor = Colours.white
                                self.safariVC?.preferredControlTintColor = Colours.tabSelected
                                self.present(self.safariVC!, animated: true, completion: nil)
                            }
                        }
                        cell.toot.handleHashtagTap { (string) in
                            // hash
                            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                let selection = UISelectionFeedbackGenerator()
                                selection.selectionChanged()
                            }
                            let controller = HashtagViewController()
                            controller.currentTagTitle = string
                            let request = Timelines.tag(string)
                            StoreStruct.client.run(request) { (statuses) in
                                if let stat = (statuses.value) {
                                    controller.currentTags = stat
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                            }
                        }
                        let bgColorView = UIView()
                        bgColorView.backgroundColor = Colours.white
                        cell.selectedBackgroundView = bgColorView
                        return cell
                    }
                    
                } else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! NotificationCell
                    cell.delegate = self
                    cell.configure(StoreStruct.notificationsMentions[indexPath.row])
                    cell.backgroundColor = Colours.white
                    //cell.userName.textColor = Colours.black
                    //cell.userTag.textColor = Colours.black.withAlphaComponent(0.6)
                    //cell.date.textColor = Colours.black.withAlphaComponent(0.6)
                    //cell.toot.textColor = Colours.black
                    cell.typeImage.backgroundColor = Colours.white
                    cell.toot.handleMentionTap { (string) in
                        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                            let selection = UISelectionFeedbackGenerator()
                            selection.selectionChanged()
                        }
                        
                        var newString = string
                        for z2 in StoreStruct.notificationsMentions[indexPath.row].status!.mentions {
                            if z2.acct.contains(string) {
                                newString = z2.acct
                            }
                        }
                        
                        
                        let controller = ThirdViewController()
                        if newString == StoreStruct.currentUser.username {} else {
                            controller.fromOtherUser = true
                        }
                        let request = Accounts.search(query: newString)
                        StoreStruct.client.run(request) { (statuses) in
                            if let stat = (statuses.value) {
                                if stat.count > 0 {
                                    controller.userIDtoUse = stat[0].id
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                            }
                        }
                    }
                    cell.toot.handleURLTap { (url) in
                        // safari
                        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                            let selection = UISelectionFeedbackGenerator()
                            selection.selectionChanged()
                        }
                        if url.absoluteString.hasPrefix(".") {
                            let z = URL(string: String(url.absoluteString.dropFirst()))!
                            self.safariVC = SFSafariViewController(url: z)
                            self.safariVC?.preferredBarTintColor = Colours.white
                            self.safariVC?.preferredControlTintColor = Colours.tabSelected
                            self.present(self.safariVC!, animated: true, completion: nil)
                        } else {
                            self.safariVC = SFSafariViewController(url: url)
                            self.safariVC?.preferredBarTintColor = Colours.white
                            self.safariVC?.preferredControlTintColor = Colours.tabSelected
                            self.present(self.safariVC!, animated: true, completion: nil)
                        }
                    }
                    cell.toot.handleHashtagTap { (string) in
                        // hash
                        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                            let selection = UISelectionFeedbackGenerator()
                            selection.selectionChanged()
                        }
                        let controller = HashtagViewController()
                        controller.currentTagTitle = string
                        let request = Timelines.tag(string)
                        StoreStruct.client.run(request) { (statuses) in
                            if let stat = (statuses.value) {
                                controller.currentTags = stat
                                DispatchQueue.main.async {
                                    self.navigationController?.pushViewController(controller, animated: true)
                                }
                            }
                        }
                    }
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = Colours.white
                    cell.selectedBackgroundView = bgColorView
                    return cell
                    
                }
            }
            
        }
        
        
    }
    
    
    @objc func didTouchProfile(sender: UIButton) {
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        
        var sto = StoreStruct.notifications
        if self.currentIndex == 0 {
            sto = StoreStruct.notifications
            print("880")
        } else if self.currentIndex == 1 {
            print("8801")
            sto = StoreStruct.notificationsMentions
        }
        
        print(sender.tag)
        print(sto[sender.tag].account.username)
        print(sto[0].account.username)
        print("test")
        
        let controller = ThirdViewController()
        if sto[sender.tag].account.username == StoreStruct.currentUser.username {} else {
            controller.fromOtherUser = true
        }
        controller.userIDtoUse = sto[sender.tag].account.id
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func tappedImage(_ sender: UIButton) {
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        
        var sto = StoreStruct.notifications
        if self.currentIndex == 0 {
            sto = StoreStruct.notifications
        } else if self.currentIndex == 1 {
            sto = StoreStruct.notificationsMentions
        }
        
        
        if sto[sender.tag].status?.mediaAttachments[0].type == .video || sto[sender.tag].status?.mediaAttachments[0].type == .gifv {
            
            let videoURL = URL(string: sto[sender.tag].status!.mediaAttachments[0].url)!
            if (UserDefaults.standard.object(forKey: "vidgif") == nil) || (UserDefaults.standard.object(forKey: "vidgif") as! Int == 0) {
                XPlayer.play(videoURL)
            } else {
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
            
            
        } else {
            
            var indexPath = IndexPath(row: sender.tag, section: 0)
            if self.currentIndex == 0 {
                indexPath = IndexPath(row: sender.tag, section: 1)
            }
            
            if self.currentIndex == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! NotificationCellImage
            var images = [SKPhoto]()
                var coun = 0
            for y in sto[indexPath.row].status!.mediaAttachments {
                if coun == 0 {
                    let photo = SKPhoto.photoWithImageURL(y.url, holder: cell.mainImageView.currentImage ?? nil)
                    photo.shouldCachePhotoURLImage = true
                    if (UserDefaults.standard.object(forKey: "captionset") == nil) || (UserDefaults.standard.object(forKey: "captionset") as! Int == 0) {
                        photo.caption = sto[indexPath.row].status?.content.stripHTML() ?? ""
                    } else {
                        photo.caption = y.description ?? ""
                    }
                    images.append(photo)
                } else {
                let photo = SKPhoto.photoWithImageURL(y.url, holder: nil)
                photo.shouldCachePhotoURLImage = true
                if (UserDefaults.standard.object(forKey: "captionset") == nil) || (UserDefaults.standard.object(forKey: "captionset") as! Int == 0) {
                    photo.caption = sto[indexPath.row].status?.content.stripHTML() ?? ""
                } else {
                    photo.caption = y.description ?? ""
                }
                images.append(photo)
                }
                coun += 1
            }
            let originImage = sender.currentImage
            if originImage != nil {
                let browser = SKPhotoBrowser(originImage: originImage ?? UIImage(), photos: images, animatedFromView: cell.mainImageView)
                browser.displayToolbar = true
                browser.displayAction = true
                browser.delegate = self
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: nil)
            }
            } else {
                
                let cell = tableView2.cellForRow(at: indexPath) as! NotificationCellImage
                var images = [SKPhoto]()
                var coun = 0
                for y in sto[indexPath.row].status!.mediaAttachments {
                    if coun == 0 {
                        let photo = SKPhoto.photoWithImageURL(y.url, holder: cell.mainImageView.currentImage ?? nil)
                        photo.shouldCachePhotoURLImage = true
                        if (UserDefaults.standard.object(forKey: "captionset") == nil) || (UserDefaults.standard.object(forKey: "captionset") as! Int == 0) {
                            photo.caption = sto[indexPath.row].status?.content.stripHTML() ?? ""
                        } else {
                            photo.caption = y.description ?? ""
                        }
                        images.append(photo)
                    } else {
                    let photo = SKPhoto.photoWithImageURL(y.url, holder: nil)
                    photo.shouldCachePhotoURLImage = true
                    if (UserDefaults.standard.object(forKey: "captionset") == nil) || (UserDefaults.standard.object(forKey: "captionset") as! Int == 0) {
                        photo.caption = sto[indexPath.row].status?.content.stripHTML() ?? ""
                    } else {
                        photo.caption = y.description ?? ""
                    }
                    images.append(photo)
                    }
                    coun += 1
                }
                let originImage = sender.currentImage
                if originImage != nil {
                    let browser = SKPhotoBrowser(originImage: originImage ?? UIImage(), photos: images, animatedFromView: cell.mainImageView)
                    browser.displayToolbar = true
                    browser.displayAction = true
                    browser.delegate = self
                    browser.initializePageIndex(0)
                    present(browser, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        var theTable = self.tableView
        var sto = StoreStruct.notifications
        if self.currentIndex == 0 {
            sto = StoreStruct.notifications
            theTable = self.tableView2
        } else if self.currentIndex == 1 {
            sto = StoreStruct.notificationsMentions
            theTable = self.tableView
        }
        
        if StoreStruct.notifications[indexPath.row].type == .mention || self.currentIndex == 1 {
            if orientation == .left {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                
                let boost = SwipeAction(style: .default, title: nil) { action, indexPath in
                    print("boost")
                    if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                        impact.impactOccurred()
                    }
                    
                    
                    if sto[indexPath.row].status!.reblogged! || StoreStruct.allBoosts.contains(sto[indexPath.row].status?.id ?? "" ) {
                        StoreStruct.allBoosts = StoreStruct.allBoosts.filter { $0 != sto[indexPath.row].status?.id ?? ""  }
                        let request2 = Statuses.unreblog(id: sto[indexPath.row].status?.id ?? "" )
                        StoreStruct.client.run(request2) { (statuses) in
                            DispatchQueue.main.async {
                                if let cell = theTable.cellForRow(at: indexPath) as? NotificationCell {
                                    if sto[indexPath.row].status!.favourited! || StoreStruct.allLikes.contains(sto[indexPath.row].status?.id ?? "" ) {
                                        cell.moreImage.image = nil
                                        cell.moreImage.image = UIImage(named: "like")
                                    } else {
                                        cell.moreImage.image = nil
                                    }
                                    cell.hideSwipe(animated: true)
                                } else {
                                    let cell = theTable.cellForRow(at: indexPath) as! NotificationCellImage
                                    if sto[indexPath.row].status!.favourited! || StoreStruct.allLikes.contains(sto[indexPath.row].status?.id ?? "" ) {
                                        cell.moreImage.image = nil
                                        cell.moreImage.image = UIImage(named: "like")
                                    } else {
                                        cell.moreImage.image = nil
                                    }
                                    cell.hideSwipe(animated: true)
                                }
                            }
                        }
                    } else {
                        StoreStruct.allBoosts.append(sto[indexPath.row].status?.id ?? "" )
                        let request2 = Statuses.reblog(id: sto[indexPath.row].status?.id ?? "" )
                        StoreStruct.client.run(request2) { (statuses) in
                            DispatchQueue.main.async {
                                if (UserDefaults.standard.object(forKey: "notifToggle") == nil) || (UserDefaults.standard.object(forKey: "notifToggle") as! Int == 0) {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "confettiCreateRe"), object: nil)
                                }
                                
                                if let cell = theTable.cellForRow(at: indexPath) as? NotificationCell {
                                    if sto[indexPath.row].status!.favourited ?? false || StoreStruct.allLikes.contains(sto[indexPath.row].status?.id ?? "" ) {
                                        cell.moreImage.image = nil
                                        cell.moreImage.image = UIImage(named: "fifty")
                                    } else {
                                        cell.moreImage.image = UIImage(named: "boost")
                                    }
                                    cell.hideSwipe(animated: true)
                                } else {
                                    let cell = theTable.cellForRow(at: indexPath) as! NotificationCellImage
                                    if sto[indexPath.row].status!.favourited ?? false || StoreStruct.allLikes.contains(sto[indexPath.row].status?.id ?? "" ) {
                                        cell.moreImage.image = nil
                                        cell.moreImage.image = UIImage(named: "fifty")
                                    } else {
                                        cell.moreImage.image = UIImage(named: "boost")
                                    }
                                    cell.hideSwipe(animated: true)
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    if let cell = theTable.cellForRow(at: indexPath) as? NotificationCell {
                        cell.hideSwipe(animated: true)
                    } else {
                        let cell = theTable.cellForRow(at: indexPath) as! NotificationCellImage
                        cell.hideSwipe(animated: true)
                    }
                }
                boost.backgroundColor = Colours.white
                boost.image = UIImage(named: "boost")
                boost.transitionDelegate = ScaleTransition.default
                boost.textColor = Colours.tabUnselected
                
                let like = SwipeAction(style: .default, title: nil) { action, indexPath in
                    print("like")
                    if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                        impact.impactOccurred()
                    }
                    
                    
                    
                    
                    
                    
                    
                    if sto[indexPath.row].status!.favourited! || StoreStruct.allLikes.contains(sto[indexPath.row].status?.id ?? "" ) {
                        StoreStruct.allLikes = StoreStruct.allLikes.filter { $0 != sto[indexPath.row].status?.id ?? "" }
                        let request2 = Statuses.unfavourite(id: sto[indexPath.row].status?.id ?? "" )
                        StoreStruct.client.run(request2) { (statuses) in
                            DispatchQueue.main.async {
                                if let cell = theTable.cellForRow(at: indexPath) as? NotificationCell {
                                    if sto[indexPath.row].status!.reblogged! || StoreStruct.allBoosts.contains(sto[indexPath.row].status?.id ?? "" ) {
                                        cell.moreImage.image = nil
                                        cell.moreImage.image = UIImage(named: "boost")
                                    } else {
                                        cell.moreImage.image = nil
                                    }
                                    cell.hideSwipe(animated: true)
                                } else {
                                    let cell = theTable.cellForRow(at: indexPath) as! NotificationCellImage
                                    if sto[indexPath.row].status!.reblogged! || StoreStruct.allBoosts.contains(sto[indexPath.row].status?.id ?? "" ) {
                                        cell.moreImage.image = nil
                                        cell.moreImage.image = UIImage(named: "boost")
                                    } else {
                                        cell.moreImage.image = nil
                                    }
                                    cell.hideSwipe(animated: true)
                                }
                            }
                        }
                    } else {
                        StoreStruct.allLikes.append(sto[indexPath.row].status?.id ?? "" )
                        let request2 = Statuses.favourite(id: sto[indexPath.row].status?.id ?? "" )
                        StoreStruct.client.run(request2) { (statuses) in
                            DispatchQueue.main.async {
                                if (UserDefaults.standard.object(forKey: "notifToggle") == nil) || (UserDefaults.standard.object(forKey: "notifToggle") as! Int == 0) {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "confettiCreateLi"), object: nil)
                                }
                                if let cell = theTable.cellForRow(at: indexPath) as? NotificationCell {
                                    if sto[indexPath.row].status!.reblogged ?? false || StoreStruct.allBoosts.contains(sto[indexPath.row].status?.id ?? "" ) {
                                        cell.moreImage.image = nil
                                        cell.moreImage.image = UIImage(named: "fifty")
                                    } else {
                                        cell.moreImage.image = UIImage(named: "like")
                                    }
                                    cell.hideSwipe(animated: true)
                                } else {
                                    let cell = theTable.cellForRow(at: indexPath) as! NotificationCellImage
                                    if sto[indexPath.row].status!.reblogged ?? false || StoreStruct.allBoosts.contains(sto[indexPath.row].status?.id ?? "" ) {
                                        cell.moreImage.image = nil
                                        cell.moreImage.image = UIImage(named: "fifty")
                                    } else {
                                        cell.moreImage.image = UIImage(named: "like")
                                    }
                                    cell.hideSwipe(animated: true)
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                    
                    
                    if let cell = theTable.cellForRow(at: indexPath) as? NotificationCell {
                        cell.hideSwipe(animated: true)
                    } else {
                        let cell = theTable.cellForRow(at: indexPath) as! NotificationCellImage
                        cell.hideSwipe(animated: true)
                    }
                }
                like.backgroundColor = Colours.white
                like.image = UIImage(named: "like")
                like.transitionDelegate = ScaleTransition.default
                like.textColor = Colours.tabUnselected
                
                let reply = SwipeAction(style: .default, title: nil) { action, indexPath in
                    print("reply")
                    if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                        impact.impactOccurred()
                    }
                    let controller = ComposeViewController()
                    StoreStruct.spoilerText = sto[indexPath.row].status?.spoilerText ?? ""
                    controller.inReply = [sto[indexPath.row].status!]
                    controller.inReplyText = sto[indexPath.row].account.username
                    controller.prevTextReply = sto[indexPath.row].status!.content.stripHTML()
                    print(sto[indexPath.row].account.username)
                    self.present(controller, animated: true, completion: nil)
                    
                    
                    if let cell = theTable.cellForRow(at: indexPath) as? NotificationCell {
                        cell.hideSwipe(animated: true)
                    } else {
                        let cell = theTable.cellForRow(at: indexPath) as! NotificationCellImage
                        cell.hideSwipe(animated: true)
                    }
                }
                reply.backgroundColor = Colours.white
                if sto[indexPath.row].status?.visibility == .direct {
                    reply.image = UIImage(named: "direct2")
                } else {
                    reply.image = UIImage(named: "reply")
                }
                reply.transitionDelegate = ScaleTransition.default
                reply.textColor = Colours.tabUnselected
                
                
                if sto[indexPath.row].status?.visibility == .direct {
                    if (UserDefaults.standard.object(forKey: "sworder") == nil) || (UserDefaults.standard.object(forKey: "sworder") as! Int == 0) {
                        return [reply, like]
                    } else if (UserDefaults.standard.object(forKey: "sworder") as! Int == 1) {
                        return [reply, like]
                    } else if (UserDefaults.standard.object(forKey: "sworder") as! Int == 2) {
                        return [reply, like]
                    } else if (UserDefaults.standard.object(forKey: "sworder") as! Int == 3) {
                        return [like, reply]
                    } else if (UserDefaults.standard.object(forKey: "sworder") as! Int == 4) {
                        return [like, reply]
                    } else {
                        return [like, reply]
                    }
                } else {
                    if (UserDefaults.standard.object(forKey: "sworder") == nil) || (UserDefaults.standard.object(forKey: "sworder") as! Int == 0) {
                        return [reply, like, boost]
                    } else if (UserDefaults.standard.object(forKey: "sworder") as! Int == 1) {
                        return [reply, boost, like]
                    } else if (UserDefaults.standard.object(forKey: "sworder") as! Int == 2) {
                        return [boost, reply, like]
                    } else if (UserDefaults.standard.object(forKey: "sworder") as! Int == 3) {
                        return [boost, like, reply]
                    } else if (UserDefaults.standard.object(forKey: "sworder") as! Int == 4) {
                        return [like, reply, boost]
                    } else {
                        return [like, boost, reply]
                    }
                }
                
                
            } else {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                
                let more = SwipeAction(style: .default, title: nil) { action, indexPath in
                    print("boost")
                    if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                        impact.impactOccurred()
                    }
                    
                    
                    var isMuted = false
                    let request0 = Mutes.all()
                    StoreStruct.client.run(request0) { (statuses) in
                        if let stat = (statuses.value) {
                            let s = stat.filter { $0.id == sto[indexPath.row].account.id }
                            if s.isEmpty {
                                isMuted = false
                            } else {
                                isMuted = true
                            }
                        }
                    }
                    var isBlocked = false
                    let request01 = Blocks.all()
                    StoreStruct.client.run(request01) { (statuses) in
                        if let stat = (statuses.value) {
                            let s = stat.filter { $0.id == sto[indexPath.row].account.id }
                            if s.isEmpty {
                                isBlocked = false
                            } else {
                                isBlocked = true
                            }
                        }
                    }
                    
                    Alertift.actionSheet(title: nil, message: nil)
                        .backgroundColor(Colours.white)
                        .titleTextColor(Colours.grayDark)
                        .messageTextColor(Colours.grayDark.withAlphaComponent(0.8))
                        .messageTextAlignment(.left)
                        .titleTextAlignment(.left)
                        .action(.default("Mute/Unmute".localized), image: UIImage(named: "block")) { (action, ind) in
                            print(action, ind)
                            
                            if isMuted == false {
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let notification = UINotificationFeedbackGenerator()
                                    notification.notificationOccurred(.success)
                                }
                                let statusAlert = StatusAlert()
                                statusAlert.image = UIImage(named: "blocklarge")?.maskWithColor(color: Colours.grayDark)
                                statusAlert.title = "Muted".localized
                                statusAlert.contentColor = Colours.grayDark
                                statusAlert.message = sto[indexPath.row].account.displayName
                                statusAlert.show()
                                
                                let request = Accounts.mute(id: sto[indexPath.row].account.id)
                                StoreStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        print("muted")
                                        print(stat)
                                    }
                                }
                            } else {
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let notification = UINotificationFeedbackGenerator()
                                    notification.notificationOccurred(.success)
                                }
                                let statusAlert = StatusAlert()
                                statusAlert.image = UIImage(named: "blocklarge")?.maskWithColor(color: Colours.grayDark)
                                statusAlert.title = "Unmuted".localized
                                statusAlert.contentColor = Colours.grayDark
                                statusAlert.message = sto[indexPath.row].account.displayName
                                statusAlert.show()
                                
                                let request = Accounts.unmute(id: sto[indexPath.row].account.id)
                                StoreStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        print("unmuted")
                                        print(stat)
                                    }
                                }
                            }
                            
                        }
                        .action(.default("Block/Unblock".localized), image: UIImage(named: "block2")) { (action, ind) in
                            print(action, ind)
                            
                            if isBlocked == false {
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let notification = UINotificationFeedbackGenerator()
                                    notification.notificationOccurred(.success)
                                }
                                let statusAlert = StatusAlert()
                                statusAlert.image = UIImage(named: "block2large")?.maskWithColor(color: Colours.grayDark)
                                statusAlert.title = "Blocked".localized
                                statusAlert.contentColor = Colours.grayDark
                                statusAlert.message = sto[indexPath.row].account.displayName
                                statusAlert.show()
                                
                                let request = Accounts.block(id: sto[indexPath.row].account.id)
                                StoreStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        print("blocked")
                                        print(stat)
                                    }
                                }
                            } else {
                                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                    let notification = UINotificationFeedbackGenerator()
                                    notification.notificationOccurred(.success)
                                }
                                let statusAlert = StatusAlert()
                                statusAlert.image = UIImage(named: "block2large")?.maskWithColor(color: Colours.grayDark)
                                statusAlert.title = "Unblocked".localized
                                statusAlert.contentColor = Colours.grayDark
                                statusAlert.message = sto[indexPath.row].account.displayName
                                statusAlert.show()
                                
                                let request = Accounts.unblock(id: sto[indexPath.row].account.id)
                                StoreStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        print("unblocked")
                                        print(stat)
                                    }
                                }
                            }
                            
                        }
                        .action(.default("Report".localized), image: UIImage(named: "report")) { (action, ind) in
                            print(action, ind)
                            
                            
                            Alertift.actionSheet()
                                .backgroundColor(Colours.white)
                                .titleTextColor(Colours.grayDark)
                                .messageTextColor(Colours.grayDark)
                                .messageTextAlignment(.left)
                                .titleTextAlignment(.left)
                                .action(.default("Harassment"), image: nil) { (action, ind) in
                                    print(action, ind)
                                    if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                        let notification = UINotificationFeedbackGenerator()
                                        notification.notificationOccurred(.success)
                                    }
                                    
                                    
                                    let statusAlert = StatusAlert()
                                    statusAlert.image = UIImage(named: "reportlarge")?.maskWithColor(color: Colours.grayDark)
                                    statusAlert.title = "Reported".localized
                                    statusAlert.contentColor = Colours.grayDark
                                    statusAlert.message = "Harassment"
                                    statusAlert.show()
                                    
                                    let request = Reports.report(accountID: sto[indexPath.row].account.id, statusIDs: [sto[indexPath.row].status?.id ?? ""], reason: "Harassment")
                                    StoreStruct.client.run(request) { (statuses) in
                                        if let stat = (statuses.value) {
                                            print("reported")
                                            print(stat)
                                        }
                                    }
                                    
                                }
                                .action(.default("No Content Warning"), image: nil) { (action, ind) in
                                    print(action, ind)
                                    if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                        let notification = UINotificationFeedbackGenerator()
                                        notification.notificationOccurred(.success)
                                    }
                                    
                                    
                                    let statusAlert = StatusAlert()
                                    statusAlert.image = UIImage(named: "reportlarge")?.maskWithColor(color: Colours.grayDark)
                                    statusAlert.title = "Reported".localized
                                    statusAlert.contentColor = Colours.grayDark
                                    statusAlert.message = "No Content Warning"
                                    statusAlert.show()
                                    
                                    let request = Reports.report(accountID: sto[indexPath.row].account.id, statusIDs: [sto[indexPath.row].status?.id ?? ""], reason: "No Content Warning")
                                    StoreStruct.client.run(request) { (statuses) in
                                        if let stat = (statuses.value) {
                                            print("reported")
                                            print(stat)
                                        }
                                    }
                                    
                                }
                                .action(.default("Spam"), image: nil) { (action, ind) in
                                    print(action, ind)
                                    if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                                        let notification = UINotificationFeedbackGenerator()
                                        notification.notificationOccurred(.success)
                                    }
                                    
                                    
                                    let statusAlert = StatusAlert()
                                    statusAlert.image = UIImage(named: "reportlarge")?.maskWithColor(color: Colours.grayDark)
                                    statusAlert.title = "Reported".localized
                                    statusAlert.contentColor = Colours.grayDark
                                    statusAlert.message = "Spam"
                                    statusAlert.show()
                                    
                                    let request = Reports.report(accountID: sto[indexPath.row].account.id, statusIDs: [sto[indexPath.row].status?.id ?? ""], reason: "Spam")
                                    StoreStruct.client.run(request) { (statuses) in
                                        if let stat = (statuses.value) {
                                            print("reported")
                                            print(stat)
                                        }
                                    }
                                    
                                }
                                .action(.cancel("Dismiss"))
                                .finally { action, index in
                                    if action.style == .cancel {
                                        return
                                    }
                                }
                                .show(on: self)
                            
                            
                        }
                        .action(.default("Translate".localized), image: UIImage(named: "translate")) { (action, ind) in
                            print(action, ind)
                            
                            let unreserved = "-._~/?"
                            let allowed = NSMutableCharacterSet.alphanumeric()
                            allowed.addCharacters(in: unreserved)
                            let bodyText = sto[indexPath.row].status?.content.stripHTML() ?? ""
                            let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
                            let unreservedCharset = NSCharacterSet(charactersIn: unreservedChars)
                            var trans = bodyText.addingPercentEncoding(withAllowedCharacters: unreservedCharset as CharacterSet)
                            trans = trans!.replacingOccurrences(of: "\n", with: "%20")
                            let langStr = Locale.current.languageCode
                            let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=\(langStr ?? "en")&dt=t&q=\(trans!)&ie=UTF-8&oe=UTF-8"
                            guard let requestUrl = URL(string:urlString) else {
                                return
                            }
                            let request = URLRequest(url:requestUrl)
                            let task = URLSession.shared.dataTask(with: request) {
                                (data, response, error) in
                                if error == nil, let usableData = data {
                                    do {
                                        let json = try JSONSerialization.jsonObject(with: usableData, options: .mutableContainers) as! [Any]
                                        
                                        var translatedText = ""
                                        for i in (json[0] as! [Any]) {
                                            translatedText = translatedText + ((i as! [Any])[0] as? String ?? "")
                                        }
                                        
                                        Alertift.actionSheet(title: nil, message: translatedText as? String ?? "Could not translate tweet")
                                            .backgroundColor(Colours.white)
                                            .titleTextColor(Colours.grayDark)
                                            .messageTextColor(Colours.grayDark)
                                            .messageTextAlignment(.left)
                                            .titleTextAlignment(.left)
                                            .action(.cancel("Dismiss"))
                                            .finally { action, index in
                                                if action.style == .cancel {
                                                    return
                                                }
                                            }
                                            .show(on: self)
                                    } catch let error as NSError {
                                        print(error)
                                    }
                                    
                                }
                            }
                            task.resume()
                        }
                        .action(.default("Share".localized), image: UIImage(named: "share")) { (action, ind) in
                            print(action, ind)
                            
                            
                            
                            
                            Alertift.actionSheet()
                                .backgroundColor(Colours.white)
                                .titleTextColor(Colours.grayDark)
                                .messageTextColor(Colours.grayDark)
                                .messageTextAlignment(.left)
                                .titleTextAlignment(.left)
                                .action(.default("Share Link".localized), image: UIImage(named: "share")) { (action, ind) in
                                    print(action, ind)
                                    
                                    if let myWebsite = sto[indexPath.row].status?.url {
                                        let objectsToShare = [myWebsite]
                                        let vc = VisualActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                                        vc.previewNumberOfLines = 5
                                        vc.previewFont = UIFont.systemFont(ofSize: 14)
                                        self.present(vc, animated: true, completion: nil)
                                    }
                                }
                                .action(.default("Share Text".localized), image: UIImage(named: "share")) { (action, ind) in
                                    print(action, ind)
                                    
                                    let bodyText = sto[indexPath.row].status?.content.stripHTML()
                                    let vc = VisualActivityViewController(text: bodyText ?? "")
                                    vc.previewNumberOfLines = 5
                                    vc.previewFont = UIFont.systemFont(ofSize: 14)
                                    self.present(vc, animated: true, completion: nil)
                                    
                                }
                                .action(.cancel("Dismiss"))
                                .finally { action, index in
                                    if action.style == .cancel {
                                        return
                                    }
                                }
                                .show(on: self)
                            
                            
                            
                            
                        }
                        .action(.cancel("Dismiss"))
                        .finally { action, index in
                            if action.style == .cancel {
                                return
                            }
                        }
                        .show(on: self)
                    
                    
                    
                    if let cell = theTable.cellForRow(at: indexPath) as? NotificationCell {
                        cell.hideSwipe(animated: true)
                    } else {
                        let cell = theTable.cellForRow(at: indexPath) as! NotificationCellImage
                        cell.hideSwipe(animated: true)
                    }
                }
                more.backgroundColor = Colours.white
                more.image = UIImage(named: "more2")
                more.transitionDelegate = ScaleTransition.default
                more.textColor = Colours.tabUnselected
                return [more]
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        if (UserDefaults.standard.object(forKey: "selectSwipe") == nil) || (UserDefaults.standard.object(forKey: "selectSwipe") as! Int == 0) {
            options.expansionStyle = .selection
        } else {
            options.expansionStyle = .none
        }
        options.transitionStyle = .drag
        options.buttonSpacing = 0
        options.buttonPadding = 0
        options.maximumButtonWidth = 60
        options.backgroundColor = Colours.white
        options.expansionDelegate = ScaleAndAlphaExpansion.default
        return options
    }
    
    
    
    func restoreScroll() {
        DispatchQueue.main.async {
            self.tableView2.reloadData()
            if (UserDefaults.standard.object(forKey: "savedRowNotif") == nil) {} else {
                if StoreStruct.notifications.count > 5 {
                    self.tableView2.setContentOffset(CGPoint(x: 0, y: UserDefaults.standard.object(forKey: "savedRowNotif") as! CGFloat), animated: false)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if (UserDefaults.standard.object(forKey: "savedRowMent") == nil) {} else {
                if StoreStruct.notificationsMentions.count > 5 {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: UserDefaults.standard.object(forKey: "savedRowMent") as! CGFloat), animated: false)
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView2.deselectRow(at: indexPath, animated: true)
        
        if self.currentIndex == 0 {
            UserDefaults.standard.set(self.tableView2.contentOffset.y, forKey: "savedRowNotif")
        } else {
            UserDefaults.standard.set(self.tableView.contentOffset.y, forKey: "savedRowMent")
        }
        
        if self.currentIndex == 0 {
            if indexPath.section == 1 {
                if StoreStruct.notifications[indexPath.row].type == .follow {
                    let controller = ThirdViewController()
                    if StoreStruct.notifications[indexPath.row].account.username == StoreStruct.currentUser.username {} else {
                        controller.fromOtherUser = true
                    }
                    controller.userIDtoUse = StoreStruct.notifications[indexPath.row].account.id
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = DetailViewController()
                    controller.mainStatus.append(StoreStruct.notifications[indexPath.row].status!)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        } else {
            
            let controller = DetailViewController()
            controller.mainStatus.append(StoreStruct.notificationsMentions[indexPath.row].status!)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    var lastThing = ""
    func fetchMoreNotifications() {
        let request = Notifications.all(range: .max(id: StoreStruct.notifications.last?.id ?? "", limit: 5000))
        StoreStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                
                
                
                
                if stat.isEmpty || self.lastThing == stat.first?.id ?? "" {} else {
                    self.lastThing = stat.first?.id ?? ""
                StoreStruct.notifications = StoreStruct.notifications + stat
                
                for x in stat {
                    if x.type == .mention {
                        StoreStruct.notificationsMentions.append(x)
                    }
                }
                
                DispatchQueue.main.async {
                    StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.sorted(by: { $0.createdAt > $1.createdAt })
                    StoreStruct.notifications = StoreStruct.notifications.sorted(by: { $0.createdAt > $1.createdAt })
                    
                    StoreStruct.notifications = StoreStruct.notifications.removeDuplicates()
                    StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
                    
                    self.tableView.reloadData()
                    self.tableView2.reloadData()
                    
                }
                    
                }
            }
        }
    }
    
    @objc func refreshCont() {
        let request = Notifications.all(range: .min(id: StoreStruct.notifications.first?.id ?? "", limit: 5000))
        DispatchQueue.global(qos: .userInitiated).async {
            StoreStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    var newestC = StoreStruct.notifications.count
                    var newestC2 = StoreStruct.notificationsMentions.count
                    
                    StoreStruct.notifications = stat + StoreStruct.notifications
                    var co = 0
                    for x in stat {
                        if x.type == .mention {
                            StoreStruct.notificationsMentions = [x] + StoreStruct.notificationsMentions
                            co = co + 1
                        }
                    }
                    
                    DispatchQueue.main.async {
                        StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.sorted(by: { $0.createdAt > $1.createdAt })
                        StoreStruct.notifications = StoreStruct.notifications.sorted(by: { $0.createdAt > $1.createdAt })
                        StoreStruct.notifications = StoreStruct.notifications.removeDuplicates()
                        StoreStruct.notificationsMentions = StoreStruct.notificationsMentions.removeDuplicates()
                        
                        newestC = StoreStruct.notifications.count - newestC
                        newestC2 = StoreStruct.notificationsMentions.count - newestC2
//                        self.tableView.reloadData()
//                        self.tableView2.reloadData()
//
//                        self.refreshControl.endRefreshing()
                        
                        
                        
                        if (UserDefaults.standard.object(forKey: "posset") == nil) || (UserDefaults.standard.object(forKey: "posset") as! Int == 0) {
                        
                        
                        if self.currentIndex == 1 {
                        self.newUpdatesB1.setTitle("\(newestC2)  ", for: .normal)
//                        self.newUpdatesB1.transform = CGAffineTransform(translationX: 120, y: 0)
                            self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width + 78)
                        springWithDelay(duration: 0.5, delay: 0, animations: {
                            self.newUpdatesB1.alpha = 1
//                            self.newUpdatesB1.transform = CGAffineTransform(translationX: 0, y: 0)
                            self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width - 42)
                        })
                        self.countcount1 = co
                        } else {
                            
                            self.newUpdatesB2.setTitle("\(newestC)  ", for: .normal)
//                            self.newUpdatesB2.transform = CGAffineTransform(translationX: 120, y: 0)
                            self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width + 78)
                            springWithDelay(duration: 0.5, delay: 0, animations: {
                                self.newUpdatesB2.alpha = 1
//                                self.newUpdatesB2.transform = CGAffineTransform(translationX: 0, y: 0)
                                self.newUpdatesB2.frame.origin.x = CGFloat(self.view.bounds.width - 42)
                            })
                            self.countcount2 = newestC
                            
                            
                        }
                        
                        UIView.setAnimationsEnabled(false)
                        self.tableView.reloadData()
                        self.tableView2.reloadData()
                        self.refreshControl.endRefreshing()
                        if self.currentIndex == 1 {
                            if StoreStruct.notificationsMentions.count > newestC2 {
                                self.tableView.scrollToRow(at: IndexPath(row: newestC2, section: 0), at: .top, animated: false)
                            }
                        } else {
                            if StoreStruct.notifications.count > newestC {
                                self.tableView2.scrollToRow(at: IndexPath(row: newestC, section: 1), at: .top, animated: false)
                            }
                        }
//                        self.restoreScroll()
                        UIView.setAnimationsEnabled(true)
                            
                        } else {
                            self.tableView.reloadData()
                            self.tableView2.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                        
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
            Colours.white = UIColor(red: 53/255.0, green: 53/255.0, blue: 64/255.0, alpha: 1.0)
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
            Colours.white = UIColor(red: 8/255.0, green: 28/255.0, blue: 88/255.0, alpha: 1.0)
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
        
        self.tableView2.backgroundColor = Colours.white
        self.tableView2.separatorColor = Colours.cellQuote
        self.tableView2.reloadData()
        self.tableView2.reloadInputViews()
        
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
    
    @objc func segTheme() {
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
        segmentedControl.removeFromSuperview()
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
        }
        
    }
    
}
