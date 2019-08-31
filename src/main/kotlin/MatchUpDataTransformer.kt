import io.reactivex.Observable
import org.jsoup.nodes.Document
import org.jsoup.nodes.Element

fun Observable<Document>.convertToSingleMatchUp(): Observable<Element> =
    flatMapIterable {
        it.select("matchup")
    }

fun Observable<Element>.convertToMatchUpObject(): Observable<Pair<Team, Team>> =
    map {
        val teams = it.select("team")
        val teamOne = generateTeamData(teams[0])
        val teamTwo = generateTeamData(teams[1])

        Pair(teamOne, teamTwo)
    }

fun Observable<Pair<Team, Team>>.convertToMatchUpMessage(): Observable<String> =
    map {
        val teamDataBuilder = StringBuilder()
        teamDataBuilder.append("${it.first.name} vs. ${it.second.name}\n")
        teamDataBuilder.append("===\n")

        val teams = it.toList()
        for (team: Team in teams) {
            teamDataBuilder.append("Team: ${team.name}\nWin Probability: ${team.winProbability}%\nProjected Points: ${team.projectedPoints}\nWaiver Priority: ${team.waiverPriority}\nFAAB: ${team.faabBalance}\nClinched Playoffs: ${team.clinchedPlayoffs}\n\n")
        }

        val finalMessage = teamDataBuilder.toString().trim()

        finalMessage
    }

fun Observable<Pair<Team, Team>>.convertToScoreUpdateMessage(): Observable<String> =
    map {
        "${it.first.name} vs. ${it.second.name}\n" +
                "${it.first.points} - ${it.second.points}"
    }

private fun generateTeamData(team: Element): Team {
    val id = team.select("team_id").text().toInt()
    val name = team.select("name").text()
    val waiverPriority = team.select("waiver_priority").text().toInt()
    val faabBalance = team.select("faab_balance").text().toInt()
    val numberOfMoves = team.select("number_of_moves").text().toInt()
    val numberOfTrades = team.select("number_of_trades").text().toInt()
    val clinchedPlayoffs = team.select("clinched_playoffs").text() == "1"
    val winProbability = team.select("win_probability").text().toDouble() * 100
    val points = team.select("team_points").select("total").text().toDouble()
    val projectedPoints = team.select("team_projected_points").select("total").text().toDouble()

    return Team(
        name,
        id,
        waiverPriority,
        faabBalance,
        numberOfMoves,
        numberOfTrades,
        winProbability,
        points,
        projectedPoints,
        clinchedPlayoffs
    )
}

class Team(
    val name: String,
    val id: Int,
    val waiverPriority: Int,
    val faabBalance: Int,
    val numberOfMoves: Int,
    val numberOfTrades: Int,
    val winProbability: Double,
    val points: Double,
    val projectedPoints: Double,
    val clinchedPlayoffs: Boolean
)