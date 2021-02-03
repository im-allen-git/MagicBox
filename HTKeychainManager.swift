import UIKit
import Security

public class HTKeychainManager: NSObject {
    
    public static let serverName = "magixBox"
    
    public static let instance :HTKeychainManager = {
        let instance = HTKeychainManager();
        return instance;
    }()
    
    public class func save(server:String,account:String,password:String)->Bool{
        var dictionry:Dictionary = Dictionary<String, Any>()
        
        dictionry.updateValue(server, forKey: kSecAttrServer as String)
        dictionry.updateValue(account, forKey: kSecAttrAccount as String)
        
        dictionry.updateValue(kSecClassInternetPassword, forKey: kSecClass as String)
        dictionry.updateValue(password.data(using: String.Encoding.utf8)!, forKey: kSecValueData as String)

        return instance.save(dictionry: dictionry);
    }
    
    public class func getUserAccount(server:String) -> String{
        
        var dict:Dictionary = Dictionary<String, Any>()
        dict.updateValue(server, forKey: kSecAttrServer as String)
        
        let dictionry = instance.readData(dict: dict) as Dictionary;
        
        guard let account = dictionry[kSecAttrAccount as String] as? String else {
           return  "";
        }
        return account
    }
    
    public class func getUserPassword(server:String) -> String{
        
        var dict:Dictionary = Dictionary<String, Any>()
        dict.updateValue(server, forKey: kSecAttrServer as String)
        
        let dictionry = instance.readData(dict: dict);
        
        guard let passwordData = dictionry[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8) else {
           return  "";
        }
        return password
    }
    
    public class func getUserPassword(server:String,account:String) -> String{
        
        var dict:Dictionary = Dictionary<String, Any>()
        dict.updateValue(server, forKey: kSecAttrServer as String)
        dict.updateValue(account, forKey: kSecAttrAccount as String)
        
        let dictionry = instance.readData(dict: dict);
        
        guard let passwordData = dictionry[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8) else {
           return  "";
        }
        return password
    }
    
    public class func deleteUser(server:String){
        
        var dict:Dictionary = Dictionary<String, Any>()
        dict.updateValue(server, forKey: kSecAttrServer as String)
        
        instance.deleteData(dict: dict);
    }
    
    public class func deleteUser(server:String,account:String){
        
        var dict:Dictionary = Dictionary<String, Any>()
        dict.updateValue(server, forKey: kSecAttrServer as String)
        dict.updateValue(account, forKey: kSecAttrAccount as String)
        
        instance.deleteData(dict: dict);
    }
    
    public func save(dictionry:Dictionary<String, Any>) -> Bool {
        if dictionry[kSecAttrAccount as String] == nil || dictionry[kSecAttrServer as String] == nil || dictionry[kSecValueData as String] == nil{
            return false;
        }
        
        // 进行存储数据
        let saveStatus = SecItemAdd(dictionry as CFDictionary, nil)
        
        if saveStatus == noErr  {
            return true
        }else{
            print("Error save cer to keychain. Error: \(saveStatus)")
            return false
        }
        
    }
    
    /*
     更新数据
     */
    private func updateData(dict:Dictionary<String, Any>)->Bool {
        // 获取更新的条件
        var attributes = dict
        attributes.removeValue(forKey: kSecAttrServer as String);
        // 创建数据存储字典
        var query = Dictionary<String, Any>()
        // 设置数据
        query.updateValue(kSecClassInternetPassword, forKey: kSecClass as String)
        query.updateValue(dict[kSecAttrServer as String] ?? "", forKey: kSecAttrServer as String)
        
        // 更新数据
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == noErr {
            return true
        }else{
            print("Error update cer to keychain. Error: \(updateStatus)")
            return false
        }
        
    }
    
    
    /*
     获取数据
     */
    private func readData(dict:Dictionary<String, Any>)-> Dictionary<String,Any> {
        
        // 获取查询条件
        var keyChainReadmutableDictionary = dict;
        // 提供查询数据的两个必要参数
        keyChainReadmutableDictionary.updateValue(true , forKey: kSecReturnData as String)
        keyChainReadmutableDictionary.updateValue(kSecMatchLimitOne, forKey: kSecMatchLimit as String)
        keyChainReadmutableDictionary.updateValue(true, forKey: kSecReturnAttributes as String)
        keyChainReadmutableDictionary.updateValue(kSecClassInternetPassword, forKey: kSecClass as String)
        // 创建获取数据的引用
        var item: CFTypeRef?
        // 通过查询是否存储在数据
        let readStatus =  SecItemCopyMatching(keyChainReadmutableDictionary as CFDictionary, &item)
        if readStatus == errSecSuccess {
            guard let existItem = item as? [String : Any]
            else {
                print("Error search cer to keychain. Error: \(readStatus)")
                return Dictionary.init()
            }
            
//            let passwordData = existingItem[kSecValueData as String] as? Data,
//            let password = String(data: passwordData, encoding: String.Encoding.utf8),
//            let account = existingItem[kSecAttrAccount as String] as? String
            return existItem;
            
        }
        
        return Dictionary.init()
    }
    
    /*
     删除数据
     */
    private func deleteData(dict:Dictionary<String, Any>)->Void{
        // 获取删除的条件
       // 创建数据存储字典
        var query = Dictionary<String, Any>()
        // 设置数据
        query.updateValue(kSecClassInternetPassword, forKey: kSecClass as String)
        query.updateValue(dict[kSecAttrServer as String] ?? "", forKey: kSecAttrServer as String)
        // 删除数据
       let deleteStatus = SecItemDelete(query as CFDictionary)
         
        if deleteStatus != noErr {
            print("Error delete cer to keychain. Error: \(deleteStatus)")
        }
    }
}

