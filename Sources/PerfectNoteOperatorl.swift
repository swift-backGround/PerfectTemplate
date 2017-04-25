//
//  PerfectNoteOperator.swift
//  PerfectTemplate
//
//  Created by LiWeijie on 2017/4/1.
//
//
import Foundation
import MySQL

let RequestResultSuccess: String = "SUCCESS"
let RequestResultFaile: String = "FAILE"
let ResultListKey = "list"
let ResultKey = "result"
let ErrorMessageKey = "errorMessage"

var BaseResponseJson: [String : Any] = [ResultListKey : [],
                                        ResultKey : RequestResultSuccess,
                                        ErrorMessageKey : "" ]
/// 操作数据库的基类
class BaseOperator {
    let dataBaseName = "test"
    var mysql: MySQL {
        get {
            return MySQLConnent.shareInstance(dataBaseName: dataBaseName)
        }
    }
    var responseJson: [String : Any] = BaseResponseJson
}
/// 构建user表的操作类
/**
 增   删   改   查
 */
class UserOperator: BaseOperator {
    let userTableName = "user"
    
    /// insert user info
    /// 增
    /// - Parameters:
    ///  - userName: 用户名
    ///  - password: 密码
    func insertUserInfo(userName: String, password: String)-> String? {
        let values = "('\(userName)', '\(password)')"
        let statement = "insert into \(userTableName) (username, password) values \(values)"
        print("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            print("\(statement)插入失败")
            self.responseJson[ResultKey] = RequestResultFaile
            self.responseJson[ErrorMessageKey] = "创建\(userName)失败"
            guard let josn = try? responseJson.jsonEncodedString() else {
                return nil
            }
            return josn
        }else {
            print("插入成功")
            return queryUserInfo(username: userName, password: password)
        }
    }
    /**
     删除用户
     */
    func deleteUser(userId: String) -> String? {
        let statement = "delete from\(userTableName) where id ='\(userId)'"
        print("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            self.responseJson[ResultKey] = RequestResultFaile
            self.responseJson[ErrorMessageKey] = "删除失败"
            print("\(statement)删除失败")
        }else {
            print("SQL:\(statement)删除成功")
            self.responseJson[ResultKey] = RequestResultSuccess
        }
        guard let josn = try? responseJson.jsonEncodedString() else {
            return nil
        }
        return josn
    }
    /**
     更新用户信息
     */
    func updateUserInfo(userId: String, userName: String, password: String) -> String? {
        let statement = "update \(userTableName) set username='\(userName)',password='\(password)',create_time=now() where id = '\(userId)'"
        print("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            print("\(statement)更新失败")
            self.responseJson[ResultKey] = RequestResultFaile
            self.responseJson[ErrorMessageKey] = "更新失败"
            guard let json = try? responseJson.jsonEncodedString()else {
                return nil
            }
            return json
        }else {
            print("SQL:\(statement)更新成功")
            return queryUserInfo(username:userName,password: password)
        }
    }
    /**
     查询
     */
    func queryUserInfo(username: String, password: String) -> String? {
        let statement = "select * from user where username = '\(username)' and password='\(password)'"
        print("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            self.responseJson[ResultKey] = RequestResultFaile
            self.responseJson[ErrorMessageKey] = "查询失败"
            print("\(statement)查询失败")
        }else {
            print("SQL:\(statement)查询成功")
            //在当前回话过程中保存查询结果
            let results = mysql.storeResults()!
            var dic = [String:String]()   //创建一个字典数组用于存储结果
            results.forEachRow { row in
                guard let userId = row.first! else { //保存选项表的Name名称字段应该是所在行的第一列，row[0]
                    return
                }
                dic["userId"] = "\(userId)"
                dic["username"] = "\(row[1]!)"
                dic["password"] = "\(row[2]!)"
                dic["create_time"] = "\(row[3]!)"
            }
            self.responseJson[ResultKey] = RequestResultSuccess
            self.responseJson[ResultListKey] = dic
        }
        guard let json = try? responseJson.jsonEncodedString() else {
            return nil
        }
        return json
    }
    
}










































