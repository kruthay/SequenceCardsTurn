//
//  CoinView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct CoinView: View {
    @Environment(\.colorScheme) var colorScheme
    var coin : Coin = .special
    var width : CGFloat
    var body: some View {
        if #available(iOS 17.0, *) {
            Circle()
                .fill(coin.color)
                .strokeBorder(colorScheme == .dark ? Color.white : Color.black, lineWidth: width/5)
                .frame(width: width)
        }
        else {
            Circle()
                .strokeBorder(colorScheme == .dark ? Color.white : Color.black, lineWidth: width/5)
                .background(Circle().foregroundColor(coin.color))
                .frame(width: width)
        }
    }
}

//#Preview {
//    CoinView(width: 17)
//}

struct CoinViewPreviews: PreviewProvider {
    static var previews: some View {
        CoinView(width: 17)
    }
}
