extends Control

@export var  planet_cache : Array[Planet] = []
@export var generation_target : Planet
const unknown_planet = preload("res://Part 2 - Shader Control/Planet/Planets/UndiscoveredPlanet.tres")

var loading = false

func travel_to_new_planet():
	if not loading:
		loading = true
		var r = LanguageModelRequest.new()
		r.add_context('Invent a new planet. The user will provide a vauge overview, and you will invent something new that fits in with the universe. Avoid general or vague descriptions.')
		r.add_context("""Relevent History:
A papal conclave is a gathering of the College of Cardinals convened to elect the bishop of Rome, also known as the pope. Catholics consider the pope to be the apostolic successor of Saint Peter and the earthly head of the Catholic Church.[1] It has the longest dynasty of historical methods of electing a particular head of state that remains in use to the present day.

Concerns around political interference led to reforms after the interregnum of 1268–1271 and Pope Gregory X's decree during the Second Council of Lyons in 1274 that the cardinal electors should be locked in seclusion cum clave (Latin for 'with a key') and not permitted to leave until a new pope had been elected.[2] Conclaves are now held in the Sistine Chapel of the Apostolic Palace in Vatican City.[3]

Since the Apostolic Age, the bishop of Rome, like other bishops, has been chosen by the consensus of the clergy and laity of the diocese.[4] In 1059, the body of electors was more precisely defined, when the College of Cardinals was designated the sole body of electors.[5] Since then, other details of the process have developed. In 1970, Pope Paul VI limited the electors to cardinals under 80 years of age in Ingravescentem aetatem. The current procedures established by Pope John Paul II in Universi Dominici gregis[3] were slightly amended in 2007 and 2013 by Pope Benedict XVI.[6]

A two-thirds supermajority vote is required to elect the new pope.[7][8] The most recent papal conclave occurred in 2013, during which time Jorge Mario Bergoglio was elected as Pope Francis, following the resignation of Pope Benedict XVI. Following the death of Pope Francis on 21 April 2025, a papal conclave is set to begin by 7 May. It may start earlier if all cardinal electors have arrived in Rome. It must start before or on 11 May because of Pope Benedict XVI's normas nonnulas, stating that a conclave should start at least 15-20 days after the seat becomes vacant.[9]
Historical development
Main article: Papal selection before 1059

The procedures for the election of the pope developed over almost two millennia. Until the College of Cardinals was created in 1059, the bishops of Rome, like those in other areas, were elected by acclamation of the local clergy and people. Procedures similar to the present system were introduced in 1274 when Gregory X promulgated Ubi periculum following the action of the magistrates of Viterbo during the interregnum of 1268–1271.[10]

The process was further refined by Gregory XV with his 1621 papal bull Aeterni Patris Filius, which established the requirement of a two-thirds majority of cardinal electors to elect a pope.[11] The Third Council of the Lateran had initially set the requirement that two-thirds of the cardinals were needed to elect a pope in 1179.[12] This requirement had varied since then, depending on whether the winning candidate was allowed to vote for himself, in which cases the required majority was two-thirds plus one vote. Aeterni Patris Filius prohibited this practice and established two-thirds as the standard needed for election.[13]

Aeterni Patris Filius did not eliminate the possibility of election by acclamation, but did require that a secret ballot take place first before a pope could be elected.[14] Prior to 1621, a cardinal could vote for himself, but it was always with the knowledge and consent of enough of the other voting cardinals, so that he did not make the final decision to make himself pope (accessus). Ballots were either signed or initialed in the corner of the ballot, or sometimes coded or numbered.[citation needed]
Electorate

As early Christian communities emerged, they elected bishops, chosen by the clergy and laity with the assistance of the bishops of neighbouring dioceses.[4] Cyprian (died 258) says that Pope Cornelius (in office 251–253) was chosen as Bishop of Rome "by the decree of God and of His Church, by the testimony of nearly all the clergy, by the college of aged bishops [sacerdotum], and of good men".[15] As in other dioceses, the clergy of the Diocese of Rome was the electoral body for the Bishop of Rome. Instead of casting votes, the bishop was selected by general consensus or by acclamation. The candidate was then submitted to the people for their general approval or disapproval. This lack of precision in the election procedures occasionally gave rise to rival popes or antipopes.[16]

The right of the laity to reject the person elected was abolished by a synod held in the Lateran in 769, but restored to Roman noblemen by Pope Nicholas I during a synod of Rome in 862.[16] The pope was also subjected to oaths of loyalty to the Holy Roman Emperor, who had the duty of providing security and public peace in Rome.[17] A major change came in 1059, when Pope Nicholas II decreed in In nomine Domini that the cardinals were to elect a candidate to take office after receiving the assent of the clergy and laity. The cardinal bishops were to meet first and discuss the candidates before summoning the cardinal priests and cardinal deacons for the actual vote.[15] The Second Council of the Lateran in 1139 removed the requirement for obtaining the assent of the lower clergy and the laity,[16] while the Third Council of the Lateran in 1179 gave equal rights to the entire College of Cardinals when electing a new pope.[18]

Through much of the Middle Ages and Renaissance the Catholic Church had only a small number of cardinals at any one time, as few as seven under either Pope Alexander IV (1254–1261)[19] or Pope John XXI (1276–1277).[20][21] The difficulty of travel further reduced the number arriving at conclaves. The small electorate magnified the significance of each vote and made it all but impossible to displace familial or political allegiances. Conclaves lasted months and even years. In his 1274 decree requiring the electors be locked in seclusion, Gregory X also limited each cardinal elector to two servants and rationed their food progressively when a conclave reached its fourth and ninth days.[16]

The cardinals disliked these rules; Pope Adrian V temporarily suspended them in 1276 and John XXI's Licet felicis recordationis revoked them later that same year.[22][a] Lengthy elections resumed and continued to be the norm until 1294, when Pope Celestine V reinstated the 1274 rules.[23] Long interregna followed: in 1314–1316 during the Avignon Papacy, where the original conclaves were dispersed by besieging mercenaries and not reconvened for almost two years;[24] and in 1415–1417, as a result of the Western Schism.

Until 1899, it was a regular practice to generally include a few lay members in the Sacred College. These were often prominent nobility, or monks who were not priests, and in all cases, celibacy was required. With the death of Teodolfo Mertel in 1899, this practice was ended.[25] In 1917, the Code of Canon Law promulgated that year, explicitly stated that all cardinals must be priests. Since 1962, all cardinals have been bishops, with the exception of a few priests who were made cardinals after 1975.

In 1587, Pope Sixtus V limited the number of cardinals to 70, following the precedent of Moses who was assisted by 70 elders in governing the Children of Israel: 6 cardinal bishops, 50 cardinal priests, and 14 cardinal deacons.[19] Beginning with the attempts of Pope John XXIII (1958–1963) to broaden the representation of nations in the College of Cardinals, that number has increased. In 1970 Paul VI ruled that cardinals who reach the age of 80 before the start of a conclave are ineligible to participate.[26]

In 1975, he limited the number of cardinal electors to 120.[27] Though this remains the theoretical limit, all of his successors have exceeded it for short periods of time. John Paul II (in office 1978–2005) also changed the age limit slightly, so that cardinals who turn 80 before a papal vacancy (not before conclave start) cannot serve as electors;[3] this eliminated the idea of scheduling the conclave to include or exclude a cardinal who is very close to the age limit (and in 2013, Cardinal Walter Kasper, 79 when the papacy became vacant, participated in the conclave at age 80).
Choice of electors and of candidates

Originally, lay status did not bar election to the See of Rome. Bishops of dioceses were sometimes elected while still catechumens, such as the case of St. Ambrose,[28] who became Bishop of Milan in 374. In the wake of the violent dispute over the 767 election of Antipope Constantine II, Pope Stephen III held the synod of 769, which decreed that only a cardinal priest or cardinal deacon could be elected, specifically excluding those that are already bishops.[15][29] Church practice deviated from this rule as early as 817 and fully ignored it from 882 with the election of Pope Marinus I, the Bishop of Caere.[30]

Nicholas II, in the synod of 1059, formally codified existing practice by decreeing that preference was to be given to the clergy of Rome, but leaving the cardinal bishops free to select a cleric from elsewhere if they so decided.[31] The Council of 1179 rescinded these restrictions on eligibility.[18] On 15 February 1559, Paul IV issued the papal bull Cum ex apostolatus officio, a codification of the ancient Catholic law that only Catholics can be elected popes, to the exclusion of non-Catholics, including former Catholics who have become public and manifest heretics.

Pope Urban VI in 1378 became the last pope elected from outside the College of Cardinals.[32] The last person elected as pope who was not already an ordained priest or deacon was the cardinal-deacon Giovanni di Lorenzo de' Medici, elected as Pope Leo X in 1513.[33] His successor, Pope Adrian VI, was the last to be elected, in 1522, in absentia.[34] Archbishop Giovanni Montini of Milan received several votes in the 1958 conclave though not yet a cardinal.[35][36] As the Catholic Church holds that women cannot be validly ordained, women are not eligible for the papacy.[b] Though the pope is the Bishop of Rome, he need not be of Italian background. As of 2025, the three most recent conclaves have elected a Pole in 1978, a German in 2005, and an Argentinian in 2013.

During the first millennium, popes were elected unanimously, at least in theory. After a decree by the Synod of Rome in 1059, some factions contended that a simple majority sufficed to elect. In 1179, the Third Council of the Lateran settled the question by calling for unanimity, but permitting the Pope to be elected by two-thirds majority, "if by chance, through some enemy sowing tares, there cannot be full agreement."[12][40] As cardinals were not allowed to vote for themselves after 1621, the ballots were designed to ensure secrecy while at the same time preventing self-voting.[c]

In 1945, Pope Pius XII removed the prohibition on a cardinal voting for himself, increasing the requisite majority to two-thirds plus one at all times.[42] He eliminated the need for signed ballots.[43] His successor John XXIII immediately reinstated the two-thirds majority if the number of cardinal electors voting is divisible by three, with an additional vote required if the number is not divisible by three.[d] Paul VI reinstated Pius XII's procedure thirteen years later,[27] but John Paul II overturned it again.

In 1996, John Paul II's constitution allowed election by absolute majority if deadlock prevailed after thirty-three or thirty-four ballots,[3] thirty-four ballots if a ballot took place on the first afternoon of the conclave. In 2007, Benedict XVI rescinded John Paul II's change, which had effectively abolished the two-thirds majority requirement, as any majority suffices to block the election until a simple majority is enough to elect the next pope, reaffirming the requirement of a two-thirds majority.[44][45]

Electors formerly made choices by accessus, acclamation (per inspirationem), adoration, compromise (per compromissum) or scrutiny (per scrutinium).[10]

	Accessus was a method for cardinals to change their most recent vote to accede to another candidate in an attempt to reach the requisite two-thirds majority and end the conclave. This method was first disallowed by the Cardinal Dean at the 1903 conclave.[10] Pius XII abolished accessus in 1945.
	With acclamation, the cardinals unanimously declared the new pope quasi afflati Spiritu Sancto (as if inspired by the Holy Spirit).[42] If this took place before any formal ballot had taken place, the method was called adoration,[46] but Pope Gregory XV excluded this method in 1621.[47][48]
	To elect by compromise, a deadlocked college unanimously delegates the election to a committee of cardinals whose choice they all agree to abide by.[42]
	Scrutiny is election via the casting of secret ballots.

The last election by compromise was that of Pope John XXII in 1316, and the last election by acclamation that of Pope Innocent XI in the 1676 conclave.[49] Universi Dominici gregis formally abolished the long-unused methods of acclamation and compromise in 1996, making scrutiny the only approved method for the election of a new pope.[3] """)		
		r.add_context('Your output should be an instance of a JSON object following the schema below')
		r.add_context(JSON.stringify(generation_target.get_planet_schema()))
		r.add_context('Nearby Planets:')
		for p in planet_cache:
			r.add_context("Existing Planet: " + p.planet_name + "-" + p.planet_overview)
		r.add_context('Generate a new planet. Limit description to bare bones geography and ecosystem. Be very intentional about the name of the planet.', "user")
		r.temperature = 1.0
		r.response_format = {
		  "type": "json_schema",
		  "json_schema": {
			"schema": generation_target.get_planet_schema(),
			"name": "planet",
			"strict": true
		  }
		}
		%LanguageModelConnection.generate(r)

func _ready() -> void:
	travel_to_new_planet()

func _on_language_model_connection_request_completed(response: Variant, request_id: Variant) -> void:
	var response_content = response.choices[0].message.content
	var parsed_response_content = %LanguageModelConnection.parse_llm_response(response_content)
	var new_planet = Planet.from_json(parsed_response_content)
	%PlanetView.planet_data = new_planet
	%Name.text = new_planet.planet_name
	%Population.text = "Population: " + str(new_planet.population) + " Million"
	%Description.text = new_planet.planet_overview
	planet_cache.append(new_planet)
	loading = false

func _on_language_model_connection_request_failed(error: Variant, request_id: Variant) -> void:
	print(error)

func _on_random_warp_pressed() -> void:
	%PlanetView.planet_data = unknown_planet
	travel_to_new_planet()
