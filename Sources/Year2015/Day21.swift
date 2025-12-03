import AoCCommon

public struct Day21: DaySolver {
    struct Item {
        let cost: Int
        let damage: Int
        let armor: Int
    }

    public struct Boss: Equatable {
        let hp: Int
        let damage: Int
        let armor: Int
    }

    public typealias ParsedData = Boss
    public typealias Result1 = Int
    public typealias Result2 = Int

    public init() {}

    public let day = 21
    public let testInput = """
        Hit Points: 12
        Damage: 7
        Armor: 2
        """
    public let expectedTestResult1: Result1? = 8
    public let expectedTestResult2: Result2? = 0

    let weapons = [
        Item(cost: 8, damage: 4, armor: 0),
        Item(cost: 10, damage: 5, armor: 0),
        Item(cost: 25, damage: 6, armor: 0),
        Item(cost: 40, damage: 7, armor: 0),
        Item(cost: 74, damage: 8, armor: 0),
    ]

    let armors = [
        Item(cost: 0, damage: 0, armor: 0),  // No armor
        Item(cost: 13, damage: 0, armor: 1),
        Item(cost: 31, damage: 0, armor: 2),
        Item(cost: 53, damage: 0, armor: 3),
        Item(cost: 75, damage: 0, armor: 4),
        Item(cost: 102, damage: 0, armor: 5),
    ]

    let rings = [
        Item(cost: 0, damage: 0, armor: 0),  // No ring
        Item(cost: 25, damage: 1, armor: 0),
        Item(cost: 50, damage: 2, armor: 0),
        Item(cost: 100, damage: 3, armor: 0),
        Item(cost: 20, damage: 0, armor: 1),
        Item(cost: 40, damage: 0, armor: 2),
        Item(cost: 80, damage: 0, armor: 3),
    ]

    public func parse(input: String) -> Boss? {
        let nums = input.integers
        guard nums.count == 3 else { return nil }
        return Boss(hp: nums[0], damage: nums[1], armor: nums[2])
    }

    public func solvePart1(data: Boss) -> Int {
        allLoadouts().filter { playerWins($0, boss: data) }.map(\.cost).min() ?? 0
    }

    public func solvePart2(data: Boss) -> Int {
        allLoadouts().filter { !playerWins($0, boss: data) }.map(\.cost).max() ?? 0
    }

    private func allLoadouts() -> [(cost: Int, damage: Int, armor: Int)] {
        var loadouts: [(Int, Int, Int)] = []
        for weapon in weapons {
            for armor in armors {
                for ring1 in rings.indices {
                    for ring2 in rings.indices {
                        if ring1 == ring2 && ring1 != 0 { continue }
                        let cost = weapon.cost + armor.cost + rings[ring1].cost + rings[ring2].cost
                        let damage =
                            weapon.damage + armor.damage + rings[ring1].damage + rings[ring2].damage
                        let armorStat =
                            weapon.armor + armor.armor + rings[ring1].armor + rings[ring2].armor
                        loadouts.append((cost, damage, armorStat))
                    }
                }
            }
        }
        return loadouts
    }

    private func playerWins(_ loadout: (cost: Int, damage: Int, armor: Int), boss: Boss) -> Bool {
        let playerDmg = max(1, loadout.damage - boss.armor)
        let bossDmg = max(1, boss.damage - loadout.armor)
        let playerTurns = (boss.hp + playerDmg - 1) / playerDmg
        let bossTurns = (100 + bossDmg - 1) / bossDmg
        return playerTurns <= bossTurns
    }
}
