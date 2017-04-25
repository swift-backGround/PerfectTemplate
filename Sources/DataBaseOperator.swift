//
//  sdd.swift
//  PerfectTemplate
//
//  Created by LiWeijie on 2017/4/1.
//
//

import Foundation
import MySQL

class MySQLConnent {
    var host: String {   //数据库
        get {
            return "127.0.0.1"
        }
    }
    var port: String {  //数据库端口
        get {
            return "3306"
        }
    }
    var user: String {  //数据库用户名
        get {
            return "root"
        }
    }
    var password: String {//数据库密码
        get {
            return "721412"
        }
    }
    private var mysql: MySQL!     //用于操作MySql的句柄
    
    //MySQL句柄单例
    private static var instanece: MySQL!
    public static func shareInstance(dataBaseName: String) -> MySQL{
        if instanece == nil {
            instanece = MySQLConnent(dataBaseName: dataBaseName).mysql
        }
        return instanece
    }
    //私有构造器
    private init(dataBaseName: String) {
        self.connectDataBase()
        self.selectDataBase(name: dataBaseName)
    }
    /**
     数据的连接，调用MySQL类中的connect(）方法，
     */
    //连接数据库
    private func connectDataBase() {
        if mysql == nil {
            mysql = MySQL()
        }
        let connected = mysql.connect(host: "\(host)", user: user, password: password)
        guard connected else { //验证连接是否成功
            print(mysql.errorMessage())
            return
        }
        print("数据连接成功")
    }
    /**
     - 选择数据库Scheme
     - Parameter name: Scheme名
     */
    func selectDataBase(name: String){
        //选择具体的数据Schema
        guard mysql.selectDatabase(named: name) else {
            print("数据库选择失败。错误代码：\(mysql.errorMessage()) 错误解释：\(mysql.errorMessage())")
            return
        }
        print("连接Schema:\(name)成功")
    }
    
}



















































































