//
//  simd_float4x4+Extensions.swift
//  SpatialPhotos
//
//  Created by mio kato on 2021/04/18.
//

import Foundation
import simd

extension simd_float4x4 {
    var translation: simd_float3 {
        [columns.3.x, columns.3.y, columns.3.z]
    }
}
