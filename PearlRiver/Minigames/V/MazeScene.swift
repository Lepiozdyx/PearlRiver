import SpriteKit
import UIKit
import SwiftUI

class MazeScene: SKScene {
    private var maze: [[Int]] = []
    private let rows: Int
    private let cols: Int
    
    private var tileSize: CGSize = .zero
    private var mazeOrigin: CGPoint = .zero
    
    private var player: SKSpriteNode!
    private var exitNode: SKSpriteNode!
    
    var isWinHandler: (() -> Void)?

    init(size: CGSize, rows: Int = MazeGameConstants.defaultRows, cols: Int = MazeGameConstants.defaultCols) {
        self.rows = rows
        self.cols = cols
        super.init(size: size)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Ups")
    }

    override func didMove(to view: SKView) {
        maze = generateMaze(rows: rows, cols: cols)
        layoutMazeArea()
        drawMaze()
        setupPlayer()
        setupExit()
    }

    private func layoutMazeArea() {
        let gridRows = maze.count
        let gridCols = maze[0].count
        
        let cellSize = min(
            size.width / CGFloat(gridCols),
            size.height / CGFloat(gridRows)
        )
        
        tileSize = CGSize(width: cellSize, height: cellSize)
        
        let totalWidth = CGFloat(gridCols) * cellSize
        let totalHeight = CGFloat(gridRows) * cellSize
        
        mazeOrigin = CGPoint(
            x: (size.width - totalWidth) / 2,
            y: (size.height - totalHeight) / 2
        )
        
        let mazeArea = SKShapeNode(rect: CGRect(
            x: mazeOrigin.x,
            y: mazeOrigin.y,
            width: totalWidth,
            height: totalHeight
        ))
        mazeArea.strokeColor = .blue
        mazeArea.lineWidth = 1
        addChild(mazeArea)
    }

    private func generateMaze(rows: Int, cols: Int) -> [[Int]] {
        let gridRows = rows * 2 + 1
        let gridCols = cols * 2 + 1
        var grid = Array(repeating: Array(repeating: 1, count: gridCols), count: gridRows)
        
        func carve(r: Int, c: Int) {
            grid[r*2 + 1][c*2 + 1] = 0
            for (dr, dc) in [(0,1),(1,0),(0,-1),(-1,0)].shuffled() {
                let nr = r + dr, nc = c + dc
                if nr >= 0, nr < rows, nc >= 0, nc < cols,
                   grid[nr*2 + 1][nc*2 + 1] == 1 {
                    grid[r*2 + 1 + dr][c*2 + 1 + dc] = 0
                    carve(r: nr, c: nc)
                }
            }
        }
        
        carve(r: 0, c: 0)
        grid[gridRows - 2][gridCols - 2] = 2
        return grid
    }

    private func drawMaze() {
        let gridRows = maze.count
        let gridCols = maze[0].count
        
        for r in 0..<gridRows {
            for c in 0..<gridCols {
                let x = mazeOrigin.x + CGFloat(c) * tileSize.width
                let y = mazeOrigin.y + CGFloat(gridRows - r - 1) * tileSize.height
                
                if maze[r][c] == 1 {
                    let wall = SKSpriteNode(color: .white, size: tileSize)
                    wall.position = CGPoint(x: x + tileSize.width/2, y: y + tileSize.height/2)
                    addChild(wall)
                } else {
                    let path = SKShapeNode(rect: CGRect(
                        x: x, y: y,
                        width: tileSize.width,
                        height: tileSize.height
                    ))
                    path.strokeColor = .darkGray
                    path.lineWidth = 0.5
                    path.fillColor = .black
                    path.alpha = 0.2
                    addChild(path)
                }
            }
        }
    }

    private func setupPlayer() {
        let startRow = 1, startCol = 1
        let pos = positionForCell(row: startRow, col: startCol)
        
        let texture = SKTexture(imageNamed: "player_king")
        player = SKSpriteNode(texture: texture, size: tileSize)
        player.position = pos
        addChild(player)
    }

    private func setupExit() {
        let gridRows = maze.count
        let gridCols = maze[0].count
        
        for r in 0..<gridRows {
            for c in 0..<gridCols where maze[r][c] == 2 {
                let pos = positionForCell(row: r, col: c)
                
                let texture = SKTexture(imageNamed: "coin")
                exitNode = SKSpriteNode(texture: texture, size: tileSize)
                exitNode.color = .yellow
                exitNode.colorBlendFactor = 0.5
                exitNode.position = pos
                
                let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0)
                let rotateForever = SKAction.repeatForever(rotateAction)
                exitNode.run(rotateForever)
                
                addChild(exitNode)
                return
            }
        }
    }

    private func positionForCell(row: Int, col: Int) -> CGPoint {
        let x = mazeOrigin.x + CGFloat(col) * tileSize.width + tileSize.width/2
        let y = mazeOrigin.y + CGFloat(maze.count - row - 1) * tileSize.height + tileSize.height/2
        return CGPoint(x: x, y: y)
    }

    private func moveBy(dx: CGFloat, dy: CGFloat) {
        let newPos = CGPoint(x: player.position.x + dx, y: player.position.y + dy)
        let col = Int((newPos.x - mazeOrigin.x) / tileSize.width)
        let rowIndex = Int((newPos.y - mazeOrigin.y) / tileSize.height)
        let row = maze.count - rowIndex - 1
        
        guard row >= 0, row < maze.count, col >= 0, col < maze[0].count, maze[row][col] != 1 else {
            return
        }
        
        let move = SKAction.move(to: newPos, duration: 0.1)
        player.run(move) {
            if self.maze[row][col] == 2 {
                self.isWinHandler?()
            }
        }
    }
    
    func moveUp() {
        moveBy(dx: 0, dy: tileSize.height)
    }
    
    func moveDown() {
        moveBy(dx: 0, dy: -tileSize.height)
    }
    
    func moveLeft() {
        moveBy(dx: -tileSize.width, dy: 0)
    }
    
    func moveRight() {
        moveBy(dx: tileSize.width, dy: 0)
    }
    
    func restartGame() {
        removeAllChildren()
        maze = generateMaze(rows: rows, cols: cols)
        layoutMazeArea()
        drawMaze()
        setupPlayer()
        setupExit()
    }
}

class MazeSceneController: ObservableObject {
    var scene: MazeScene?
    
    func moveUp() {
        scene?.moveUp()
    }
    
    func moveDown() {
        scene?.moveDown()
    }
    
    func moveLeft() {
        scene?.moveLeft()
    }
    
    func moveRight() {
        scene?.moveRight()
    }
    
    func restartGame() {
        scene?.restartGame()
    }
}
