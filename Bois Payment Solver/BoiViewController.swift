//
//  BoiViewController.swift
//  Bois Payment Solver
//
//  Created by Adelina Dutskinova on 12.09.18.
//  Copyright © 2018 Adelina Dutskinova. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class BoiViewController: UIViewController, NSFetchedResultsControllerDelegate {

    var products: [NSManagedObject] = []
    var boiName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var orders =  getOrders()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getOrders() -> [String: Decimal] {
        
        var result: [String: Decimal] = [:]
        
        for item in products {
            let bois = item.value(forKey: "bois") as! [String: Decimal]
            for boi in bois {
                if(boi.key == self.boiName){
                    result[boi.key] = boi.value
                }
            }
        }
        
        return result
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
