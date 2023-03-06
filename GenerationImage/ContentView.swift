//
//  ContentView.swift
//  GenerationImage
//
//  Created by Aleksandr Mayyura on 06.03.2023.
//

import SwiftUI
import OpenAIKit

class ViewModel: ObservableObject {
    private var openAi: OpenAI?
    
    func setup() {
        openAi = OpenAI(Configuration(
            organization: "Personal",
            apiKey: Token.myToken.rawValue
        ))
    }
    
    func generationImage(prompt: String) async -> UIImage? {
        guard let openAi = openAi else { return nil }
        
        do {
            let params = ImageParameters(
                prompt: prompt,
                resolution: .medium,
                responseFormat: .base64Json
            )
            let result = try await openAi.createImage(parameters: params)
            guard let data = result.data.first?.image else { return nil }
            let image = try openAi.decodeBase64Image(data)
            return image
            
        }
        catch {
            print(String(describing: error))
            return nil
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    @State var isOn = false
    
    var body: some View {
        
        VStack {
            HStack {
                Text("DALL'E")
                    .font(.largeTitle)
                    .bold()
                Image("openAi")
                    .resizable()
                    .frame(width: 75, height: 70)
            }
            Spacer()
            if isOn {
                ProgressView()
                    .scaleEffect(2)
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350, height: 350)
            } else {
                Text("Generation image")
            }
            Spacer()
            HStack {
                TextField("Type prompt here...", text: $text)
                    .textFieldStyle(.roundedBorder)
                Button {
                    withAnimation {
                        if !text.isEmpty {
                            isOn = true
                            Task {
                                let result = await viewModel.generationImage(prompt: text)
                                if result == nil {
                                    print("Fail to get image")
                                }
                                self.image = result
                                isOn.toggle()
                                
                            }
                        }
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 26))
                        .padding(.horizontal, 10)
                }
                .disabled(isOn)
            }
            .onAppear {
                viewModel.setup()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
