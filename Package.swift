// swift-tools-version: 6.1

import Foundation // for String.capitalized
import PackageDescription

_ = Package(
  name: "HemiprocneMystaceaTask",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [.library(name: .libraryName, targets: [.libraryName])],
  dependencies: [Module.ExternalDependency.Swift.docC.package]
    + Set(modules.flatMap(\.externalDependencies)).map(\.package),
  targets: modules.map(\.target)
)

var modules: [Module] {
  [
    .init(
      target: .target(name: .libraryName),
      externalDependencies: [

      ]
    ),
    .init(
      target: .testTarget(
        name: .LibraryName.suffixed("Tests")
      ),
      internalDependencyNames: [.libraryName],
      externalDependencies: [
        .Catterwaul.hmError,
        .Catterwaul.thrappture
      ]
    )
  ]
}

extension String {
  static let libraryName = "HMTask"
  enum LibraryName {
    static func suffixed(_ suffix: String) -> String {
      "\(libraryName).\(suffix)"
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
    target.dependencies += externalDependencies.map(\.product)
    self.target = target
    self.externalDependencies = externalDependencies
  }
}

extension Module {
  /// A repository on GitHub.
  struct ExternalDependency {
    let organization: String
    let productName: String
    let repositoryName: String
    let branch: String
  }
}

// MARK: - Module.Dependency
extension Module.ExternalDependency {
  // MARK: - commonly-used
  enum Swift {
    static var algorithms: Module.ExternalDependency { apple(repositoryName: "algorithms") }
    static var asyncAlgorithms: Module.ExternalDependency { apple(repositoryName: "async-algorithms") }
    static var numerics: Module.ExternalDependency { apple(repositoryName: "numerics") }
    static var collections: Module.ExternalDependency { apple(repositoryName: "collections") }
    static var docC: Module.ExternalDependency { dependency(repositoryName: "docc-plugin") }

    private static func apple(repositoryName: String) -> Module.ExternalDependency {
      dependency(organization: "apple", repositoryName: repositoryName)
    }

    private static func dependency(
      organization: String = "swiftlang", repositoryName: String
    ) -> Module.ExternalDependency {
      .init(
        organization: organization,
        productName: repositoryName.split(separator: "-").map(\.capitalized).joined(),
        repositoryName: "swift-\(repositoryName)"
      )
    }
  }

  enum Catterwaul {
    static var cast: Module.ExternalDependency { dependency(name: "Cast") }
    static var hmAlgorithms: Module.ExternalDependency { hm("Algorithms") }
    static var hmCodable: Module.ExternalDependency { hm("Codable") }
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
        productName: name,
        repositoryName: repositoryName ?? name,
        branch: branch
      )
    }
  }

  private init(organization: String, productName: String, repositoryName: String, branch: String? = nil) {
    self.init(
      organization: organization,
      productName: productName,
      repositoryName: repositoryName,
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

  var product: Target.Dependency {
    .product(name: productName, package: repositoryName)
  }
}

// MARK: Equatable
extension Module.ExternalDependency: Equatable {
  static func == (dependency0: Self, dependency1: Self) -> Bool {
    (dependency0.organization, dependency0.productName) ==
    (dependency1.organization, dependency1.productName)
  }
}

// MARK: Hashable
extension Module.ExternalDependency: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(organization)
    hasher.combine(productName)
  }
}
