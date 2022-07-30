//
//  ImagePickerViewModel.swift
//  PropupImagePicker
//
//  Created by yamato hagi on 2022/07/08.
//

import SwiftUI
import PhotosUI



class ImagePickerViewModel: NSObject, ObservableObject {
    // MARL: Properties
    @Published var fetchedImages: [ImageAsset] = []
    @Published var selectedImages: [ImageAsset] = []
    
    @Published var currentIndex:Int
    let beforeAry: [ImageAsset] = []
    var fetchResult: PHFetchResult<PHAsset>? = nil
    
    override init() {
        self.currentIndex = 0
        super.init()
        let beforeAry = fetchImages()
        self.fetchedImages = beforeAry
        PHPhotoLibrary.shared().register(self)
        
    }
    
    
    public func update(){
        
        fetchedImages = []
        fetchImages()
        print("あああaaaaaaaaaーーーーーーーーーーーーー")
        print(fetchedImages.count)
    }
    
    public func delete(){
        fetchedImages = []
        fetchImages()
        fetchedImages.remove(at: 0)
        print("あああaaaaaaaaaーーーーーーーーーーーーー")
        print(fetchedImages.count)
    }
    
    //MARK: Fetching Images
    public func fetchImages() -> Array<ImageAsset>{
        var ary:[ImageAsset] = []
        let options = PHFetchOptions()
        // MARK: Modify As Per Your Wish
        options.fetchLimit = 100
        options.includeHiddenAssets = true
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: .image,options: options)
        
        
        self.fetchResult?.enumerateObjects{ asset, _, _ in
            
            let imageAssset: ImageAsset = .init(asset: asset)
            ary.append(imageAssset)
        }
        return ary
        //こっちでは消せる
        //        var removeList: [ImageAsset] = []
        //        removeList.append(fetchedImages[0])
        //        self.fetchedImages.remove(at: 0)
        //        print("removelist")
        //        print(removeList)
        //        print(type(of: removeList))
        //        print(type(of: fetchedImages[0]))
        //        print("removelist")
    }
}


extension ImagePickerViewModel: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        //非同期で実行
        //非同期でなくてもよいならその必要はない
        DispatchQueue.main.async(execute: { () -> Void in
            
            //対比していたPHFetchResultを渡して、変更内容を取得
            //変更がない場合はnil
            if let fetchResult = self.fetchResult, let changeDetails = changeInstance.changeDetails(for:fetchResult) {
                //                       let newFetchResul = changeDetails.fetchResultAfterChanges
                
                
                var ary:[ImageAsset] = []
                
                //insertedObjectsには追加されたオブジェクトが入っている。
                //オブジェクトの型はFetchしたときの型で決まる。
                //今回はPHAsset。PHAssetCollectionにしたいときはself.fetchの取得時にPHAssetCollectionのメンバメソッドでFetchする
                if changeDetails.hasIncrementalChanges {
                    
                    var indexChenged = 0
                    if let removed = changeDetails.removedIndexes, !removed.isEmpty {
                        removed.map({ IndexPath(item: $0, section: 0) })
                        print(removed.map({ IndexPath(item: $0, section: 0) }))
//                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changeDetails.insertedIndexes, !inserted.isEmpty {
//                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                        print(inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changeDetails.enumerateMoves { fromIndex, toIndex in
//                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
//                                                to: IndexPath(item: toIndex, section: 0))
                        print("aaaアイアイあいあ")
                        print("fromIndex\(fromIndex)")
                        print("toIndex\(toIndex)")
                    }
                    
                    if let changed = changeDetails.changedIndexes, !changed.isEmpty {
                        print("changed\(changed)")
                    }
                    
                    
                    //                    if let inserted = changeDetails.insertedIndexes {
                    //                        print("insert")
                    //                        print((changeDetails.index))
                    //                    }
                    //                    if let removed = changeDetails.removedIndexes {
                    //                        print("remo")
                    //                        print((changeDetails.index))
                    //                        print((removed))
                    //                    }
                }
                
                let newFetchResul = changeDetails.fetchResultAfterChanges
                newFetchResul.enumerateObjects{ asset, _, _ in
                    
                    let imageAssset: ImageAsset = .init(asset: asset)
                    ary.append(imageAssset)
                }
                
                
                for i in (0 ..< ary.count){
                    PHCachingImageManager.default().requestImage(for: ary[i].asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { image,
                        _ in
                        ary[i].thumbnail = image
                    }
                }
                self.fetchedImages = ary
         
            }
        })
    }
    
    //  func photoLibraryDidChange(_ changeInstance: PHChange) {
    //      photoLibraryDidChange()
    //      if let fetchResult = self.fetchResult, let changeDetails = changeInstance.changeDetails(for:fetchResult) {
    //                  let fetchResult = changeDetails.fetchResultAfterChanges
    //              }
    //      print("フォトライブラリに何らかの変更がありました")
    //
    //  }
}
