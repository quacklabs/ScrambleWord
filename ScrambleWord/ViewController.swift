//
//  ViewController.swift
//  Scrambleword
//
//  Created by Sprinthub on 11/02/2019.
//  Copyright © 2019 Sprinthub Mobile. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        
        //load our words from file
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            //text file found, lets get to work
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }
        //
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        
        startGame()
        
    }
    
    //show prompt demanding for answers and anagrams
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        //define our submit action
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    //handle submit action properly
    func submit(answer: String){
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    showError(errorTitle : "Word not recognised", errorMessage: "You can't just make them up, you know!")
                }
            } else {
                showError(errorTitle : "Word used already", errorMessage:  "Be more original!")
            }
        } else {
            showError(errorTitle: "Word not possible", errorMessage: "You can't spell that word from '\(title!.lowercased())'")
        }
        
    }
    
    //show an error message to the user using default alert
    func showError(errorTitle: String, errorMessage: String){
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        for letter in word {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
    
    //check if word is original and not the start word
    func isOriginal(word: String) -> Bool {
        
        //the start word is the title so we take it first
        let tempWord = title!.lowercased()
        
        //check if submitted word is blank or is the start word
        if word == tempWord || word == ""{
            //failed. get out of here joor
            return false
        }
        
        //hooray, oya check if the word has already been supplied as a previous answer
        return !usedWords.contains(word)
    }
    
    
    //check if its a real word
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    
    //check if word length is at least 3 characters
    func islong(word: String) -> Bool{
        if word.utf16.count < 3 {
            return false
        }
        
        return true;
    }
    
    //start our game.
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    //this will return a count of used words as number of table rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    
    //this will populate table rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //this runs a loop on the table using the identifiers.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
}

