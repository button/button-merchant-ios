import UIKit
@testable import ButtonMerchant

final class TestSystem: SystemProtocol {

    //Test Properties
    var testIsNewInstall = false
    var testCurrentDate: Date = Date.ISO8601Formatter.date(from: "2018-01-23T12:00:00Z")!
    var testSignals: Signals?

    // SystemProtocol
    var fileManager: FileManagerProtocol
    var calendar: CalendarProtocol
    var adIdManager: ASIdentifierManagerProtocol
    var device: UIDeviceProtocol
    var screen: UIScreenProtocol
    var locale: LocaleProtocol

    var currentDate: Date {
        return testCurrentDate
    }

    var isNewInstall: Bool {
        return testIsNewInstall
    }

    init(fileManager: FileManagerProtocol = TestFileManager(),
         calendar: CalendarProtocol = TestCalendar(),
         adIdManager: ASIdentifierManagerProtocol = TestAdIdManager(),
         device: UIDeviceProtocol = TestDevice(),
         screen: UIScreenProtocol = TestScreen(),
         locale: LocaleProtocol = TestLocale()) {
        self.fileManager = fileManager
        self.calendar = calendar
        self.adIdManager = adIdManager
        self.device = device
        self.screen = screen
        self.locale = locale
    }
}
