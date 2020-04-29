//
//  Requirement.swift
//  testBadger
//
//  Created by Milos Otasevic on 29/04/2020.
//  Copyright © 2020 Milos Otasevic. All rights reserved.
//

import UIKit

protocol ConnectionRequirement{
    var connection: Connection {get}
}

extension ConnectionRequirement{
    unowned var connection: Connection{
        (UIApplication.shared.delegate as! AppDelegate).connection
    }
}
