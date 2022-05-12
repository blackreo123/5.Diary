//
//  DiaryDetailViewContoller.swift
//  5.Diary
//
//  Created by JIHA on 2022/04/12.
//

import Foundation
import UIKit

class DiaryDetailViewContoller: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
        
    var diary: Diary?
    var indexPath: IndexPath?
    
    var starButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(starDiaryNotification(_:)),
                                               name: NSNotification.Name("starDiary"),
                                               object: nil)
    }
    
    @objc private func starDiaryNotification(_ notification: NSNotification) {
        guard let starDiary = notification.object as? [String: Any] else {return}
        guard let isStar = starDiary["isStar"] as? Bool else {return}
        guard let uuidString = starDiary["uuidString"] as? String else {return}
        guard let diary = self.diary else {return}
        if diary.uuidString == uuidString {
            self.diary?.isStar = isStar
            self.configureView()
        }
        guard let navigationController = self.navigationController else {return}
        var previousViewController: UIViewController? {
            navigationController.viewControllers.count > 1 ? navigationController.viewControllers[navigationController.viewControllers.count - 2] : nil
            }
        if previousViewController is StarViewController {
            navigationController.popViewController(animated: true)
        }
                
    }
    
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    
    @objc private func tapStarButton() {
        guard let isStar = self.diary?.isStar else {return}
        guard let indexPath = self.diary?.uuidString else {return}
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        
        NotificationCenter.default.post(name: NSNotification.Name("starDiary"),
                                        object: [
                                            "diary": self.diary,
                                            "isStar": self.diary?.isStar ?? false,
                                            "uuidString": indexPath
                                        ])
    }
            
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @objc private func editDiaryNotification(_ notification: NSNotification) {
        guard let diary = notification.object as? Diary else {return}
        self.diary = diary
        self.configureView()
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else {return}
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        viewController.diaryEditorMode = .edit(indexPath, diary)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editDiaryNotification(_:)),
                                               name: NSNotification.Name("diaryEdit"),
                                               object: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let uuidString = self.diary?.uuidString else { return }
        NotificationCenter.default.post(name: NSNotification.Name("deleteDiary"),
                                        object: uuidString)
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
