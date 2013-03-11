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
		console.log("game made")
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
			@tieIntermediary.addInput(d)

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



class TrioBox
	constructor: (@game, @idx) ->
		trio = @game.tripleSets[@idx]
		@name = trio[0]
		@posNeuron = trio[1]
		@negNeuron = trio[2]
		@tieNeuron = trio[3]

		@TBox = document.createElement("div")
		@TBox.id = @name + "TBox"
		@TBox.className = "TrioBox"

		posColors = ["#808080", "#AA5555", "D52B2B", "FF0000"]
		negColors = ["#808080", "#55AA55", "2BD52B", "00FF00"]
		tieColors = ["#808080", "purple"]
		@posBox = new NeuronBox(@posNeuron, posColors, @me, "smallNeuronBox")
		@posBox = new NeuronBox(@posNeuron, posColors, @me, "smallNeuronBox")
		@posBox = new NeuronBox(@posNeuron, posColors, @me, "smallNeuronBox")


		

class OutcomeBox
	constructor: (@game) ->
		@me = document.createElement("div")
		@me.id = "outcomeBox"
		@me.className = "outcomeContainer"
		document.body.appendChild(@me)
		posColors = ["grey", "red"]
		negColors = ["grey", "blue"]
		tieColors = ["grey", "purple"]
		@posBox = new NeuronBox(game.posOutcome, posColors, @me, "neuronBox")
		@negBox = new NeuronBox(game.negOutcome, negColors, @me, "neuronBox")
		@tieBox = new NeuronBox(game.tieOutcome, tieColors, @me, "neuronBox")

	reload: () ->
		@posBox.reload()
		@negBox.reload()
		@tieBox.reload()


class NeuronBox
	constructor: (@neuron, @colors, @container, className) ->
		#console.log("made box @neuron.name")
		@me = document.createElement("div")
		@me.id = "neuronBox " + @neuron.name 
		@me.className = className
		@container.appendChild(@me)
		@s = @me.style
		text = document.createTextNode(@neuron.name)
		#text.style.fontColor = "grey"
		@me.appendChild(text)

	reload: () ->
		energyLevel = @neuron.energyLevel
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
		console.log("reloading")
		@nb.reload()

class Box
	constructor: (@game, @grid, @idx) ->
		#console.log("constructing", @game)
		@elem = document.createElement("div")
		@elem.id = "box" + idx
		@elem.className = "box"
		@elem.onclick = @toggle #"toggleBox(" + @idx + ")"
		@grid.me.appendChild(@elem)

	toggle: () =>
		#alert("click")
		#console.log("game: ", @game, @idx)
		ns = @game.toggleBox(@idx)
		c = "grey" if ns is 0
		c = "red"  if ns is 1
		c = "blue" if ns is -1
		@elem.style.backgroundColor = c
		console.log("grid go reload", @grid)
		@grid.reload()

game = new TicTacToeNN()

ob = new OutcomeBox(game)
gg = new GameGrid(game, ob)



# toggleBox = (i) ->
# 	console.log("clicked")
# 	s = game.toggleBox(i)
# 	c = "grey" if ns is 0
# 	c = "red" if ns is 1
# 	c = "blue" if ns is -1
# 	boxes[i].elem.style.backgroundColor = c



