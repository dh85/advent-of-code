import AoCCommon
import Year2015
import Year2016
import Year2025

let years: [any YearSolutions.Type] = [
    Year2025.self
]

let dayFilter = parseDayFilter()

for year in years {
    runYear(year, dayFilter: dayFilter)
}
