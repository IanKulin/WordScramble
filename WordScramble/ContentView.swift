//
//  ContentView.swift
//  WordScramble
//
//  Created by Ian Bailey on 13/9/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var newWord = ""
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var allWords = [String]()
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    
    var body: some View {
        NavigationView {
            
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id:\.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: loadWords)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role:.cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Text("Score: \(score)")
                        Spacer()
                        
                        Button("New Word") {
                            startGame()
                        }
                    }
                }
            }
        }

    }
    
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell '\(answer)' from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make them up!")
            return
        }
        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "Your words need to be three letters or longer")
            return
        }
        guard isNovel(word: answer) else {
            wordError(title: "Plagiarised", message: "Make up your own words!")
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        score += answer.count
    }
    
    
    func loadWords() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
                startGame()
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    
    func startGame() {
        usedWords = [String]()
        rootWord = allWords.randomElement() ?? "silkworm"
        score = 0
    }
    
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    
    func isLongEnough(word: String) -> Bool {
        return word.count > 2
    }
    
    func isNovel(word: String) -> Bool {
        return word != rootWord
    }
    
    
    func wordError(title: String, message:String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
