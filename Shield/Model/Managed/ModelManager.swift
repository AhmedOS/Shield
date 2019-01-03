//
//  ModelManager.swift
//  Shield
//
//  Created by Ahmed Osama on 12/4/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import CoreData

class ModelManager {
    
    static fileprivate let modelName = "Shield"
    static fileprivate let modelManager = ModelManager(modelName: modelName)
    
    static func shared() -> ModelManager {
        return modelManager
    }
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    let backgroundContext: NSManagedObjectContext!
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            //self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
    
    func getAllObjects<T: NSManagedObject>(for entity: T.Type) -> [T] {
        let request: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        var objects: [T]!
        do {
            objects = try viewContext.fetch(request)
        }
        catch {
            objects = [T]()
        }
        return objects
    }
    
    func getFileScanReport(for sha256: String) -> FileScanReport? {
        let request: NSFetchRequest<FileScanReport> = FileScanReport.fetchRequest()
        request.predicate = NSPredicate(format: "sha256 == %@", sha256)
        var objects: [FileScanReport]!
        do {
            objects = try viewContext.fetch(request)
        }
        catch {
            objects = [FileScanReport]()
        }
        return objects.first
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // fatalError() causes the application to generate a crash log and terminate.
                // I should not use this function in a shipping application.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteObject<T: NSManagedObject>(object: T) {
        viewContext.delete(object)
        saveContext()
    }
    
    fileprivate func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
}

// MARK: - Autosaving

extension ModelManager {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
