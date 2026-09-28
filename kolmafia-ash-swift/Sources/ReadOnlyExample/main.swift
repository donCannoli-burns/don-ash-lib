import Foundation
import KoLmafiaASH

@main
struct ReadOnlyExample {
    static func main() async {
        guard let pwd = ProcessInfo.processInfo.environment["KOLMAFIA_PWD"], !pwd.isEmpty else {
            print("Set KOLMAFIA_PWD to the current KoLmafia session hash before running this example.")
            return
        }

        let client = AshClient(options: AshClientOptions(passwordProvider: { pwd }))

        do {
            let response = try await client.batch(ASHBatchRequest(
                functions: [
                    ASHFunctionCall(name: "myName"),
                    ASHFunctionCall(name: "myMeat"),
                    ASHFunctionCall(name: "myAdventures"),
                ]
            ))
            print(response.functions)
        } catch {
            let message = "KoLmafia ASH call failed: \(error)\n"
            FileHandle.standardError.write(Data(message.utf8))
        }
    }
}
