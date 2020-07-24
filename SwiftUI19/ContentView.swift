//
//  ContentView.swift
//  SwiftUI19
//
//  Created by Rohit Saini on 24/07/20.
//  Copyright © 2020 AccessDenied. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var name = ""
    var body: some View {
        NavigationView{
            ZStack{
                Color.orange
                VStack{
                    Text("Please enter your chat name").fontWeight(.heavy).padding()
                    TextField("Enter Chat Name", text: $name).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                    NavigationLink(destination: GlobalChatView(name: name)){
                        HStack{
                            
                            Image(systemName: "arrow.right.circle.fill").resizable().frame(width: 50, height: 50).foregroundColor(.orange)
                            
                        }
                    }.padding()
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding()
            }.edgesIgnoringSafeArea(.all)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Message:Identifiable,Codable {
    var id,name,text:String
}

class MessageObserver:ObservableObject {
    @Published var messages = [Message]()
    init(){
        let db = Firestore.firestore()
        db.collection("messages").addSnapshotListener { (snap, err) in
            if err != nil{
                print(err!)
                return
            }
            for i in snap!.documentChanges{
                if i.type == .added{
                    let id  = i.document.documentID
                    let name = i.document.get("name") as! String
                    let text = i.document.get("text") as! String
                    self.messages.append(Message(id: id, name: name, text: text))
                }
            }
        }
    }
    
    func sendMsg(text: String,name: String){
       let db = Firestore.firestore()
        db.collection("messages").addDocument(data: ["name":name,"text":text]) { (err) in
            if err != nil{
                print(err)
                return
            }
            print("Success")
        }
    }
}

struct GlobalChatView:View{
    var name = ""
    @State var typedMsg = ""
    @ObservedObject var msgObj = MessageObserver()
    var body: some View{
        VStack{
            List(msgObj.messages) { msg in
                    if msg.name == self.name{
                        HStack{
                            Spacer()
                            VStack(alignment: .trailing){
                            Text(msg.text).fontWeight(.heavy).padding().background(Color.orange).foregroundColor(.white).cornerRadius(5)
                           Text(msg.name).fontWeight(.bold)
                            }
                        }
                        
                    }
                    else{
                      HStack{
                        VStack(alignment: .leading){
                            
                        Text(msg.text).fontWeight(.heavy).padding().background(Color.green).foregroundColor(.white).cornerRadius(5)
                            Text(msg.name).fontWeight(.bold)
                        }
                            
                        Spacer()
                        }
                    }
                   
                
            }.navigationBarTitle("Chats",displayMode: .inline)
            HStack{
                TextField("Send Message", text: $typedMsg).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                Button(action: {
                    self.msgObj.sendMsg(text: self.typedMsg, name: self.name)
                    self.typedMsg = ""
                    
                }) {
                    Image(systemName: "location.fill").resizable().frame(width: 25, height: 25).foregroundColor(.orange).padding()
                }
            }
            
        }
        
    }
}


extension Encodable {

    //MARK:-  Converting object to postable JSON
    public func toJSON(_ encoder: JSONEncoder = JSONEncoder()) -> [String: Any] {
        guard let data = try? encoder.encode(self) else { return [:] }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return [:] }
        guard let json = object as? [String: Any] else { return [:] }
        return json
    }
}
