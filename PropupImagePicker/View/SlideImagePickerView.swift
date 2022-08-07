//
//  SlideImagePickerViewa.swift
//  PropupImagePicker
//
//  Created by yamato hagi on 2022/07/17.
//

import SwiftUI
import Photos


struct SlideImagePickerView: View {
    
    @StateObject var imagePickerModel = ImagePickerViewModel()
    
    @GestureState private var dragOffset: CGFloat = 0
    
    let itemPadding: CGFloat = 30
    
    
    var body: some View {
        
        Button("更新") {
            self.imagePickerModel.update()
            
        }
        Button("削除") {
            self.imagePickerModel.delete()
            
        }
        
        GeometryReader { bodyView in
            LazyHStack(spacing: itemPadding) {
                let fetchedImagesAry = $imagePickerModel.fetchedImages
                
                
                ForEach(fetchedImagesAry) { $imageAsset in
                    
                    // カルーセル対象のView
                    SlideContent(imageAsset: imageAsset)
                        .offset(x: self.dragOffset)
                        .offset(x: -CGFloat(self.imagePickerModel.currentAry.firstIndex(of: self.imagePickerModel.currentKey)!) * (bodyView.size.width * 1 + itemPadding))
                        .gesture(
                            DragGesture()
                                .updating(self.$dragOffset, body: { (value, state, _) in
                                    // 先頭・末尾ではスクロールする必要がないので、画面サイズの1/5までドラッグで制御する
                                    if self.imagePickerModel.currentAry.firstIndex(of: self.imagePickerModel.currentKey)! == 0, value.translation.width > 0 {
                                        state = value.translation.width / 5
                                        //                                        let _ = print(self.dragOffset)
                                    } else if self.imagePickerModel.currentAry.firstIndex(of: self.imagePickerModel.currentKey)! == (fetchedImagesAry.count - 1), value.translation.width < 0 {
                                        state = value.translation.width / 5
                                    } else {
                                        state = value.translation.width
                                    }
                                })
                                .onEnded({ value in
                                    var newIndex = self.imagePickerModel.currentAry.firstIndex(of: self.imagePickerModel.currentKey)!
                                    // ドラッグ幅からページングを判定
                                    
                                    let now_ary_index =  self.imagePickerModel.currentAry.firstIndex(of: self.imagePickerModel.currentKey)!
                                    
                                    
                                    if abs(value.translation.width) > bodyView.size.width * 0.1 {
                                        newIndex = value.translation.width > 0 ? now_ary_index - 1 : now_ary_index + 1
                                        
                                    }
                                    // 最小ページ、最大ページを超えないようチェック
                                    if newIndex < 0 {
                                        newIndex = 0
                                    } else if newIndex > (fetchedImagesAry.count - 1) {
                                        newIndex = fetchedImagesAry.count - 1
                                        
                                    }
                                    self.imagePickerModel.currentKey = self.imagePickerModel.currentAry[newIndex]
                                    
                                    self.imagePickerModel.currentIndex = self.imagePickerModel.currentAry.firstIndex(of: self.imagePickerModel.currentKey)!
                                    let _ = print("self.imagePickerModel.currentIndex\(self.imagePickerModel.currentIndex)")
                                    let _ = print(self.imagePickerModel.currentKey)
                                    let _ = print(self.imagePickerModel.currentAry.firstIndex(of: self.imagePickerModel.currentKey)!)
                                    
                                })
                        )
                        .onAppear() {
                            if imageAsset.thumbnail == nil{
                                let options = PHImageRequestOptions()
                                options.isNetworkAccessAllowed = true
                                options.deliveryMode = .opportunistic
                                // MARK: Fetching Thumbnail Image
                                let manager = PHCachingImageManager.default()
                                manager.requestImage(for: imageAsset.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image,
                                    
                                    _ in
                                    imageAsset.thumbnail = image
                                }
                            }
                        }
                        .foregroundColor(Color.white)
                        .font(.system(size: 50, weight: .bold))
                        .frame(width: bodyView.size.width * 1, height: 300)
                        .background(Color.gray)
                    //                    .padding(.leading, index == 0 ? bodyView.size.width * 0 : 0)
                }
                
            }
            
        }
        .animation(.interpolatingSpring(mass: 0.6, stiffness: 150, damping: 80, initialVelocity: 0.1), value: dragOffset)
    }
    
    func SlideContent(imageAsset: ImageAsset)->some View{
        GeometryReader{ proxy in
            let size = proxy.size
            
            
            if let thumbnail = imageAsset.thumbnail{
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
            }else{
                Text("HDD")
                //                ProgressView()
                //                    .frame(width: size.width, height: size.height,alignment: .center)
            }
            
        }
        
    }
}

struct SlideImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        SlideImagePickerView()
    }
}
