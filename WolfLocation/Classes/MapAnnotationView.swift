//
//  MapAnnotationView.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/9/18.
//

import MapKit

open class MapAnnotationView: MKAnnotationView {
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        _setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }

    private func _setup() {
        __setup()
        setup()
    }

    open func setup() { }
}
