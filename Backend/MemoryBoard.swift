//
//  MemoryBoard.swift
//  
//
//  Created by Minh Pham on 13/04/2023.
//

import Foundation

enum MemoryError : Error {
    case InvalidAddress
    case InvalidAddressItem
}

class Item : Equatable, Identifiable {
    var address : Int
    var label: String
    var value: Int
    var id: Int {
        return address
    }
    init(address: Int, label: String, value: Int) {
        self.address = address
        self.label = label
        self.value = value
    }
    
    static func == (left: Item, right: Item) -> Bool {
        return (left.address == right.address) && (left.label == right.label) && (left.value == right.value)
    }
}

class MemoryBoard : ObservableObject {
//    var item_dictionary : [String: Item]
    var items : [Int : Item]
    
    init(){
        self.items = [:]
        for i in 0...10 {
            items[256 + i * 8] = Item(address: 256 + i * 8, label: "", value: 0)
        }
    }
    
    init(items: [Item]){
        self.items = [:]
        for i in 0...10 {
            self.items[256 + i * 8] = Item(address: 256 + i * 8, label: "", value: 0)
        }
        for item in items {
            self.items[item.address] = item
        }
    }
    
    static func validateBoard(userBoard: MemoryBoard, machineBoard: MemoryBoard) -> Bool {
        return userBoard.items == machineBoard.items
    }
    
    func getItem(id: Int) ->  Item {
        return items[id]!
    }
    
    func getSortedItemsByAddress() -> [Item] {
        let array = Array(items.values).sorted{ $0.address < $1.address
        }
        return array
    }
    
    static func parseItemString(address: Int, label: String, string: String) -> Item {
        let itemList = string.components(separatedBy: " ").filter{!$0.isEmpty}
        return Item(address: address, label: label, value: Int(itemList[1]) ?? -1)
        
    }
    
    func getLabelAddress(label: String) throws -> Int {
        for (address, item) in self.items {
            if item.label == label {
                return address
            }
        }
        throw MemoryError.InvalidAddress
    }
    
    static func parseMemoryInputString(string: String) -> [Item] {
        let partition = string.components(separatedBy: "\n").filter {!$0.isEmpty}
        let startPosition = Int(partition[0].components(separatedBy: " ")[1]) ?? 256
        var index = 1
        var itemList : [Item] = []
        while index < partition.count {
            let item : Item
            if partition[index].contains(":") {
                let label = String(partition[index].dropLast(1))
                item = parseItemString(address: startPosition + itemList.count * 8, label: label, string: partition[index + 1])
                index += 2
            } else {
                item = parseItemString(address: startPosition + itemList.count * 8, label: "", string: partition[index])
                index += 1
            }
            itemList.append(item)
        }
        return itemList
    }
    
    func memoryButtonOnlick() {
        print(getSortedItemsByAddress())
    }
}
