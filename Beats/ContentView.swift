//
//  ContentView.swift
//  Beats
//
//  Created by 강대민 on 2022/06/12.
//
import MusicKit
import SwiftUI

struct Item: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let artist: String
    let imageUrl: URL?
}

struct ContentView: View {
    @State var songs = [Item]()
    
    var body: some View {
        NavigationView {
            List(songs) { song in
                HStack {
                    //비동기 이미지에 던질 h스택
                    AsyncImage(url: song.imageUrl)
                        .frame(width: 75, height: 75, alignment: .center)
                    VStack(alignment: .leading) {
                        Text(song.name)
                            .font(.title3)
                        Text(song.artist)
                            .font(.footnote)
                    }
                    .padding()
                }
            }
        }
        .onAppear() {
            fetchMusic()
        }
    }
    
    private let request: MusicCatalogSearchRequest = {
        var request = MusicCatalogSearchRequest(term: "Happy", types: [Song.self])
        //100개 요청은 에러 기본5개 이 프로젝트에선 25
        request.limit = 25
        return request
    }()
    
    private func fetchMusic() {
        Task {
            // request permission
            let status = await MusicAuthorization.request()
            switch status {
            case .authorized:
                //request -> response
                do {
                    //여기서 모든걸 처리하기위햐 await
                    let result = try await request.response()
                    //configure
                    self.songs = result.songs.compactMap({
                        return .init(name: $0.title, artist: $0.artistName, imageUrl: $0.artwork?.url(width: 75, height: 75))
                    })
                    print(String(describing: songs[0]))
                } catch {
                    print(String(describing: error))
                }
                //assigns songs
            default:
                break
            }
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
