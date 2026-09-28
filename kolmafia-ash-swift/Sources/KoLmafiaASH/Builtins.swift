import Foundation

public extension AshClient {
    func myName() async throws -> String {
        try (await call("myName")).requireString("myName")
    }

    func myMeat() async throws -> Int {
        try (await call("myMeat")).requireInt("myMeat")
    }

    func myAdventures() async throws -> Int {
        try (await call("myAdventures")).requireInt("myAdventures")
    }

    func availableAmount(_ item: Item) async throws -> Int {
        try (await call("availableAmount", item)).requireInt("availableAmount")
    }

    func itemAmount(_ item: Item) async throws -> Int {
        try (await call("itemAmount", item)).requireInt("itemAmount")
    }

    func haveSkill(_ skill: Skill) async throws -> Bool {
        try (await call("haveSkill", skill)).requireBool("haveSkill")
    }

    func numericModifier(_ name: String) async throws -> Double {
        try (await call("numericModifier", name)).requireDouble("numericModifier")
    }

    func getRevision() async throws -> Int {
        try (await call("getRevision")).requireInt("getRevision")
    }

    func getVersion() async throws -> String {
        try (await call("getVersion")).requireString("getVersion")
    }
}
