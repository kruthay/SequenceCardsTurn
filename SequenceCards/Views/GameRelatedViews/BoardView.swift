//
//  BoardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var game: CleverJacksGame
    var size : CGSize
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        Grid{
            ForEach(game.boardCards, id: \.self){ boardRow in
                GridRow {
                    ForEach(boardRow) { card in
                        BoardCardView(card: card, size: size)
                            .opacity(card.belongsToASequence ? 0.4 : 1)
                        
                    }
                    
                }
            }
        }
    }
    
}


struct BoardViewPreviews: PreviewProvider {
    static var previews: some View {
        BoardView( size: CGSize(width: 30, height: 50))
            .environmentObject(CleverJacksGame())
    }
}


