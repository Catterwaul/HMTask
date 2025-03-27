// swift-tools-version: 6.1

import Foundation // for String.capitalized
import PackageDescription

_ = Package(
  name: "HemiprocneMystaceaTask",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [.library(name: .LibraryName.unsuffixed, targets: [.LibraryName.unsuffixed])],
  dependencies: [Module.ExternalDependency.Swift.docC.package]
    + Set(modules.flatMap(\.externalDependencies)).map(\.package),
  targets: modules.map(\.target)
)

var modules: [Module] {
  [
    .init(
      target: .target(name: .LibraryName.unsuffixed),
      externalDependencies: [

      ]
    ),
    .init(
      target: .testTarget(
        name: .LibraryName.suffixed("Tests")
      ),
      internalDependencyNames: [.LibraryName.unsuffixed],
      externalDependencies: [
        .Catterwaul.hmError,
        .Catterwaul.thrappture
      ]
    )
  ]
}

extension String {
  static let macros = "Macros"
  static let previews = "Previews"
  enum LibraryName {
    static let unsuffixed = "HMTask"
    static func suffixed(_ suffix: String) -> String {
      "\(unsuffixed).\(suffix)"
    }
  }
}

// MARK: - Module
struct Module {
  let target: Target
  let externalDependencies: [ExternalDependency]

  /// - Parameters:
  ///   - internalDependencyNames: Names of targets within this package.
  init(
    target: Target,
    internalDependencyNames: [String] = [],
    externalDependencies: [ExternalDependency] = []
  ) {
    target.dependencies += internalDependencyNames.map(Target.Dependency.init)
    target.dependencies += externalDependencies.flatMap(\.products)
    self.target = target
    self.externalDependencies = externalDependencies
  }
}

extension Module {
  /// A repository on GitHub.
  struct ExternalDependency {
    let organization: String
    let repositoryName: String
    let packageNames: [String]
    let branch: String
  }
}

// MARK: - Module.Dependency
extension Module.ExternalDependency {
  // MARK: - commonly-used
  enum Swift {
    static var algorithms: Module.ExternalDependency { apple(repositoryName: "algorithms") }
    static var asyncAlgorithms: Module.ExternalDependency { apple(repositoryName: "async-algorithms") }
    static var macros: Module.ExternalDependency {
      dependency(repositoryName: "syntax", packageNames: ["SyntaxMacros", "CompilerPlugin"])
    }
    static var numerics: Module.ExternalDependency { dependency(repositoryName: "numerics") }
    static var collections: Module.ExternalDependency { apple(repositoryName: "collections") }
    static var docC: Module.ExternalDependency { dependency(repositoryName: "docc-plugin") }

    private static func apple(repositoryName: String) -> Module.ExternalDependency {
      dependency(organization: "apple", repositoryName: repositoryName)
    }

    private static func dependency(
      organization: String = "swiftlang", repositoryName: String,
      packageNames: [String]? = nil
    ) -> Module.ExternalDependency {
      .init(
        organization: organization,
        repositoryName: "swift-\(repositoryName)",
        packageNames:
          packageNames.map { $0.map { "Swift\($0)" } }
          ?? [repositoryName.split(separator: "-").map(\.capitalized).joined()]
      )
    }
  }

  enum Catterwaul {
    static var cast: Module.ExternalDependency { dependency(name: "Cast") }
    static var hmAlgorithms: Module.ExternalDependency { hm("Algorithms") }
    static var hmError: Module.ExternalDependency { hm("Error") }
    static var hmNumerics: Module.ExternalDependency { hm("Numerics") }
    static var littleAny: Module.ExternalDependency { dependency(name: "LittleAny") }
    static var thrappture: Module.ExternalDependency { dependency(name: "Thrappture") }
    static var tuplé: Module.ExternalDependency { dependency(name: "Tuplé", repositoryName: "Tuplay") }

    private static func hm(_ name: String) -> Module.ExternalDependency {
      dependency(
        name: "HM\(name)",
        repositoryName: "HemiprocneMystacea\(name)"
      )
    }

    private static func dependency(
      name: String, repositoryName: String? = nil, branch: String? = nil
    ) -> Module.ExternalDependency {
      .init(
        organization: "Catterwaul",
        repositoryName: repositoryName ?? name,
        packageNames: [name],
        branch: branch
      )
    }
  }

  private init(organization: String, repositoryName: String, packageNames: [String], branch: String? = nil) {
    self.init(
      organization: organization,
      repositoryName: repositoryName,
      packageNames: packageNames,
      branch: branch ?? "main"
    )
  }

  // MARK: - instance members
  var package: Package.Dependency {
    .package(
      url: "https://github.com/\(organization)/\(repositoryName)",
      branch: branch
    )
  }

  var products: [Target.Dependency] {
    packageNames.map { .product(name: $0, package: repositoryName) }
  }
}

// MARK: Equatable
extension Module.ExternalDependency: Equatable {
  static func == (dependency0: Self, dependency1: Self) -> Bool {
    (dependency0.organization, dependency0.repositoryName) ==
    (dependency1.organization, dependency1.repositoryName)
  }
}

// MARK: Hashable
extension Module.ExternalDependency: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(organization)
    hasher.combine(repositoryName)
  }
}
