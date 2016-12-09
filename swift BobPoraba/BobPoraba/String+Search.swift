//
//  String+Search.swift
//  BobPoraba
//
//  Created by Amadej Pevec on 7. 11. 16.
//  Copyright © 2016 Amadej Pevec. All rights reserved.
//

import Foundation

extension String {
    func index(of string: String) -> String.Index? {
        return range(of: string)?.lowerBound
    }
}
