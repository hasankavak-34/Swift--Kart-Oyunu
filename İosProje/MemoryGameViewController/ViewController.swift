//
//  ViewController.swift
//  MemoryGameViewController
//
//  Created by Bilal Zeyd Kılıç on 20.05.2025.
//
import UIKit

class ViewController: UIViewController {
    
    
    private var gridStackView: UIStackView!
    private var statusLabel: UILabel!
    private var timerLabel: UILabel!
    private var startButton: UIButton!
    private var restartButton: UIButton!
    
    
    private let allSymbols = ["🐶", "🐱", "🐰", "🦊", "🐸", "🐵", "🐯", "🐼"]
    
    private var cards = [String]()
    private var buttons = [UIButton]()
    
    private var firstSelectedIndex: Int?
    private var secondSelectedIndex: Int?
    
    private var matchedPairs = 0
    private var gameOver = false
    
    private var difficultyLevel = 4
    
    private var countdownTime = 0
    private var countdownTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        showStartScreen()
    }
    
    func setupUI() {
        
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        view.addSubview(statusLabel)
        
        
        timerLabel = UILabel()
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        view.addSubview(timerLabel)
        
        
        startButton = UIButton(type: .system)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Başlat", for: .normal)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
        
        
        restartButton = UIButton(type: .system)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.setTitle("Tekrar Başla", for: .normal)
        restartButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        restartButton.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)
        restartButton.isHidden = true
        view.addSubview(restartButton)
        
        
        gridStackView = UIStackView()
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        gridStackView.axis = .vertical
        gridStackView.spacing = 10
        gridStackView.distribution = .fillEqually
        view.addSubview(gridStackView)
        
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(equalToConstant: 30),
            
            timerLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            timerLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor),
            timerLabel.heightAnchor.constraint(equalToConstant: 30),
            
            startButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 16),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 44),
            startButton.widthAnchor.constraint(equalToConstant: 150),
            
            restartButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 16),
            restartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restartButton.heightAnchor.constraint(equalToConstant: 44),
            restartButton.widthAnchor.constraint(equalToConstant: 150),
            
            gridStackView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            gridStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gridStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            gridStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func showStartScreen() {
        startButton.isHidden = false
        restartButton.isHidden = true
        statusLabel.text = "Başlamak için Başlat'a dokun"
        timerLabel.text = "Süre: 0 sn"
        
        
        for btn in buttons {
            btn.removeFromSuperview()
        }
        buttons.removeAll()
        
        for view in gridStackView.arrangedSubviews {
            gridStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    @objc func startButtonTapped() {
        startButton.isHidden = true
        restartButton.isHidden = true
        difficultyLevel = 4
        startLevel(difficultyLevel)
    }
    
    @objc func restartButtonTapped() {
        restartButton.isHidden = true
        difficultyLevel = 4
        startLevel(difficultyLevel)
    }
    
    func startLevel(_ level: Int) {
        difficultyLevel = level
        setupGame()
        startCountdownTimer()
    }
    
    func setupGame() {
        buttons.removeAll()
        firstSelectedIndex = nil
        secondSelectedIndex = nil
        matchedPairs = 0
        gameOver = false
        
        statusLabel.text = "Kartları eşleştir! Seviye: \(difficultyLevel)"
        
        let symbols = Array(allSymbols.prefix(difficultyLevel))
        cards = (symbols + symbols).shuffled()
        
        for view in gridStackView.arrangedSubviews {
            gridStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        let columns = 4
        let rows = Int(ceil(Double(cards.count) / Double(columns)))
        
        var cardIndex = 0
        for _ in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.distribution = .fillEqually
            
            for _ in 0..<columns {
                if cardIndex < cards.count {
                    let button = UIButton(type: .system)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
                    button.setTitle("❓", for: .normal)
                    button.backgroundColor = .systemGray5
                    button.layer.cornerRadius = 8
                    button.tag = cardIndex
                    button.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
                    
                    buttons.append(button)
                    rowStack.addArrangedSubview(button)
                    cardIndex += 1
                } else {
                    let emptyView = UIView()
                    rowStack.addArrangedSubview(emptyView)
                }
            }
            gridStackView.addArrangedSubview(rowStack)
        }
    }
    
    @objc func cardTapped(_ sender: UIButton) {
        if gameOver { return }
        let index = sender.tag
        if firstSelectedIndex == index || secondSelectedIndex == index { return }
        if secondSelectedIndex != nil { return }
        
        sender.setTitle(cards[index], for: .normal)
        
        if firstSelectedIndex == nil {
            firstSelectedIndex = index
        } else {
            secondSelectedIndex = index
            
            if cards[firstSelectedIndex!] == cards[secondSelectedIndex!] {
                matchedPairs += 1
                statusLabel.text = "Doğru eşleştirme! \(matchedPairs)/\(difficultyLevel)"
                
                firstSelectedIndex = nil
                secondSelectedIndex = nil
                
                if matchedPairs == difficultyLevel {
                    gameOver = true
                    statusLabel.text = "Tebrikler! Seviye \(difficultyLevel) tamamlandı."
                    countdownTimer?.invalidate()
                    
                    difficultyLevel += 1
                    if difficultyLevel > allSymbols.count {
                        difficultyLevel = allSymbols.count
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.startLevel(self.difficultyLevel)
                    }
                }
            } else {
                statusLabel.text = "Yanlış eşleştirme, tekrar dene."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.buttons[self.firstSelectedIndex!].setTitle("❓", for: .normal)
                    self.buttons[self.secondSelectedIndex!].setTitle("❓", for: .normal)
                    self.firstSelectedIndex = nil
                    self.secondSelectedIndex = nil
                    self.statusLabel.text = "Kartları eşleştir! Seviye: \(self.difficultyLevel)"
                }
            }
        }
    }
    
    func startCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTime = max(40, 60 - (difficultyLevel - 1) * 5)
        timerLabel.text = "Süre: \(countdownTime) sn"
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdownTime > 0 && !self.gameOver {
                self.countdownTime -= 1
                self.timerLabel.text = "Süre: \(self.countdownTime) sn"
            } else if !self.gameOver {
                timer.invalidate()
                self.gameOver = true
                self.statusLabel.text = "Süre bitti! Oyunu tekrar başlatın."
                self.restartButton.isHidden = false
            }
        }
    }
}
