class Neuron
	@numNeurons =  0

	constructor: (@name) ->
		@id = Neuron.numNeurons
		Neuron.numNeurons++
		@energyLevel = 0
		#Neuron.allNeurons.push(this)
		@inputs = [] # [Neuron, threshold] pairs
		@externalInput = 0 # for inputting to the system from non-neural sources

	recalculate: () -> 
		@energyLevel = @externalInput
		for [n, threshold] in @inputs
			@energyLevel++ if n.energyLevel >= threshold

	addInput: (inputNeuron, threshold=1) ->
		@inputs.push([inputNeuron, threshold])


class TicTacToeNN
	constructor: () ->
		@boxes = (0 for x in [0..8])  # Each will take on a +1 0 or -1 state, initialize to 0
		@neuralLevels = ([] for x in [0..4])
		@tripleSets = []
		# level 0: Input neurons connected to boxes
		# level 1: trinary win neurons
		# level 2: double tie neurons, redWins, blueWins
		# level 3: tie Intermediary
		# level 4: tie outcome

		@posBaseNeurons = (@addNeuron(i + '+', 0) for i in [0..8])
		@negBaseNeurons = (@addNeuron(i + '-', 0) for i in [0..8])
		#@baseNeurons = [@posNeurons, @negNeurons]

		@posWinNeurons = []
		@negWinNeurons = []
		@tieNeurons = []

		@addTripleSet("Top Across", [0, 1, 2])
		@addTripleSet("Mid Across", [3, 4, 5])
		@addTripleSet("Bot Across", [6, 7, 8])

		@addTripleSet("Left  Vertical", [0, 3, 6])
		@addTripleSet("Mid   Vertical", [1, 4, 7])
		@addTripleSet("Right Vertical", [2, 5, 8])

		@addTripleSet("Up Diagonal",   [6, 4, 2])
		@addTripleSet("Down Diagonal", [0, 4, 8])

		@addOutcomeNeurons()


	addNeuron: (name, level) ->
		newN = new Neuron(name)
		@neuralLevels[level].push(newN)
		return newN


	addTripleSet: (name, ipts) ->
		# Add a trio of neurons representing a winning combo
		newPos  = @addNeuron(name + '+', 1)
		newNeg  = @addNeuron(name + '-', 1)
		newtie = @addNeuron(name + '=', 2)
		for i in ipts
			newPos.addInput(@posBaseNeurons[i])
			newNeg.addInput(@negBaseNeurons[i])
		newtie.addInput(newPos)
		newtie.addInput(newNeg)

		@posWinNeurons.push(newPos)
		@negWinNeurons.push(newNeg)
		@tieNeurons.push(newtie)
		@tripleSets.push([name, newPos, newNeg, newtie])
		return true

	addOutcomeNeurons: () ->
		@posOutcome = @addNeuron("Red Wins!", 2)
		@negOutcome = @addNeuron("Blue Wins!", 2)

		for posWin in @posWinNeurons
			@posOutcome.addInput(posWin, 3)

		for negWin in @negWinNeurons
			@negOutcome.addInput(negWin, 3)

		@tieIntermediary = @addNeuron("tie Intermediary", 3)
		for d in @tieNeurons
			@tieIntermediary.addInput(d,2)

		@tieOutcome = @addNeuron("It's a tie!", 4)
		@tieOutcome.addInput(@tieIntermediary, 8)

		return true

	recalculate: () ->
		for l in @neuralLevels
			for n in l
				n.recalculate()
		return true

	changeBox: (boxIdx, newState) ->
		@boxes[boxIdx] = newState

		@posBaseNeurons[boxIdx].externalInput = if (newState ==  1) then 1 else 0
		@negBaseNeurons[boxIdx].externalInput = if (newState == -1) then 1 else 0

		@recalculate()

	toggleBox: (boxIdx) ->
		currentState = @boxes[boxIdx]
		if currentState == 1 then newState = -1 else newState = currentState + 1
		@changeBox(boxIdx, newState)
		newState


class TrioContainer
	constructor: (@game) ->
		@me = document.createElement("div")
		@me.id = "AlTrioBoxes"
		@me.className = "trioContainer"
		document.body.appendChild(@me)
		@trios = []
		for i in [0..7]
			@trios.push(new TrioBox(@game, i, @me))

	reload: () ->
		for t in @trios
			t.reload()


class TrioBox
	constructor: (@game, @idx, parent) ->
		trio = @game.tripleSets[@idx]
		@name = trio[0]
		@posNeuron = trio[1]
		@negNeuron = trio[2]
		@tieNeuron = trio[3]

		@me = document.createElement("div")
		@me.id = @name + "TBox"
		@me.className = "trioBox"
		parent.appendChild(@me)

		@title = document.createElement("div")
		@title.id = @name + "Title"
		@title.className = "trioTitle"
		@me.appendChild(@title)

		@titleText = document.createTextNode(@name)
		@title.appendChild(@titleText)
		#document.body.appendChild(parent)


		posColors = ["#808080", "#AA5555", "#D52B2B", "#FF0000"]
		negColors = ["#808080", "#5555AA", "#2B2BD5", "#0000FF"]
		tieColors = ["#808080", "#DA70D6", "purple"]
		@posBox = new NeuronBox(@posNeuron, posColors, @me, true)
		@negBox = new NeuronBox(@negNeuron, negColors, @me, true)
		@tieBox = new NeuronBox(@tieNeuron, tieColors, @me, true)

	reload: () => 
		@posBox.reload()
		@negBox.reload()
		@tieBox.reload()

		

class OutcomeBox
	constructor: (@game) ->
		@me = document.createElement("div")
		@me.id = "outcomeBox"
		@me.className = "outcomeContainer"
		document.body.appendChild(@me)
		posColors = ["grey", "red"]
		negColors = ["grey", "blue"]
		tieColors = ["grey", "purple"]
		@posBox = new NeuronBox(game.posOutcome, posColors, @me, false)
		@negBox = new NeuronBox(game.negOutcome, negColors, @me, false)
		@tieBox = new NeuronBox(game.tieOutcome, tieColors, @me, false)

	reload: () ->
		@posBox.reload()
		@negBox.reload()
		@tieBox.reload()


class NeuronBox
	constructor: (@neuron, @colors, @container, isSmall) ->
		if isSmall
			className = "smallNeuronBox"
		else
			className = "neuronBox"
		@me = document.createElement("div")
		@me.id = "neuronBox " + @neuron.name 
		@me.className = className
		@container.appendChild(@me)
		@s = @me.style
		unless isSmall
			text = document.createTextNode(@neuron.name)
			@me.appendChild(text)

	reload: () ->
		energyLevel = @neuron.energyLevel
		#console.log("reloaded ", @neuron.name, "color to ", @colors[energyLevel], @colors, energyLevel)
		@me.style.backgroundColor = @colors[energyLevel]

class GameGrid
	constructor: (@game, @nb) ->
		@me = document.createElement("div");
		@me.id = "grid"
		@me.className = "gameGrid"
		document.body.appendChild(@me)
		boxes = []
		for i in [0..8]
			boxes.push( new Box(game, @, i) )

	reload: () =>
		@nb.reload()

class Box
	nextToggle = 1
	constructor: (@game, @grid, @idx) ->
		@elem = document.createElement("div")
		@elem.id = "box" + idx
		@elem.className = "box"
		@elem.onclick = @toggle #"toggleBox(" + @idx + ")"
		@grid.me.appendChild(@elem)

	toggle: () =>
		if @game.boxes[@idx] == 0
			console.log("toggling box ", @idx, nextToggle)
			#ns = @game.toggleBox(@idx)
			ns = nextToggle
			@game.changeBox(@idx, ns)
			nextToggle *= -1
			c = "grey" if ns is 0
			c = "red"  if ns is 1
			c = "blue" if ns is -1
			@elem.style.backgroundColor = c
		@grid.reload()

class BoardAndNeurons
	constructor: (@game) ->
		@ob = new OutcomeBox(@game)
		@tc = new TrioContainer(@game)
		@gg = new GameGrid(game, @)

	reload: () =>
		@tc.reload()
		@ob.reload()



game = new TicTacToeNN()

ban = new BoardAndNeurons(game)



# toggleBox = (i) ->
# 	s = game.toggleBox(i)
# 	c = "grey" if ns is 0
# 	c = "red" if ns is 1
# 	c = "blue" if ns is -1
# 	boxes[i].elem.style.backgroundColor = c



