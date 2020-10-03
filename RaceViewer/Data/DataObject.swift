import Foundation
import MapKit
import SwiftUI

struct DataObject: Codable {
  var aparentWindAngle: Decimal
  var apparentWindSpeed: Decimal
  var courseOverGround: Decimal
  var currentDrift: Decimal
  var currentSet: Decimal
  var heading: Decimal
  var latitude: Decimal
  var longitude: Decimal
  var speedOverGround: Decimal
  var timestamp: String
  var trueWindAngle: Decimal
  var trueWindDirection: Decimal
  var trueWindSpeed: Decimal
  var waterSpeed: Decimal
}

extension DataObject {
  var location: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: Angle(radians: latitude.doubleValue).degrees,
      longitude: Angle(radians: longitude.doubleValue).degrees
    )
  }
}

extension Decimal {
  var doubleValue: Double { (self as NSDecimalNumber).doubleValue }
}
