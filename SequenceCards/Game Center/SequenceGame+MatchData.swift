//
//  CleverJacksGame+MatchData.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

import GameKit
import SwiftUI

// MARK: Game Data Objects

struct Message: Identifiable {
    var id = UUID()
    var content: String
    var playerName: String
    var isLocalPlayer: Bool = false
}

// A participant object with their items.
struct Participant: Identifiable {
    var id = UUID()
    var player: GKPlayer
    var avatar = Image(systemName: "person")
    var data : PlayerGameData?
    struct PlayerGameData : Codable {
        var cardsOnHand : [Card] = []
        let coin : Coin?
        var noOfSequences = 0
        var turns = 0
        let currentMatchID : String 
        var result : Result = .noResult
        
    }
}

enum Result : Codable {
    case won
    case lost
    case noResult
}


// Codable game data for sending to players.
struct GameData: Codable, CustomStringConvertible {
    var board: Board?
    var cardCurrentlyPlayed : Card?
    var allPlayersData : [String: Participant.PlayerGameData]
    var lastPlayedBy: String
    var description: String {
        return "PlayerData : \(allPlayersData) Board : \(String(describing: board))"
    }
    // board ( may be cardstack inside the board )
}

extension CleverJacksGame {
    
    // MARK: Codable Game Data
    
    /// Creates a data representation of the game count and items for each player.
    ///
    /// - Returns: A representation of game data that contains only the game scores.
    func encodeGameData() -> Data? {
        // Create a dictionary of data for each player.
        var allPlayersData = [String: Participant.PlayerGameData]()
        // Add the local player's items.
        var lastPlayedBy = ""
        if let localPlayerName = localParticipant?.player.displayName {
            if let playerGameData = localParticipant?.data {
                allPlayersData[localPlayerName] = playerGameData
            }
        }
        
        // Add the opponent's items.
        
        // Saving for persistance purposes, some values are not decoded
        if let opponentPlayerName = opponent?.player.displayName {
            if let playerGameData = opponent?.data {
                allPlayersData[opponentPlayerName] = playerGameData
            }
        }
        
        if let opponent2PlayerName = opponent2?.player.displayName {
            
            if let playerGameData = opponent2?.data {
                allPlayersData[opponent2PlayerName] = playerGameData
            }
        }
        
        if let playersName = whichPlayersTurn?.displayName {
            lastPlayedBy = playersName
        }
        
        
        let gameData = GameData(board: board , cardCurrentlyPlayed: cardCurrentlyPlayed, allPlayersData: allPlayersData, lastPlayedBy: lastPlayedBy)
        
        return encode(gameData: gameData)
    }
    
    /// Creates a data representation from the game data for sending to other players.
    ///
    /// - Returns: A representation of the game data.
    func encode(gameData: GameData) -> Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(gameData)
            return data
        } catch {
            print("Error: \(error.localizedDescription).")
            return nil
        }
    }
    
    func decode(matchData: Data) -> GameData? {
        let gameData = try? PropertyListDecoder().decode(GameData.self, from: matchData)
        if let gameData = gameData {
            return gameData
        }
        return nil
    }
    
    /// Decodes a data representation of game data and updates the scores.
    ///
    /// - Parameter matchData: A data representation of the game data.
    func decodeGameData(matchData: Data) {
        let gameData = try? PropertyListDecoder().decode(GameData.self, from: matchData)
        guard let gameData = gameData else { return }
        
        // Set the match count.
        
        cardCurrentlyPlayed = gameData.cardCurrentlyPlayed
        // update the current board,
        board = gameData.board
        
        lastPlayedBy = gameData.lastPlayedBy
        

        //  we don't need items for now.
        if let localPlayerName = localParticipant?.player.displayName {
            
            if let playerGameData = gameData.allPlayersData[localPlayerName] {
                localParticipant?.data = playerGameData
            }
        }
        
        // Add the opponent's items.
        
        // Saving for persistance purposes, some values are not decoded
        if let opponentPlayerName = opponent?.player.displayName {
            if let playerGameData = gameData.allPlayersData[opponentPlayerName] {
                opponent?.data = playerGameData
            }
        }
        
        if let opponent2PlayerName = opponent2?.player.displayName {
            
            if let playerGameData = gameData.allPlayersData[opponent2PlayerName] {
                opponent2?.data = playerGameData
            }
        }
        
        
        // Set the opponent's items.

    }
}