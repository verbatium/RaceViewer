import Foundation
import MapKit

class WMSTileOverlay: MKTileOverlay {

  let scaleFactor = CGFloat(1)
  var url: String
  var useMercator: Bool
  let wmsVersion: String
  var alpha: CGFloat = 1.0

  init(urlArg: String, useMercator: Bool = false, wmsVersion: String) {
    self.url = urlArg
    self.useMercator = useMercator
    self.wmsVersion = wmsVersion
    super.init(urlTemplate: url)
    self.tileSize = CGSize(width: CGFloat(1024), height: CGFloat(1024))
  }

  func xOfColumn(column: Int, zoom: Int) -> Double {
    let xCoordinate = Double(column)
    let zCoordinate = Double(zoom)
    return xCoordinate / pow(2.0, zCoordinate) * 360.0 - 180
  }

  func yOfRow(row: Int, zoom: Int) -> Double {
    let yCoordinate = Double(row)
    let zCoordinate = Double(zoom)
    let factorN = Double.pi - 2.0 * Double.pi * yCoordinate / pow(2.0, zCoordinate)
    return 180.0 / Double.pi * atan(0.5 * (exp(factorN) - exp(-factorN)))
  }

  func mercatorXofLongitude(lon: Double) -> Double {
    lon * 20037508.34 / 180
  }

  func mercatorYofLatitude(lat: Double) -> Double {
    var yCoordinate = log(tan((90 + lat) * Double.pi / 360)) / (Double.pi / 180)
    yCoordinate = yCoordinate * 20037508.34 / 180
    return yCoordinate
  }

  public override func url(forTilePath path: MKTileOverlayPath) -> URL {
    var components = URLComponents(string: self.url)!
    components.queryItems = [
      URLQueryItem(name: "SERVICE", value: "WMS"),
      URLQueryItem(name: "REQUEST", value: "GetMap"),
      URLQueryItem(name: "FORMAT", value: "image/png"),
      URLQueryItem(name: "TRANSPARENT", value: "TRUE"),
      URLQueryItem(name: "TRANSPARENT", value: "TRUE"),
      URLQueryItem(name: "STYLES", value: ""),
      URLQueryItem(name: "LAYERS", value: "cells"),
      URLQueryItem(name: "WIDTH", value: "\(Int(self.tileSize.width / scaleFactor))"),
      URLQueryItem(name: "HEIGHT", value: "\(Int(self.tileSize.height / scaleFactor))"),
      URLQueryItem(name: "SRS", value: "EPSG:4326"),
      URLQueryItem(name: "VERSION", value: wmsVersion),
      URLQueryItem(name: "BBOX", value: bbox(for: path)),
    ]
    let url = components.url!
    return url
  }

  func bbox(for path: MKTileOverlayPath) -> String {
    var left = xOfColumn(column: path.x, zoom: path.z)
    var right = xOfColumn(column: path.x + 1, zoom: path.z)
    var bottom = yOfRow(row: path.y + 1, zoom: path.z)
    var top = yOfRow(row: path.y, zoom: path.z)
    if useMercator {
      left = mercatorXofLongitude(lon: left)  // minX
      right = mercatorXofLongitude(lon: right)  // maxX
      bottom = mercatorYofLatitude(lat: bottom)  // minY
      top = mercatorYofLatitude(lat: top)  // maxY
    }
    if wmsVersion.contains("1.3") {
      return "\(bottom),\(left),\(top),\(right)"
    } else {
      return "\(left),\(bottom),\(right),\(top)"
    }
  }

  func tileZ(zoomScale: MKZoomScale) -> Int {
    let numTilesAt10 = MKMapSize.world.width / Double(tileSize.width)
    let zoomLevelAt10 = log2(Float(numTilesAt10))
    let zoomLevel = max(0, zoomLevelAt10 + floor(log2f(Float(zoomScale)) + 0.5))
    return Int(zoomLevel)
  }
}
