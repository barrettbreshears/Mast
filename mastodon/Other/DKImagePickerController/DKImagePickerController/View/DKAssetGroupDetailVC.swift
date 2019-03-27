//
//  DKAssetGroupDetailVC.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/10.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

private extension UICollectionView {
    
    func indexPathsForElements(in rect: CGRect, _ hidesCamera: Bool) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        
        if hidesCamera {
            return allLayoutAttributes.map { $0.indexPath }
        } else {
            return allLayoutAttributes.flatMap { $0.indexPath.item == 0 ? nil : IndexPath(item: $0.indexPath.item - 1, section: $0.indexPath.section) }
        }
    }
    
}

// Show all images in the asset group
open class DKAssetGroupDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DKGroupDataManagerObserver {
    	
    public lazy var selectGroupButton: UIButton = {
        let button = UIButton()
		
        let globalTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor
		button.setTitleColor((UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) ? UIColor(red: 40/250, green: 40/250, blue: 40/250, alpha: 1.0) : (UserDefaults.standard.object(forKey: "theme") != nil && UserDefaults.standard.object(forKey: "theme") as! Int == 1) ? UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0) : UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0), for: .normal)
		
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont.fontAwesome(ofSize: 16)]
		let globalTitleFont = UIFont.fontAwesome(ofSize: 18)
		button.titleLabel!.font = globalTitleFont ?? UIFont.boldSystemFont(ofSize: 18.0)
		
		button.addTarget(self, action: #selector(DKAssetGroupDetailVC.showGroupSelector), for: .touchUpInside)
        return button
    }()
		
    internal var collectionView: UICollectionView!
    internal weak var imagePickerController: DKImagePickerController!
    public var selectedGroupId: String?
	private var groupListVC: DKAssetGroupListVC!
    private var hidesCamera: Bool = false
	private var footerView: UIView?
    private var currentViewSize: CGSize!
    private var registeredCellIdentifiers = Set<String>()
    private var thumbnailSize = CGSize.zero
    private var curSwipingPath:IndexPath? = nil
	
	override open func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		if let currentViewSize = self.currentViewSize, currentViewSize.equalTo(self.view.bounds.size) {
			return
		} else {
			currentViewSize = self.view.bounds.size
		}

		self.collectionView?.collectionViewLayout.invalidateLayout()
	}
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                
                let topIcon = UIButton(frame:(CGRect(x: self.view.bounds.width/2 - 100, y: 50, width: 200, height: 30)))
                topIcon.adjustsImageWhenHighlighted = false
                topIcon.addTarget(self, action: #selector(DKAssetGroupDetailVC.showGroupSelector), for: .touchUpInside)
                self.navigationController?.view.addSubview(topIcon)
                
            default:
                
                let topIcon = UIButton(frame:(CGRect(x: self.view.bounds.width/2 - 100, y: 26, width: 200, height: 30)))
                topIcon.adjustsImageWhenHighlighted = false
                topIcon.addTarget(self, action: #selector(DKAssetGroupDetailVC.showGroupSelector), for: .touchUpInside)
                self.navigationController?.view.addSubview(topIcon)
                
            }
        }
        
        
        
        let theCol = Colours.tabSelected
        
        var statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = Colours.white
        self.navigationController?.view.addSubview(statusBarView)
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: theCol], for: .normal)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0), for:UIBarMetrics.default)
        
        self.navigationController?.navigationBar.backgroundColor = Colours.white
        self.navigationController?.navigationBar.barTintColor = Colours.tabSelected
		
		let layout = self.imagePickerController.UIDelegate.layoutForImagePickerController(self.imagePickerController).init()
		self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = Colours.white
        self.collectionView.allowsMultipleSelection = true
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.view.addSubview(self.collectionView)
		
		self.footerView = self.imagePickerController.UIDelegate.imagePickerControllerFooterView(self.imagePickerController)
		if let footerView = self.footerView {
			self.view.addSubview(footerView)
		}
		
        self.hidesCamera = true
		//self.hidesCamera = self.imagePickerController.sourceType == .photo
		self.checkPhotoPermission()
        
        if self.imagePickerController.allowSwipeToSelect {
            let swipeOutGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.swiping(gesture:)))
            self.collectionView.addGestureRecognizer(swipeOutGesture)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateCachedAssets()
    }
	
	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let footerView = self.footerView {
			footerView.frame = CGRect(x: 0, y: self.view.bounds.height - footerView.bounds.height, width: self.view.bounds.width, height: footerView.bounds.height)
			self.collectionView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - footerView.bounds.height)
			
		} else {
			self.collectionView.frame = self.view.bounds
		}
	}
	
	internal func checkPhotoPermission() {
		func photoDenied() {
			self.view.addSubview(DKPermissionView.permissionView(.photo))
			self.view.backgroundColor = UIColor.black
			self.collectionView?.isHidden = true
		}
		
		func setup() {
            self.resetCachedAssets()
			getImageManager().groupDataManager.addObserver(self)
			self.groupListVC = DKAssetGroupListVC(selectedGroupDidChangeBlock: { [unowned self] groupId in
				self.selectAssetGroup(groupId)
			}, defaultAssetGroup: self.imagePickerController.defaultAssetGroup)
			self.groupListVC.loadGroups()
		}
		
		DKImageManager.checkPhotoPermission { granted in
			granted ? setup() : photoDenied()
		}
	}
	
    func selectAssetGroup(_ groupId: String?) {
        if self.selectedGroupId == groupId {
            self.updateTitleView()
            return
        }
        
        self.selectedGroupId = groupId
		self.updateTitleView()
		self.collectionView!.reloadData()
    }
    
    //use the swiping gesture to select the currently swiping cell.
    @objc private func swiping(gesture: UIPanGestureRecognizer) {
        if gesture.state != .ended {
            let loc = gesture.location(ofTouch: 0, in: self.collectionView)
            if let path = self.collectionView.indexPathForItem(at: loc), let cell = self.collectionView.cellForItem(at: path), let cc = cell as? DKAssetGroupDetailBaseCell {
                if let ast = cc.asset {
                    if curSwipingPath != path {
                        curSwipingPath = path
                        if !self.imagePickerController.selectedAssets.contains(ast) {
                            self.imagePickerController.selectImage(atIndexPath: path)
                        } else {
                            self.imagePickerController.deselectAsset(ast)
                        }
                    }
                }
            }
        }
    }
	
	open func updateTitleView() {
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
		self.title = group.groupName
		
		let groupsCount = getImageManager().groupDataManager.groupIds?.count ?? 0
		self.selectGroupButton.setTitle(group.groupName + (groupsCount > 1 ? "  \(String.fontAwesomeIcon(code: "fa-angle-down") ?? "")" : "" ), for: .normal)
		self.selectGroupButton.sizeToFit()
		self.selectGroupButton.isEnabled = groupsCount > 1
		
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : (UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) ? UIColor(red: 40/250, green: 40/250, blue: 40/250, alpha: 1.0) : (UserDefaults.standard.object(forKey: "theme") != nil && UserDefaults.standard.object(forKey: "theme") as! Int == 1) ? UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0) : UIColor(red: 250/250, green: 250/250, blue: 250/250, alpha: 1.0), NSAttributedString.Key.font : UIFont.fontAwesome(ofSize: 16)]
        self.navigationController?.navigationBar.topItem?.title = group.groupName + (groupsCount > 1 ? "  \(String.fontAwesomeIcon(code: "fa-angle-down") ?? "")" : "" )
		//self.navigationItem.titleView = self.selectGroupButton
	}
    
    @objc func showGroupSelector() {
        DKPopoverViewController.popoverViewController(self.groupListVC, fromView: self.selectGroupButton)
    }
    
    func fetchAsset(for index: Int) -> DKAsset? {
        if !self.hidesCamera && index == 0 {
            return nil
        }
        let assetIndex = (index - (self.hidesCamera ? 0 : 1))
        let group = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
        return getImageManager().groupDataManager.fetchAsset(group, index: assetIndex)
    }
    
    //select an asset at a specific index
    public func selectAsset(atIndex indexPath: IndexPath) {
        let selectedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetGroupDetailBaseCell)
        if let ss = selectedAsset {
            selectAsset(cellToSelect: ss)
        }
    }
    
    public func selectAsset(cellToSelect cell:DKAssetGroupDetailBaseCell) {
        guard let ast = cell.asset else {
            return
        }
        
        self.imagePickerController.selectImage(ast)
        cell.index = self.imagePickerController.selectedAssets.count - 1
    }
    
    func isCameraCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == 0 && !self.hidesCamera
    }
	
    // MARK: - Cells
    
    func registerCellIfNeeded(cellClass: DKAssetGroupDetailBaseCell.Type) {
        let cellReuseIdentifier = cellClass.cellReuseIdentifier()
        
        if !self.registeredCellIdentifiers.contains(cellReuseIdentifier) {
            self.collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
            self.registeredCellIdentifiers.insert(cellReuseIdentifier)
        }
    }
    
    func dequeueReusableCell(for indexPath: IndexPath) -> DKAssetGroupDetailBaseCell {
        let asset = self.fetchAsset(for: indexPath.row)!
        
        let cellClass: DKAssetGroupDetailBaseCell.Type!
        if asset.isVideo {
            cellClass = self.imagePickerController.UIDelegate.imagePickerControllerCollectionVideoCell()
        } else {
            cellClass = self.imagePickerController.UIDelegate.imagePickerControllerCollectionImageCell()
        }
        self.registerCellIfNeeded(cellClass: cellClass)
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.cellReuseIdentifier(), for: indexPath) as! DKAssetGroupDetailBaseCell
        self.setup(assetCell: cell, for: indexPath, with: asset)
        
        return cell
    }
    
    func dequeueReusableCameraCell(for indexPath: IndexPath) -> DKAssetGroupDetailBaseCell {
        let cellClass = self.imagePickerController.UIDelegate.imagePickerControllerCollectionCameraCell()
        self.registerCellIfNeeded(cellClass: cellClass)
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.cellReuseIdentifier(), for: indexPath)
        return cell as! DKAssetGroupDetailBaseCell
    }
	
    func setup(assetCell cell: DKAssetGroupDetailBaseCell, for indexPath: IndexPath, with asset: DKAsset) {
        cell.asset = asset
		let tag = indexPath.row + 1
		cell.tag = tag
		
        if self.thumbnailSize.equalTo(CGSize.zero) {
            self.thumbnailSize = self.collectionView!.collectionViewLayout.layoutAttributesForItem(at: indexPath)!.size.toPixel()
        }
        
        asset.fetchImageWithSize(self.thumbnailSize, options: nil, contentMode: .aspectFill) { (image, info) in
            if cell.tag == tag {
                cell.thumbnailImage = image
            }
        }

		if let index = self.imagePickerController.selectedAssets.firstIndex(of: asset) {
			cell.isSelected = true
			cell.index = index
			self.collectionView!.selectItem(at: indexPath, animated: false, scrollPosition: [])
		} else {
			cell.isSelected = false
			self.collectionView!.deselectItem(at: indexPath, animated: false)
		}
	}

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let selectedGroupId = self.selectedGroupId else { return 0 }
		
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(selectedGroupId)
        
        var totalCount = 0
        if self.imagePickerController.fetchLimit > 0 {
            totalCount = min(group.totalCount ?? 0, self.imagePickerController.fetchLimit)
        } else {
            totalCount = group.totalCount ?? 0
        }
        return totalCount + (self.hidesCamera ? 0 : 1)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DKAssetGroupDetailBaseCell!
        if self.isCameraCell(indexPath: indexPath) {
            cell = self.dequeueReusableCameraCell(for: indexPath)
        } else {
            cell = self.dequeueReusableCell(for: indexPath)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if let firstSelectedAsset = self.imagePickerController.selectedAssets.first, firstSelectedAsset.isVideo {
            self.imagePickerController.maxSelectableCount = 1
        }
        if let firstSelectedAsset = self.imagePickerController.selectedAssets.first, !firstSelectedAsset.isVideo {
            self.imagePickerController.maxSelectableCount = 4
        }
        
        if let firstSelectedAsset = self.imagePickerController.selectedAssets.first,
            let selectedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetGroupDetailBaseCell)?.asset, self.imagePickerController.allowMultipleTypes == false && firstSelectedAsset.isVideo != selectedAsset.isVideo {

            /*let alert = UIAlertController(
                    title: DKImageLocalizedStringWithKey("selectPhotosOrVideos")
                    , message: DKImageLocalizedStringWithKey("selectPhotosOrVideosError")
                    , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: DKImageLocalizedStringWithKey("ok"), style: .cancel) { _ in })
            self.imagePickerController.present(alert, animated: true){}*/

            return false
        }
		
		let shouldSelect = self.imagePickerController.selectedAssets.count < self.imagePickerController.maxSelectableCount
		if !shouldSelect {
			self.imagePickerController.UIDelegate.imagePickerControllerDidReachMaxLimit(self.imagePickerController)
		}
		
		return shouldSelect
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (UserDefaults.standard.object(forKey: "otherhaptics") == nil) || (UserDefaults.standard.object(forKey: "otherhaptics") as! Int == 0) {
            if #available(iOS 10.0, *) {
                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                let selection = UISelectionFeedbackGenerator()
                selection.selectionChanged()
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
        if self.isCameraCell(indexPath: indexPath) {
            collectionView .deselectItem(at: indexPath, animated: false)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.presentCamera()
            }
        } else {
            selectAsset(atIndex: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if (UserDefaults.standard.object(forKey: "otherhaptics") == nil) || (UserDefaults.standard.object(forKey: "otherhaptics") as! Int == 0) {
            if #available(iOS 10.0, *) {
                if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
                let selection = UISelectionFeedbackGenerator()
                selection.selectionChanged()
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
		if let removedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetGroupDetailBaseCell)?.asset {
			let removedIndex = self.imagePickerController.selectedAssets.firstIndex(of: removedAsset)!
			
			/// Minimize the number of times.
			let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems!
			let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
			
			let intersect = Set(indexPathsForVisibleItems).intersection(Set(indexPathsForSelectedItems))
			
			for selectedIndexPath in intersect {
                if let selectedCell = (collectionView.cellForItem(at: selectedIndexPath) as? DKAssetGroupDetailBaseCell), let selectedCellAsset = selectedCell.asset, let selectedIndex = self.imagePickerController.selectedAssets.firstIndex(of: selectedCellAsset) {
					if selectedIndex > removedIndex {
						selectedCell.index = selectedCell.index - 1
					}
				}
			}
			
			self.imagePickerController.deselectImage(removedAsset)
		}
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateCachedAssets()
    }
    
    // MARK: - Asset Caching
    
    var previousPreheatRect = CGRect.zero
    
    fileprivate func resetCachedAssets() {
        getImageManager().stopCachingForAllAssets()
        self.previousPreheatRect = .zero
    }

    func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil && self.selectedGroupId != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let preheatRect = view!.bounds.insetBy(dx: 0, dy: -0.5 * view!.bounds.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        let group = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = self.differencesBetweenRects(self.previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in self.collectionView!.indexPathsForElements(in: rect, self.hidesCamera) }
            .map { indexPath in getImageManager().groupDataManager.fetchOriginalAsset(group, index: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in self.collectionView!.indexPathsForElements(in: rect, self.hidesCamera) }
            .map { indexPath in getImageManager().groupDataManager.fetchOriginalAsset(group, index: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        getImageManager().startCachingAssets(for: addedAssets,
                                             targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
        getImageManager().stopCachingAssets(for: removedAssets,
                                            targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
	
	// MARK: - DKGroupDataManagerObserver methods
	
	func groupDidUpdate(_ groupId: String) {
		if self.selectedGroupId == groupId {
			self.updateTitleView()
		}
	}
	
	func group(_ groupId: String, didRemoveAssets assets: [DKAsset]) {
		for (_, selectedAsset) in self.imagePickerController.selectedAssets.enumerated() {
			for removedAsset in assets {
				if selectedAsset.isEqual(removedAsset) {
					self.imagePickerController.deselectImage(selectedAsset)
				}
			}
		}
	}
    
    func groupDidUpdateComplete(_ groupId: String) {
        if self.selectedGroupId == groupId {
            self.resetCachedAssets()
            self.collectionView?.reloadData()
        }
    }

}
