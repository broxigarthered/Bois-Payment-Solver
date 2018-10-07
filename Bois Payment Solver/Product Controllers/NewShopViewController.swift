//
//  NewShopViewController.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 12.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol UpdateShopListDelegate: AnyObject
{
   func addNewShopToTableRow(shop: Shop?)
}


class NewShopViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var newShopName: UITextField!
    weak var delegate: UpdateShopListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveNewShoplist(_ sender: Any) {
        guard let shopName = self.newShopName.text else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        if(shopName == ""){
            dismiss(animated: true, completion: nil )
        }
        else{
            self.saveShop(shopName: shopName)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func saveShop(shopName: String){
        let shop = CoreDataManager.sharedManager.insertShop(shopName: shopName)
        self.delegate?.addNewShopToTableRow(shop: shop)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
