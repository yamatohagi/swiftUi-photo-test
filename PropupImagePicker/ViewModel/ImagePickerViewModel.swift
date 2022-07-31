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
    @Published var currentIndex:Int = 0
    @Published var currentKey:String = ""
    @Published var currentAry:[String] = []
    
    let beforeAry: [ImageAsset] = []
    
    var fetchResult: PHFetchResult<PHAsset>? = nil
    
    override init() {

        super.init()
        let beforeAry = fetchImages()
        self.fetchedImages = beforeAry
        PHPhotoLibrary.shared().register(self)
        
        
    }
    
    
    public func update(){
        self.currentIndex = 1
//        fetchedImages = []
//        fetchImages()
//        print("あああaaaaaaaaaーーーーーーーーーーーーー")
//        print(fetchedImages.count)
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
        options.fetchLimit = 1
        options.includeHiddenAssets = false
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        self.fetchResult = PHAsset.fetchAssets(with: .image,options: options)
        
        
        
        
        self.fetchResult?.enumerateObjects{ asset, index, _ in
            
       
       
            var imageAssset: ImageAsset = .init(asset: asset)
            let options = PHImageRequestOptions()
            
      
//            if imageAssset.thumbnail == nil{
//                // MARK: Fetching Thumbnail Image
//                let manager = PHCachingImageManager.default()
//                manager.requestImage(for: imageAssset.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { image,
//                    _ in
//                    imageAssset.thumbnail = image
//                }
//            }
            
            if(self.currentKey == ""){
                self.currentKey = asset.value(forKey: "filename") as! String
            }
           
            self.currentAry.append(asset.value(forKey: "filename") as! String)
            ary.append(imageAssset)
            
            print("aaa変更前")
               let _ = print(self.currentAry)
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
                       
                        
                        removed.map({
                            print("$0----\($0)")
                            print("self.currentAry\(self.currentAry)")
//                            self.currentAry.remove(at: $0)
             })
                        
//                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    for deletion in changeDetails.removedObjects {
                        if deletion.value(forKey: "filename") as! String == self.currentKey {
                            self.currentIndex = self.currentIndex + 1
                            self.currentKey = self.currentAry[self.currentIndex]
                            print("これね変更後のcurrentKey\(self.currentKey)")
                        }
                        
                    }
            
                    
                    if let inserted = changeDetails.insertedIndexes, !inserted.isEmpty {
//                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                        inserted.map({ i in
                            print(i)
//                            self.currentAry.insert($0.id, at: $0)
                         })
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
                self.currentAry = []
                let newFetchResul = changeDetails.fetchResultAfterChanges
                newFetchResul.enumerateObjects{ asset, index, _ in
                    
                    let imageAssset: ImageAsset = .init(asset: asset)
                    self.currentAry.append(asset.value(forKey: "filename") as! String)
  
                    ary.append(imageAssset)
                }
                
//
//                for i in (0 ..< ary.count){
//                    PHCachingImageManager.default().requestImage(for: ary[i].asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { image,
//                        _ in
//                        ary[i].thumbnail = image
//                    }
//                }
                self.fetchedImages = ary
                print("aaa変更後")
                let _ = print(self.currentAry)
         
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
