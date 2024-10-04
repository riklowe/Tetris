//
//  Tetromino.swift
//  Tetris AI
//
//  Created by Richard Lowe on 01/10/2024.
//

import SpriteKit

//
//class Tetromino {
//    var shape: [[Int]]   // The shape of the Tetromino
//    var position: (x: Int, y: Int)  // The position on the grid
//    var color: SKColor    // The color of the Tetromino
//
//    // Custom initializer that accepts a shape and color
//    init(shape: [[Int]], position: (x: Int, y: Int), color: SKColor) {
//        self.shape = shape
//        self.position = position
//        self.color = color
//    }
//
//    // Moves the Tetromino down by decreasing the y coordinate
//    func moveDown() { position.y -= 1 }
//
//    // Moves the Tetromino up by increasing the y coordinate
//    func moveUp() { position.y += 1 }
//
//    // Moves the Tetromino left
//    func moveLeft() { position.x -= 1 }
//
//    // Moves the Tetromino right
//    func moveRight() { position.x += 1 }
//
//    // Rotates the Tetromino shape clockwise
//    func rotate() {
//        let rowCount = shape.count
//        let colCount = shape[0].count
//
//        var newShape = Array(repeating: Array(repeating: 0, count: rowCount), count: colCount)
//
//        for i in 0..<rowCount {
//            for j in 0..<colCount {
//                newShape[j][rowCount - 1 - i] = shape[i][j]
//            }
//        }
//
//        shape = newShape
//    }
//
//
//    // Static function to return a random Tetromino with a random color
//    static func random() -> Tetromino {
//        let shapes = [
//            [[1, 1, 1, 1]],           // I piece
//            [[1, 1], [1, 1]],         // O piece
//            [[0, 1, 0], [1, 1, 1]],   // T piece
//            [[1, 1, 0], [0, 1, 1]],   // Z piece
//            [[0, 1, 1], [1, 1, 0]],   // S piece
//            [[1, 1, 1], [1, 0, 0]],   // L piece
//            [[1, 1, 1], [0, 0, 1]]    // J piece
//        ]
//
//        let colors = [
//            SKColor.red, SKColor.blue, SKColor.green, SKColor.yellow, SKColor.orange, SKColor.purple
//        ]
//
//        let randomShape = shapes[Int.random(in: 0..<shapes.count)]
//        let randomColor = colors.randomElement()!
//        return Tetromino(shape: randomShape, position: (x: 4, y: 20), color: randomColor)
//    }
//}

// Tetromino class representing the Tetris pieces
class Tetromino {
    var shape: [[Int]]
    var color: SKColor
    var position: (x: Int, y: Int)

    init(shape: [[Int]], color: SKColor) {
        self.shape = shape
        self.color = color
        self.position = (x: 0, y: 0)
    }

    func moveLeft() {
        position.x -= 1
    }

    func moveRight() {
        position.x += 1
    }

    func moveDown() {
        position.y -= 1
    }

    func moveUp() {
        position.y += 1
    }

    //    func rotate() {
    //        // Rotate the shape matrix clockwise
    //        let n = shape.count
    //        var rotatedShape = Array(repeating: Array(repeating: 0, count: n), count: n)
    //        for i in 0..<n {
    //            for j in 0..<n {
    //                rotatedShape[j][n - i - 1] = shape[i][j]
    //            }
    //        }
    //        shape = rotatedShape
    //    }

    func rotate() {
        let numRows = shape.count
        let numCols = shape[0].count

        var rotatedShape = Array(repeating: Array(repeating: 0, count: numRows), count: numCols)

        for i in 0..<numRows {
            for j in 0..<numCols {
                rotatedShape[j][numRows - i - 1] = shape[i][j]
            }
        }

        shape = rotatedShape
    }

    func adjustPositionAfterRotation(gridWidth: Int) {
        // Adjust horizontally
        if position.x < 0 {
            position.x = 0
        } else if position.x + shape[0].count > gridWidth {
            position.x = gridWidth - shape[0].count
        }
    }

    static func random() -> Tetromino {
        // Define possible shapes and their corresponding colors
        let shapes = [
            ([[1, 1    , 1, 1]], SKColor.cyan),                     // I-shape
            ([[1, 1]   ,[1, 1]], SKColor.yellow),                   // O-shape
            ([[0, 1, 0],[1, 1, 1]], SKColor.purple),                // T-shape
            ([[1, 0, 0],[1, 1, 1]], SKColor.orange),                // L-shape
            ([[0, 0, 1],[1, 1, 1]], SKColor.blue),                  // J-shape
            ([[0, 1, 1],[1, 1, 0]], SKColor.green),                 // S-shape
            ([[1, 1, 0],[0, 1, 1]], SKColor.red)                    // Z-shape
        ]

        let index = Int(arc4random_uniform(UInt32(shapes.count)))
        let (shape, color) = shapes[index]
        return Tetromino(shape: shape, color: color)
    }

}
