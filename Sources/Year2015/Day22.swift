import AoCCommon

public struct Day22: DaySolver {
    public struct Boss: Equatable {
        let hp: Int
        let damage: Int
    }

    struct State {
        var playerHP: Int
        var playerMana: Int
        var bossHP: Int
        var shieldTimer: Int
        var poisonTimer: Int
        var rechargeTimer: Int
        var manaSpent: Int
    }

    public typealias ParsedData = Boss
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 22
    public let testInput = """
        Hit Points: 14
        Damage: 8
        """
    public let expectedTestResult1: Result1? = 212
    public let expectedTestResult2: Result2? = 212

    public func parse(input: String) -> Boss? {
        let nums = input.integers
        guard nums.count == 2 else { return nil }
        return Boss(hp: nums[0], damage: nums[1])
    }

    public func solvePart1(data: Boss) -> Int {
        simulate(boss: data, hardMode: false)
    }

    public func solvePart2(data: Boss) -> Int {
        simulate(boss: data, hardMode: true)
    }

    private func simulate(boss: Boss, hardMode: Bool) -> Int {
        var minMana = Int.max

        func dfs(_ state: State) {
            var state = state

            // Hard mode: lose 1 HP at start of player turn
            if hardMode {
                state.playerHP -= 1
                if state.playerHP <= 0 { return }
            }

            // Player turn - apply effects
            state = applyEffects(state)
            if state.bossHP <= 0 {
                minMana = min(minMana, state.manaSpent)
                return
            }

            // Try each spell (sorted by cost for better pruning)
            for spell in Spell.all {
                guard state.playerMana >= spell.cost else { continue }
                guard !isEffectActive(state, spell) else { continue }

                var newState = state
                newState.playerMana -= spell.cost
                newState.manaSpent += spell.cost

                if newState.manaSpent >= minMana { continue }

                // Apply spell
                newState = castSpell(newState, spell)

                if newState.bossHP <= 0 {
                    minMana = min(minMana, newState.manaSpent)
                    continue
                }

                // Boss turn - apply effects
                newState = applyEffects(newState)
                if newState.bossHP <= 0 {
                    minMana = min(minMana, newState.manaSpent)
                    continue
                }

                // Boss attacks
                let damage = max(1, boss.damage - (newState.shieldTimer > 0 ? 7 : 0))
                newState.playerHP -= damage

                if newState.playerHP > 0 {
                    dfs(newState)
                }
            }
        }

        dfs(
            State(
                playerHP: 50, playerMana: 500, bossHP: boss.hp, shieldTimer: 0, poisonTimer: 0,
                rechargeTimer: 0, manaSpent: 0))
        return minMana
    }

    enum Spell {
        case missile, drain, shield, poison, recharge

        var cost: Int {
            switch self {
            case .missile: 53
            case .drain: 73
            case .shield: 113
            case .poison: 173
            case .recharge: 229
            }
        }

        static let all: [Spell] = [.missile, .drain, .shield, .poison, .recharge]
    }

    private func applyEffects(_ state: State) -> State {
        var s = state
        if s.shieldTimer > 0 { s.shieldTimer -= 1 }
        if s.poisonTimer > 0 {
            s.bossHP -= 3
            s.poisonTimer -= 1
        }
        if s.rechargeTimer > 0 {
            s.playerMana += 101
            s.rechargeTimer -= 1
        }
        return s
    }

    private func isEffectActive(_ state: State, _ spell: Spell) -> Bool {
        switch spell {
        case .shield: state.shieldTimer > 0
        case .poison: state.poisonTimer > 0
        case .recharge: state.rechargeTimer > 0
        default: false
        }
    }

    private func castSpell(_ state: State, _ spell: Spell) -> State {
        var s = state
        switch spell {
        case .missile: s.bossHP -= 4
        case .drain:
            s.bossHP -= 2
            s.playerHP += 2
        case .shield: s.shieldTimer = 6
        case .poison: s.poisonTimer = 6
        case .recharge: s.rechargeTimer = 5
        }
        return s
    }

}
