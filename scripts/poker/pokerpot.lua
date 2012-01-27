--- Class PokerPot

PokerPot = {}

-- payment[PokerPlayer] = Höhe der kumulierten
-- Einzahlungen von gegebenem Spieler
PokerPot.payments = {}

-- Einzahlungen von Spielern die aus dem Spiel geflogen sind.
PokerPot.general_payments = 0

PokerPot.max_payment = nil

-- Speichert ob ein Spieler nur Raise gespielt hat
PokerPot.player_did_only_raise = {}

--- Erstellt ein neues Objekt von Typ PokerPot
-- @param max Maximale Gesamtsumme an Geld, die ein Spieler einzahlen darf
function PokerPot:new(max)
    local res = {}
	setmetatable(res, self)
	self.__index = self
	res.max_payment = max
	return res
end

--- Gibt den Gesamthöchsteinsatz zurück
-- Der Gesamthöchsteinsatz ist da, um All-Ins zu vermeiden
-- @return Gesamthöchsteinsatz
function PokerPot:getMaxPayment()
    return self.max_payment
end

--- PRIVATE: Gibt die bisherigen kum. Einzahlungen eines Spielers zurück
-- @param player Spieler von Typ PokerPlayer
-- @return kum. Einzahlungen des Players
function PokerPot:getPaymentOf(player)
    if self.payments[player] == nil then
        return 0
    else
        return self.payments[player]
    end
end

--- Gibt die momentan höchstmögliche Einzahlung für einen Spieler im
-- Rahmen des vorher festgelegten Maximums zurück
-- @param player Spieler vom Typ PokerPlayer
-- @return Die höchstmögliche Einzahlung, die player noch tätigen darf
function PokerPot:getHighestPossiblePayment(player)
    return self:getMaxPayment() - self:getPaymentOf(player)
end

--- Funktion um eine gewisse Menge in den Pot einzuzahlen
-- @param player Spieler, der die Einzahlung tätigt (PokerPlayer-Objekt)
-- @param amount Höhe der Einzahlung, keine Werte <0
function PokerPot:doPayment(player, amount)
    if self.player_did_only_raise[player] == nil then
        self.player_did_only_raise[player] = true
    end

    if self.payments[player] == nil then
        self.payments[player] = 0
    end
    self.payments[player] = self:getPaymentOf(player) + amount
end


--- Gibt die Menge an Geld zurück, die ein Spieler
-- mindestens noch zahlen muss um im Spiel zu bleiben
-- @param player Spieler vom Typ PokerPlayer
-- @return Höhe der min. notwendigen Einzahlung
function PokerPot:getMoneyPlayerHasToRaise(player)
    max_input = 0
    for my_player, payment in ipairs(self.payments) do
        if my_player ~= player then
            if max_input < payment then
                max_input = payment
            end
        end 
    end
    return max_input - self:getPaymentOf(player)
end

--- Gibt die Menge des Geldes im Pot zurück
-- @return Menge des Geldes im Pot
function PokerPot:getAmountOfPayments()
    local content = 0
    for player, payment in ipairs(self.payments) do
        content = content + payment
    end
    return content
end

--- Gibt die Möglichkeiten eines Spielers zurück.
-- @param player Der Spieler
-- @return Gibt die Möglichkeiten von player zurück.
function PokerPot:getPossibilitiesOfPlayer(player)
    local min = self:getMoneyPlayerHasToRaise(player)
    local max = self:getHighestPossiblePayment(player)
    local possibilities = {}
    table.insert(possibilities, PokerConstants.POSSIBILITY_FOLD)
    if player:getMoney() >= min then
        
        table.insert(possibilities, PokerConstants.POSSIBILITY_CALL)
        if max > 0 then -- Hat das maximale Bugdet noch nicht erreicht
            if self:playerDidOnlyRaise(player) then
                table.insert(possibilities, PokerConstants.POSSIBILITY_RAISE)
            end
        end
    end
    return possibilities
end

--- Verschiebt den Einsatz eines Spielers in general_payment.
-- wird aufgerufen wenn ein Spieler entfernt wird.
-- @param player Spieler dessen Einsatz verschoben werden soll.
function PokerPot:pushPaymentOfPlayerToGeneralPot(player)
    self.general_payments = self.general_payments +
      self:getPaymentOf(player)
    self.payments[player] = 0
end

--- Gibt zurück ob noch Einsatze gemacht werden müssen.
-- @return true wenn noch Einsätze gemacht werden müssen, false wenn nicht.
function PokerPot:arePaymentsRequired()
    for i, player in ipairs(self.payments) do
        if self:getMoneyPlayerHasToRaise(player) >= 0 then
            return true
        end
    end
    return false
end

--- Gibt zurück ob ein Spieler bereits am Zug war und keine andere Aktion als erhöhen durchgeführt hat.
-- @return true, wenn der Spieler noch keine anderen Aktionen als Raise durchgeführt hat.
function PokerPot:playerDidOnlyRaise(my_player)
    return self.player_did_only_raise[my_player]
end

--- Setzt rundenspezifische Variablen zurück
function PokerPot:nextRound()
    self.player_did_only_raise = {}
end

--- Sagt dem Pot, dass nicht Raise gespielt wurde.
function PokerPot:playerDidNotRaise(my_player)
    self.player_did_only_raise[my_player] = false
end
