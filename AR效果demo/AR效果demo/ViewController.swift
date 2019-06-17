//
//  ViewController.swift
//  AR效果demo
//
//  Created by 志强 on 2019/6/14.
//  Copyright © 2019 222. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
   
    let array : NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        array.add("示例一")
        let tabview = UITableView(frame: self.view.frame, style: UITableView.Style.plain)
        tabview.delegate = self
        tabview.dataSource = self
        self.view.addSubview(tabview)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return array.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        for index in array {
            cell.textLabel?.text = index as! String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("dianji")
        self.navigationController?.pushViewController(ARTestViewController(), animated: true)

    }
    


}

