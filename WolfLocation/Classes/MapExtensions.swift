//
//  MapExtensions.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/9/18.
//

import MapKit
import WolfCore

extension MKMapPoint {
    public func convert(from mapRect: MKMapRect, to bounds: CGRect) -> CGPoint {
        let x2 = x.lerped(from: MKMapRectGetMinX(mapRect)..MKMapRectGetMaxX(mapRect), to: Double(bounds.minX)..Double(bounds.maxX))
        let y2 = y.lerped(from: MKMapRectGetMinY(mapRect)..MKMapRectGetMaxY(mapRect), to: Double(bounds.minY)..Double(bounds.maxY))
        let point = CGPoint(x: CGFloat(x2), y: CGFloat(y2))
        return point
    }
}

extension CGSize {
    public func convert(from bounds: CGRect, to mapRect: MKMapRect) -> MKMapPoint {
        let x2 = Double(width).lerped(from: Double(bounds.minX)..Double(bounds.maxX), to: MKMapRectGetMinX(mapRect)..MKMapRectGetMaxX(mapRect))
        let y2 = Double(height).lerped(from: Double(bounds.minY)..Double(bounds.maxY), to: MKMapRectGetMinY(mapRect)..MKMapRectGetMaxY(mapRect))
        let mapPoint = MKMapPoint(x: x2, y: y2)
        return mapPoint
    }
}

extension MKTileOverlay {
    public static func worldTileWidth(for zoomLevel: Int) -> Double {
        return pow(2, Double(zoomLevel))
    }
}

extension MKTileOverlayPath {
    public var mapRect: MKMapRect {
        let tileWidth = MKTileOverlay.worldTileWidth(for: z)
        let scale = Size(width: Double(x), height: Double(y)) / tileWidth
        let worldSize = MKMapSizeWorld
        let origin = MKMapPoint(x: worldSize.width * scale.width, y: worldSize.height * scale.height)
        let size = MKMapSize(width: worldSize.width / tileWidth, height: worldSize.height / tileWidth)
        return MKMapRect(origin: origin, size: size)
    }
}

public extension CLLocationCoordinate2D {
    public func convert(from mapRect: MKMapRect, to bounds: CGRect) -> CGPoint {
        let mapPoint = MKMapPointForCoordinate(self)
        return mapPoint.convert(from: mapRect, to: bounds)
    }

    public func translate(latitudeMeters: CLLocationDistance, longitudeMeters: CLLocationDistance) -> CLLocationCoordinate2D {
        let metersPerPoint = MKMetersPerMapPointAtLatitude(self.latitude)
        let latPoints = latitudeMeters / metersPerPoint
        let lonPoints = longitudeMeters / metersPerPoint

        let mapPoint = MKMapPointForCoordinate(self)
        let offsetMapPoint = MKMapPoint(x: mapPoint.x + lonPoints, y: mapPoint.y + latPoints)
        let offsetCoord = MKCoordinateForMapPoint(offsetMapPoint)
        return offsetCoord
    }

    public func rotated(by theta: Double, aroundCenter center: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let centerMapPoint = MKMapPointForCoordinate(center)
        let selfMapPoint = MKMapPointForCoordinate(self)

        let v = Vector(dx: selfMapPoint.x - centerMapPoint.x, dy: centerMapPoint.y - selfMapPoint.y)
        let v2 = v.rotated(by: theta)
        let p = MKMapPoint(x: centerMapPoint.x + v2.dx, y: centerMapPoint.y + v2.dy)
        let rotatedCoord = MKCoordinateForMapPoint(p)
        return rotatedCoord
    }
}

public extension MKCoordinateRegion {
    public var mapRect: MKMapRect {
        let halfLatDelta = span.latitudeDelta / 2
        let halfLonDelta = span.longitudeDelta / 2
        let topLeft = CLLocationCoordinate2D(latitude: center.latitude + halfLatDelta, longitude: center.longitude - halfLonDelta)
        let bottomRight = CLLocationCoordinate2D(latitude: center.latitude - halfLatDelta, longitude: center.longitude + halfLonDelta)

        let a = MKMapPointForCoordinate(topLeft)
        let b = MKMapPointForCoordinate(bottomRight)

        return MKMapRect(origin: MKMapPoint(x: min(a.x, b.x), y: min(a.y, b.y)), size: MKMapSize(width: abs(a.x - b.x), height: abs(a.y - b.y)))
    }
}
