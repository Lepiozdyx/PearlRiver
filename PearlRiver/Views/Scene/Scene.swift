import SpriteKit
import SwiftUI

// MARK: - Physics Categories
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0      // 1
    static let obstacle: UInt32 = 0x1 << 1    // 2
    static let coin: UInt32 = 0x1 << 2        // 4
    static let amulet: UInt32 = 0x1 << 3      // 8
    static let boundary: UInt32 = 0x1 << 4    // 16
}

// MARK: - Game Scene Delegate
protocol GameSceneDelegate: AnyObject {
    func didCollectCoin()
    func didCollectAmulet()
    func didHitObstacle()
}

// MARK: - GameScene
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    weak var gameDelegate: GameSceneDelegate?
    
    // Game nodes
    private var player: SKSpriteNode!
    private var background: SKSpriteNode!
    
    // Objects
    private var fallingObjects: [SKSpriteNode] = []
    
    // Game parameters
    private let level: Int
    private let backgroundId: String
    private let skinId: String
    
    // Timing
    private var lastUpdateTime: TimeInterval = 0
    private var lastSpawnTime: TimeInterval = 0
    
    // Game state
    private var isGamePaused: Bool = false
    
    // Speed calculations
    private var objectFallSpeed: CGFloat
    private var spawnInterval: TimeInterval
    
    // MARK: - Initialization
    init(size: CGSize, level: Int, backgroundId: String, skinId: String) {
        self.level = level
        self.backgroundId = backgroundId
        self.skinId = skinId
        
        // Calculate level-based parameters
        self.objectFallSpeed = GameConstants.objectFallSpeed(for: level)
        self.spawnInterval = GameConstants.spawnInterval(for: level)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        // Setup physics
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        // Setup game elements
        setupBackground()
        setupPlayer()
        setupBoundaries()
        
        // Start game
        startGame()
    }
    
    // MARK: - Setup Methods
    private func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: BackgroundItem.getBackground(id: backgroundId).imageName)
        background = SKSpriteNode(texture: backgroundTexture)
        background.size = size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    private func setupPlayer() {
        let playerTexture = SKTexture(imageNamed: PlayerSkinItem.getSkin(id: skinId).imageName)
        player = SKSpriteNode(texture: playerTexture)
        player.size = GameConstants.playerSize
        
        // Position at bottom center
        let playerX = size.width * GameConstants.playerInitialX
        let playerY = size.height * (1 - GameConstants.playerVerticalPosition)
        player.position = CGPoint(x: playerX, y: playerY)
        
        // Physics body
        let physicsSize = CGSize(
            width: player.size.width * GameConstants.playerPhysicsBodyScale,
            height: player.size.height * GameConstants.playerPhysicsBodyScale
        )
        player.physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.coin | PhysicsCategory.amulet
        player.physicsBody?.collisionBitMask = PhysicsCategory.boundary
        player.physicsBody?.affectedByGravity = false
        
        player.zPosition = 10
        addChild(player)
        
        // Add idle animation
        addIdleAnimation()
    }
    
    private func setupBoundaries() {
        // Left boundary
        let leftBoundary = SKNode()
        leftBoundary.position = CGPoint(x: 0, y: size.height / 2)
        leftBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: size.height))
        leftBoundary.physicsBody?.isDynamic = false
        leftBoundary.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        addChild(leftBoundary)
        
        // Right boundary
        let rightBoundary = SKNode()
        rightBoundary.position = CGPoint(x: size.width, y: size.height / 2)
        rightBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: size.height))
        rightBoundary.physicsBody?.isDynamic = false
        rightBoundary.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        addChild(rightBoundary)
    }
    
    // MARK: - Animations
    private func addIdleAnimation() {
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.95, duration: 1.0)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatForever = SKAction.repeatForever(sequence)
        player.run(repeatForever)
    }
    
    private func flashPlayer() {
        // Remove previous flash if exists
        player.removeAction(forKey: "flash")
        
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: GameConstants.playerFlashDuration)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: GameConstants.playerFlashDuration)
        let flashSequence = SKAction.sequence([fadeOut, fadeIn])
        let repeatFlash = SKAction.repeat(flashSequence, count: GameConstants.playerFlashCount)
        
        player.run(repeatFlash, withKey: "flash")
    }
    
    // MARK: - Game Control
    func startGame() {
        isGamePaused = false
        lastUpdateTime = 0
        lastSpawnTime = 0
    }
    
    func pauseGame() {
        isGamePaused = true
        self.isPaused = true
    }
    
    func resumeGame() {
        if isGamePaused {
            isGamePaused = false
            lastUpdateTime = CACurrentMediaTime()
            self.isPaused = false
        }
    }
    
    func resetGame() {
        // Remove all falling objects
        for object in fallingObjects {
            object.removeFromParent()
        }
        fallingObjects.removeAll()
        
        // Reset player position
        let playerX = size.width * GameConstants.playerInitialX
        let playerY = size.height * (1 - GameConstants.playerVerticalPosition)
        player.position = CGPoint(x: playerX, y: playerY)
        player.alpha = 1.0
        
        // Reset timers
        lastUpdateTime = 0
        lastSpawnTime = 0
        
        // Pause until explicitly resumed
        isGamePaused = true
        self.isPaused = true
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        // Initialize lastUpdateTime
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if isGamePaused {
            return
        }
        
        // Update falling objects
        updateFallingObjects(deltaTime: deltaTime)
        
        // Spawn new objects
        if currentTime - lastSpawnTime > spawnInterval {
            spawnObject()
            lastSpawnTime = currentTime
        }
        
        // Clean up off-screen objects
        cleanupObjects()
    }
    
    private func updateFallingObjects(deltaTime: TimeInterval) {
        for object in fallingObjects {
            object.position.y -= objectFallSpeed * CGFloat(deltaTime)
            
            // Update rotation for coins and amulets
            if let userData = object.userData,
               let typeRawValue = userData["type"] as? Int,
               let type = FallingObjectType(rawValue: typeRawValue) {
                if type == .coin || type == .amulet {
                    object.zRotation += CGFloat(deltaTime) * 2 * .pi
                }
            }
        }
    }
    
    private func spawnObject() {
        let objectType = FallingObjectType.random()
        let texture = SKTexture(imageNamed: objectType.imageName)
        let object = SKSpriteNode(texture: texture)
        
        object.size = objectType.size
        
        // Random X position
        let minX = GameConstants.objectSpawnMinX + object.size.width / 2
        let maxX = size.width - GameConstants.objectSpawnMaxX - object.size.width / 2
        let randomX = CGFloat.random(in: minX...maxX)
        
        // Start above screen
        object.position = CGPoint(x: randomX, y: size.height + object.size.height / 2)
        object.zPosition = 5
        
        // Physics body
        object.physicsBody = SKPhysicsBody(rectangleOf: object.size)
        object.physicsBody?.isDynamic = true
        object.physicsBody?.affectedByGravity = false
        object.physicsBody?.allowsRotation = false
        
        // Set category based on type
        switch objectType {
        case .coin:
            object.physicsBody?.categoryBitMask = PhysicsCategory.coin
            addCoinAnimation(to: object)
        case .amulet:
            object.physicsBody?.categoryBitMask = PhysicsCategory.amulet
            addAmuletAnimation(to: object)
        default:
            object.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        }
        
        object.physicsBody?.contactTestBitMask = PhysicsCategory.player
        object.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Store type in userData
        object.userData = ["type": objectType.rawValue]
        
        addChild(object)
        fallingObjects.append(object)
    }
    
    private func addCoinAnimation(to node: SKSpriteNode) {
        // Add glow effect
        let glow = SKSpriteNode(color: .yellow, size: CGSize(width: node.size.width * 1.5, height: node.size.height * 1.5))
        glow.alpha = 0.3
        glow.zPosition = -1
        glow.blendMode = .add
        node.addChild(glow)
        
        // Pulse animation
        let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.5)
        let pulse = SKAction.sequence([fadeIn, fadeOut])
        glow.run(SKAction.repeatForever(pulse))
    }
    
    private func addAmuletAnimation(to node: SKSpriteNode) {
        // Add purple glow
        let glow = SKSpriteNode(color: .purple, size: CGSize(width: node.size.width * 2, height: node.size.height * 2))
        glow.alpha = 0.4
        glow.zPosition = -1
        glow.blendMode = .add
        node.addChild(glow)
        
        // Sparkle effect
        let scaleUp = SKAction.scale(to: 1.2, duration: GameConstants.amuletGlowDuration / 2)
        let scaleDown = SKAction.scale(to: 0.8, duration: GameConstants.amuletGlowDuration / 2)
        let sparkle = SKAction.sequence([scaleUp, scaleDown])
        glow.run(SKAction.repeatForever(sparkle))
    }
    
    private func cleanupObjects() {
        fallingObjects = fallingObjects.filter { object in
            if object.position.y < -object.size.height {
                object.removeFromParent()
                return false
            }
            return true
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        movePlayer(to: location.x)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        movePlayer(to: location.x)
    }
    
    private func movePlayer(to xPosition: CGFloat) {
        guard !isGamePaused else { return }
        
        // Clamp position within boundaries
        let minX = player.size.width / 2
        let maxX = size.width - player.size.width / 2
        let clampedX = max(minX, min(maxX, xPosition))
        
        // Smooth movement
        let moveAction = SKAction.moveTo(x: clampedX, duration: 0.1)
        player.run(moveAction)
    }
    
    // MARK: - Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.player | PhysicsCategory.coin {
            if let coin = (contact.bodyA.categoryBitMask == PhysicsCategory.coin ? contact.bodyA.node : contact.bodyB.node) as? SKSpriteNode {
                handleCoinCollection(coin)
            }
        } else if collision == PhysicsCategory.player | PhysicsCategory.amulet {
            if let amulet = (contact.bodyA.categoryBitMask == PhysicsCategory.amulet ? contact.bodyA.node : contact.bodyB.node) as? SKSpriteNode {
                handleAmuletCollection(amulet)
            }
        } else if collision == PhysicsCategory.player | PhysicsCategory.obstacle {
            if let obstacle = (contact.bodyA.categoryBitMask == PhysicsCategory.obstacle ? contact.bodyA.node : contact.bodyB.node) as? SKSpriteNode {
                handleObstacleHit(obstacle)
            }
        }
    }
    
    private func handleCoinCollection(_ coin: SKSpriteNode) {
        // Create collection effect
        createCollectionEffect(at: coin.position, color: .yellow)
        
        // Remove coin
        coin.removeFromParent()
        if let index = fallingObjects.firstIndex(of: coin) {
            fallingObjects.remove(at: index)
        }
        
        // Notify delegate
        gameDelegate?.didCollectCoin()
    }
    
    private func handleAmuletCollection(_ amulet: SKSpriteNode) {
        // Create special effect
        createCollectionEffect(at: amulet.position, color: .purple)
        
        // Remove amulet
        amulet.removeFromParent()
        if let index = fallingObjects.firstIndex(of: amulet) {
            fallingObjects.remove(at: index)
        }
        
        // Notify delegate
        gameDelegate?.didCollectAmulet()
    }
    
    private func handleObstacleHit(_ obstacle: SKSpriteNode) {
        // Flash player
        flashPlayer()
        
        // Create hit effect
        createHitEffect(at: player.position)
        
        // Remove obstacle
        obstacle.removeFromParent()
        if let index = fallingObjects.firstIndex(of: obstacle) {
            fallingObjects.remove(at: index)
        }
        
        // Notify delegate
        gameDelegate?.didHitObstacle()
    }
    
    // MARK: - Effects
    private func createCollectionEffect(at position: CGPoint, color: UIColor) {
        let emitter = SKEmitterNode()
        emitter.position = position
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 0.5
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngleRange = .pi * 2
        emitter.particleScale = 0.2
        emitter.particleScaleRange = 0.1
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -1.5
        emitter.zPosition = 15
        
        addChild(emitter)
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ])
        emitter.run(removeAction)
    }
    
    private func createHitEffect(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.position = position
        emitter.particleBirthRate = 50
        emitter.numParticlesToEmit = 10
        emitter.particleLifetime = 0.3
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 40
        emitter.emissionAngleRange = .pi * 2
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.2
        emitter.particleColor = .red
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.7
        emitter.particleAlphaSpeed = -2.0
        emitter.zPosition = 15
        
        addChild(emitter)
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ])
        emitter.run(removeAction)
    }
}
