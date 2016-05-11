//
//  ViewController.swift
//  ExpandableTableView
//
//  Created by 三斗 on 5/11/16.
//  Copyright © 2016 com.streamind. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var expandableTableView: UITableView!
  var cellDescriptors: NSMutableArray!
  var visibleRowsPerSection = [[Int]]()
  //MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCellDescriptors()
    configTableView()
    print(cellDescriptors)
    // Do any additional setup after loading the view, typically from a nib.
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func configTableView(){
    
    
  }
  
  func getIndicesOfVisibleRows(){
    visibleRowsPerSection.removeAll()
    for currentSectionCells in cellDescriptors{
      var visibleRows = [Int]()
      for row in 0..<(currentSectionCells as! [[String:AnyObject]]).count{
        if currentSectionCells[row]["isVisible"] as! Int == 1{
          visibleRows.append(row)
        }
      }
      visibleRowsPerSection.append(visibleRows)
    }
    print(visibleRowsPerSection)
  }
  
  func loadCellDescriptors(){
    if let path = NSBundle.mainBundle().pathForResource("cellDescriptors", ofType: "plist"){
      cellDescriptors = NSMutableArray(contentsOfFile: path)
      getIndicesOfVisibleRows()
      expandableTableView.reloadData()
    }
  }
  
  func getCellDescriptorForIndexPath(indexPath:NSIndexPath) -> [String:AnyObject]{
    print(indexPath)
    let indexOfVisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row]
    let cellDescriptor = cellDescriptors[indexPath.section][indexOfVisibleRow] as! [String:AnyObject]
    
    return cellDescriptor
  }
}
extension ViewController:UITableViewDataSource,UITableViewDelegate{
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if cellDescriptors != nil{
      return cellDescriptors.count
    }else{
      return 0
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return visibleRowsPerSection[section].count
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section{
    case 0: return "Person"
    case 1: return "Preferences"
    default: return "Work Experience"
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]
    if cellDescriptors[indexPath.section][indexOfTappedRow]["isExpandable"]  as! Bool == true{
        var showOtherRows = false
      if cellDescriptors[indexPath.section][indexOfTappedRow]["isExpanded"] as! Bool == false{
        showOtherRows = true
        }
      cellDescriptors[indexPath.section][indexOfTappedRow].setValue(showOtherRows, forKey: "isExpanded")
      for i in indexOfTappedRow + 1 ... indexOfTappedRow + (cellDescriptors[indexPath.section][indexOfTappedRow]["additionalRows"] as! Int){
          cellDescriptors[indexPath.section][i].setValue(showOtherRows, forKey: "isVisible")

      }
    }
    getIndicesOfVisibleRows()
    expandableTableView.reloadSections(NSIndexSet(index:indexPath.section), withRowAnimation: .None)
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = expandableTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    let CurrentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
    cell.accessoryType = CurrentCellDescriptor["isExpandable"] as! Bool ? .DisclosureIndicator: .None
    cell.textLabel?.text = CurrentCellDescriptor["primaryTitle"] as? String
    cell.detailTextLabel?.text = CurrentCellDescriptor["secondaryTitle"] as? String
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
  }
}