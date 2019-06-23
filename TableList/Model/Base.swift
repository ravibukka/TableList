//
//  Base.swift
//  ListTable
//
//  Created by Administrator on 20/06/19.
//  Copyright © 2019 Ravi. All rights reserved.
//

import Foundation


struct Base : Codable {
    let title : String?
    let rows : [Rows]?
    
    enum CodingKeys: String, CodingKey {
        
        case title = "title"
        case rows = "rows"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        rows = try values.decodeIfPresent([Rows].self, forKey: .rows)
    }
    
}

