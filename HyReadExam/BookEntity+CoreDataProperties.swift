//
//  BookEntity+CoreDataProperties.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//
//

import Foundation
import CoreData


extension BookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged public var uuid: Int64
    @NSManaged public var title: String?
    @NSManaged public var coverUrl: String?
    @NSManaged public var publishDate: String?
    @NSManaged public var publisher: String?
    @NSManaged public var author: String?

}

extension BookEntity : Identifiable {

}
