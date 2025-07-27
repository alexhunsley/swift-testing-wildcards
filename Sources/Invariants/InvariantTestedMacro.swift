// TODO this actually belongs in a .macro bit (tuist), not here in main target

//import SwiftSyntax
//import SwiftSyntaxBuilder
//import SwiftSyntaxMacros
//
//public struct InvariantTestedMacro: PeerMacro {
//    public static func expansion(
//        of node: AttributeSyntax,
//        providingPeersOf declaration: some DeclSyntaxProtocol,
//        in context: some MacroExpansionContext
//    ) throws -> [DeclSyntax] {
//        guard let funcDecl = declaration.as(FunctionDeclSyntax.self),
//              let args = node.arguments?.as(LabeledExprListSyntax.self) else {
//            throw ExpansionError("Expected function with macro arguments")
//        }
//
//        func extract(_ name: String) -> ExprSyntax? {
//            args.first(where: { $0.label?.text == name })?.expression
//        }
//
//        guard let prototype = extract("prototype"),
//              let keyPaths = extract("keyPaths") else {
//            throw ExpansionError("Missing required prototype or keyPaths")
//        }
//
//        var testArgs: [String] = [
//            "arguments: InvariantCombinator.testCases(from: \(prototype), keyPaths: \(keyPaths).map { .init($0) }"
//        ]
//
//        if let vo = extract("valueOverrides") {
//            testArgs[0] += ", valueOverrides: \(vo)"
//        }
//
//        testArgs[0] += ")"
//
//        if let desc = extract("description") {
//            testArgs.append("description: \(desc)")
//        }
//
//        if let traits = extract("traits") {
//            testArgs.append("traits: \(traits)")
//        }
//
//        let attr = try AttributeSyntax(stringLiteral: "@Test(\(testArgs.joined(separator: ", ")))")
//
//        var modified = funcDecl
//        modified.attributes = modified.attributes?.appending(attr) ?? AttributeListSyntax([attr])
//        return [DeclSyntax(modified)]
//    }
//
//    struct ExpansionError: Error, CustomStringConvertible {
//        var message: String
//        var description: String { message }
//        init(_ msg: String) { message = msg }
//    }
//}
