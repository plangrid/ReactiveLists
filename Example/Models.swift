//
//  PlanGrid
//  https://www.plangrid.com
//  https://medium.com/plangrid-technology
//
//  Documentation
//  https://plangrid.github.io/ReactiveLists
//
//  GitHub
//  https://github.com/plangrid/ReactiveLists
//
//  License
//  Copyright © 2018-present PlanGrid, Inc.
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

import Foundation

struct ToolGroup {
    let name: String
    var tools: [Tool]
}

struct Tool {
    let type: ToolType
    let uuid = UUID()

    static func randomTool() -> Tool {
        let randomNumber = arc4random_uniform((UInt32(ToolType.allValues.count)))
        return Tool(type: ToolType(rawValue: randomNumber)!)
    }
}

enum ToolType: UInt32 {
    case hammer
    case wrench
    case clamp
    case nutBolt
    case crane

    static let allValues: [ToolType] = [.hammer, .wrench, .clamp, .nutBolt, .crane]

    var name: String {
        switch self {
        case .hammer:
            return "Hammer"
        case .wrench:
            return "Wrench"
        case .clamp:
            return "Clamp"
        case .nutBolt:
            return "Bolt"
        case .crane:
            return "Crane"
        }
    }

    var emoji: String {
        switch self {
        case .hammer:
            return "🔨"
        case .wrench:
            return "🔧"
        case .clamp:
            return "🗜️"
        case .nutBolt:
            return "🔩"
        case .crane:
            return "🏗️"
        }

    }
}
