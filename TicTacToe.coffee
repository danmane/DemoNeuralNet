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
		if (@name == '0+')
			console.log('recalculating ', @name, @externalInput, this)
		@energyLevel = @externalInput
		if (@name == '0+')
			console.log(@name, @externalInput, @energyLevel)
		for [n, threshold] in @inputs
			console.log(n, threshold)
			@energyLevel++ if n.energyLevel >= threshold

	addInput: (inputNeuron, threshold=1) ->
		@inputs.push([inputNeuron, threshold])


class TicTacToeNN
	constructor: () ->
#		@NN = new NeuralNet("Tic Tac Toe Neural Net")
		@boxes = (0 for x in [0..8])  # Each will take on a +1 0 or -1 state, initialize to 0
		@neuralLevels = ([] for x in [0..4])
		@tripleSets = []
		# level 0: Input neurons connected to boxes
		# level 1: trinary win neurons
		# level 2: double draw neurons, redWins, blueWins
		# level 3: draw Intermediary
		# level 4: draw outcome

		@posBaseNeurons = (@addNeuron(i + '+', 0) for i in [0..8])
		@negBaseNeurons = (@addNeuron(i + '-', 0) for i in [0..8])
		#@baseNeurons = [@posNeurons, @negNeurons]

		@posWinNeurons = []
		@negWinNeurons = []
		@drawNeurons = []

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
		newDraw = @addNeuron(name + '=', 2)
		for i in ipts
			newPos.addInput(@posBaseNeurons[i])
			newNeg.addInput(@negBaseNeurons[i])
		newDraw.addInput(newPos)
		newDraw.addInput(newNeg)

		@posWinNeurons.push(newPos)
		@negWinNeurons.push(newNeg)
		@drawNeurons.push(newDraw)
		@tripleSets.push([name, newPos, newNeg, newDraw])
		return true

	addOutcomeNeurons: () ->
		@posOutcome = @addNeuron("Positive Outcome", 2)
		@negOutcome = @addNeuron("Negative Outcome", 2)

		for posWin in @posWinNeurons
			@posOutcome.addInput(posWin, 3)

		for negWin in @negWinNeurons
			@negOutcome.addInput(negWin, 3)

		@drawIntermediary = @addNeuron("Draw Intermediary", 3)
		for d in @drawNeurons
			@drawIntermediary.addInput(d)

		@drawOutcome = @addNeuron("Draw Outcome", 4)
		@drawOutcome.addInput(@drawIntermediary, 8)

		return true

	recalculate: () ->
		# console.log(@neuralLevels)
		for l in @neuralLevels
			# console.log(l)
			for n in l
				# console.log(n)
				n.recalculate()
		return true

	changeBox: (boxIdx, newState) ->
		console.log("Called change box: idx, state ", boxIdx, newState, @posBaseNeurons[boxIdx])
		@boxes[boxIdx] = newState

		@posBaseNeurons[boxIdx].externalInput = if (newState ==  1) then 1 else 0
		@negBaseNeurons[boxIdx].externalInput = if (newState == -1) then 1 else 0


		#console.log("After switch: ", @posBaseNeurons[boxIdx])


		@recalculate()

		#console.log("Neuron after recalculate: ", @posBaseNeurons[boxIdx])


	toggleBox: (boxIdx) ->
		currentState = @boxes[boxIdx]
		if currentState == 1 then newState = -1 else newState = currentState + 1
		@changeBox(boxIdx, newState)
		newState


# n = new Neuron("test")
# n.recalculate()
# console.log(n)
# n.externalInput = 1
# n.recalculate()
# console.log(n)

class Box
	constructor: (@game, grid, @idx) ->
		console.log("constructing")
		@elem = document.createElement("div")
		@elem.id = "box" + idx
		@elem.className = "box"
		@elem.onclick = @toggle()
		grid.appendChild(@)

	toggle: () ->
		ns = @game.toggleBox(@idx)
		c = "grey" if ns is 0
		c = "red"  if ns is 1
		c = "blue" if ns is -1
		@elem.style.backgroundColor = c





game = new TicTacToeNN()

gameGrid = document.createElement("div");
gameGrid.id = "grid"
gameGrid.className = "gameGrid"
document.body.appendChild(gameGrid)
for i in [0..8]
	b = new Box(game, gameGrid, i)
	# console.log('making box')
	# box = document.createElement("div");
	# box.id = "box" + i
	# box.className = "box"
	# box.onclick = @toggle()
	# gameGrid.appendChild(box)




#console.log(game.posOutcome.inputs)
# console.log(game.neuralLevels[0])
# console.log('==================')
# console.log('==================')
# console.log('==================')
# console.log(game.posBaseNeurons)
# console.log("Toggling box 0")
# game.toggleBox(0)
# #game.toggleBox(1)
# #game.toggleBox(2)
# console.log("Boxes: ", game.boxes)
# console.log("Neuron 0: ", game.posBaseNeurons[0])
# console.log("Calling recalculate on neuron 0:")
# game.posBaseNeurons[0].recalculate()

# console.log("Neuron 0: ", game.posBaseNeurons[0])

