//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import MySQL
// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(data: [String:Any]) throws -> RequestHandler {
	return {
		request, response in
		// Respond with a simple message.
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
		// Ensure that response.completed() is called when your processing is done.
		response.completed()
	}
}


//创建路由并添加
let server = HTTPServer()
var routes = Routes()
routes.add(method: .get, uri: "/login") { (request, response) in
    response.setBody(string: "我是/login路径返回的信息")
    response.appendBody(string: "是的，你请求到了get请求")
    response.completed()
}
//MARK: -路由变量
let valueKey = "key"
routes.add(method: .get, uri: "/path1/{\(valueKey)}/detail") { (request, response) in
    response.appendBody(string: "该URL中的路由变量为：\(String(describing: request.urlVariables[valueKey]))")
    response.completed()
}
//MARK: -路由通配符 *
routes.add(method: .get, uri: "/path2/*/detail") { (request, response) in
    response.appendBody(string: "通配符URL为\((request.path))")
    response.completed()
}
//MARK: -结尾通配符
/*
 结尾处使用“**”来匹配尾部所有符合规则的url，然后通过routeTralilingWildcardKey来获取通配的内容
 */
routes.add(method: .get, uri: "/path3/**") { (request, response) in
    response.appendBody(string: "该URL中的结尾通配符对应的变量:\((describing: request.urlVariables[routeTrailingWildcardKey]))")
    response.completed()
}

//MARK -post请求
routes.add(method: .post, uri: "/login") { (requst, response) in
    guard let userName = requst.param(name:"userName") else {
        return
    }
    guard let password = requst.param(name:"password") else {
        return
    }
    let responsDic: [String: Any] = ["responsBody":["userName":userName, "password":password],
                                     "result":"sucess",
                                     "resultMessage":"请求成功"
    ]
    
    do {
        let json = try responsDic.jsonEncodedString()
        response.setBody(string:json)
        
    }catch {
        response.setBody(string: "json数据出错")
    }
    response.completed()
}

//向数据库中增加一条消息

routes.add(method: .get, uri: "/create") { (request, response) in
    guard let userName: String = request.param(name: "userName") else {
        print("userName为nil")
        response.completed()
        return
    }
    guard let password: String = request.param(name: "password") else {
        print("password为nil")
        response.completed()
        return
    }
    guard let json = UserOperator().insertUserInfo(userName: userName, password: password) else {
        print("json为nil")
        response.completed()
        return
    }
    print(json)
    response.setBody(string: json)
    response.completed()
}




//配置一写基础信息，
server.addRoutes(routes)
server.serverPort = 8080
server.documentRoot = "./webroot"
//运行
do {
    try server.start()
} catch {
    fatalError("\(error)") // fatal error launching one of the servers
}

/*

// Configuration data for two example servers.
// This example configuration shows how to launch one or more servers 
// using a configuration dictionary.

let port1 = 8080, port2 = 8181

let confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
			"name":"localhost",
			"port":port1,
			"routes":[
				["method":"get", "uri":"/", "handler":handler],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot",
				 "allowResponseFilters":true]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		],
		// Configuration data for another server which:
		//	* Redirects all traffic back to the first server.
		[
			"name":"localhost",
			"port":port2,
			"routes":[
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
				 "base":"http://localhost:\(port1)"]
			]
		]
	]
]

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}
*/*/*/
