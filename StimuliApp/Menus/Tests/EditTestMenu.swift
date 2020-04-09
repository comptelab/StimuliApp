//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditTestMenu: Menu {

    // MARK: - Setting
    override func setting() {
        buttonImage = "preview test"
        export = true
        title2 = Flow.shared.test.name.string

        sections = []
        makeSection0()
        makeSection1()
        makeSection2()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Test name")
        section.dependency = Flow.shared.test.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)

        makeOption(from: Flow.shared.test.name,
                     sectionNumber: sectionNumber,
                     badNames: Flow.shared.tests.map({ $0.name.string }))
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Test settings")
        section.dependency = Flow.shared.test.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)

        makeOption(from: Flow.shared.test.frameRate, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.test.brightness, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.test.distance, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.test.cancelButtonPosition, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.test.randomness, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.test.gamma, sectionNumber: sectionNumber)
    }

    private func makeSection2() {
        let sectionNumber = 2
        let section = MenuSection(title: "First section")
        section.dependency = Flow.shared.test.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeFirstSection(sectionNumber: sectionNumber)
    }

    private func makeFirstSection(sectionNumber: Int) {
        let firstSection = Flow.shared.test.firstSection
        var option = Option(name: firstSection.name + ":")
        if firstSection.somethingId == "" {
            option.detail = firstSection.text
        } else {
            option.detail = firstSection.nameToShow
        }
        option.infoMessage = firstSection.info
        option.nextScreen = {
            Flow.shared.property = firstSection
            return SelectFirstSectionMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)
    }
}
