//
//  ImageAsset.swift
//  PropupImagePicker
//
//  Created by yamato hagi on 2022/07/08.
//

import SwiftUI
import PhotosUI
//MARK: Selected Image Asset Model
struct ImageAsset: Identifiable {
    var id: String = UUID().uuidString
    var asset: PHAsset
    var thumbnail: UIImage?
    //MARK: Selected Image Index
    var assetIndex: Int = -1
}
