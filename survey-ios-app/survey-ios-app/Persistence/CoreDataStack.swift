//
//  CoreDataStack.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import Foundation
import CoreData
import Combine

enum RecordType {
    static let question = "QuestionMO"
}

protocol PersistentFeachable {
    func fetch(
        entityName: String,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        context: NSManagedObjectContext?
    ) -> [NSFetchRequestResult]?

    func getRecordsCount(
        name: String, predicate: NSPredicate?,
        context: NSManagedObjectContext?
    ) -> Int
}

protocol PersistentSavable {
    func saveViewContext()
    func save(context: NSManagedObjectContext, reset: Bool, wait: Bool)
}

protocol PersistentStore: PersistentFeachable, PersistentSavable {
    var bgMOC: NSManagedObjectContext { get }
}

class CoreDataStack: PersistentStore {
    // swiftlint:disable implicitly_unwrapped_optional
    private var persistentContainer: NSPersistentContainer!
    // swiftlint:enable implicitly_unwrapped_optional
    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
        self.createPersistentContainer {}
    }

    private func createPersistentContainer(completion: @escaping () -> Void) {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { description, error  in
            self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            guard error == nil else {
                fatalError("""
                           Store description \(description)
                           was unable to load store \(error?.localizedDescription ?? "")
                           """)
            }
            completion()
        }
    }

    private(set) lazy var bgMOC: NSManagedObjectContext = {
        newBackgroundContext()
    }()

    private(set) lazy var mainMOC: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.name = "viewContext"
        return context
    }()

    private func newBackgroundContext() -> NSManagedObjectContext {
        let bgContext = persistentContainer.newBackgroundContext()
        bgContext.name = "bgContext \(UUID().uuidString)"
        bgContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        bgContext.automaticallyMergesChangesFromParent = true
        return bgContext
    }
}

extension CoreDataStack {
    func saveViewContext() {
        DispatchQueue.main.async {
            self.save(context: self.mainMOC, reset: false, wait: false)
        }
    }

    func save(context: NSManagedObjectContext, reset: Bool, wait: Bool) {
        let block = {
            guard context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                AppLogger.log(message: error.localizedDescription, category: .storage, type: .error)
            }
            if reset {
                context.reset()
            }
        }
        if wait {
            context.performAndWait(block)
        } else {
            context.perform(block)
        }
    }
}

extension CoreDataStack {
    func fetch(
        entityName: String,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        context: NSManagedObjectContext?
    ) -> [NSFetchRequestResult]? {
        let managedContext = context ?? persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if !sortDescriptors.isNilOrEmpty {
            fetchRequest.sortDescriptors = sortDescriptors
        }

        fetchRequest.returnsObjectsAsFaults = false

        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        var result: [NSFetchRequestResult] = []
        managedContext.performAndWait {
            do {
                result = try managedContext.fetch(fetchRequest)
            } catch {
                AppLogger.log(message: error.localizedDescription, category: .storage, type: .error)
            }
        }

        return result
    }

    func getRecordsCount(name: String, predicate: NSPredicate?, context: NSManagedObjectContext?) -> Int {
        let context = context ?? mainMOC
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)

        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        return (try? context.count(for: fetchRequest)) ?? 0
    }
}
