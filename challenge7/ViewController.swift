//
//  ViewController.swift
//  challenge7
//
//  Created by Ivan Pavic on 20.2.22..
//

import UIKit

class ViewController: UITableViewController, DataSharingDelegateProtocol {
    
    var notes = [Note]() 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationLabel = UILabel()
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha: 0.2)
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset = CGSize(width: 1, height: 2)
        let navTitle = NSMutableAttributedString(string: "Notes", attributes: [
            NSAttributedString.Key.shadow : shadow,
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "Noteworthy", size: 26) as Any
        ])
        navigationLabel.attributedText = navTitle
        self.navigationItem.titleView = navigationLabel
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        
        
        let defaults = UserDefaults.standard
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                fatalError("Unable to decode savedNotes")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].noteTitle
        cell.textLabel?.font = UIFont(name: "Noteworthy", size: 16)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController else { return }
        vc.selectedNote = notes[indexPath.row].noteTitle
        vc.selectedBody = notes[indexPath.row].noteBody
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
            save()
        }
    }
    
    @objc func addNewNote() {
        let ac = UIAlertController(title: "Add new note", message: "Enter note title", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak self, weak ac] _ in
            guard let noteTitle = ac?.textFields?[0].text else { return }
            self?.submit(noteTitle)
            self?.save()
        })
        present(ac, animated: true)
    }
    
    func submit (_ noteTitle: String) {
        let newNote = Note(noteTitle: noteTitle, noteBody: "")
        notes.insert(newNote, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .right)
        return
    }
    
    func sendDataToTableView(myData: Note) {
        let title = myData.noteTitle
        if let index = notes.firstIndex(where: {$0.noteTitle == title}) {
            notes[index].noteBody = myData.noteBody
            notes = rearrangeTable(array: notes, fromIndex: index, toIndex: 0)
            tableView.reloadData()
            save()
        }
    }
    
    func rearrangeTable (array: Array<Note>, fromIndex: Int, toIndex: Int) -> Array<Note> {
        var array = notes
        let element = array.remove(at: fromIndex)
        array.insert(element, at: toIndex)
        return array
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        }
    }
}
