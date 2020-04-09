//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import UIKit

struct SceneData {

    static func makeBackground(id: String) -> Object {

        let background = Object()
        background.name = ObjectData.makeNameProperty(text: "background")
        background.order = 0
        background.sceneId = id

        return background
    }

    static func makeNameProperty(text: String) -> Property {

        return Property(name: "name",
                        info: Texts.sceneName,
                        text: text)
    }

    static func makeDurationProperty(selected: Int) -> Property {
        return Property(name: "duration",
                        info: Texts.sceneDuration,
                        propertyType: .sceneDuration,
                        unitType: .decimal,
                        fixedValues: FixedDuration.allCases.map { $0.name },
                        selectedValue: selected)
    }

    static func makeNumberOfLayersProperty(selected: Int) -> Property {
        return Property(name: "numberOfLayers",
                        info: Texts.numberOfLayers,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: FixedNumberOfLayers.allCases.map { $0.name },
                        selectedValue: selected)
    }

    static func makeContinuousResolutionProperty(selected: Int) -> Property {
        return Property(name: "continuousResolution",
                        info: Texts.continuousResolution,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: FixedContinuousResolution.allCases.map { $0.name },
                        selectedValue: selected)
    }

    static func makeResponseProperty(selected: Int) -> Property {
        return Property(name: "response",
                        info: Texts.sceneResponse,
                        propertyType: .response,
                        unitType: .decimal,
                        fixedValues: FixedResponse.allCases.map { $0.name },
                        selectedValue: selected)
    }

    static func addPropertiesToOriginResponse(property: Property) {

        property.properties = []

        guard let selected = FixedOrigin2d(rawValue: property.string) else { return }
        switch selected {
        case .center:
            break
        case .cartesian:
            let propertyX = Property(name: property.name + "X",
                                     info: "Horizontal position.",
                                     propertyType: .simpleFloat,
                                     unitType: .size,
                                     float: property.float)

            let propertyY = Property(name: property.name + "Y",
                                     info: "Vertical position.",
                                     propertyType: .simpleFloat,
                                     unitType: .size,
                                     float: property.float)

            property.properties.append(propertyX)
            property.properties.append(propertyY)
        case .polar:
            let propertyRadius = Property(name: property.name + "Radius",
                                          info: "Radius position.",
                                          propertyType: .timeFloat,
                                          unitType: .size,
                                          float: property.float)

            let propertyAngle = Property(name: property.name + "Angle",
                                         info: "Angle position.",
                                         propertyType: .timeFloat,
                                         unitType: .angle,
                                         float: property.float)

            property.properties.append(propertyRadius)
            property.properties.append(propertyAngle)
        }
    }

    static func addPropertiesToPositionResponse(property: Property) {

        property.properties = []

        guard let selected = FixedPositionResponse(rawValue: property.string) else { return }
        switch selected {
        case .cartesian:
            let propertyX = Property(name: property.name + "X",
                                     info: "Horizontal position.",
                                     propertyType: .select,
                                     unitType: .decimal,
                                     fixedValues: UnitType.size.possibleUnits.map({ $0.name }),
                                     selectedValue: 0)
            let propertyY = Property(name: property.name + "Y",
                                     info: "Vertical position.",
                                     propertyType: .select,
                                     unitType: .decimal,
                                     fixedValues: UnitType.size.possibleUnits.map({ $0.name }),
                                     selectedValue: 0)
            property.properties.append(propertyX)
            property.properties.append(propertyY)
        case .polar:
            let propertyRadius = Property(name: property.name + "Radius",
                                          info: "Radius position.",
                                          propertyType: .select,
                                          unitType: .decimal,
                                          fixedValues: UnitType.size.possibleUnits.map({ $0.name }),
                                          selectedValue: 0)
            let propertyAngle = Property(name: property.name + "Angle",
                                         info: "Angle position.",
                                         propertyType: .select,
                                         unitType: .decimal,
                                         fixedValues: UnitType.angle.possibleUnits.map({ $0.name }),
                                         selectedValue: 0)
            property.properties.append(propertyRadius)
            property.properties.append(propertyAngle)
        }
    }

    static func addPropertiesToResponse(property: Property) {

        property.properties = []

        let startTime = Property(name: "startTime",
                                 info: """
                                 Time from which it is possible to respond.
                                 By default it is zero, the user can respond at any time.
                                 """,
                                 propertyType: .simpleFloat,
                                 unitType: .time,
                                 float: 0)

        let leftValue = Property(name: "leftValue",
                                 info: "Numeric value for the left response.",
                                 propertyType: .simpleFloat,
                                 unitType: .decimal,
                                 float: 0)

        let rightValue = Property(name: "rightValue",
                                  info: "Numeric value for the right response.",
                                  propertyType: .simpleFloat,
                                  unitType: .decimal,
                                  float: 1)

        let topValue = Property(name: "topValue",
                                info: "Numeric value for the top response.",
                                propertyType: .simpleFloat,
                                unitType: .decimal,
                                float: 1)

        let bottomValue = Property(name: "bottomValue",
                                   info: "Numeric value for the bottom response.",
                                   propertyType: .simpleFloat,
                                   unitType: .decimal,
                                   float: 0)

        let keyboardType = Property(name: "keyboardType",
                                    info: """
                                    Default and numeric keyboards let you give a response when the scene ends.
                                    If your are using a device wiht a hardware keyboard you can also use simple keys \
                                    to give a response at any time just by pressing a key that you previously \
                                    have linked to certain value.
                                    """,
                                    propertyType: .select,
                                    unitType: .decimal,
                                    fixedValues: FixedKeyboard.allCases.map({ $0.name }),
                                    selectedValue: 0)

        let responseInTitle = Property(name: "responseInTitle",
                                       info: """
                                       When the results report is generated, we can make the value of the keyboard \
                                       response appear in the section title.
                                       For example, if we request a participant name or code, it may be helpful to \
                                       have that code in the title of the corresponding section of the result to \
                                       easily identify the participant.
                                       """,
                                       propertyType: .select,
                                       unitType: .decimal,
                                       fixedValues: FixedResponseInTitle.allCases.map({ $0.name }),
                                       selectedValue: 0)

        let endPath = Property(name: "endPath",
                               info: """
                               Lift: the response path ends when the participant lifts their finger from the screen.

                               Touch object: the response path ends when the participant touches any object other \
                               than the moving object.
                               """,
                               propertyType: .select,
                               unitType: .decimal,
                               fixedValues: FixedEndPath.allCases.map({ $0.name }),
                               selectedValue: 0)

        let origin = Property(name: "originCoordinates",
                              info: """
                              By default, the center of the screen is the origin of coordinates but you can change \
                              the origin so that it is in any other point.
                              """,
                              propertyType: .originResponse,
                              unitType: .decimal,
                              fixedValues: FixedOrigin2d.allCases.map({ $0.name }),
                              selectedValue: 0)

        let position = Property(name: "position",
                                info: """
                                The response position, measured in cartesian or polar variables.
                                """,
                                propertyType: .positionResponse,
                                unitType: .decimal,
                                fixedValues: FixedPositionResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key1 = Property(name: "key1",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key2 = Property(name: "key2",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key3 = Property(name: "key3",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key4 = Property(name: "key4",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key5 = Property(name: "key5",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key6 = Property(name: "key6",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key7 = Property(name: "key7",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key8 = Property(name: "key8",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key9 = Property(name: "key9",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        let key10 = Property(name: "key10",
                                info: "The key that triggers the response.",
                                propertyType: .keyResponse,
                                unitType: .decimal,
                                fixedValues: FixedKeyResponse.allCases.map({ $0.name }),
                                selectedValue: 0)

        guard let selected = FixedResponse(rawValue: property.string) else { return }
        switch selected {
        case .none:
            break
        case .leftRight:
            property.properties.append(startTime)
            property.properties.append(leftValue)
            property.properties.append(rightValue)
        case .topBottom:
            property.properties.append(startTime)
            property.properties.append(topValue)
            property.properties.append(bottomValue)
        case .touch:
            property.properties.append(startTime)
            property.properties.append(origin)
            property.properties.append(position)
        case .path:
            property.properties.append(startTime)
            property.properties.append(origin)
            property.properties.append(position)
        case .touchObject:
            property.properties.append(startTime)
            let backgroundProperty = makePropertyToAddToResponse(object: nil)
            property.properties.append(backgroundProperty)
            for object in Flow.shared.scene.movableObjects {
                let newProperty = makePropertyToAddToResponse(object: object)
                property.properties.append(newProperty)
            }
        case .moveObject:
            property.properties.append(startTime)
            property.properties.append(origin)
            property.properties.append(position)
            property.properties.append(endPath)
            for object in Flow.shared.scene.movableObjects {
                let newProperty = makePropertyToAddToResponse(object: object)
                property.properties.append(newProperty)
            }
        case .keyboard:
            property.properties.append(keyboardType)
            property.properties.append(responseInTitle)
        case .keys:
            property.properties.append(key1)
            property.properties.append(key2)
            property.properties.append(key3)
            property.properties.append(key4)
            property.properties.append(key5)
            property.properties.append(key6)
            property.properties.append(key7)
            property.properties.append(key8)
            property.properties.append(key9)
            property.properties.append(key10)
        }
    }

    static func makePropertyToAddToResponse(object: Object?) -> Property {
        let newProperty = Property(name: "background",
                                   info: "To establish whether the background is interactive or not.",
                                   propertyType: .objectResponse,
                                   unitType: .decimal,
                                   fixedValues: FixedObjectResponse.allCases.map({ $0.name }),
                                   selectedValue: 0)
        if let object = object {
            newProperty.name = object.id
            newProperty.somethingId = object.id
            newProperty.info = "To establish whether the object is interactive or not."
        }

        return newProperty
    }

    static func addPropertiesToSceneDuration(property: Property) {

        property.properties = []

        let duration = Property(name: "durationValue",
                                 info: Texts.durationValue,
                                 propertyType: .simpleFloat,
                                 unitType: .time,
                                 float: 100)

        guard let selected = FixedDuration(rawValue: property.string) else { return }
        switch selected {
        case .constant:
            property.properties.append(duration)
        case .stimuli:
            break
        }
    }

    static func addPropertiesToObjectResponse(property: Property) {

        property.properties = []

        let name = property.name == "background" ? "backgroundValue" : "Value"

        let objectResponse = Property(name: name,
                                      info: "The value associated with this object.",
                                      propertyType: .simpleFloat,
                                      unitType: .decimal,
                                      float: 0)
        objectResponse.somethingId = property.somethingId

        guard let selected = FixedObjectResponse(rawValue: property.string) else { return }
        switch selected {
        case .yes:
            property.properties.append(objectResponse)
        case .no:
            break
        }
    }

    static func addPropertiesToKeyResponse(property: Property) {

        property.properties = []

        let key = Property(name: "Key",
                           info: "Key.",
                           propertyType: .key,
                           unitType: .decimal,
                           float: 0)

        let keyResponse = Property(name: "Value",
                                   info: "The value associated with this key.",
                                   propertyType: .simpleFloat,
                                   unitType: .decimal,
                                   float: 0)

        guard let selected = FixedKeyResponse(rawValue: property.string) else { return }
        switch selected {
        case .inactive:
            break
        case .spaceBar, .left, .right, .up, .down:
            property.properties.append(keyResponse)
        case .other:
            property.properties.append(key)
            property.properties.append(keyResponse)
        }
    }
}

//do not change the names without checking the comment fixedNames
enum FixedResponse: String, Codable, CaseIterable {

    case none = "none"
    case leftRight = "left or right"
    case topBottom = "top or bottom"
    case touch = "touch screen"
    case path = "path"
    case touchObject = "touch object"
    case moveObject = "move object"
    case keyboard = "keyboard"
    case keys = "keys"

    var description: String {
        switch self {
        case .none: return "The user can not interact with the screen in this scene."
        case .leftRight: return """
            Any touch on the 1/3 left part of the screen is considered a left response.
            Any touch on the 1/3 right part of the screen is considered a right response.
            Any touch on the 1/3 central part of the screen is ignored.
            """
        case .topBottom: return """
            Any touch on the 1/3 top part of the screen is considered a top response.
            Any touch on the 1/3 bottom part of the screen is considered a bottom response.
            Any touch on the 1/3 central part of the screen is ignored.
            """

        case .touch: return """
            Any touch on the screen is considered a response and the position (x, y) or (radius, angle) is saved.
            """

        case .path: return """
            Any touch on the screen initiates a path that ends when the finger is lifted from the screen.
            The path is saved as (x, y) or (radius, angle).
            """
        case .touchObject: return """
            Touching certain objects of the screen can be considered a response with certain numeric value associated.
            """
        case .moveObject: return """
            Move an existing object by touching it.
            """
        case .keyboard: return """
            When the scene ends, a keyboard appears on the screen and the user can type the response.
            """
        case .keys: return """
            If a hardware keyboard is available, it is possible to link some keys to certain response values \
            so the user can respond simply by pressing a key at any time.
            """
        }
    }

    var name: String {
        return rawValue
    }
}

enum FixedCorrect: String, Codable, CaseIterable {

    case value
    case positionVector
    case positionX
    case positionY
    case positionRadius
    case positionAngle

    var description: String {
        switch self {
        case .value: return "The value of the response."
        case .positionVector: return "The last touch position."
        case .positionX: return "The last x component of the touch position."
        case .positionY: return "The last y component of the touch position."
        case .positionRadius: return "The last radius component of the touch position."
        case .positionAngle: return "The last angle component of the touch position."
        }
    }

    var name: String {
        return rawValue
    }
}

enum FixedDuration: String, Codable, CaseIterable {

    case constant = "constant"
    case stimuli = "stimuli end"

    var description: String {
        switch self {
        case .constant: return "The duration of the scene is a fixed value."
        case .stimuli: return "The scene ends when all stimuli end."
        }
    }

    var name: String {
        return rawValue
    }
}

enum FixedNumberOfLayers: String, Codable, CaseIterable {

    case one
    case two
    case three

    var description: String {
        switch self {
        case .one:
            return "One layer."
        case .two:
            return "Two layers."
        case .three:
            return "Three layers."
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedContinuousResolution: String, Codable, CaseIterable {

    case no
    case yes

    var description: String {
        switch self {
        case .no:
            return "8 bits per channel (red, green, blue). 256 different values for each channel."
        case .yes:
            return "Adding noise to increase the depth of color."
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedPositionResponse: String, Codable, CaseIterable {

    case cartesian = "cartesian vars"
    case polar = "polar vars"

    var description: String {
        switch self {
        case .cartesian:
            return "Two independent cartesian variables."
        case .polar:
            return "Two independent polar variables."
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedResponseValue: String, Codable, CaseIterable {

    case value = "value"
    case position = "positionVector"
    case xPosition = "positionX"
    case yPosition = "positionY"
    case radiusPosition = "positionRadius"
    case anglePosition = "positionAngle"

    var description: String {
        switch self {
        case .value:
            return "value"
        case .position:
            return "positionVector"
        case .xPosition:
            return "positionX"
        case .yPosition:
            return "positionY"
        case .radiusPosition:
            return "positionRadius"
        case .anglePosition:
            return "positionAngle"
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedObjectResponse: String, Codable, CaseIterable {

    case no = "not interactive"
    case yes = "interactive"

    var description: String {
        switch self {
        case .no:
            return """
            Touching the object is NOT considered a response.
            If your are using a 'move object response', the object can NOT be moved.
            """
        case .yes:
            return """
            Touching the object is considered a response.
            If your are using a 'move object response', the object can be moved.
            """
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedKeyResponse: String, Codable, CaseIterable {

    case inactive = "inactive"
    case spaceBar = "space bar"
    case left = "left"
    case right = "right"
    case up = "up"
    case down = "down"
    case other = "other key"

    var description: String {
        return self.rawValue
    }

    var name: String {
        return self.rawValue
    }

    var value: String {
        switch self {
        case .inactive, .other:
            return ""
        case .spaceBar:
            return " "
        case .left:
            return UIKeyCommand.inputLeftArrow
        case .right:
            return UIKeyCommand.inputRightArrow
        case .up:
            return UIKeyCommand.inputUpArrow
        case .down:
            return UIKeyCommand.inputDownArrow
        }

    }
}

enum FixedEndPath: String, Codable, CaseIterable {

    case lift = "lift"
    case touch = "touch object"

    var name: String {
        return self.rawValue
    }
}

enum FixedKeyboard: String, Codable, CaseIterable {

    case normal = "default"
    case numeric = "numeric"

    var name: String {
        return self.rawValue
    }
}

enum FixedResponseInTitle: String, Codable, CaseIterable {

    case no
    case yes

    var name: String {
        return self.rawValue
    }
}
