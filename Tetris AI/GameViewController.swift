//
//  GameViewController.swift
//  Tetris AI
//
//  Created by Richard Lowe on 01/10/2024.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Create the game scene and present it
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill // Ensures the scene fits the screen
            view.presentScene(scene)

            view.ignoresSiblingOrder = true
            view.showsFPS = true        // Show frames per second for debugging
            view.showsNodeCount = true  // Show number of nodes in the scene
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
