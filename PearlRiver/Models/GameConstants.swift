import SwiftUI

struct GameConstants {
    // MARK: - Общие константы
    static let defaultAnimationDuration: Double = 0.3
    static let currencyAnimationDelay: Double = 0.3
    
    // MARK: - Игровой процесс
    static let gameDuration: TimeInterval = 60.0 // 60 секунд на уровень
    static let playerInitialX: CGFloat = 0.5 // Начальная позиция игрока (в процентах от ширины экрана)
    static let playerVerticalPosition: CGFloat = 0.75 // Позиция игрока по вертикали (90% от низа)
    static let playerSize = CGSize(width: 75, height: 150) // Размер персонажа
    
    // MARK: - Падающие объекты
    static let objectFallBaseSpeed: CGFloat = 100.0 // Базовая скорость падения объектов
    static let objectSpawnInterval: TimeInterval = 1.5 // Интервал появления объектов
    static let objectSpawnMinX: CGFloat = 40 // Минимальный отступ от края экрана
    static let objectSpawnMaxX: CGFloat = 40 // Максимальный отступ от края экрана
    
    // Размеры объектов
    struct ObjectSizes {
        static let shield = CGSize(width: 50, height: 60)
        static let vase = CGSize(width: 40, height: 50)
        static let torch = CGSize(width: 35, height: 60)
        static let coin = CGSize(width: 40, height: 40)
        static let amulet = CGSize(width: 45, height: 45)
    }
    
    // MARK: - Валюта и награды
    static let coinValue: Int = 5 // Награда за сбор монеты
    static let dailyReward: Int = 10 // Ежедневная награда
    static let achievementReward: Int = 10 // Награда за достижение
    
    // MARK: - Бонусная игра (пазл)
    static let puzzleTimerDuration: TimeInterval = 20 // секунд на сборку пазла
    static let puzzleReward: Int = 10 // Награда амулетов за успешную сборку
    static let puzzleGridSize: Int = 3 // Пазл 3x3
    
    // MARK: - Дворец
    static let palaceUpdateInterval: TimeInterval = 86400 // 24 часа в секундах (1 день)
    static let palaceObjectsCount: Int = 5 // Количество объектов во дворце
    
    // MARK: - Магазин
    static let shopItemPrice: Int = 100 // Стоимость предметов в магазине
    static let backgroundsCount: Int = 4 // Количество фонов
    static let skinsCount: Int = 4 // Количество скинов
    
    // MARK: - Уровни
    static let maxLevels: Int = 10 // Всего уровней
    static let levelSpeedMultiplier: CGFloat = 0.15 // Увеличение скорости на каждый уровень
    
    // Расчет скорости для уровня
    static func objectFallSpeed(for level: Int) -> CGFloat {
        return objectFallBaseSpeed + (objectFallBaseSpeed * levelSpeedMultiplier * CGFloat(level - 1))
    }
    
    // Расчет интервала появления для уровня
    static func spawnInterval(for level: Int) -> TimeInterval {
        let reduction = TimeInterval(level - 1) * 0.1
        return max(0.5, objectSpawnInterval - reduction) // Минимум 0.5 секунды
    }
    
    // MARK: - Анимации
    static let coinRotationDuration: TimeInterval = 1.0
    static let amuletGlowDuration: TimeInterval = 1.5
    static let playerFlashDuration: TimeInterval = 0.2
    static let playerFlashCount: Int = 3
    
    // MARK: - Физика
    static let playerPhysicsBodyScale: CGFloat = 0.8 // Масштаб физического тела игрока
    static let gravity: CGFloat = 0 // Гравитация отключена (объекты падают с постоянной скоростью)
}
