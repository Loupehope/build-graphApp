import Foundation
import FileAnalyzer

public struct BuildSettingsParser {
    fileprivate(set) var settings: BuildSettings?
    
    private var projectFileURL: URL?
    private let xCodeProjectFileExt = "xcodeproj"
    
    public init(projectURL: URL) {
        if projectURL.path.lowercased().hasSuffix(xCodeProjectFileExt) {
            self.projectFileURL = projectURL
        } else if let foundProjectFile = self.findXCodeProjectFile(folderURL: projectURL) {
            self.projectFileURL = foundProjectFile
        } else {
            fatalError("Wrong XCode project file URL (or file not found in folder (\(projectURL)")
        }
        
        let settingsString = shell("xcodebuild -project \(projectFileURL!.path) -showBuildSettings")
        
        let arrayOfSettings = settingsString.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.contains("=") }
            
        let arrayOfSettingPairs = arrayOfSettings
            .map { $0.split(separator: "=")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            }

        var dict = [String: String]()
        for pair in arrayOfSettingPairs {
            if pair.count == 2 {
                dict[pair[0]] = pair[1]
            }
        }
        
        settings = BuildSettings(raw: dict)
    }
    
    private func findXCodeProjectFile(folderURL: URL) -> URL? {
        let foundResults = try? FileManager.default.findInDirectory(url: folderURL, by: "xcodeproj", isRecursively: false)
        return foundResults?.first
    }
}

struct BuildSettings {
    let raw: [String: String]
    
    var derivedDataDir: URL? {
        guard let buildRoot = raw["BUILD_ROOT"],
              var buildRootURL = URL(string: buildRoot) else { return nil }

        while buildRootURL.pathComponents.count > 0,
              !buildRootURL.lastPathComponent.lowercased().contains("derived"),
              !buildRootURL.lastPathComponent.lowercased().contains("xcode")
        {
            buildRootURL.deleteLastPathComponent()
        }
        return buildRootURL
    }
    
    var project: String? {
        raw["PROJECT"]
    }
}


// Raw settings example

//ACTION = build
//AD_HOC_CODE_SIGNING_ALLOWED = NO
//ALTERNATE_GROUP = staff
//ALTERNATE_MODE = u+w,go-w,a+rX
//ALTERNATE_OWNER = yaroslavbredikhin
//ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES
//ALWAYS_SEARCH_USER_PATHS = NO
//ALWAYS_USE_SEPARATE_HEADERMAPS = NO
//APPLE_INTERNAL_DEVELOPER_DIR = /AppleInternal/Developer
//APPLE_INTERNAL_DIR = /AppleInternal
//APPLE_INTERNAL_DOCUMENTATION_DIR = /AppleInternal/Documentation
//APPLE_INTERNAL_LIBRARY_DIR = /AppleInternal/Library
//APPLE_INTERNAL_TOOLS = /AppleInternal/Developer/Tools
//APPLICATION_EXTENSION_API_ONLY = NO
//APPLY_RULES_IN_COPY_FILES = NO
//APPLY_RULES_IN_COPY_HEADERS = NO
//ARCHS = arm64
//ARCHS_STANDARD = arm64 armv7
//ARCHS_STANDARD_32_64_BIT = armv7 arm64
//ARCHS_STANDARD_32_BIT = armv7
//ARCHS_STANDARD_64_BIT = arm64
//ARCHS_STANDARD_INCLUDING_64_BIT = arm64 armv7
//ARCHS_UNIVERSAL_IPHONE_OS = armv7 arm64
//ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-debug
//AVAILABLE_PLATFORMS = appletvos appletvsimulator iphoneos iphonesimulator macosx watchos watchsimulator
//BITCODE_GENERATION_MODE = marker
//BUILD_ACTIVE_RESOURCES_ONLY = NO
//BUILD_COMPONENTS = headers build
//BUILD_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products
//BUILD_LIBRARY_FOR_DISTRIBUTION = NO
//BUILD_ROOT = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products
//BUILD_STYLE =
//BUILD_VARIANTS = normal
//BUILT_PRODUCTS_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos
//BUNDLE_CONTENTS_FOLDER_PATH_deep = Contents/
//BUNDLE_EXECUTABLE_FOLDER_NAME_deep = MacOS
//BUNDLE_FORMAT = shallow
//BUNDLE_FRAMEWORKS_FOLDER_PATH = Frameworks
//BUNDLE_PLUGINS_FOLDER_PATH = PlugIns
//BUNDLE_PRIVATE_HEADERS_FOLDER_PATH = PrivateHeaders
//BUNDLE_PUBLIC_HEADERS_FOLDER_PATH = Headers
//CACHE_ROOT = /var/folders/3f/y159bq_d07b8fskd9sp_3sym0000gn/C/com.apple.DeveloperTools/12.5.1-12E507/Xcode
//CCHROOT = /var/folders/3f/y159bq_d07b8fskd9sp_3sym0000gn/C/com.apple.DeveloperTools/12.5.1-12E507/Xcode
//CHMOD = /bin/chmod
//CHOWN = /usr/sbin/chown
//CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED = YES
//CLANG_ANALYZER_NONNULL = YES
//CLANG_ENABLE_MODULES = YES
//CLANG_ENABLE_OBJC_ARC = YES
//CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES
//CLANG_WARN_BOOL_CONVERSION = YES
//CLANG_WARN_COMMA = YES
//CLANG_WARN_CONSTANT_CONVERSION = YES
//CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES
//CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR
//CLANG_WARN_DOCUMENTATION_COMMENTS = YES
//CLANG_WARN_EMPTY_BODY = YES
//CLANG_WARN_ENUM_CONVERSION = YES
//CLANG_WARN_INFINITE_RECURSION = YES
//CLANG_WARN_INT_CONVERSION = YES
//CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES
//CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES
//CLANG_WARN_OBJC_LITERAL_CONVERSION = YES
//CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR
//CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = NO
//CLANG_WARN_RANGE_LOOP_ANALYSIS = YES
//CLANG_WARN_STRICT_PROTOTYPES = YES
//CLANG_WARN_SUSPICIOUS_MOVE = YES
//CLANG_WARN_UNREACHABLE_CODE = YES
//CLANG_WARN__DUPLICATE_METHOD_MATCH = YES
//CLASS_FILE_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/JavaClasses
//CLEAN_PRECOMPS = YES
//CLONE_HEADERS = NO
//COCOAPODS_PARALLEL_CODE_SIGN = true
//CODESIGNING_FOLDER_PATH = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DodoPizza.app
//CODE_SIGNING_ALLOWED = YES
//CODE_SIGNING_REQUIRED = YES
//CODE_SIGN_CONTEXT_CLASS = XCiPhoneOSCodeSignContext
//CODE_SIGN_ENTITLEMENTS = DodoPizza/DodoPizza.entitlements
//CODE_SIGN_IDENTITY = Apple Distribution: Dodo Franchaizing, OOO (AVGCX5Z5VU)
//CODE_SIGN_INJECT_BASE_ENTITLEMENTS = YES
//CODE_SIGN_STYLE = Manual
//COLOR_DIAGNOSTICS = NO
//COMBINE_HIDPI_IMAGES = NO
//COMPILER_INDEX_STORE_ENABLE = Default
//COMPOSITE_SDK_DIRS = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/CompositeSDKs
//COMPRESS_PNG_FILES = YES
//CONFIGURATION = Ad-Hoc
//CONFIGURATION_BUILD_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos
//CONFIGURATION_TEMP_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos
//CONTENTS_FOLDER_PATH = DodoPizza.app
//COPYING_PRESERVES_HFS_DATA = NO
//COPY_HEADERS_RUN_UNIFDEF = NO
//COPY_PHASE_STRIP = NO
//COPY_RESOURCES_FROM_STATIC_FRAMEWORKS = YES
//CORRESPONDING_SIMULATOR_PLATFORM_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform
//CORRESPONDING_SIMULATOR_PLATFORM_NAME = iphonesimulator
//CORRESPONDING_SIMULATOR_SDK_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator14.5.sdk
//CORRESPONDING_SIMULATOR_SDK_NAME = iphonesimulator14.5
//CP = /bin/cp
//CREATE_INFOPLIST_SECTION_IN_BINARY = NO
//CURRENT_ARCH = arm64
//CURRENT_PROJECT_VERSION = 7890
//CURRENT_VARIANT = normal
//DEAD_CODE_STRIPPING = YES
//DEBUGGING_SYMBOLS = YES
//DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
//DEFAULT_COMPILER = com.apple.compilers.llvm.clang.1_0
//DEFAULT_DEXT_INSTALL_PATH = /System/Library/DriverExtensions
//DEFAULT_KEXT_INSTALL_PATH = /System/Library/Extensions
//DEFINES_MODULE = NO
//DEPLOYMENT_LOCATION = NO
//DEPLOYMENT_POSTPROCESSING = NO
//DEPLOYMENT_TARGET_CLANG_ENV_NAME = IPHONEOS_DEPLOYMENT_TARGET
//DEPLOYMENT_TARGET_CLANG_FLAG_NAME = miphoneos-version-min
//DEPLOYMENT_TARGET_CLANG_FLAG_PREFIX = -miphoneos-version-min=
//DEPLOYMENT_TARGET_LD_ENV_NAME = IPHONEOS_DEPLOYMENT_TARGET
//DEPLOYMENT_TARGET_LD_FLAG_NAME = ios_version_min
//DEPLOYMENT_TARGET_SETTING_NAME = IPHONEOS_DEPLOYMENT_TARGET
//DEPLOYMENT_TARGET_SUGGESTED_VALUES = 9.0 9.2 10.0 10.2 11.0 11.2 11.4 12.1 12.3 13.0 13.2 13.4 13.6 14.1 14.3 14.5
//DERIVED_FILES_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/DerivedSources
//DERIVED_FILE_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/DerivedSources
//DERIVED_SOURCES_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/DerivedSources
//DEVELOPER_APPLICATIONS_DIR = /Applications/Xcode.app/Contents/Developer/Applications
//DEVELOPER_BIN_DIR = /Applications/Xcode.app/Contents/Developer/usr/bin
//DEVELOPER_DIR = /Applications/Xcode.app/Contents/Developer
//DEVELOPER_FRAMEWORKS_DIR = /Applications/Xcode.app/Contents/Developer/Library/Frameworks
//DEVELOPER_FRAMEWORKS_DIR_QUOTED = /Applications/Xcode.app/Contents/Developer/Library/Frameworks
//DEVELOPER_LIBRARY_DIR = /Applications/Xcode.app/Contents/Developer/Library
//DEVELOPER_SDK_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs
//DEVELOPER_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Tools
//DEVELOPER_USR_DIR = /Applications/Xcode.app/Contents/Developer/usr
//DEVELOPMENT_LANGUAGE = en
//DEVELOPMENT_TEAM = AVGCX5Z5VU
//DOCUMENTATION_FOLDER_PATH = DodoPizza.app/en.lproj/Documentation
//DONT_GENERATE_INFOPLIST_FILE = NO
//DO_HEADER_SCANNING_IN_JAM = NO
//DSTROOT = /tmp/DodoPizza.dst
//DT_TOOLCHAIN_DIR = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain
//DWARF_DSYM_FILE_NAME = DodoPizza.app.dSYM
//DWARF_DSYM_FILE_SHOULD_ACCOMPANY_PRODUCT = NO
//DWARF_DSYM_FOLDER_PATH = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos
//EFFECTIVE_PLATFORM_NAME = -iphoneos
//EMBEDDED_CONTENT_CONTAINS_SWIFT = NO
//EMBEDDED_PROFILE_NAME = embedded.mobileprovision
//EMBED_ASSET_PACKS_IN_PRODUCT_BUNDLE = NO
//ENABLE_BITCODE = YES
//ENABLE_DEFAULT_HEADER_SEARCH_PATHS = YES
//ENABLE_HARDENED_RUNTIME = NO
//ENABLE_HEADER_DEPENDENCIES = YES
//ENABLE_NS_ASSERTIONS = NO
//ENABLE_ON_DEMAND_RESOURCES = YES
//ENABLE_STRICT_OBJC_MSGSEND = YES
//ENABLE_TESTABILITY = NO
//ENABLE_TESTING_SEARCH_PATHS = NO
//ENTITLEMENTS_ALLOWED = YES
//ENTITLEMENTS_DESTINATION = Signature
//ENTITLEMENTS_REQUIRED = YES
//EXCLUDED_INSTALLSRC_SUBDIRECTORY_PATTERNS = .DS_Store .svn .git .hg CVS
//EXCLUDED_RECURSIVE_SEARCH_PATH_SUBDIRECTORIES = *.nib *.lproj *.framework *.gch *.xcode* *.xcassets (*) .DS_Store CVS .svn .git .hg *.pbproj *.pbxproj
//EXECUTABLES_FOLDER_PATH = DodoPizza.app/Executables
//EXECUTABLE_FOLDER_PATH = DodoPizza.app
//EXECUTABLE_NAME = DodoPizza
//EXECUTABLE_PATH = DodoPizza.app/DodoPizza
//EXPANDED_CODE_SIGN_IDENTITY =
//EXPANDED_CODE_SIGN_IDENTITY_NAME =
//EXPANDED_PROVISIONING_PROFILE =
//FILE_LIST = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/Objects/LinkFileList
//FIXED_FILES_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/FixedFiles
//FRAMEWORKS_FOLDER_PATH = DodoPizza.app/Frameworks
//FRAMEWORK_FLAG_PREFIX = -framework
//FRAMEWORK_SEARCH_PATHS =  /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/FirebaseAnalytics/Frameworks \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Acquirers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Address\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/AppSetup\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/AreYouInPizzeria\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Auth\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Autocomplete\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/BRYXBanner\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Bagel\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/BlackBox\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Bonuses\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Cart\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Chat\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/CheckAPI\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Checkout\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/CityLanding\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/CocoaAsyncSocket\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Crypto\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DAnalytics\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DCommon\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DFoundation\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DID\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DMapKit\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DNetwork\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DPushNotifications\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DSecurity\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DUIKit\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DataPersistence\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DeliveryLocation\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DeliveryLocationUI\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DeviceKit\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Domain\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Dune\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DynamicType\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseABTesting\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseCore\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseCoreDiagnostics\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseCrashlytics\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseDynamicLinks\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseInstallations\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseMessaging\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebasePerformance\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseRemoteConfig\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Geolocation\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/GoogleDataTransport\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/GoogleUtilities\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/HCaptcha\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/KVOController\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/KeychainSwift\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Kusto\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/LKAlertController\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Locality\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Loyalty\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/MARoundButton\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/MBProgressHUD\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Menu\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/MenuSearch\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Mindbox\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/MobileBackend\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/NCallback\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/NInject\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/NQueue\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/NRequest\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Nuke\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/OrderHistory\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/OrderHistoryDomain\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/OrderTracking\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/PREBorderView\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/ParallaxEditor\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Payment\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Phone\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/PinLayout\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Pizzeria\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Product\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/PromisesObjC\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Protobuf\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/RTIconButton\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Rate\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/SZTextView\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/ServicePush\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/State\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Stories\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/SwCrypt\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/libPhoneNumber-iOS\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/nanopb\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/AppsFlyerFramework\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/FirebaseAnalytics/Frameworks\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/GoogleAppMeasurement/Frameworks\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/InAppStory\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Threads\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/XCFrameworkIntermediates/AppsFlyerFramework/Main\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/XCFrameworkIntermediates/FirebaseAnalytics/Base\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/XCFrameworkIntermediates/GoogleAppMeasurement/AdIdSupport\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/XCFrameworkIntermediates/InAppStory\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/XCFrameworkIntermediates/Threads\"
//FRAMEWORK_VERSION = A
//FULL_PRODUCT_NAME = DodoPizza.app
//GCC3_VERSION = 3.3
//GCC_INLINES_ARE_PRIVATE_EXTERN = YES
//GCC_NO_COMMON_BLOCKS = YES
//GCC_PFE_FILE_C_DIALECTS = c objective-c c++ objective-c++
//GCC_PREPROCESSOR_DEFINITIONS =  SHOULD_USE_DEBUG=1 COCOAPODS=1  SHOULD_USE_DEBUG=1 GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1  SHOULD_USE_DEBUG=1 PB_FIELD_32BIT=1 PB_NO_PACKED_STRUCTS=1 PB_ENABLE_MALLOC=1
//GCC_SYMBOLS_PRIVATE_EXTERN = YES
//GCC_THUMB_SUPPORT = YES
//GCC_TREAT_WARNINGS_AS_ERRORS = NO
//GCC_VERSION = com.apple.compilers.llvm.clang.1_0
//GCC_VERSION_IDENTIFIER = com_apple_compilers_llvm_clang_1_0
//GCC_WARN_64_TO_32_BIT_CONVERSION = YES
//GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR
//GCC_WARN_UNDECLARED_SELECTOR = YES
//GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE
//GCC_WARN_UNUSED_FUNCTION = YES
//GCC_WARN_UNUSED_LABEL = YES
//GCC_WARN_UNUSED_PARAMETER = YES
//GCC_WARN_UNUSED_VARIABLE = YES
//GENERATED_MODULEMAP_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/GeneratedModuleMaps-iphoneos
//GENERATE_MASTER_OBJECT_FILE = NO
//GENERATE_PKGINFO_FILE = YES
//GENERATE_PROFILING_CODE = NO
//GENERATE_TEXT_BASED_STUBS = NO
//GID = 20
//GROUP = staff
//HEADERMAP_INCLUDES_FLAT_ENTRIES_FOR_TARGET_BEING_BUILT = YES
//HEADERMAP_INCLUDES_FRAMEWORK_ENTRIES_FOR_ALL_PRODUCT_TYPES = YES
//HEADERMAP_INCLUDES_NONPUBLIC_NONPRIVATE_HEADERS = YES
//HEADERMAP_INCLUDES_PROJECT_HEADERS = YES
//HEADERMAP_USES_FRAMEWORK_PREFIX_ENTRIES = YES
//HEADERMAP_USES_VFS = NO
//HEADER_SEARCH_PATHS =  /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Firebase/Core/Sources \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public/CardIO\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public/Firebase\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public/GoogleAnalytics\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Acquirers/Acquirers.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Address/Address.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/AppSetup/AppSetup.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/AreYouInPizzeria/AreYouInPizzeria.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Auth/Auth.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Autocomplete/Autocomplete.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/BRYXBanner/BRYXBanner.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Bagel/Bagel.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/BlackBox/BlackBox.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Bonuses/Bonuses.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Cart/Cart.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Chat/Chat.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/CheckAPI/CheckAPI.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Checkout/Checkout.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/CityLanding/CityLanding.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/CocoaAsyncSocket/CocoaAsyncSocket.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Crypto/Crypto.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DAnalytics/DAnalytics.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DCommon/DCommon.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DFoundation/DFoundation.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DID/DID.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DMapKit/DMapKit.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DNetwork/DNetwork.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DPushNotifications/DPushNotifications.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DSecurity/DSecurity.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DUIKit/DUIKit.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DataPersistence/DataPersistence.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DeliveryLocation/DeliveryLocation.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DeliveryLocationUI/DeliveryLocationUI.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DeviceKit/DeviceKit.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Domain/Domain.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Dune/Dune.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DynamicType/DynamicType.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseABTesting/FirebaseABTesting.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseCore/FirebaseCore.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseCoreDiagnostics/FirebaseCoreDiagnostics.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseCrashlytics/FirebaseCrashlytics.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseDynamicLinks/FirebaseDynamicLinks.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseInstallations/FirebaseInstallations.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseMessaging/FirebaseMessaging.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebasePerformance/FirebasePerformance.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/FirebaseRemoteConfig/FirebaseRemoteConfig.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Geolocation/Geolocation.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/GoogleDataTransport/GoogleDataTransport.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/GoogleUtilities/GoogleUtilities.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/HCaptcha/HCaptcha.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/KVOController/KVOController.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/KeychainSwift/KeychainSwift.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Kusto/Kusto.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/LKAlertController/LKAlertController.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Locality/Locality.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Loyalty/Loyalty.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/MARoundButton/MARoundButton.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/MBProgressHUD/MBProgressHUD.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Menu/Menu.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/MenuSearch/MenuSearch.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Mindbox/Mindbox.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/MobileBackend/MobileBackend.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/NCallback/NCallback.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/NInject/NInject.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/NQueue/NQueue.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/NRequest/NRequest.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Nuke/Nuke.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/OrderHistory/OrderHistory.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/OrderHistoryDomain/OrderHistoryDomain.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/OrderTracking/OrderTracking.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/PREBorderView/PREBorderView.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/ParallaxEditor/ParallaxEditor.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Payment/Payment.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Phone/Phone.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/PinLayout/PinLayout.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Pizzeria/Pizzeria.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Product/Product.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/PromisesObjC/FBLPromises.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Protobuf/Protobuf.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/RTIconButton/RTIconButton.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Rate/Rate.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/SZTextView/SZTextView.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/ServicePush/ServicePush.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/State/State.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/Stories/Stories.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/SwCrypt/SwCrypt.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/libPhoneNumber-iOS/libPhoneNumber_iOS.framework/Headers\" \"/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/nanopb/nanopb.framework/Headers\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public/Firebase\"  /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Firebase/Core/Sources \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public/CardIO\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public/Firebase\" \"/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Headers/Public/GoogleAnalytics\" /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods/Firebase/CoreOnly/Sources \"/Sources/FBLPromises/include\"
//HIDE_BITCODE_SYMBOLS = YES
//HOME = /Users/yaroslavbredikhin
//ICONV = /usr/bin/iconv
//INFOPLIST_EXPAND_BUILD_SETTINGS = YES
//INFOPLIST_FILE = DodoPizza/Info.plist
//INFOPLIST_OUTPUT_FORMAT = binary
//INFOPLIST_PATH = DodoPizza.app/Info.plist
//INFOPLIST_PREPROCESS = NO
//INFOSTRINGS_PATH = DodoPizza.app/en.lproj/InfoPlist.strings
//INLINE_PRIVATE_FRAMEWORKS = NO
//INSTALLHDRS_COPY_PHASE = NO
//INSTALLHDRS_SCRIPT_PHASE = NO
//INSTALL_DIR = /tmp/DodoPizza.dst/Applications
//INSTALL_GROUP = staff
//INSTALL_MODE_FLAG = u+w,go-w,a+rX
//INSTALL_OWNER = yaroslavbredikhin
//INSTALL_PATH = /Applications
//INSTALL_ROOT = /tmp/DodoPizza.dst
//IPHONEOS_DEPLOYMENT_TARGET = 10.0
//JAVAC_DEFAULT_FLAGS = -J-Xms64m -J-XX:NewSize=4M -J-Dfile.encoding=UTF8
//JAVA_APP_STUB = /System/Library/Frameworks/JavaVM.framework/Resources/MacOS/JavaApplicationStub
//JAVA_ARCHIVE_CLASSES = YES
//JAVA_ARCHIVE_TYPE = JAR
//JAVA_COMPILER = /usr/bin/javac
//JAVA_FOLDER_PATH = DodoPizza.app/Java
//JAVA_FRAMEWORK_RESOURCES_DIRS = Resources
//JAVA_JAR_FLAGS = cv
//JAVA_SOURCE_SUBDIR = .
//JAVA_USE_DEPENDENCIES = YES
//JAVA_ZIP_FLAGS = -urg
//JIKES_DEFAULT_FLAGS = +E +OLDCSO
//KASAN_DEFAULT_CFLAGS = -DKASAN=1 -fsanitize=address -mllvm -asan-globals-live-support -mllvm -asan-force-dynamic-shadow
//KEEP_PRIVATE_EXTERNS = NO
//LD_DEPENDENCY_INFO_FILE = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/Objects-normal/arm64/DodoPizza_dependency_info.dat
//LD_GENERATE_MAP_FILE = NO
//LD_MAP_FILE_PATH = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/DodoPizza-LinkMap-normal-arm64.txt
//LD_NO_PIE = NO
//LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER = YES
//LD_RUNPATH_SEARCH_PATHS =  @executable_path/Frameworks /usr/lib/swift \'@executable_path/Frameworks\' \'@loader_path/Frameworks\' @executable_path/Frameworks
//LEGACY_DEVELOPER_DIR = /Applications/Xcode.app/Contents/PlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer
//LEX = lex
//LIBRARY_DEXT_INSTALL_PATH = /Library/DriverExtensions
//LIBRARY_FLAG_NOSPACE = YES
//LIBRARY_FLAG_PREFIX = -l
//LIBRARY_KEXT_INSTALL_PATH = /Library/Extensions
//LIBRARY_SEARCH_PATHS =  \"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos\" /usr/lib/swift
//LINKER_DISPLAYS_MANGLED_NAMES = NO
//LINK_FILE_LIST_normal_arm64 =
//LINK_WITH_STANDARD_LIBRARIES = YES
//LLVM_TARGET_TRIPLE_OS_VERSION = ios10.0
//LLVM_TARGET_TRIPLE_VENDOR = apple
//LOCALIZABLE_CONTENT_DIR =
//LOCALIZATION_EXPORT_SUPPORTED = YES
//LOCALIZED_RESOURCES_FOLDER_PATH = DodoPizza.app/en.lproj
//LOCALIZED_STRING_MACRO_NAMES = NSLocalizedString CFCopyLocalizedString
//LOCALIZED_STRING_SWIFTUI_SUPPORT = YES
//LOCAL_ADMIN_APPS_DIR = /Applications/Utilities
//LOCAL_APPS_DIR = /Applications
//LOCAL_DEVELOPER_DIR = /Library/Developer
//LOCAL_LIBRARY_DIR = /Library
//LOCROOT =
//LOCSYMROOT =
//MACH_O_TYPE = mh_execute
//MAC_OS_X_PRODUCT_BUILD_VERSION = 20D74
//MAC_OS_X_VERSION_ACTUAL = 110201
//MAC_OS_X_VERSION_MAJOR = 110000
//MAC_OS_X_VERSION_MINOR = 110200
//MARKETING_VERSION = 8.16.2
//METAL_LIBRARY_FILE_BASE = default
//METAL_LIBRARY_OUTPUT_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DodoPizza.app
//MODULES_FOLDER_PATH = DodoPizza.app/Modules
//MODULE_CACHE_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
//NATIVE_ARCH = armv7
//NATIVE_ARCH_32_BIT = i386
//NATIVE_ARCH_64_BIT = x86_64
//NATIVE_ARCH_ACTUAL = x86_64
//NO_COMMON = YES
//OBJECT_FILE_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/Objects
//OBJECT_FILE_DIR_normal = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/Objects-normal
//OBJROOT = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex
//ONLY_ACTIVE_ARCH = YES
//OS = MACOS
//OSAC = /usr/bin/osacompile
//OTHER_LDFLAGS =  -ObjC -l\"c++\" -l\"sqlite3\" -l\"z\" -framework \"Acquirers\" -framework \"Address\" -framework \"AppSetup\" -framework \"AppsFlyerLib\" -framework \"AreYouInPizzeria\" -framework \"Auth\" -framework \"Autocomplete\" -framework \"BRYXBanner\" -framework \"Bagel\" -framework \"BlackBox\" -framework \"Bonuses\" -framework \"CFNetwork\" -framework \"Cart\" -framework \"Chat\" -framework \"CheckAPI\" -framework \"Checkout\" -framework \"CityLanding\" -framework \"CocoaAsyncSocket\" -framework \"CoreGraphics\" -framework \"CoreTelephony\" -framework \"Crypto\" -framework \"DAnalytics\" -framework \"DCommon\" -framework \"DFoundation\" -framework \"DID\" -framework \"DMapKit\" -framework \"DNetwork\" -framework \"DPushNotifications\" -framework \"DSecurity\" -framework \"DUIKit\" -framework \"DataPersistence\" -framework \"DeliveryLocation\" -framework \"DeliveryLocationUI\" -framework \"DeviceKit\" -framework \"Domain\" -framework \"Dune\" -framework \"DynamicType\" -framework \"EDNAPushLite\" -framework \"FBLPromises\" -framework \"FirebaseABTesting\" -framework \"FirebaseAnalytics\" -framework \"FirebaseCore\" -framework \"FirebaseCoreDiagnostics\" -framework \"FirebaseCrashlytics\" -framework \"FirebaseDynamicLinks\" -framework \"FirebaseInstallations\" -framework \"FirebaseMessaging\" -framework \"FirebasePerformance\" -framework \"FirebaseRemoteConfig\" -framework \"Foundation\" -framework \"Geolocation\" -framework \"GoogleAppMeasurement\" -framework \"GoogleDataTransport\" -framework \"GoogleUtilities\" -framework \"HCaptcha\" -framework \"InAppStorySDK\" -framework \"KVOController\" -framework \"KeychainSwift\" -framework \"Kusto\" -framework \"LKAlertController\" -framework \"Locality\" -framework \"Loyalty\" -framework \"MARoundButton\" -framework \"MBProgressHUD\" -framework \"Menu\" -framework \"MenuSearch\" -framework \"MessageUI\" -framework \"Mindbox\" -framework \"MobileBackend\" -framework \"MobileCoreServices\" -framework \"NCallback\" -framework \"NInject\" -framework \"NQueue\" -framework \"NRequest\" -framework \"Nuke\" -framework \"OrderHistory\" -framework \"OrderHistoryDomain\" -framework \"OrderTracking\" -framework \"PREBorderView\" -framework \"ParallaxEditor\" -framework \"Payment\" -framework \"Phone\" -framework \"PinLayout\" -framework \"Pizzeria\" -framework \"Product\" -framework \"Protobuf\" -framework \"QuartzCore\" -framework \"RTIconButton\" -framework \"Rate\" -framework \"SZTextView\" -framework \"Security\" -framework \"ServicePush\" -framework \"SpriteKit\" -framework \"State\" -framework \"StoreKit\" -framework \"Stories\" -framework \"SwCrypt\" -framework \"SystemConfiguration\" -framework \"Threads\" -framework \"UIKit\" -framework \"UniformTypeIdentifiers\" -framework \"WebKit\" -framework \"libPhoneNumber_iOS\" -framework \"nanopb\" -weak_framework \"UserNotifications\" -weak_framework \"WebKit\"
//OTHER_SWIFT_FLAGS =  -D COCOAPODS
//PACKAGE_TYPE = com.apple.package-type.wrapper.application
//PASCAL_STRINGS = YES
//PATH = /Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin
//PATH_PREFIXES_EXCLUDED_FROM_HEADER_DEPENDENCIES = /usr/include /usr/local/include /System/Library/Frameworks /System/Library/PrivateFrameworks /Applications/Xcode.app/Contents/Developer/Headers /Applications/Xcode.app/Contents/Developer/SDKs /Applications/Xcode.app/Contents/Developer/Platforms
//PBDEVELOPMENTPLIST_PATH = DodoPizza.app/pbdevelopment.plist
//PKGINFO_FILE_PATH = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/PkgInfo
//PKGINFO_PATH = DodoPizza.app/PkgInfo
//PLATFORM_DEVELOPER_APPLICATIONS_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Applications
//PLATFORM_DEVELOPER_BIN_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin
//PLATFORM_DEVELOPER_LIBRARY_DIR = /Applications/Xcode.app/Contents/PlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer/Library
//PLATFORM_DEVELOPER_SDK_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs
//PLATFORM_DEVELOPER_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Tools
//PLATFORM_DEVELOPER_USR_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr
//PLATFORM_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform
//PLATFORM_DISPLAY_NAME = iOS
//PLATFORM_NAME = iphoneos
//PLATFORM_PREFERRED_ARCH = arm64
//PLATFORM_PRODUCT_BUILD_VERSION = 18E182
//PLIST_FILE_OUTPUT_FORMAT = binary
//PLUGINS_FOLDER_PATH = DodoPizza.app/PlugIns
//PODS_BUILD_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products
//PODS_CONFIGURATION_BUILD_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos
//PODS_PODFILE_DIR_PATH = /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/.
//PODS_ROOT = /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/Pods
//PODS_XCFRAMEWORKS_BUILD_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/XCFrameworkIntermediates
//PRECOMPS_INCLUDE_HEADERS_FROM_BUILT_PRODUCTS_DIR = YES
//PRECOMP_DESTINATION_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/PrefixHeaders
//PRESERVE_DEAD_CODE_INITS_AND_TERMS = NO
//PRIVATE_HEADERS_FOLDER_PATH = DodoPizza.app/PrivateHeaders
//PRODUCT_BUNDLE_IDENTIFIER = ru.dodopizza.DodoPizza.beta
//PRODUCT_BUNDLE_PACKAGE_TYPE = APPL
//PRODUCT_MODULE_NAME = DodoPizza
//PRODUCT_NAME = DodoPizza
//PRODUCT_SETTINGS_PATH = /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/DodoPizza/Info.plist
//PRODUCT_TYPE = com.apple.product-type.application
//PRODUCT_VERSION = 8.16.2
//PROFILING_CODE = NO
//PROJECT = DodoPizza
//PROJECT_DERIVED_FILE_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/DerivedSources
//PROJECT_DIR = /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza
//PROJECT_FILE_PATH = /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza/DodoPizza.xcodeproj
//PROJECT_NAME = DodoPizza
//PROJECT_TEMP_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build
//PROJECT_TEMP_ROOT = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex
//PROVISIONING_PROFILE_REQUIRED = YES
//PROVISIONING_PROFILE_SPECIFIER = match AdHoc ru.dodopizza.DodoPizza.beta
//PUBLIC_HEADERS_FOLDER_PATH = DodoPizza.app/Headers
//RECURSIVE_SEARCH_PATHS_FOLLOW_SYMLINKS = YES
//REMOVE_CVS_FROM_RESOURCES = YES
//REMOVE_GIT_FROM_RESOURCES = YES
//REMOVE_HEADERS_FROM_EMBEDDED_BUNDLES = YES
//REMOVE_HG_FROM_RESOURCES = YES
//REMOVE_SVN_FROM_RESOURCES = YES
//RESOURCE_RULES_REQUIRED = YES
//REZ_COLLECTOR_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/ResourceManagerResources
//REZ_OBJECTS_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build/ResourceManagerResources/Objects
//SCAN_ALL_SOURCE_FILES_FOR_INCLUDES = NO
//SCRIPTS_FOLDER_PATH = DodoPizza.app/Scripts
//SDKROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.5.sdk
//SDK_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.5.sdk
//SDK_DIR_iphoneos14_5 = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.5.sdk
//SDK_NAME = iphoneos14.5
//SDK_NAMES = iphoneos14.5
//SDK_PRODUCT_BUILD_VERSION = 18E182
//SDK_VERSION = 14.5
//SDK_VERSION_ACTUAL = 140500
//SDK_VERSION_MAJOR = 140000
//SDK_VERSION_MINOR = 140500
//SED = /usr/bin/sed
//SEPARATE_STRIP = NO
//SEPARATE_SYMBOL_EDIT = NO
//SET_DIR_MODE_OWNER_GROUP = YES
//SET_FILE_MODE_OWNER_GROUP = NO
//SHALLOW_BUNDLE = YES
//SHARED_DERIVED_FILE_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos/DerivedSources
//SHARED_FRAMEWORKS_FOLDER_PATH = DodoPizza.app/SharedFrameworks
//SHARED_PRECOMPS_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/PrecompiledHeaders
//SHARED_SUPPORT_FOLDER_PATH = DodoPizza.app/SharedSupport
//SKIP_INSTALL = NO
//SOURCE_ROOT = /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza
//SRCROOT = /Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza
//STRINGS_FILE_INFOPLIST_RENAME = YES
//STRINGS_FILE_OUTPUT_ENCODING = binary
//STRIP_BITCODE_FROM_COPIED_FILES = YES
//STRIP_INSTALLED_PRODUCT = YES
//STRIP_STYLE = all
//STRIP_SWIFT_SYMBOLS = YES
//SUPPORTED_DEVICE_FAMILIES = 1,2
//SUPPORTED_PLATFORMS = iphonesimulator iphoneos
//SUPPORTS_MACCATALYST = NO
//SUPPORTS_TEXT_BASED_API = NO
//SWIFT_ACTIVE_COMPILATION_CONDITIONS = SHOULD_USE_DEBUG
//SWIFT_COMPILATION_MODE = wholemodule
//SWIFT_OPTIMIZATION_LEVEL = -O
//SWIFT_PLATFORM_TARGET_PREFIX = ios
//SWIFT_PRECOMPILE_BRIDGING_HEADER = NO
//SWIFT_VERSION = 5.0
//SYMROOT = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products
//SYSTEM_ADMIN_APPS_DIR = /Applications/Utilities
//SYSTEM_APPS_DIR = /Applications
//SYSTEM_CORE_SERVICES_DIR = /System/Library/CoreServices
//SYSTEM_DEMOS_DIR = /Applications/Extras
//SYSTEM_DEVELOPER_APPS_DIR = /Applications/Xcode.app/Contents/Developer/Applications
//SYSTEM_DEVELOPER_BIN_DIR = /Applications/Xcode.app/Contents/Developer/usr/bin
//SYSTEM_DEVELOPER_DEMOS_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Utilities/Built Examples
//SYSTEM_DEVELOPER_DIR = /Applications/Xcode.app/Contents/Developer
//SYSTEM_DEVELOPER_DOC_DIR = /Applications/Xcode.app/Contents/Developer/ADC Reference Library
//SYSTEM_DEVELOPER_GRAPHICS_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Graphics Tools
//SYSTEM_DEVELOPER_JAVA_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Java Tools
//SYSTEM_DEVELOPER_PERFORMANCE_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Performance Tools
//SYSTEM_DEVELOPER_RELEASENOTES_DIR = /Applications/Xcode.app/Contents/Developer/ADC Reference Library/releasenotes
//SYSTEM_DEVELOPER_TOOLS = /Applications/Xcode.app/Contents/Developer/Tools
//SYSTEM_DEVELOPER_TOOLS_DOC_DIR = /Applications/Xcode.app/Contents/Developer/ADC Reference Library/documentation/DeveloperTools
//SYSTEM_DEVELOPER_TOOLS_RELEASENOTES_DIR = /Applications/Xcode.app/Contents/Developer/ADC Reference Library/releasenotes/DeveloperTools
//SYSTEM_DEVELOPER_USR_DIR = /Applications/Xcode.app/Contents/Developer/usr
//SYSTEM_DEVELOPER_UTILITIES_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Utilities
//SYSTEM_DEXT_INSTALL_PATH = /System/Library/DriverExtensions
//SYSTEM_DOCUMENTATION_DIR = /Library/Documentation
//SYSTEM_KEXT_INSTALL_PATH = /System/Library/Extensions
//SYSTEM_LIBRARY_DIR = /System/Library
//TAPI_VERIFY_MODE = ErrorsOnly
//TARGETED_DEVICE_FAMILY = 1
//TARGETNAME = DodoPizza
//TARGET_BUILD_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Products/Ad-Hoc-iphoneos
//TARGET_NAME = DodoPizza
//TARGET_TEMP_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build
//TEMP_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build
//TEMP_FILES_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build
//TEMP_FILE_DIR = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex/DodoPizza.build/Ad-Hoc-iphoneos/DodoPizza.build
//TEMP_ROOT = /Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-cjfoycogvzgsoabaqbokfyxwztuu/Build/Intermediates.noindex
//TEST_FRAMEWORK_SEARCH_PATHS =  /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Frameworks /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.5.sdk/Developer/Library/Frameworks
//TEST_LIBRARY_SEARCH_PATHS =  /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib
//TOOLCHAIN_DIR = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain
//TREAT_MISSING_BASELINES_AS_TEST_FAILURES = NO
//UID = 501
//UNLOCALIZED_RESOURCES_FOLDER_PATH = DodoPizza.app
//UNSTRIPPED_PRODUCT = NO
//USER = yaroslavbredikhin
//USER_APPS_DIR = /Users/yaroslavbredikhin/Applications
//USER_LIBRARY_DIR = /Users/yaroslavbredikhin/Library
//USE_DYNAMIC_NO_PIC = YES
//USE_HEADERMAP = YES
//USE_HEADER_SYMLINKS = NO
//USE_LLVM_TARGET_TRIPLES = YES
//USE_LLVM_TARGET_TRIPLES_FOR_CLANG = YES
//USE_LLVM_TARGET_TRIPLES_FOR_LD = YES
//USE_LLVM_TARGET_TRIPLES_FOR_TAPI = YES
//USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES = YES
//VALIDATE_PRODUCT = YES
//VALIDATE_WORKSPACE = NO
//VALID_ARCHS = arm64 arm64e armv7 armv7s
//VERBOSE_PBXCP = NO
//VERSIONPLIST_PATH = DodoPizza.app/version.plist
//VERSION_INFO_BUILDER = yaroslavbredikhin
//VERSION_INFO_FILE = DodoPizza_vers.c
//VERSION_INFO_STRING = \"@(#)PROGRAM:DodoPizza  PROJECT:DodoPizza-7890\"
//WRAPPER_EXTENSION = app
//WRAPPER_NAME = DodoPizza.app
//WRAPPER_SUFFIX = .app
//WRAP_ASSET_PACKS_IN_SEPARATE_DIRECTORIES = NO
//XCODE_APP_SUPPORT_DIR = /Applications/Xcode.app/Contents/Developer/Library/Xcode
//XCODE_PRODUCT_BUILD_VERSION = 12E507
//XCODE_VERSION_ACTUAL = 1251
//XCODE_VERSION_MAJOR = 1200
//XCODE_VERSION_MINOR = 1250
//XPCSERVICES_FOLDER_PATH = DodoPizza.app/XPCServices
//YACC = yacc
//arch = arm64
//variant = normal
