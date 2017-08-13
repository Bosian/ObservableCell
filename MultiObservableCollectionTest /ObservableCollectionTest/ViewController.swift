//
//  ViewController.swift
//  ObservableCollectionTest
//
//  Created by 劉柏賢 on 2017/7/19.
//  Copyright © 2017年 Bobson. All rights reserved.
//

import UIKit

struct CellViewModel {
    let title: String
}

struct ViewModel: MutatingClosure {
    
    var sectionMaxIndex: Int = 0
    var section: Int = 0
    
    let cellViewModels = ObservableCell<String, CellViewModel>(insertSectionsAnimation: .none,
                                                               deleteSectionsAnimation: .none,
                                                               reloadSectionsAnimation: .automatic)
    
    weak var binder: Binder?
    
    init(binder: Binder)
    {
        self.binder = binder
        
        refresh()
    }
    
    func refresh() {
        
        let copySelf = self
        
        DispatchQueue.main.async {
            
            copySelf.mutating {
                let range = 0...5
                
                for section in range
                {
                    $0.cellViewModels.append( 
                        (
                            section: String(section),
                            row: ObservableCollection<CellViewModel>(section: section, insertRowsAnimation: .automatic, deleteRowsAnimation: .automatic, reloadRowsAnimation: .automatic)
                        )
                    )
                }
                
                $0.sectionMaxIndex = range.upperBound
            }
            
        }
    }
    
    mutating func addHandler() {
        
        let count = String(cellViewModels[section].row.count)
        
        cellViewModels[section].row.append(CellViewModel(title: count))
    }
    
    mutating func deleteHandler() {
        cellViewModels[section].row.remove(at: 0)
    }
    
    mutating func reloadHandler() {
        
        cellViewModels[section].row[0] = CellViewModel(title: "reload")
    }
    
    mutating func addSectionHandler() {
        cellViewModels.insert((section: String(section), row: ObservableCollection<CellViewModel>(section: section)), at: section)
    }
    
    mutating func deleteSectionHandler() {
        cellViewModels.remove(at: section)
    }
    
    mutating func reloadSectionHandler() {
        cellViewModels[section] = (
            section: String(section),
            row: ObservableCollection<CellViewModel>(section: section, insertRowsAnimation: .automatic, deleteRowsAnimation: .automatic, reloadRowsAnimation: .automatic)
        )
    }
    
    mutating func removeAllSectionHandler() {
         cellViewModels.removeAll()
    }
}

class ViewController: UIViewController, Viewer {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var sectionLabel: UILabel!
    
    typealias ViewModelType = ViewModel
    var viewModel: ViewModelType! {
        didSet {
            stepper.maximumValue = Double(viewModel.sectionMaxIndex)
            
            stepper.value = Double(viewModel.section)
            sectionLabel.text = String(viewModel.section)
        }
    }
    
    override func viewDidLoad() {
        
        viewModel = ViewModelType(binder: self)
        
        viewModel.cellViewModels.collectionChanged += CollectionChangeParameter(method: { [weak self] (args) in
            
            guard let weakSelf = self else {
                return
            }
            
            guard !args.insertRows.isEmpty || !args.deleteRows.isEmpty || !args.reloadRows.isEmpty ||
                  args.insertSections != nil || args.deleteSections != nil || args.reloadSections != nil else {
                    
                weakSelf.tableView.reloadData()
                return
            }

            weakSelf.tableView.beginUpdates()
            weakSelf.tableView.insertRows(at: args.insertRows, with: args.insertRowsAnimation)
            weakSelf.tableView.deleteRows(at: args.deleteRows, with: args.deleteRowsAnimation)
            weakSelf.tableView.reloadRows(at: args.reloadRows, with: args.reloadRowsAnimation)
            
            if let insertSections = args.insertSections
            {
                weakSelf.tableView.insertSections(insertSections, with: args.insertSectionsAnimation)
            }
            
            if let deleteSections = args.deleteSections
            {
                weakSelf.tableView.deleteSections(deleteSections, with: args.deleteSectionsAnimation)
            }
            
            if let reloadSections = args.reloadSections
            {
                weakSelf.tableView.reloadSections(reloadSections, with: args.reloadSectionsAnimation)
            }
            
            weakSelf.tableView.endUpdates()
        })
    }
    
    @IBAction func addHandler(_ sender: UIButton) {
        viewModel.addHandler()
    }
    
    @IBAction func deleteHandler(_ sender: UIButton) {
        viewModel.deleteHandler()
    }
    
    @IBAction func reloadHandler(_ sender: UIButton) {
        viewModel.reloadHandler()
    }
    
    @IBAction func stepperHandler(_ sender: UIStepper) {
        viewModel.section = Int(sender.value)
    }

    @IBAction func addSectionHandler(_ sender: UIButton) {
        viewModel.addSectionHandler()
    }
    
    @IBAction func deleteSectionHandler(_ sender: UIButton) {
        viewModel.deleteSectionHandler()
    }
    
    @IBAction func reloadSectionHandler(_ sender: UIButton) {
        viewModel.reloadSectionHandler()
    }
    
    @IBAction func removeAll(_ sender: UIButton) {
        viewModel.removeAllSectionHandler()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels[section].row.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let id = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        
        cell.textLabel?.text = viewModel.cellViewModels[indexPath.section].row[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.cellViewModels[section].section
    }
}
