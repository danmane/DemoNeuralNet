class Neuron
	@numNeurons =  0

	constructor: (@name) ->
		@id = Neuron.numNeurons
		Neuron.numNeurons++
		@energyLevel = 0
		#Neuron.allNeurons.push(this)
		@inputs = [] # [Neuron, threshold] pairs
		@externalInput = 0 # for inputting to the system from non-neural sources

	calculateEnergy: () -> 
		@energyLevel = @externalInput
		for [n, threshold] in @inputs
			@energyLevel++ if n.energyLevel > threshold

	addInput: (inputNeuron, threshold=1) ->
		@inputs.push([inputNeuron, threshold])


class TicTacToeNN
	constructor: () ->
#		@NN = new NeuralNet("Tic Tac Toe Neural Net")
		@boxes = (0 for x in [0..8])  # Each will take on a +1 0 or -1 state, initialize to 0
		@neuralLevels = ([] for x in [0..3])
		# level 0: Input neurons connected to boxes
		# level 1: trinary win neurons
		# level 2: double draw neurons, redWins, blueWins
		# level 3: outcome draw, outcome invalid

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

		@addOutcomeNeurons


	addNeuron: (name, level) ->
		newN = new Neuron(name)
		@neuralLevels[level].push(new Neuron(name))
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
		return true

	addOutcomeNeurons: () ->
		@posOutcome = addNeuron("Positive Outcome", 2)
		@negOutcome = addNeuron("Negative Outcome", 2)

		for posWin in @posWinNeurons
			@posOutcome.addInput(posWin, 3)

		for negWin in @negWinNeurons
			@negOutcome.addInput(negWin, 3)

		@drawOutcome = addNeuron("Draw Outcome", 3)
		for d in @drawNeurons
			@drawOutcome.addInput(d)
		return true

	recalculate: () ->
		for l in @neuralLevels
			for n in l
				n.recalculate()
		return true

	changeBox: (boxIdx, newState) ->
		@boxes[boxIdx] = newState
		
		@posBaseNeurons[boxIdx].externalInput = if (newState == 1) then 1 else 0
		@negBaseNeurons[boxIdx].externalInput = if (newState ==-1) then 1 else 0
		return true










# n1 = new Neuron(0, "first")
# n2 = new Neuron(1, "second")
# console.log(n1)
# console.log(Neuron)
# n1.externalInput = 1
# n2.addInput(n1, 1)
# console.log("n1", n1)
# console.log("n2", n2)