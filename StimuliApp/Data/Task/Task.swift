//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

struct Seed {

    var id: String
    var value: UInt64
    var nameComplete: String
    var nameCompleteCapitalized: String

    init(id: String) {
        self.id = id
        self.value = UInt64.random(in: 0 ... 1000000)

        if let list = Flow.shared.test.listsOfValues.first(where: { $0.id == id }) {
            self.nameComplete = "seed for list: " + list.name.string
            self.nameCompleteCapitalized = "SEED FOR LIST: " + list.name.string
        } else if let section = Flow.shared.test.sections.first(where: { $0.id == id }) {
            self.nameComplete = "seed for section: " + section.name.string
            self.nameCompleteCapitalized = "SEED FOR SECTION: " + section.name.string
        } else {
            self.nameComplete = ""
            self.nameCompleteCapitalized = ""
        }
    }

    init(id: String, value: UInt64) {
        self.id = id
        self.value = value

        if let list = Flow.shared.test.listsOfValues.first(where: { $0.id == id }) {
            self.nameComplete = "seed for list: " + list.name.string
            self.nameCompleteCapitalized = "SEED FOR LIST: " + list.name.string
        } else if let section = Flow.shared.test.sections.first(where: { $0.id == id }) {
            self.nameComplete = "seed for section: " + section.name.string
            self.nameCompleteCapitalized = "SEED FOR SECTION: " + section.name.string
        } else {
            self.nameComplete = ""
            self.nameCompleteCapitalized = ""
        }
    }

    var info: String {
        return nameCompleteCapitalized + ": \(value)"
    }
}

struct LongFrame {
    let scene: String
    let trial: Int
    let frame: Int
    let duration: Double

    var info: String {
        return """
        scene: \(scene)
        trial: \(trial)
        frame: \(frame)
        duration: \(duration)
        """
    }
}

struct UserResponse {
    var integer: Int?
    var float: Float?
    var string: String?

    var xTouches: [Float] = []
    var yTouches: [Float] = []
    var radiusTouches: [Float] = []
    var angleTouches: [Float] = []
    var clocks: [Double] = []

    var liftClock: Double?

    init() {}
}

enum Preview {
    case no
    case previewTest
    case previewScene
    case previewStimulus
    case variablesSection
}

struct PolarPosition: Hashable {
    let a: Int
    let b: Int
}

class Task {

    static let shared =  Task()

    var name: String = ""
    var seeds: [Seed] = []
    var error: String = ""
    var preview: Preview = .no
    var gamma: Float = Constants.gamma
    var inversGamma: Float = Constants.inversGamma
    var sectionTasks: [SectionTask] = []

    var sectionTask = SectionTask()
    var sceneTask = SceneTask()
    var dataTask = DataTask()
    var sectionZeroTask = SectionTask()

    var actualFrameTime: Double = 0
    var previousFrameTime: Double = 0
    var longFrames: [LongFrame] = []
    var totalNumberOfFrames: Int = 0

    var userResponse: UserResponse = UserResponse()

    var computeThreadsPerGroupX: [Int] = Array(repeating: 1, count: Constants.numberOfComputeKernels)
    var computeThreadsPerGroupY: [Int] = Array(repeating: 1, count: Constants.numberOfComputeKernels)
    var computeNumberOfGroupsX: [Int] = Array(repeating: 1, count: Constants.numberOfComputeKernels)
    var computeNumberOfGroupsY: [Int] = Array(repeating: 1, count: Constants.numberOfComputeKernels)
    var computeNumberOfGroups: [Int] = Array(repeating: 1, count: Constants.numberOfComputeKernels)

    var semiWidth: Float = 0
    var semiHeight: Float = 0
    var computeNumber = 0
    var numberOfLayers = 1

    var images: [(name: String, image: UIImage?)] = []
    var videos: [(name: String, url: URL?)] = []
    var audios: [(name: String, url: URL?)] = []

    var dots: [Float] = [] //(maximumnumberofdots * numberOfDotsxValuesPerDot)
    var dots1: [Float] = [] //(maximumnumberofdots * numberOfDotsxValuesPerDot)

    var xButtonPosition: FixedXButton = .topLeft

    var responseMovingObject: Int?

    var responseKeyboard: String = ""

    var percentageLongFrames: String {
        let value: Double = Double(longFrames.count) / Double(totalNumberOfFrames) * 100

        let percentage = String(format: "%.05f", value)

        return "\(percentage)%"
    }

    var longFramesString: String {
        let duration = String(format: "%.05f", Flow.shared.settings.delta)

        var longlist = ""

        for longFrame in longFrames {
            longlist += longFrame.info
            longlist += "\n"
        }

        return """
        Frame rate: \(Flow.shared.settings.frameRate) Hz.

        Expected duration of a frame: \(duration).

        The number of long frames is: \(longFrames.count)

        from a total number of: \(totalNumberOfFrames) frames.

        The percentage of long frames is: \(percentageLongFrames).

        List of long frames:

        \(longlist)
        """
    }

    // create methods
    func createTask(test: Test, preview: Preview) -> String {
        self.preview = preview
        self.name = test.name.string
        Flow.shared.test = test
        if preview != .no {
            createRandomSeeds(from: test)
        }
        error = importSettings(from: test)
        if error != "" {
            return error
        }
        calculateSectionZero(from: test)
        guard !self.sectionZeroTask.conditions.isEmpty else {
            return """
            ERROR: select the first section of the test.
            """
        }
        for section in test.sections {
            error = calculateSection(from: section)
            if error != "" {
                return error
            }
        }
        return ""
    }

    func createSection(section: Section, test: Test) -> String {
        preview = .variablesSection
        createRandomSeeds(from: test)
        error = importSettings(from: test)
        if error != "" {
            return error
        }
        return calculateSection(from: section)
    }

    func createTask(section: Section, scene: Scene, test: Test) -> String {
        preview = .previewScene
        let sceneNumber = section.scenes.firstIndex(where: { $0 === scene }) ?? 0

        createRandomSeeds(from: test)
        error = importSettings(from: test)
        if error != "" {
            return error
        }

        calculateSectionZero(from: test)
        guard !self.sectionZeroTask.conditions.isEmpty else {
            return """
            ERROR: select the first section of the test.
            """
        }

        error = calculateSection(from: section, sceneNumber: sceneNumber)
        if error != "" {
            return error
        }

        return ""
    }

    func createTask(stimulus: Stimulus) -> String {
        preview = .previewStimulus
        let test = createTest(stimulus: stimulus, test: Flow.shared.test)
        createRandomSeeds(from: test)
        error = importSettings(from: test)
        if error != "" {
            return error
        }

        calculateSectionZero(from: test)
        guard !self.sectionZeroTask.conditions.isEmpty else {

            return """
            ERROR: select the first section of the test.
            """
        }
        for section in test.sections {
            error = calculateSection(from: section)
            if error != "" {
                return error
            }
        }
        return ""
    }

    // private methods
    private func importSettings(from test: Test) -> String {
        xButtonPosition = FixedXButton(rawValue: test.cancelButtonPosition.string) ?? .topLeft
        longFrames = []
        images = []
        totalNumberOfFrames = 0
        userResponse = UserResponse()
        let gammaType = FixedGamma(rawValue: test.gamma.string) ?? .linear
        switch gammaType {
        case .linear:
            gamma = Constants.gamma
            inversGamma = Constants.inversGamma
        case .normal:
            gamma = 1
            inversGamma = 1
        case .calibrated:
            gamma = test.gamma.properties[0].float
            inversGamma = 1 / gamma
        }
        sectionTasks = []
        error = ""
        Flow.shared.settings.update(from: test)

        for variable in test.variables {
            guard let listOfValues = variable.listOfValues  else {
                return """
                ERROR: variable: \(variable.name) has no list assigned.
                """
            }
            let listError = listOfValues.calculateGoodValues()
            if listError != "" {
                return """
                ERROR: in variable: \(variable.name).
                \(listError)
                """
            }

            if let selection = FixedSelection(rawValue: variable.selection.string) {
                if selection == .correct {
                    if let varProperty = variable.selection.properties.first(where: { $0.somethingId == variable.id}) {
                        let number = varProperty.float.toInt
                        if number > listOfValues.values.count { return """
                            ERROR: in variable: \(variable.name).
                            The listOfValues: \(listOfValues.name.string) has \(listOfValues.values.count) values
                            and you are selecting the value \(number) as first value.
                            """ }
                    } else {
                        if listOfValues.values.count < 2 { return """
                            ERROR: in variable: \(variable.name).
                            The listOfValues: \(listOfValues.name.string) has \(listOfValues.values.count) values
                            and for a variable of type correct/incorrect you need at least 2 values.
                            """
                        }
                    }
                }
            }
        }
        for list in test.listsOfValues where list.dimensions > 3 {
            error = list.calculateGoodValues()
            if error != "" {
                return error
            }
        }
        return ""
    }

    private func createRandomSeeds(from test: Test) {
        seeds = []
        let properties = test.randomness.properties
        for property in properties {
            let seed = Seed(id: property.somethingId)
            seeds.append(seed)
        }
    }

    func updateData(device: MTLDevice, trial: Int, timeInFrames: Int, status: DisplayRender.Status) {

        DataTask.backgroundValues = sceneTask.backgroundFloats[trial]
        DataTask.backgroundValues[BackGroundValues.timeInFrames] = Float(timeInFrames)
        DataTask.backgroundValues[BackGroundValues.status] = status.toFloat
        DataTask.backgroundValues[BackGroundValues.randomSeed] =
            DataTask.backgroundValues[BackGroundValues.randomSeedInitial] *
            (DataTask.backgroundValues[BackGroundValues.timeInFrames] + 1)

        Task.shared.updateEverything(sceneTask: sceneTask,
                                     trialNumber: trial,
                                     timeInFrames: timeInFrames)

        DataTask.metalValues = sceneTask.metalFloats[trial]
        DataTask.activatedBools = sceneTask.activatedBools[trial]
    }

    func updateScene(device: MTLDevice, trial: Int, status: DisplayRender.Status) {


        updateDependentVariables(trial: trial)
        updateData(device: device, trial: trial, timeInFrames: 0, status: status)

        DataTask.images = sceneTask.images[trial]

        computeNumber = sceneTask.computeNumber
        numberOfLayers = sceneTask.numberOfLayers
    }

    private func updateDependentVariables(trial: Int) {

        let frameRate = Float(Flow.shared.settings.frameRate)

        var polarPositions: Set<PolarPosition> = []

        for variable in sceneTask.dependentVariables {

            let object = variable.objectNumber
            let position = variable.position
            let repetitions = variable.repetitions
            let values = variable.values

            if trial == 0 {
                variable.dependentValue = variable.initialValue
            }

            switch variable.method {
            case .zero:
                if sectionTask.last == 0 {
                    variable.dependentValue = 1
                } else if sectionTask.last == 1 {
                    variable.dependentValue = 0
                }
            case .one:
                if sectionTask.last == 0 && variable.dependentValue < variable.list.goodValues.count - 1 {
                    variable.dependentValue += 1
                } else if sectionTask.last == 1 && variable.dependentValue > 0 {
                    variable.dependentValue -= 1
                }
            case .two:
                if sectionTask.last == 0 {
                    variable.previousDependentSum = 0
                    variable.starting = false
                    if variable.dependentValue < variable.list.goodValues.count - 1 {
                        variable.dependentValue += 1
                    }
                } else if sectionTask.last == 1 {
                    if variable.previousDependentSum == 1 || variable.starting {
                        variable.previousDependentSum = 0
                        if variable.dependentValue > 0 {
                            variable.dependentValue -= 1
                        }
                    } else {
                        variable.previousDependentSum += 1
                    }
                }
            case .three:
                if sectionTask.last == 0 {
                    variable.starting = false
                    variable.previousDependentSum = 0
                    if variable.dependentValue < variable.list.goodValues.count - 1 {
                        variable.dependentValue += 1
                    }
                } else if sectionTask.last == 1 {
                    if variable.previousDependentSum == 2 || variable.starting {
                        variable.previousDependentSum = 0
                        if variable.dependentValue > 0 {
                            variable.dependentValue -= 1
                        }
                    } else {
                        variable.previousDependentSum += 1
                    }
                }
            }

            let value = Property(from: variable.list.goodValues[variable.dependentValue])

            value.unit = variable.variableTask.property.unit
            value.timeUnit = variable.variableTask.property.timeUnit
            value.timeExponent = variable.variableTask.property.timeExponent
            value.unitType = variable.variableTask.property.unitType
            value.changeValue(new: [value.float, value.float1, value.float2])

            variable.variableTask.values[trial] = value
            if let trialValue = variable.variableTask.trialValueAssociated {
                trialValue.values[trial] = trialValue.list.values[variable.dependentValue]
                //values instead goodValues in this case
                calculateSectionValue(trial: trial, variableValue: trialValue)
            }

            switch variable.type {
            case .activatedBools:
                sceneTask.activatedBools[trial][object] = value.float > 0.5 ? true : false
                modifyFinalCheckPoint(trial: trial)
            case .start:
                sceneTask.startTimesInFrames[trial][object] = (value.float * frameRate).toInt
                sceneTask.endTimesInFrames[trial][object] =
                    sceneTask.startTimesInFrames[trial][object] + sceneTask.durationTimesInFrames[trial][object]
                modifyFinalCheckPoint(trial: trial)
            case .duration:
                sceneTask.durationTimesInFrames[trial][object] = (value.float * frameRate).toInt
                sceneTask.endTimesInFrames[trial][object] =
                    sceneTask.startTimesInFrames[trial][object] + sceneTask.durationTimesInFrames[trial][object]
                modifyFinalCheckPoint(trial: trial)
            case .background:
                if values == 1 {
                    for i in position ..< position + repetitions {
                        sceneTask.backgroundFloats[trial][i] = value.float
                    }
                } else if values == 2 {
                    sceneTask.backgroundFloats[trial][position] = value.float
                    sceneTask.backgroundFloats[trial][position + 1] = value.float1
                } else if values == 3 {
                    sceneTask.backgroundFloats[trial][position] = value.float
                    sceneTask.backgroundFloats[trial][position + 1] = value.float1
                    sceneTask.backgroundFloats[trial][position + 2] = value.float2
                }
            case .metal:
                if values == 1 {
                    for i in position ..< position + repetitions {
                        sceneTask.metalFloats[trial][object][i] = value.float
                    }
                } else if values == 2 {
                    sceneTask.metalFloats[trial][object][position] = value.float
                    sceneTask.metalFloats[trial][object][position + 1] = value.float1
                } else if values == 3 {
                    sceneTask.metalFloats[trial][object][position] = value.float
                    sceneTask.metalFloats[trial][object][position + 1] = value.float1
                    sceneTask.metalFloats[trial][object][position + 2] = value.float2
                }
            case .image:
                guard let listOfImages = Flow.shared.test.listsOfValues.first(where: { $0.type == .images }) else {
                    return
                }

                if position == 0 {
                    var textInt = min(value.float.toInt, listOfImages.goodValues.count) - 1
                    textInt = max(textInt, 0)
                    let name = listOfImages.goodValues[textInt].somethingId
                    if let index = images.firstIndex(where: { $0.name == name }) {
                        sceneTask.images[trial][object] = index
                    }
                }
            case .audio:
                guard let listOfAudios = Flow.shared.test.listsOfValues.first(where: { $0.type == .audios }) else {
                    return
                }
                if position == 10 || position == 11 || position == 12 {

                    if position == 10 {
                        sceneTask.audioObjects[trial][object].activated = value.float > 0.5 ? true : false
                    } else if position == 11 {
                        let first = sceneTask.audioObjects[trial][object].start
                        let second = (value.float * frameRate).toInt
                        sceneTask.audioObjects[trial][object].start = second
                        sceneTask.audioObjects[trial][object].end += (second - first)
                    } else {
                        let start = sceneTask.audioObjects[trial][object].start
                        let duration = (value.float * frameRate).toInt
                        sceneTask.audioObjects[trial][object].end = start + duration
                    }
                    let activated = sceneTask.audioObjects[trial][object].activated
                    let start = sceneTask.audioObjects[trial][object].start
                    let end = sceneTask.audioObjects[trial][object].end

                    sceneTask.checkPoints[trial] = sceneTask.checkPoints[trial].filter({
                        $0.objectNumber != object || $0.type != .audio
                    })

                    if activated {
                        let checkPoint = SceneTask.CheckPoint(time: start, action: .startAudio,
                                                              objectNumber: object, type: .audio)
                        let checkPoint2 = SceneTask.CheckPoint(time: end, action: .endAudio,
                                                               objectNumber: object, type: .audio)
                        sceneTask.checkPoints[trial] += [checkPoint, checkPoint2]
                    }
                    modifyFinalCheckPoint(trial: trial)

                } else if position == 0 {
                    var textInt = min(value.float.toInt, listOfAudios.goodValues.count) - 1
                    textInt = max(textInt, 0)
                    let name = listOfAudios.goodValues[textInt].somethingId
                    if let audio = audios.first(where: { $0.name == name }) {
                        sceneTask.audioObjects[trial][object].url = audio.url
                    }
                }
            case .video:
                guard let listOfVideos = Flow.shared.test.listsOfValues.first(where: { $0.type == .videos }) else {
                    return
                }
                if position == 10 || position == 11 || position == 12 {

                    if position == 10 {
                        sceneTask.videoObjects[trial][object].activated = value.float > 0.5 ? true : false
                    } else if position == 11 {
                        let first = sceneTask.videoObjects[trial][object].start
                        let second = (value.float * frameRate).toInt
                        sceneTask.videoObjects[trial][object].start = second
                        sceneTask.videoObjects[trial][object].end += (second - first)
                    } else {
                        let start = sceneTask.videoObjects[trial][object].start
                        let duration = (value.float * frameRate).toInt
                        sceneTask.videoObjects[trial][object].end = start + duration
                    }
                    let activated = sceneTask.videoObjects[trial][object].activated
                    let start = sceneTask.videoObjects[trial][object].start
                    let end = sceneTask.videoObjects[trial][object].end

                    sceneTask.checkPoints[trial] = sceneTask.checkPoints[trial].filter({
                        $0.objectNumber != object || $0.type != .video
                    })

                    if activated {
                        let checkPoint = SceneTask.CheckPoint(time: start, action: .startVideo,
                                                              objectNumber: object, type: .video)
                        let checkPoint2 = SceneTask.CheckPoint(time: end, action: .endVideo,
                                                               objectNumber: object, type: .video)
                        sceneTask.checkPoints[trial] += [checkPoint, checkPoint2]
                    }
                    modifyFinalCheckPoint(trial: trial)

                } else if position == 0 {
                    var textInt = min(value.float.toInt, listOfVideos.goodValues.count) - 1
                    textInt = max(textInt, 0)
                    let name = listOfVideos.goodValues[textInt].somethingId
                    if let video = videos.first(where: { $0.name == name }) {
                        sceneTask.videoObjects[trial][object].url = video.url
                    }
                }
            case .text:
                guard let listOfTexts = Flow.shared.test.listsOfValues.first(where: { $0.type == .texts }) else {
                    return
                }
                if position == 10 || position == 11 || position == 12 {

                    if position == 10 {
                        sceneTask.textObjects[trial][object].activated = value.float > 0.5 ? true : false
                    } else if position == 11 {
                        let first = sceneTask.textObjects[trial][object].start
                        let second = (value.float * frameRate).toInt
                        sceneTask.textObjects[trial][object].start = second
                        sceneTask.textObjects[trial][object].end += (second - first)
                    } else {
                        let start = sceneTask.textObjects[trial][object].start
                        let duration = (value.float * frameRate).toInt
                        sceneTask.textObjects[trial][object].end = start + duration
                    }
                    let activated = sceneTask.textObjects[trial][object].activated
                    let start = sceneTask.textObjects[trial][object].start
                    let end = sceneTask.textObjects[trial][object].end

                    sceneTask.checkPoints[trial] = sceneTask.checkPoints[trial].filter({
                        $0.objectNumber != object || $0.type != .text
                    })

                    if activated {
                        let checkPoint = SceneTask.CheckPoint(time: start, action: .startText,
                                                              objectNumber: object, type: .text)
                        let checkPoint2 = SceneTask.CheckPoint(time: end, action: .endText,
                                                               objectNumber: object, type: .text)
                        sceneTask.checkPoints[trial] += [checkPoint, checkPoint2]
                    }
                    modifyFinalCheckPoint(trial: trial)

                } else if position == 0 {
                    var textInt = min(value.float.toInt, listOfTexts.goodValues.count) - 1
                    textInt = max(textInt, 0)
                    sceneTask.textObjects[trial][object].text = listOfTexts.goodValues[textInt].text
                } else if position == 2 {
                    sceneTask.textObjects[trial][object].font.withSize(CGFloat(value.float))
                } else if position == 3 {
                    sceneTask.textObjects[trial][object].positionX = CGFloat(value.float)
                } else if position == 4 {
                    sceneTask.textObjects[trial][object].positionY = CGFloat(value.float)
                } else if position == 5 {
                    if values == 1 {
                        sceneTask.textObjects[trial][object].red = CGFloat(value.float)
                        if repetitions == 3 {
                            sceneTask.textObjects[trial][object].green = CGFloat(value.float)
                            sceneTask.textObjects[trial][object].blue = CGFloat(value.float)
                        }
                    } else if values == 3 {
                        sceneTask.textObjects[trial][object].red = CGFloat(value.float)
                        sceneTask.textObjects[trial][object].green = CGFloat(value.float1)
                        sceneTask.textObjects[trial][object].blue = CGFloat(value.float2)
                    }
                } else if position == 6 {
                    sceneTask.textObjects[trial][object].green = CGFloat(value.float)
                } else if position == 7 {
                    sceneTask.textObjects[trial][object].blue = CGFloat(value.float)
                }
            case .pureTone:

                if position == 10 || position == 11 || position == 12 {

                    if position == 10 {
                        sceneTask.sineWaveObjects[trial][object].activated = value.float > 0.5 ? true : false
                    } else if position == 11 {
                        let first = sceneTask.sineWaveObjects[trial][object].startFloat
                        let second = value.float
                        sceneTask.sineWaveObjects[trial][object].startFloat = second
                        sceneTask.sineWaveObjects[trial][object].endFloat += (second - first)
                        sceneTask.sineWaveObjects[trial][object].start =
                            (sceneTask.sineWaveObjects[trial][object].startFloat * frameRate).toInt
                        sceneTask.sineWaveObjects[trial][object].end =
                            (sceneTask.sineWaveObjects[trial][object].endFloat * frameRate).toInt
                    } else {
                        let startFloat = sceneTask.sineWaveObjects[trial][object].startFloat
                        sceneTask.sineWaveObjects[trial][object].endFloat = startFloat + value.float
                        sceneTask.sineWaveObjects[trial][object].end =
                            (sceneTask.sineWaveObjects[trial][object].endFloat * frameRate).toInt
                    }
                    let activated = sceneTask.sineWaveObjects[trial][object].activated
                    let start = sceneTask.sineWaveObjects[trial][object].start
                    let end = sceneTask.sineWaveObjects[trial][object].end

                    sceneTask.checkPoints[trial] = sceneTask.checkPoints[trial].filter({
                        $0.objectNumber != object || $0.type != .sineWave
                    })

                    if activated {
                        let checkPoint = SceneTask.CheckPoint(time: start, action: .startSineWave,
                                                              objectNumber: object, type: .sineWave)
                        let checkPoint2 = SceneTask.CheckPoint(time: end, action: .endSineWave,
                                                               objectNumber: object, type: .sineWave)
                        sceneTask.checkPoints[trial] += [checkPoint, checkPoint2]
                    }
                    modifyFinalCheckPoint(trial: trial)

                } else if position == 0 {
                    sceneTask.sineWaveObjects[trial][object].amplitude = value.float
                } else if position == 1 {
                    sceneTask.sineWaveObjects[trial][object].frequency = value.float
                }
                modifySineWaveFloats(trial: trial, object: object)
            case .timeDependent:
                if let update = variable.update, let parameter = variable.parameter {
                    update.parameters[trial][parameter] = value.float
                }
            }

            if variable.polarRadius {
                polarPositions.insert(PolarPosition(a: object, b: position))
            } else if variable.polarAngle {
                polarPositions.insert(PolarPosition(a: object, b: position - 1))
            }
        }

        for position in polarPositions {

            let radius = sceneTask.metalFloats[trial][position.a][position.b]
            let angle = sceneTask.metalFloats[trial][position.a][position.b + 1]

            let values = AppUtility.polarToCartesian(radius: radius, angle: angle)

            sceneTask.metalFloats[trial][position.a][position.b] = values.0
            sceneTask.metalFloats[trial][position.a][position.b + 1] = values.1
        }
    }

    func saveTaskDataTime() {
        if !longFrames.isEmpty {
            longFrames.remove(at: 0)
        }
    }

    func saveTestAsResult() {

        let result = Result(name: name, order: Flow.shared.results.count)

        result.responseKeyboard = responseKeyboard

        let testSettings = """
        TEST: \(result.name.string)
        USER: \(Flow.shared.settings.userProperty.string)
        DATE: \(result.dateString)
        """

        let settings = Flow.shared.settings.info

        var testOptions = ["FRAME RATE: \(Flow.shared.test.frameRate.string)"]
        testOptions += ["BRIGHTNESS: \(Flow.shared.test.brightness.string)"]
        testOptions += ["VIEWING DISTANCE: \(Flow.shared.test.distance.properties[0].string)"]
        testOptions += ["GAMMA: \(Flow.shared.test.gamma.string)"]
        if let gamma = FixedGamma(rawValue: Flow.shared.test.gamma.string) {
            if gamma == .calibrated {
                testOptions += ["GAMMA CORRECTION: \(Flow.shared.test.gamma.properties[0].string)"]
            }
        }
        testOptions += ["RANDOMNESS: \(Flow.shared.test.randomness.string)"]
        let seedsInfo = seeds.map({ $0.info })
        testOptions += seedsInfo

        let testOptionsString = testOptions.joined(separator: "\n")

        result.data = Constants.separator + testSettings + Constants.separator + settings +
            Constants.separator + testOptionsString + Constants.separator

        for sectionTask in sectionTasks {
            let sectionResult = sectionTask.calculateResultInfo()
            result.data += sectionResult.result
            result.data += Constants.separator
            result.csvs.append(sectionResult.csv0)
            result.csvNames.append(sectionResult.csv0Name)
            if sectionResult.csv1 != "" {
                result.csvs.append(sectionResult.csv1)
                result.csvNames.append(sectionResult.csv1Name)
            }
        }

        var stimuli: [String] = []

        for stimulus in Flow.shared.test.stimuli {
            let stimulusName = stimulus.name.string
            for property in stimulus.allProperties where property.timeDependency != .variable {
                let name = stimulusName + "_" + property.name
                let value = property.string
                let string = name + ": " + value
                stimuli.append(string)
            }
        }

        let stimuliString = stimuli.joined(separator: "\n")

        result.data += "VALUES OF THE CONSTANT PROPERTIES:" + "\n\n" + stimuliString + Constants.separator

        result.data += "FRAME RATE:" + "\n\n" + longFramesString + Constants.separator

        _ = Flow.shared.createSaveAndSelectNewResult(result)
    }
}
