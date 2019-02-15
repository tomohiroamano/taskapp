//
//  ViewController.swift
//  taskapp
//
//  Created by 天野智広 on 2019/02/04.
//  Copyright © 2019 天野智広. All rights reserved.
//

import UIKit
import RealmSwift   // ←追加
import UserNotifications    // 追加

//課題：UISearchBarDelegateを追加
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar! //課題：UISearchBarを追加
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    
    // DB内のタスクが格納されるリスト。objects(_:)メソッドでデータの一覧を取得
    // 日付近い順\順でソート：降順　ascending:false
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)  // ←追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self //課題：デリゲート先を自分に設定
        searchbar.showsCancelButton = true //課題：キャンセルボタンを表示
        
        //課題：プレースホルダの指定
        searchbar.placeholder = "カテゴリ検索の文字列を入力"
        
        //課題：何も入力されていなくてもReturnキーを押せるようにする。
        searchbar.enablesReturnKeyAutomatically = false
        
    }
    
    //課題：検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchbar: UISearchBar) {
        //キーボード以外をタッチするとキーボードが下がる
        searchbar.endEditing(true)

    //課題：サーチボックスに何か入力されている時
    if self.searchbar.text != "" {
    //入力欄に入れた文字列を定数に格納
    let categoryinput:String! = self.searchbar.text
    //フィルター検索実施でtaskArrayを更新
        taskArray = try! Realm().objects(Task.self).filter("category  == %@", categoryinput).sorted(byKeyPath: "date", ascending: false) // ←追加
        }
        //検索結果でTableViewを更新
        tableView.reloadData()
        
    }
    
    //課題：サーチボックのキャンセルボタンがタップされた時の動作を記述
    func searchBarCancelButtonClicked(_ searchbar: UISearchBar) {
        //キーボード以外をタッチするとキーボードが下がる
        searchbar.endEditing(true)
        //サーチボックスを空にする
        searchbar.text = ""
        //taskArrayのフィルタリングを外す（元に戻す）
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        //TableViewを更新
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // tableView(_:numberOfRowsInSection:)はデータの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  // ←修正する
    }

    // tableView(_:cellForRowAtIndexPath:)メソッドは各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.  --- ここから ---
        //indexPath.rowの位置のtaskArrayの中身（tableViewの行の位置のデータ）を取得
        let task = taskArray[indexPath.row]
        //?はオプショナルチェイニング、オプショナル型変数に続けてプロパティ取得、メソッドを呼び出し時に使用
        cell.textLabel?.text = task.title
        
        //DateFormatter()インスタンスを取得、日付のフォーマットを変えたりするのに使うClass
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        //日付はDate型であるため、cell.detailTextLabel?.textに代入するためにString型に変換
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString //変更したものをセット
        // --- ここまで追加 ---
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segueのIDを指定して遷移させるメソッド
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    //tableView(_:commit:forRowAt)メソッドはセルの削除を行う時に呼び出される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // --- ここから --- tableViewの編集モードが.deleteの時
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                //Realmクラスのdeleteメソッドに削除したいオブジェクトを与えることで削除
                self.realm.delete(task)
                //deleteRows(at:with:)メソッドでセルをアニメーションさせながら削除
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで変更 ---
        
    }
  
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        //InputViewControllerクラスのtaskプロパティに値を引き渡す
        let inputViewController:InputViewController = segue.destination as! InputViewController
        //if(既存セルをタップしたとき)、else(新規にタスクを作成するとき)
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            //初期値として現在時間と、プライマリキーであるIDを設定
            let task = Task()  //Taskクラスのインスタンス作成
            task.date = Date() //現在時刻を取得するメソッド
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1 //既存のタスクid+1を設定
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる //Willappearは画面遷移の直前に1回だけ呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
}

