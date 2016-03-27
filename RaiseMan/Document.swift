//
//  Document.swift
//  RaiseMan
//
//  Created by Sebastian on 3/26/16.
//  Copyright © 2016 Sebastian. All rights reserved.
//

import Cocoa

private var KVOContext: Int = 0

class Document: NSDocument, NSWindowDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var arrayController: NSArrayController!
    
    var employees: [Employee] = [] {
        willSet {
            for employee in employees {
                stopObservingEmployee(employee)
            }
        }
        didSet {
            for employee in employees {
                startObservingEmployee(employee)
            }
        }
    }
    

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "Document"
    }

    override func dataOfType(typeName: String) throws -> NSData {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    func validateRaise(raiseNumberPointer: AutoreleasingUnsafeMutablePointer<NSNumber?>, error outError: NSErrorPointer) -> Bool {
        let raiseNumber = raiseNumberPointer.memory
        
        if raiseNumber == nil {
            let domain = "UserInputValidationErrorDomain"
            let code = 0
            let userInfo = [NSLocalizedDescriptionKey: "An employee's raise must be a number"]
            outError.memory = NSError(domain: domain, code: code, userInfo: userInfo)
            
            return false
        } else {
            return true
        }
    }
    
    //MARK: - Actions
    
    @IBAction func addEmployee(sender: NSButton) {
        
        let windowController = windowControllers[0]
        let window = windowController.window!
        
        let endedEditing = window.makeFirstResponder(window)
        
        if !endedEditing {
            return
        }
        
        let undo: NSUndoManager = undoManager!
        
        if undo.groupingLevel > 0 {
            undo.endUndoGrouping()
            undo.beginUndoGrouping()
        }
        
        
        
        let employee = arrayController.newObject() as! Employee
        arrayController.addObject(employee)
        arrayController.rearrangeObjects()
        
        let sortedEmployees = arrayController.arrangedObjects as! [Employee]
        
        let row = sortedEmployees.indexOf(employee)!
        
        tableView.editColumn(0, row: row, withEvent: nil, select: true)
    }
    
    //MARK: - Accessors
    
    func insertObject(employee: Employee, inEmployeesAtIndex index: Int) {
        
        let undo: NSUndoManager = undoManager!
        undo.prepareWithInvocationTarget(self).removeObjectFromEmployeesAtIndex(employees.count)
        
        if !undo.undoing {
            undo.setActionName("Add Person")
        }
        
        employees.append(employee)
    }

    func removeObjectFromEmployeesAtIndex(index: Int) {
        
        let employee: Employee = employees[index]
        
        let undo: NSUndoManager = undoManager!
        undo.prepareWithInvocationTarget(self).insertObject(employee, inEmployeesAtIndex: index)
        
        if !undo.undoing {
            undo.setActionName("Remove Person")
        }
        
        employees.removeAtIndex(index)
    }
    
    //MARK: - Key Value Observing
    
    func startObservingEmployee(employee: Employee) {
        employee.addObserver(self, forKeyPath: "name", options: .Old, context: &KVOContext)
        employee.addObserver(self, forKeyPath: "raise", options: .Old, context: &KVOContext)
        
    }
    
    func stopObservingEmployee(employee: Employee) {
        employee.removeObserver(self, forKeyPath: "name", context: &KVOContext)
        employee.removeObserver(self, forKeyPath: "raise", context: &KVOContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context != &KVOContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        var oldValue: AnyObject? = change![NSKeyValueChangeOldKey]
        if oldValue is NSNull {
            oldValue = nil
        }
        
        let undo: NSUndoManager  = undoManager!
        undo.prepareWithInvocationTarget(object!).setValue(oldValue, forKeyPath: keyPath!)
    }
    
    //MARK: - NSWindowDelegate
    
    func windowWillClose(notification: NSNotification) {
        employees = []
    }
}

