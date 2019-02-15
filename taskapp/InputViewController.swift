//
//  InputViewController.swift
//  taskapp
//
//  Created by 天野智広 on 2019/02/04.
//  Copyright © 2019 天野智広. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications    // 追加 ローカル通知

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField! //課題：カテゴリ追加
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm() //Realm()インスタンス作成
    var task: Task! //画面遷移元のViewcontrollerから値を受け取る
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        //UITextField等をタップするとキーボードが出てくるが、そのままでは引っ込まない
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        categoryTextField.text = task.category //課題：カテゴリ追加
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    
    //遷移する際に、画面が非表示になるとき呼ばれるメソッド、viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            //入力欄の中に書いてあるデータをtaskにぶち込む
            self.task.title = self.titleTextField.text!
            self.task.category = self.categoryTextField.text! //課題：カテゴリー追加
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            //taskオブジェクトを更新する
            self.realm.add(self.task, update: true)
        }
        
        setNotification(task: task)   // 追加
        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    } // --- ここまで追加 ---
    
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    
    
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

