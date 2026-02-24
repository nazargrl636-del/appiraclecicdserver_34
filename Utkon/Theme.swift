import SwiftUI
import UIKit

// MARK: - Dark Theme Colors

extension Color {
    /// Основной фон приложения — #04072B
    static let darkBackground = Color(red: 4 / 255, green: 7 / 255, blue: 43 / 255)

    /// Поверхность для карточек и ячеек списка — чуть светлее фона
    static let darkSurface = Color(red: 12 / 255, green: 17 / 255, blue: 65 / 255)

    /// Приподнятая поверхность для вложенных элементов
    static let darkElevated = Color(red: 20 / 255, green: 27 / 255, blue: 82 / 255)

    /// Разделительная линия
    static let darkSeparator = Color.white.opacity(0.1)
}

extension UIColor {
    static let darkBackground = UIColor(red: 4 / 255, green: 7 / 255, blue: 43 / 255, alpha: 1)
    static let darkSurface = UIColor(red: 12 / 255, green: 17 / 255, blue: 65 / 255, alpha: 1)
    static let darkElevated = UIColor(red: 20 / 255, green: 27 / 255, blue: 82 / 255, alpha: 1)
}

// MARK: - Theme Configuration

enum Theme {
    static func configure() {
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .darkBackground
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = .systemBlue

        // Tab Bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .darkBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = .systemBlue

        // Table View (List / Form)
        UITableView.appearance().backgroundColor = .darkBackground
        UITableView.appearance().separatorColor = UIColor.white.withAlphaComponent(0.1)

        // TextField
        UITextField.appearance().tintColor = .systemBlue
    }
}
