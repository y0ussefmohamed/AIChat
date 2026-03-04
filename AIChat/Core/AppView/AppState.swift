//
//  AppState.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import Foundation
import SwiftUI

@Observable
class AppState { /// holds variable for showTabBar across the whole app
    private(set) var showTabBar: Bool {
        didSet { /// before `=` (When it's getting changed)
            UserDefaults.showTabbarView = showTabBar /// every time we set this we save it to `UserDefaults`
        }
    }

    init(showTabBar: Bool = UserDefaults.showTabbarView) {
        self.showTabBar = showTabBar
    }

    func updateViewState(showTabBar: Bool) {
        self.showTabBar = showTabBar
    }
}

extension UserDefaults {
    private struct Keys {
        static let showTabbarView = "showTabbarView"
    }

    static var showTabbarView: Bool {
        get { /// after `=` (being accessed)
            standard.bool(forKey: Keys.showTabbarView)
        }
        set { /// before `=`
            standard.set(newValue, forKey: Keys.showTabbarView)
        }
    }
}
