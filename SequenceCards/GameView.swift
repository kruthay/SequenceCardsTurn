//
//  GameView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI
import AVFoundation


struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var game: CleverJacksGame
    @State private var showMessages: Bool = false
    var body: some View {
        VStack {
            HStack {
                Button("Back") {
                    withAnimation {
                        game.quitGame()
                    }
                }
                .hoverEffect(.lift)
                Spacer()
                Button {
                    game.isLoading = true
                    Task {
                        await game.refresh()
                    }
                } label: {
                    Text(Image(systemName: "arrow.clockwise"))
                }
                
                if game.isLoading {
                    ProgressView()
                }
                Spacer()
                Button("Forfeit") {
                    Task {
                        await game.forfeitMatch()
                    }
                }
                .hoverEffect(.lift)
            }
            .padding(.horizontal)
            Divider()
            HStack  {
                Spacer()
                HStack {
                    game.myAvatar
                        .resizable()
                        .frame(width: 25.0, height: 25)
                        .clipShape(Circle())
                        .wiggling(toWiggle: game.myTurn)
                    if game.board?.numberOfPlayers == 2 {
                        Text(game.myName == "" ? "SomeName" : game.myName)
                            .lineLimit(2)
                            .font(.caption)
                    }
                    Text(String(game.myNoOfSequences))
                }
                .padding(4.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(game.myCoin?.color ?? .blue, lineWidth: 2)
                )
                .opacity(game.myTurn ? 1 : 0.5)
                Spacer()
                HStack {
                    game.opponentAvatar
                        .resizable()
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                        .wiggling(toWiggle: game.whichPlayersTurn == game.opponent?.player )
                    if game.board?.numberOfPlayers == 2 {
                        Text(game.opponentName)
                            .lineLimit(2)
                            .font(.caption)
                    }
                    Text(String(game.opponentNoOfSequences))
                }
                .padding(4.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(game.opponentCoin?.color ?? .green, lineWidth: 2)
                )
                .opacity(game.myTurn ? 0.5 : 1)
                Spacer()
                if game.board?.numberOfPlayers ?? 0 > 2 {
                    HStack {
                        game.opponent2Avatar
                            .resizable()
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                            .wiggling(toWiggle: game.whichPlayersTurn == game.opponent?.player )
                        Text(String(game.opponent2NoOfSequences))
                    }
                    .padding(4.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(game.opponent2Coin?.color ?? .red, lineWidth: 2)
                    )
                    .opacity(game.myTurn ? 0.5 : 1)
                    Spacer()
                    
                }
            }
            Divider()
            GeometryReader {
                proxy in
                if proxy.size.width > proxy.size.height {
                    HStack {
                        BoardView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20))
                        
                        HStack{
                            if let card = game.cardCurrentlyPlayed {
                                CardView(card: card, size:CGSize(width: proxy.size.height/20, height: proxy.size.width/30) )
                            }
                            else {
                                CardView(card: Card(), size:CGSize(width: proxy.size.height/20, height: proxy.size.width/30))
                            }
                        }
                        .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                        PlayerCardsView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20), horizontalView: true)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else{
                    VStack {
                        BoardView(game: game, size : CGSize(width: proxy.size.width/12.5, height: proxy.size.height/14))
                        Spacer()
                        HStack {
                            Button("Message") {
                                withAnimation(.easeInOut(duration: 1)) {
                                    showMessages = true
                                }
                            }
                            .buttonStyle(MessageButtonStyle())
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                            Spacer()
                            HStack {
                                if game.myTurn {
                                    if let matchMessage = game.matchMessage {
                                        HStack {
                                            Text(matchMessage)
                                        }
                                        .onAppear {
                                            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                                                withAnimation(.easeInOut(duration: 5)) {
                                                    game.matchMessage = nil
                                                }
                                            }
                                            AudioServicesPlaySystemSound(1106)
                                        }
                                    }
                                }
                                
                                // Send text messages as exchange items.
                                
                            }
                            if let card = game.cardCurrentlyPlayed {
                                CardView(card: card, size:CGSize(width: proxy.size.width/16, height: proxy.size.height/20) )
                            }
                            else {
                                CardView(card: Card(coin:.special), size:CGSize(width: proxy.size.width/16, height: proxy.size.height/20))
                            }
                            
                            // Send a reminder to take their turn.
                            Spacer()
                            Button {
                                Task {
                                    await game.sendReminder()
                                }
                                AudioServicesPlaySystemSound(1105)
                            }  label: {
                                Label(
                                    title: { },
                                    icon: { Image(systemName: "bell.and.waves.left.and.right")  }
                                )
                            }
                            .disabled(game.myTurn)
                        }
                        .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                        Spacer()
                        PlayerCardsView(game: game, size : CGSize(width: proxy.size.width/12.5, height: proxy.size.height/14))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding()
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                game.isLoading = true
                Task {
                    await game.refresh()
                }
            }
        }
        .sheet(isPresented: $showMessages) {
            ChatView(game: game)
        }
        .alert("Game Over", isPresented: $game.youWon, actions: {
            Button("OK", role: .cancel) {
                game.resetGame()
            }
        }, message: {
            Text("Hurray! You win.")
        })
        .alert("Game Over", isPresented: $game.youLost, actions: {
            Button("OK", role: .cancel) {
                game.resetGame()
            }
        }, message: {
            Text("Oh No! You lose.")
        })
    }
}
struct MessageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isPressed ? "bubble.left.fill" : "bubble.left")
        }
        .foregroundColor(Color.blue)
    }
}



struct GameViewPreviews: PreviewProvider {
    static var previews: some View {
        GameView(game: CleverJacksGame())
    }
}
