import SpriteKit
import SwiftUI

protocol GameSceneDelegate: AnyObject {
    func didCollectCoin()
    func didCollectAmulet()
    func didHitObstacle()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Constants
    
    private enum PhysicsCategory {
        static let none: UInt32 = 0
        static let player: UInt32 = 0x1 << 0
        static let obstacle: UInt32 = 0x1 << 1
        static let coin: UInt32 = 0x1 << 2
        static let amulet: UInt32 = 0x1 << 3
    }
    
    // MARK: - Properties
    
    weak var gameDelegate: GameSceneDelegate?
    private var player: SKSpriteNode?
    private var isGameActive = false
    private var objectsSpawnTimer: Timer?
    
    // Добавляем свойства для хранения ID скина и фона
    private var skinId: String
    private var backgroundId: String
    private var level: Int
    
    // Размеры
    private let playerWidth: CGFloat = GameConstants.playerSize.width
    private let playerHeight: CGFloat = GameConstants.playerSize.height
    
    // MARK: - Инициализация
    
    init(size: CGSize, level: Int, backgroundId: String, skinId: String) {
        self.level = level
        self.backgroundId = backgroundId
        self.skinId = skinId
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.level = 1
        self.backgroundId = "medieval_castle"
        self.skinId = "king_default"
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupBackground()
        setupPhysics()
        setupPlayer()
        
        isGameActive = true
        startSpawningObjects()
    }
    
    // MARK: - Setup
    
    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -GameConstants.gravity)
        physicsWorld.contactDelegate = self
    }
    
    private func setupBackground() {
        let backgroundImageName = BackgroundItem.getBackground(id: backgroundId).imageName
        let background = SKSpriteNode(imageNamed: backgroundImageName)
        
        let scaleX = frame.width / background.size.width
        let scaleY = frame.height / background.size.height
        let scale = max(scaleX, scaleY)
        background.setScale(scale)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -100
        
        addChild(background)
    }
    
    private func setupPlayer() {
        let playerImageName = PlayerSkinItem.getSkin(id: skinId).imageName
        player = SKSpriteNode(imageNamed: playerImageName)
        
        guard let player = player else { return }
        
        player.size = CGSize(width: playerWidth, height: playerHeight)
        let playerY = frame.height * (1.0 - GameConstants.playerVerticalPosition)
        player.position = CGPoint(x: frame.midX, y: playerY)
        player.zPosition = 10
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(
            width: player.size.width * GameConstants.playerPhysicsBodyScale,
            height: player.size.height * GameConstants.playerPhysicsBodyScale
        ))
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.coin | PhysicsCategory.amulet
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(player)
    }
    
    // MARK: - Game Control
    
    func resetGame() {
        removeAllObjects()
        isPaused = false
        isGameActive = true
        
        // Отменяем все текущие таймеры
        objectsSpawnTimer?.invalidate()
        
        // Запускаем новые таймеры
        startSpawningObjects()
    }
    
    func pauseGame() {
        isGameActive = false
        objectsSpawnTimer?.invalidate()
        
        // Останавливаем все движущиеся объекты
        self.isPaused = true
    }
    
    func resumeGame() {
        isGameActive = true
        self.isPaused = false
        startSpawningObjects()
    }
    
    private func startSpawningObjects() {
        objectsSpawnTimer?.invalidate()
        
        let spawnInterval = GameConstants.spawnInterval(for: level)
        objectsSpawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            self.spawnObject()
        }
    }
    
    private func spawnObject() {
        let objectType = FallingObjectType.random()
        
        let object = SKSpriteNode(imageNamed: objectType.imageName)
        object.size = objectType.size
        
        // Случайная позиция по X с отступами от краев
        let minX = GameConstants.objectSpawnMinX + object.size.width/2
        let maxX = size.width - GameConstants.objectSpawnMaxX - object.size.width/2
        let randomX = CGFloat.random(in: minX...maxX)
        
        object.position = CGPoint(x: randomX, y: size.height + object.size.height)
        object.zPosition = 5
        
        // Физика
        object.physicsBody = SKPhysicsBody(rectangleOf: object.size)
        object.physicsBody?.affectedByGravity = false
        object.physicsBody?.allowsRotation = false
        
        // Устанавливаем категорию в зависимости от типа объекта
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
        
        addChild(object)
        
        // Анимация падения
        let fallSpeed = GameConstants.objectFallSpeed(for: level)
        let fallDistance = size.height + object.size.height * 2
        let fallDuration = TimeInterval(fallDistance / fallSpeed)
        
        let fallAction = SKAction.moveBy(x: 0, y: -fallDistance, duration: fallDuration)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fallAction, removeAction])
        
        object.run(sequence)
    }
    
    private func addCoinAnimation(to node: SKSpriteNode) {
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: GameConstants.coinRotationDuration)
        let repeatAction = SKAction.repeatForever(rotateAction)
        node.run(repeatAction)
    }
    
    private func addAmuletAnimation(to node: SKSpriteNode) {
        let scaleUp = SKAction.scale(to: 1.2, duration: GameConstants.amuletGlowDuration / 2)
        let scaleDown = SKAction.scale(to: 0.8, duration: GameConstants.amuletGlowDuration / 2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
    }
    
    private func removeAllObjects() {
        self.enumerateChildNodes(withName: "//*") { node, _ in
            if node.physicsBody?.categoryBitMask == PhysicsCategory.obstacle ||
               node.physicsBody?.categoryBitMask == PhysicsCategory.coin ||
               node.physicsBody?.categoryBitMask == PhysicsCategory.amulet {
                node.removeFromParent()
            }
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            movePlayer(to: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            movePlayer(to: location)
        }
    }
    
    private func movePlayer(to location: CGPoint) {
        guard let player = player, isGameActive else { return }
        
        // Ограничение по краям экрана
        let minX = player.size.width / 2
        let maxX = size.width - player.size.width / 2
        let newX = min(maxX, max(minX, location.x))
        
        // Плавное перемещение
        let moveAction = SKAction.moveTo(x: newX, duration: 0.1)
        player.run(moveAction)
    }
    
    // MARK: - Collision Handling
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.coin) ||
            (bodyA.categoryBitMask == PhysicsCategory.coin && bodyB.categoryBitMask == PhysicsCategory.player) {
            // Столкновение игрока и монеты
            let coinBody = bodyA.categoryBitMask == PhysicsCategory.coin ? bodyA : bodyB
            handleCoinCollection(coinBody.node)
        } else if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.amulet) ||
                    (bodyA.categoryBitMask == PhysicsCategory.amulet && bodyB.categoryBitMask == PhysicsCategory.player) {
            // Столкновение игрока и амулета
            let amuletBody = bodyA.categoryBitMask == PhysicsCategory.amulet ? bodyA : bodyB
            handleAmuletCollection(amuletBody.node)
        } else if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.obstacle) ||
                    (bodyA.categoryBitMask == PhysicsCategory.obstacle && bodyB.categoryBitMask == PhysicsCategory.player) {
            // Столкновение игрока и препятствия
            let obstacleBody = bodyA.categoryBitMask == PhysicsCategory.obstacle ? bodyA : bodyB
            handleObstacleHit(obstacleBody.node)
        }
    }
    
    private func handleCoinCollection(_ node: SKNode?) {
        guard isGameActive else { return }
        
        gameDelegate?.didCollectCoin()
        
        // Добавляем эффект сбора
        showCollectionEffect(at: node?.position ?? .zero, isSuccess: true)
        
        // Удаляем монету
        node?.removeFromParent()
    }
    
    private func handleAmuletCollection(_ node: SKNode?) {
        guard isGameActive else { return }
        
        gameDelegate?.didCollectAmulet()
        
        // Добавляем эффект сбора
        showCollectionEffect(at: node?.position ?? .zero, isSuccess: true, isAmulet: true)
        
        // Удаляем амулет
        node?.removeFromParent()
    }
    
    private func handleObstacleHit(_ node: SKNode?) {
        guard isGameActive else { return }
        
        gameDelegate?.didHitObstacle()
        
        // Добавляем эффект попадания и мигание игрока
        showCollectionEffect(at: node?.position ?? .zero, isSuccess: false)
        flashPlayer()
        
        // Удаляем препятствие
        node?.removeFromParent()
    }
    
    private func flashPlayer() {
        guard let player = player else { return }
        
        // Убираем предыдущую анимацию мигания если есть
        player.removeAction(forKey: "flash")
        
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: GameConstants.playerFlashDuration)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: GameConstants.playerFlashDuration)
        let flashSequence = SKAction.sequence([fadeOut, fadeIn])
        let repeatFlash = SKAction.repeat(flashSequence, count: GameConstants.playerFlashCount)
        
        player.run(repeatFlash, withKey: "flash")
    }
    
    private func showCollectionEffect(at position: CGPoint, isSuccess: Bool, isAmulet: Bool = false) {
        // Создаем эмиттер частиц для эффекта
        let emitterName = isAmulet ? "AmuletEffect" : (isSuccess ? "CoinCollectEffect" : "ObstacleHitEffect")
        let emitter = createParticleEffect(named: emitterName, at: position)
        addChild(emitter)
        
        // Автоматически убираем через небольшое время
        let wait = SKAction.wait(forDuration: 0.7)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
    
    private func createParticleEffect(named: String, at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position
        
        // Создаем простую частицу
        let particleNode = SKShapeNode(circleOfRadius: 3)
        particleNode.fillColor = .white
        particleNode.strokeColor = .clear
        
        emitter.particleTexture = SKView().texture(from: particleNode)
        
        switch named {
        case "CoinCollectEffect":
            emitter.particleBirthRate = 100
            emitter.numParticlesToEmit = 30
            emitter.particleLifetime = 0.5
            emitter.particleSpeed = 100
            emitter.particleSpeedRange = 50
            emitter.emissionAngle = 0
            emitter.emissionAngleRange = CGFloat.pi * 2
            emitter.particleAlpha = 0.8
            emitter.particleAlphaRange = 0.2
            emitter.particleAlphaSpeed = -1.0
            emitter.particleScale = 0.2
            emitter.particleScaleRange = 0.1
            emitter.particleColor = .green
            
        case "ObstacleHitEffect":
            emitter.particleBirthRate = 80
            emitter.numParticlesToEmit = 20
            emitter.particleLifetime = 0.3
            emitter.particleSpeed = 80
            emitter.particleSpeedRange = 40
            emitter.emissionAngle = CGFloat.pi * 1.5
            emitter.emissionAngleRange = CGFloat.pi / 2
            emitter.particleAlpha = 0.8
            emitter.particleAlphaRange = 0.2
            emitter.particleAlphaSpeed = -2.0
            emitter.particleScale = 0.2
            emitter.particleScaleRange = 0.1
            emitter.particleColor = .red
            
        case "AmuletEffect":
            emitter.particleBirthRate = 150
            emitter.numParticlesToEmit = 50
            emitter.particleLifetime = 0.7
            emitter.particleSpeed = 120
            emitter.particleSpeedRange = 60
            emitter.emissionAngle = 0
            emitter.emissionAngleRange = CGFloat.pi * 2
            emitter.particleAlpha = 1.0
            emitter.particleAlphaRange = 0.2
            emitter.particleAlphaSpeed = -1.0
            emitter.particleScale = 0.3
            emitter.particleScaleRange = 0.1
            emitter.particleColor = .purple
            
        default:
            break
        }
        
        return emitter
    }
}
