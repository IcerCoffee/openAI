//
//  SortListVC.swift
//  SmartUI
//
//  Created by why on 2025/2/6.
//

import UIKit

class SortListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // 数据源：示例中用字符串数组作为数据
    var data = [String]()
    
    // UICollectionView 实例
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 初始化数据，比如 20 个项目
        for i in 1...20 {
            data.append("Item \(i)")
        }
        
        // 创建并配置 UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        // 计算 cell 宽度，保证左右间距和中间间距正确，屏幕宽度减去 3 个间距后均分两个 cell
        let itemWidth = (view.bounds.width - spacing * 3) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 40)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        // 创建 UICollectionView
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor.white
        
        // 设置数据源与代理
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 注册 cell（使用系统自带的 UICollectionViewCell）
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        
        // 添加长按手势，用于拖动排序
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gesture:)))
        collectionView.addGestureRecognizer(longPress)
    }
    
    // MARK: - UICollectionViewDataSource
    
    // 返回项目数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    // 配置 cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 获取 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // 为了防止 cell 重用时内容混乱，先移除旧的子视图
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 添加一个 label 用于显示数据
        let label = UILabel(frame: cell.contentView.bounds)
        label.text = data[indexPath.item]
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(label)
        
        // 设置 cell 背景色
        cell.backgroundColor = UIColor.lightGray
        cell.layer.cornerRadius = 4
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    // 可选：允许 cell 拖动（默认返回 true 也可）
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 更新数据源：拖动结束后，会调用该方法
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 更新数据源数组
        let movedItem = data.remove(at: sourceIndexPath.item)
        data.insert(movedItem, at: destinationIndexPath.item)
    }
    
    // MARK: - 长按手势处理方法
    
    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        // 获取手势在 collectionView 中的位置
        let location = gesture.location(in: collectionView)
        
        switch gesture.state {
        case .began:
            // 找到手势所在的 cell 对应的 indexPath，并开始交互式移动
            if let selectedIndexPath = collectionView.indexPathForItem(at: location) {
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            }
        case .changed:
            // 更新移动的 cell 位置
            collectionView.updateInteractiveMovementTargetPosition(location)
        case .ended:
            // 结束交互式移动
            collectionView.endInteractiveMovement()
        default:
            // 取消交互式移动
            collectionView.cancelInteractiveMovement()
        }
    }
}
