//
//  ViewController.swift
//  Texas
//

import UIKit
import MessageUI

class ViewController: UIViewController {
  @IBOutlet private weak var tableView: UITableView!
  
  private var objects: [SavedObject] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    reload()
  }
  
  private func reload() {
    let data = UserDefaults.standard.data(forKey: "objects") ?? Data()
    let objects = (try? JSONDecoder().decode([SavedObject].self, from: data)) ?? []
    
    self.objects = objects
    tableView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destination = segue.destination
    
    (destination as? AddViewController)?.onDidAdd = { [weak self] in
      self?.reload()
    }
  }
  
  private func send(object: SavedObject) {
    let alert = UIAlertController(title: "Укажите Email", message: nil, preferredStyle: .alert)
    alert.addTextField { field in
      field.keyboardType = .emailAddress
      field.autocorrectionType = .no
      field.autocapitalizationType = .none
      field.textContentType = .emailAddress
    }
    alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { [weak self, weak alert] _ in
      let field = alert?.textFields?.first
      let email = field?.text
      self?.sendEmail(object: object, email: email)
    }))
    alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  private func sendEmail(object: SavedObject, email: String?) {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      mail.setToRecipients([email ?? ""])
      
      var emailText = ""
      
      let objectToSend = [
        "coordinates": [
          "lat": object.lat,
          "lon": object.lon
        ],
        "objects": [
          "object": [
            "type": object.type.rawValue,
            "count": object.count
          ]
        ]
      ]
      
      if let data = try? JSONSerialization.data(withJSONObject: objectToSend, options: [.prettyPrinted]),
         let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
        emailText = prettyPrintedString as String
      }
      
      mail.setMessageBody(emailText, isHTML: true)
      
      present(mail, animated: true)
    } else {
      let alert = UIAlertController(title: "Ошибка",
                                    message: "Не удалось отправить письмо. Возможно, на вашем устройстве не настроен почтовый аккаунт.",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
    }
  }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return objects.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "objectCell", for: indexPath)
    let index = indexPath.row
    guard index >= 0, index < objects.count else { return UITableViewCell() }
    let object = objects[index]
    (cell.viewWithTag(1) as? UILabel)?.text = "\(object.type.title) x\(object.count)"
    (cell.viewWithTag(2) as? CustomButton)?.onTap = { [weak self] in
      self?.send(object: object)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      objects.remove(at: indexPath.row)
      if let data = try? JSONEncoder().encode(objects) {
        UserDefaults.standard.set(data, forKey: "objects")
      }
      
      tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
  }
}

// MARK: - MFMailComposeViewControllerDelegate

extension ViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult, error: Error?) {
      controller.dismiss(animated: true)
  }
}
