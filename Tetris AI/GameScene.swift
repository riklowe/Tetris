//
//  GameScene.swift
//  Tetris AI
//
//  Created by Richard Lowe on 01/10/2024.
//

import SpriteKit

class GameScene: SKScene {
    // Game grid dimensions
    var gridWidth = 10
    var gridHeight = 20

    var grid = [[Int]]()            // 2D array to represent the grid
    var gridColors = [[SKColor]]()  // 2D array to represent block colors

    // Current and next Tetrominoes
    var currentPiece: Tetromino?    // Current Tetromino falling
    var nextPiece: Tetromino?       // Next Tetromino preview

    // Nodes for rendering
    var gridNode: SKNode!
    var nextPieceNode: SKNode!

    // Score tracking
    var score = 0
    var highScore = 0
    var scoreLabel: SKLabelNode!
    var nextLabel: SKLabelNode!

    // Game over flag
    var gameOver = false

    override func didMove(to view: SKView) {
        self.backgroundColor = .black

        // Initialize the grid and grid node
        gridNode = SKNode()
        addChild(gridNode)

        createGrid()

        // Initialize and display the score label
        scoreLabel = SKLabelNode(text: "")
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 100)
        addChild(scoreLabel)

        // Load the high score from UserDefaults
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
        updateScoreLabel()

        // Initialize the next piece node
        nextPieceNode = SKNode()
        nextPieceNode.position = CGPoint(x: self.size.width - 80, y: self.size.height - 150)
        addChild(nextPieceNode)

        // Add a background for the next piece preview
        let previewBackground = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
        previewBackground.position = CGPoint(x: 40, y: -40)  // Centered in nextPieceNode
        previewBackground.fillColor = SKColor.darkGray
        previewBackground.strokeColor = SKColor.white
        nextPieceNode.addChild(previewBackground)

        // Add a label for the next piece preview
        nextLabel = SKLabelNode(text: "Next")
        nextLabel.fontSize = 20
        nextLabel.fontColor = SKColor.white
        nextLabel.position = CGPoint(x: self.size.width - 160, y: self.size.height - 150)
        addChild(nextLabel)

        // Initialize the next piece
        nextPiece = Tetromino.random()

        // Spawn the first piece
        spawnPiece()
        startGameLoop()
    }

    func createGrid() {
        // Initialize the grid and color grid
        grid = Array(repeating: Array(repeating: 0, count: gridWidth), count: gridHeight)
        gridColors = Array(repeating: Array(repeating: SKColor.clear, count: gridWidth), count: gridHeight)
    }

    func spawnPiece() {
        // Set currentPiece to the nextPiece
        currentPiece = nextPiece

        // Position the currentPiece within the grid
        currentPiece?.position = (x: gridWidth / 2 - 1, y: gridHeight - currentPiece!.shape.count)

        // Check for collision after positioning the piece
        if checkCollision() {
            endGame()
            return
        }

        // Generate a new nextPiece
        nextPiece = Tetromino.random()

        // Render the grid and next piece
        renderGrid()
        renderNextPiece()
    }

    func startGameLoop() {
        let wait = SKAction.wait(forDuration: 0.5)
        let updateAction = SKAction.run { [weak self] in
            self?.updateGame()
        }
        let sequence = SKAction.sequence([wait, updateAction])
        let repeatAction = SKAction.repeatForever(sequence)
        run(repeatAction)
    }

    func updateGame() {
        if let piece = currentPiece {
            piece.moveDown()

            // If a collision is detected, move the piece back up, lock it, and spawn a new one
            if checkCollision() {
                piece.moveUp()
                lockPiece()
                spawnPiece()
            }
        }
        renderGrid()  // Update the visual representation of the grid
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        if gameOver {
            return  // Disable touch controls if the game is over
        }

        // Handle left, right, rotation, and hard drop
        if touchLocation.x < self.size.width / 3 {
            currentPiece?.moveLeft()
            if checkCollision() {
                currentPiece?.moveRight()
            }
        } else if touchLocation.x > 2 * self.size.width / 3 {
            currentPiece?.moveRight()
            if checkCollision() {
                currentPiece?.moveLeft()
            }
        } else if touchLocation.y < self.size.height / 3 {
            // Trigger the hard drop if the bottom third of the screen is tapped
            hardDrop()
        } else {
            // Rotate the piece if the middle third of the screen is tapped
            currentPiece?.rotate()
            if checkCollision() {
                currentPiece?.rotate()  // Undo rotation by rotating three more times
                currentPiece?.rotate()
                currentPiece?.rotate()
            }
        }

        renderGrid()  // Update the grid after the movement
    }

    func enableRestartGesture() {
        // Remove existing gesture recognizers to avoid conflicts
        if let recognizers = view?.gestureRecognizers {
            for recognizer in recognizers {
                view?.removeGestureRecognizer(recognizer)
            }
        }

        // Add the double-tap gesture to restart the game
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(restartGame))
        doubleTap.numberOfTapsRequired = 2
        view?.addGestureRecognizer(doubleTap)
    }

    func checkCollision() -> Bool {
        if let piece = currentPiece {
            let shapeRows = piece.shape.count
            let shapeCols = piece.shape[0].count

            for row in 0..<shapeRows {
                for col in 0..<shapeCols {
                    if piece.shape[row][col] == 1 {
                        let newX = piece.position.x + col
                        let newY = piece.position.y + row

                        // Check if the piece is outside the bounds of the grid
                        if newX < 0 || newX >= gridWidth || newY < 0 || newY >= gridHeight {
                            return true
                        }

                        // Check if the piece collides with already locked blocks
                        if grid[newY][newX] == 1 {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }


    func checkGameOver() -> Bool {
        if let piece = currentPiece {
            for row in 0..<piece.shape.count {
                for col in 0..<piece.shape[row].count {
                    if piece.shape[row][col] == 1 {
                        let newX = piece.position.x + col
                        let newY = piece.position.y + row
                        if grid[newY][newX] == 1 {
                            return true  // Game over condition
                        }
                    }
                }
            }
        }
        return false
    }

    func lockPiece() {
        if gameOver { return }

        if let piece = currentPiece {
            for row in 0..<piece.shape.count {
                for col in 0..<piece.shape[row].count {
                    if piece.shape[row][col] == 1 {
                        let newX = piece.position.x + col
                        let newY = piece.position.y + row

                        grid[newY][newX] = 1  // Lock the piece into the grid
                        gridColors[newY][newX] = piece.color  // Store the color
                    }
                }
            }
        }

        // After locking, clear completed lines
        clearCompletedLines()
    }

    func renderGrid() {
        gridNode.removeAllChildren()

        let cellSize = CGSize(width: 30, height: 30)

        let xOffset = (self.size.width - CGFloat(gridWidth) * cellSize.width) / 2
        let yOffset = (self.size.height - CGFloat(gridHeight) * cellSize.height) / 2

        // Render locked blocks
        for row in 0..<gridHeight {
            for col in 0..<gridWidth {
                let cell = SKShapeNode(rectOf: cellSize)
                cell.position = CGPoint(x: xOffset + CGFloat(col) * cellSize.width, y: yOffset + CGFloat(row) * cellSize.height)

                if grid[row][col] == 1 {
                    cell.fillColor = gridColors[row][col]
                } else {
                    cell.fillColor = .clear
                }

                cell.strokeColor = .white
                gridNode.addChild(cell)
            }
        }

        // Render the current piece
        if let piece = currentPiece {
            for row in 0..<piece.shape.count {
                for col in 0..<piece.shape[row].count {
                    if piece.shape[row][col] == 1 {
                        let xPos = xOffset + CGFloat(piece.position.x + col) * cellSize.width
                        let yPos = yOffset + CGFloat(piece.position.y + row) * cellSize.height

                        let block = SKShapeNode(rectOf: cellSize)
                        block.position = CGPoint(x: xPos, y: yPos)
                        block.fillColor = piece.color
                        block.strokeColor = .white
                        gridNode.addChild(block)
                    }
                }
            }
        }
    }

    func renderNextPiece() {
        nextPieceNode.removeAllChildren()

        guard let piece = nextPiece else { return }

        let cellSize = CGSize(width: 20, height: 20)  // Adjust as needed

        // Determine the dimensions of the shape
        let shapeRows = piece.shape.count
        let shapeCols = piece.shape[0].count

        // Calculate the total width and height of the shape
        let shapeWidth = CGFloat(shapeCols) * cellSize.width
        let shapeHeight = CGFloat(shapeRows) * cellSize.height

        // Calculate offsets to center the shape
        let xOffset = -shapeWidth / 2 + cellSize.width / 2
        let yOffset = -shapeHeight / 2 + cellSize.height / 2

        for row in 0..<shapeRows {
            for col in 0..<shapeCols {
                if piece.shape[row][col] == 1 {
                    let block = SKShapeNode(rectOf: cellSize)
                    let xPos = CGFloat(col) * cellSize.width + xOffset
                    let yPos = CGFloat(row) * cellSize.height + yOffset

                    block.position = CGPoint(x: xPos, y: yPos)
                    block.fillColor = piece.color
                    block.strokeColor = .white
                    nextPieceNode.addChild(block)
                }
            }
        }
    }

    func endGame() {
        self.removeAllActions()  // Stop the game loop
        gameOver = true

        // Check if the current score is higher than the high score
        if score > highScore {
            highScore = score

            // Save the new high score to UserDefaults
            UserDefaults.standard.set(highScore, forKey: "HighScore")
            UserDefaults.standard.synchronize()

            // Display a congratulatory message
            let newHighScoreLabel = SKLabelNode(text: "New High Score!")
            newHighScoreLabel.fontSize = 50
            newHighScoreLabel.fontColor = SKColor.yellow
            newHighScoreLabel.fontName = "Helvetica-Bold"
            newHighScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 100)
            newHighScoreLabel.zPosition = 1  // Ensure it's on top of other nodes
            addChild(newHighScoreLabel)
        }

        // Display the "Game Over" message
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 80
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.fontName = "Helvetica-Bold"
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameOverLabel.zPosition = 1  // Ensure it's on top of other nodes
        addChild(gameOverLabel)

        // Update the score label to reflect the new high score
        updateScoreLabel()

        // Add a 2-second delay before enabling the restart gesture
        let wait = SKAction.wait(forDuration: 2.0)
        let enableRestart = SKAction.run { [weak self] in
            self?.enableRestartGesture()
        }
        let sequence = SKAction.sequence([wait, enableRestart])
        run(sequence)
    }

    @objc func restartGame() {
        if gameOver {
            gameOver = false  // Reset the game over flag
            score = 0  // Reset the current score
            updateScoreLabel()  // Update the score label

            createGrid()  // Reset the grid

            removeAllChildren()  // Clear all nodes

            addChild(scoreLabel)  // Add back UI elements
            addChild(nextLabel)  // Add back UI elements
            addChild(nextPieceNode)  // Re-add the nextPieceNode

            // Reinitialize the game
            gridNode = SKNode()
            addChild(gridNode)

            nextPiece = Tetromino.random()  // Initialize the next piece
            spawnPiece()
            startGameLoop()

            // Remove the gesture recognizer after restarting to avoid duplicate triggers
            if let recognizers = view?.gestureRecognizers {
                for recognizer in recognizers {
                    view?.removeGestureRecognizer(recognizer)
                }
            }
        }
    }

    func hardDrop() {
        guard let piece = currentPiece else { return }

        // Keep moving the piece down until a collision is detected
        while !checkCollision() {
            piece.moveDown()
        }

        // Move back up one step to the last valid position
        piece.moveUp()

        // Lock the piece into place
        lockPiece()

        // Spawn a new piece after locking
        spawnPiece()
    }

    func clearCompletedLines() {
        var rowsCleared = 0
        var row = 0  // Start from the bottom row

        while row < gridHeight {
            var isRowComplete = true

            // Check if the current row is completely filled
            for col in 0..<gridWidth {
                if grid[row][col] == 0 {
                    isRowComplete = false
                    break
                }
            }

            if isRowComplete {
                rowsCleared += 1

                // Shift all rows above the current one down by one
                for r in row..<gridHeight - 1 {
                    grid[r] = grid[r + 1]
                    gridColors[r] = gridColors[r + 1]
                }

                // Clear the top row after shifting
                grid[gridHeight - 1] = Array(repeating: 0, count: gridWidth)
                gridColors[gridHeight - 1] = Array(repeating: SKColor.clear, count: gridWidth)

                // Do not increment row to re-check the same row index
            } else {
                row += 1  // Move to the next row up
            }
        }

        // Update the score if any rows were cleared
        if rowsCleared > 0 {
            score += rowsCleared
            updateScoreLabel()
        }
    }

    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)  High Score: \(highScore)"
    }
}
