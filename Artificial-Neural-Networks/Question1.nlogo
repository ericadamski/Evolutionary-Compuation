links-own [weight]

breed [bias-nodes bias-node]
breed [input-nodes input-node]
breed [output-nodes output-node]
breed [hidden-nodes hidden-node]

turtles-own [
  activation     ;; Determines the nodes output ( I think this may need to be changed )
  err            ;; Used by backpropagation to feed error backwards
]

globals [
  epoch-error    ;; measurement of how many training examples the network got wrong in the epoch
  
  input-node-1   ;; keep the input and output nodes
  input-node-2   ;; in global variables so we can
  output-node-1  ;; refer to them directly
  
  ;; four input nodes
  ;;;;;;;;;;;;;;;;;
  ;; sepal nodes ;;
  ;;;;;;;;;;;;;;;;;
  sepal-length-node
  sepal-width-node
  
  ;;;;;;;;;;;;;;;;;
  ;; petal nodes ;;
  ;;;;;;;;;;;;;;;;; 
  petal-length-node
  petal-width-node
  
  ;;;;;;;;;;;;
  ;; output ;;
  ;;;;;;;;;;;;
  classification-node
  
  ;;;;;;;;;;
  ;; Data ;;
  ;;;;;;;;;;
  test-set
  setosa-test-set
  setosa-verification-set
  versicolor-test-set
  versicolor-verification-set
  virginica-test-set
  virginica-verification-set
  
  min-activation
  max-activation
  
  virginica
  setosa
  versicolor
]

;;;
;;; SETUP PROCEDURES
;;;

to setup
  clear-all
  set virginica 0.0
  set setosa 0.5
  set versicolor 1.0
  set test-set [
     ["iris-setosa" [
      [5.1 3.5 1.4 0.2]
      [4.9 3.0 1.4 0.2]
      [4.7 3.2 1.3 0.2]
      [4.6 3.1 1.5 0.2]
      [5.0 3.6 1.4 0.2]
      [5.4 3.9 1.7 0.4]
      [4.6 3.4 1.4 0.3]
      [5.0 3.4 1.5 0.2]
      [4.4 2.9 1.4 0.2]
      [4.9 3.1 1.5 0.1]
      [5.4 3.7 1.5 0.2]
      [4.8 3.4 1.6 0.2]
      [4.8 3.0 1.4 0.1]
      [4.3 3.0 1.1 0.1]
      [5.8 4.0 1.2 0.2]
      [5.7 4.4 1.5 0.4]
      [5.4 3.9 1.3 0.4]
      [5.1 3.5 1.4 0.3]
      [5.7 3.8 1.7 0.3]
      [5.1 3.8 1.5 0.3]
      [5.4 3.4 1.7 0.2]
      [5.1 3.7 1.5 0.4]
      [4.6 3.6 1.0 0.2]
      [5.1 3.3 1.7 0.5]
      [4.8 3.4 1.9 0.2]
      [5.0 3.0 1.6 0.2]
      [5.0 3.4 1.6 0.4]
      [5.2 3.5 1.5 0.2]
      [5.2 3.4 1.4 0.2]
      [4.7 3.2 1.6 0.2]
      [4.8 3.1 1.6 0.2]
      [5.4 3.4 1.5 0.4]
      [5.2 4.1 1.5 0.1]
      [5.5 4.2 1.4 0.2]
      [4.9 3.1 1.5 0.1]
      [5.0 3.2 1.2 0.2]
      [5.5 3.5 1.3 0.2]
      [4.9 3.1 1.5 0.1]
      [4.4 3.0 1.3 0.2]
      [5.1 3.4 1.5 0.2]
      [5.0 3.5 1.3 0.3]
      [4.5 2.3 1.3 0.3]
      [4.4 3.2 1.3 0.2]
      [5.0 3.5 1.6 0.6]
      [5.1 3.8 1.9 0.4]
      [4.8 3.0 1.4 0.3]
      [5.1 3.8 1.6 0.2]
      [4.6 3.2 1.4 0.2]
      [5.3 3.7 1.5 0.2]
      [5.0 3.3 1.4 0.2]
     ]]
     ["iris-versicolor" [
      [7.0 3.2 4.7 1.4]
      [6.4 3.2 4.5 1.5]
      [6.9 3.1 4.9 1.5]
      [5.5 2.3 4.0 1.3]
      [6.5 2.8 4.6 1.5]
      [5.7 2.8 4.5 1.3]
      [6.3 3.3 4.7 1.6]
      [4.9 2.4 3.3 1.0]
      [6.6 2.9 4.6 1.3]
      [5.2 2.7 3.9 1.4]
      [5.0 2.0 3.5 1.0]
      [5.9 3.0 4.2 1.5]
      [6.0 2.2 4.0 1.0]
      [6.1 2.9 4.7 1.4]
      [5.6 2.9 3.6 1.3]
      [6.7 3.1 4.4 1.4]
      [5.6 3.0 4.5 1.5]
      [5.8 2.7 4.1 1.0]
      [6.2 2.2 4.5 1.5]
      [5.6 2.5 3.9 1.1]
      [5.9 3.2 4.8 1.8]
      [6.1 2.8 4.0 1.3]
      [6.3 2.5 4.9 1.5]
      [6.1 2.8 4.7 1.2]
      [6.4 2.9 4.3 1.3]
      [6.6 3.0 4.4 1.4]
      [6.8 2.8 4.8 1.4]
      [6.7 3.0 5.0 1.7]
      [6.0 2.9 4.5 1.5]
      [5.7 2.6 3.5 1.0]
      [5.5 2.4 3.8 1.1]
      [5.5 2.4 3.7 1.0]
      [5.8 2.7 3.9 1.2]
      [6.0 2.7 5.1 1.6]
      [5.4 3.0 4.5 1.5]
      [6.0 3.4 4.5 1.6]
      [6.7 3.1 4.7 1.5]
      [6.3 2.3 4.4 1.3]
      [5.6 3.0 4.1 1.3]
      [5.5 2.5 4.0 1.3]
      [5.5 2.6 4.4 1.2]
      [6.1 3.0 4.6 1.4]
      [5.8 2.6 4.0 1.2]
      [5.0 2.3 3.3 1.0]
      [5.6 2.7 4.2 1.3]
      [5.7 3.0 4.2 1.2]
      [5.7 2.9 4.2 1.3]
      [6.2 2.9 4.3 1.3]
      [5.1 2.5 3.0 1.1]
      [5.7 2.8 4.1 1.3]
    ]] 
    ["iris-virginica"  [
      [6.3 3.3 6.0 2.5] 
      [5.8 2.7 5.1 1.9] 
      [7.1 3.0 5.9 2.1] 
      [6.3 2.9 5.6 1.8] 
      [6.5 3.0 5.8 2.2] 
      [7.6 3.0 6.6 2.1] 
      [4.9 2.5 4.5 1.7] 
      [7.3 2.9 6.3 1.8] 
      [6.7 2.5 5.8 1.8] 
      [7.2 3.6 6.1 2.5] 
      [6.5 3.2 5.1 2.0] 
      [6.4 2.7 5.3 1.9] 
      [6.8 3.0 5.5 2.1] 
      [5.7 2.5 5.0 2.0] 
      [5.8 2.8 5.1 2.4] 
      [6.4 3.2 5.3 2.3] 
      [6.5 3.0 5.5 1.8] 
      [7.7 3.8 6.7 2.2] 
      [7.7 2.6 6.9 2.3] 
      [6.0 2.2 5.0 1.5] 
      [6.9 3.2 5.7 2.3] 
      [5.6 2.8 4.9 2.0] 
      [7.7 2.8 6.7 2.0] 
      [6.3 2.7 4.9 1.8] 
      [6.7 3.3 5.7 2.1] 
      [7.2 3.2 6.0 1.8] 
      [6.2 2.8 4.8 1.8] 
      [6.1 3.0 4.9 1.8] 
      [6.4 2.8 5.6 2.1] 
      [7.2 3.0 5.8 1.6] 
      [7.4 2.8 6.1 1.9] 
      [7.9 3.8 6.4 2.0] 
      [6.4 2.8 5.6 2.2] 
      [6.3 2.8 5.1 1.5] 
      [6.1 2.6 5.6 1.4] 
      [7.7 3.0 6.1 2.3] 
      [6.3 3.4 5.6 2.4] 
      [6.4 3.1 5.5 1.8] 
      [6.0 3.0 4.8 1.8] 
      [6.9 3.1 5.4 2.1] 
      [6.7 3.1 5.6 2.4] 
      [6.9 3.1 5.1 2.3] 
      [5.8 2.7 5.1 1.9] 
      [6.8 3.2 5.9 2.3] 
      [6.7 3.3 5.7 2.5] 
      [6.7 3.0 5.2 2.3] 
      [6.3 2.5 5.0 1.9] 
      [6.5 3.0 5.2 2.0] 
      [6.2 3.4 5.4 2.3] 
      [5.9 3.0 5.1 1.8]
    ]]
  ]
  ask patches [ set pcolor gray ]
  set-default-shape bias-nodes "bias-node"
  set-default-shape input-nodes "circle"
  set-default-shape output-nodes "output-node"
  set-default-shape hidden-nodes "output-node"
  set-default-shape links "small-arrow-shape"
  ;;setup-nodes
  ;;setup-links
  setup-setosa
  setup-versicolor
  setup-virginica
  set min-activation min-value
  set max-activation max-value
  setup-flower-nodes
  setup-flower-links
  propagate
  reset-ticks
end

to setup-virginica
  let virginica-data-set get-data-set "virginica"
  set virginica-test-set build-test-set ( (length virginica-data-set) / 2 ) virginica-data-set
  set virginica-verification-set filter [ not member? ? virginica-data-set ] virginica-test-set
  
  let normalized-test-virginica []
  let normalized-veri-virginica []
  
  foreach virginica-verification-set [
    set normalized-veri-virginica lput column-normalization ? normalized-veri-virginica 
  ]
  
  foreach virginica-test-set [
    set normalized-test-virginica lput column-normalization ? normalized-test-virginica
  ]
  
  set virginica-test-set normalized-test-virginica
  set virginica-verification-set normalized-veri-virginica
end

to setup-setosa
  let setosa-data-set get-data-set "setosa"
  set setosa-test-set build-test-set ( (length setosa-data-set) / 2 ) setosa-data-set
  set setosa-verification-set filter [ not member? ? setosa-data-set ] setosa-test-set
  
  let normalized-test []
  let normalized-veri []
  
  foreach setosa-test-set [
     set normalized-test lput column-normalization ? normalized-test
  ]
  
  foreach setosa-verification-set [
     set normalized-veri lput column-normalization ? normalized-veri
  ]
  
  set setosa-test-set normalized-test
  set setosa-verification-set normalized-veri
end

to setup-versicolor
  let versicolor-data-set get-data-set "versicolor"
  set versicolor-test-set build-test-set ( (length versicolor-data-set) / 2 ) versicolor-data-set
  set versicolor-verification-set filter [ not member? ? versicolor-data-set ] versicolor-test-set
  
  let normalized-test []
  let normalized-veri []
  
  foreach versicolor-test-set [
     set normalized-test lput column-normalization ? normalized-test
  ]
  
  foreach versicolor-verification-set [
     set normalized-veri lput column-normalization ? normalized-veri
  ]
  
  set versicolor-test-set normalized-test
  set versicolor-verification-set normalized-veri
end

to setup-nodes
  create-bias-nodes 1 [ setxy -4 6 ]
  ask bias-nodes [ set activation 1 ]
  create-input-nodes 1 [
    setxy -6 -2
    set input-node-1 self
  ]
  create-input-nodes 1 [
    setxy -6 2
    set input-node-2 self
  ]
  ask input-nodes [ set activation random 2 ]
  create-hidden-nodes 1 [ setxy 0 -2 ]
  create-hidden-nodes 1 [ setxy 0  2 ]
  ask hidden-nodes [
    set activation random 2
    set size 1.5
  ]
  create-output-nodes 1 [
    setxy 5 0
    set output-node-1 self
    set activation random 2
  ]
end

to setup-flower-nodes
  ;;create-bias-nodes 1 [ setxy -4 6 ] ;; no bias in the paper
  ;;ask bias-nodes [ set activation 1 ]
  
  ;; Sepal Length
  create-input-nodes 1 [
    setxy -6 4
    set sepal-length-node self
  ]
  
  ;; Sepal Width
  create-input-nodes 1 [
    setxy -5 2
    set sepal-width-node self
  ]
  
  ;; Petal Length
  create-input-nodes 1 [
    setxy -6 -4
    set petal-length-node self
  ]
  
  ;; Petal Width
  create-input-nodes 1 [
    setxy -5 -2
    set petal-width-node self
  ]
  ask input-nodes [ set activation random-activation ]
  
  ;; Create 4 hidden nodes, one for each input ;;
  create-hidden-nodes 1 [ setxy 0 2 ]
  create-hidden-nodes 1 [ setxy 0 0 ]
  create-hidden-nodes 1 [ setxy 0 -2 ]
  
  ask hidden-nodes [ 
    set activation random-activation
    set size 1.5
  ]
  
  create-output-nodes 1 [
    setxy 5 0
    set classification-node self
    set activation random-activation
  ]
end

to setup-links
  connect-all bias-nodes hidden-nodes
  connect-all bias-nodes output-nodes
  connect-all input-nodes hidden-nodes
  connect-all hidden-nodes output-nodes
end

to setup-flower-links
  connect-all input-nodes hidden-nodes
  connect-all hidden-nodes output-nodes
end

to connect-all [nodes1 nodes2]
  ask nodes1 [
    create-links-to nodes2 [
      set weight random-float 0.2 - 0.1
    ]
  ]
end

to recolor
  ask turtles [
    set color item (step activation) [black white]
  ]
  ask links [
    set thickness 0.05 * abs weight
    ifelse show-weights? [
      set label precision weight 4
    ] [
      set label ""
    ]
    ifelse weight > 0
      [ set color [ 255 0 0 196 ] ]   ; transparent red
      [ set color [ 0 0 255 196 ] ] ; transparent light blue
  ]
end

;;;
;;; TRAINING PROCEDURES
;;;

to train
  ;; assign a value from a test column ( [ a b c d ] ) to an input node,
  ;; check the output value against the class ( 0 .5 1 )
  ;; back propagate if incorrect
  let classes (list setosa versicolor virginica)
  foreach classes [
    let class ?
    foreach get-test-set class [
      assign-input-node-values ?
      propagate
      back-propagate class
    ]
  ]
  tick
end

to assign-input-node-values [colm]
  ask sepal-width-node [ set activation first colm]
  ask sepal-length-node [ set activation first but-first colm ]
  ask petal-width-node [ set activation last but-last colm ]
  ask petal-length-node [ set activation last colm ]
end

to-report get-test-set [class]
  if class = setosa [
    ;;setosa
    report setosa-test-set
  ]
  
  if class = versicolor [
    ;;versicolor
    report versicolor-test-set
  ]
  
  if class = virginica [
    ;;virginica
    report virginica-test-set
  ]
end

;;;
;;; FUNCTIONS TO LEARN
;;;

to-report classification [class]
  ;; percent?
  report 0
end

to-report average-classification
  let setosa-classification classification setosa
  let versicolor-classification classification versicolor
  let virginica-classification classification virginica
  
  report ( setosa-classification + versicolor-classification + virginica-classification ) / 3
end

;;;
;;; PROPAGATION PROCEDURES
;;;

;; carry out one calculation from beginning to end
to propagate
  ask hidden-nodes [ set activation new-activation ]
  ask output-nodes [ set activation new-activation ]
  recolor
end

;; Determine the activation of a node based on the activation of its input nodes
to-report new-activation  ;; node procedure
  report sigmoid sum [[activation] of end1 * weight] of my-in-links
end

;; changes weights to correct for errors
to back-propagate [answer] 
  let example-error 0
   
  ask classification-node [
    set err activation * (1 - activation) * (answer - activation)
    set example-error example-error + ( (answer - activation) ^ 2 )
  ]
  
  ;; The hidden layer nodes are given error values adjusted appropriately for their
  ;; link weights
  ask hidden-nodes [
    set err activation * (1 - activation) * sum [weight * [err] of end2] of my-out-links
  ]
  ask links [
    set weight weight + learning-rate * [err] of end2 * [activation] of end1
  ]
end

;;;
;;; MISC PROCEDURES
;;;

;; computes the sigmoid function given an input value and the weight on the link
to-report sigmoid [input]
  report 1 / (1 + e ^ (- input))
end

;; computes the step function given an input value and the weight on the link
to-report step [input]
  report ifelse-value (input > ( max-activation / 2 ) ) [1][0]
end

to-report get-data-set [flower-set]
  ;; a flower-set has the form [flower-name, data-set]
  if flower-set = "setosa" [
    ;; first in the test-set
    report last first test-set
  ]
  
  if flower-set = "versicolor" [
    ;; middle in the test-set
    report last first but-first test-set
  ]
  
  if flower-set = "virginica" [
    ;; last in the test-set
    report last last test-set
  ]
end

to-report build-test-set [set-size parent-set]
  let build-set []
  
  repeat set-size [
    let current one-of parent-set
    
    while [member? current build-set] [
      set current one-of parent-set
    ]
    
    set build-set lput current build-set
  ]
  
  report build-set
end

;;;
;;; TESTING PROCEDURES
;;;
to-report get-verification-set [class]
  if class = setosa [
    report setosa-verification-set
  ]
  
  if class = virginica [
    report virginica-verification-set
  ]
  
  if class = versicolor [
    report versicolor-verification-set
  ]
end
;; test runs one instance and computes the output
to-report test-set-CA
  let test-ca 0
  
  let classes (list setosa versicolor virginica)
  foreach classes [
    let class ?
    foreach get-verification-set class [
      propagate
    ]
    ask classification-node [
      set test-ca test-ca + ( (class - activation) ^ 2 )
    ]
  ]
  report (1 - (test-ca / 75)) * 100
end

to-report result-for-inputs [n1 n2]
  ask input-node-1 [ set activation n1 ]
  ask input-node-2 [ set activation n2 ]
  propagate
  report step [activation] of one-of output-nodes
end

to-report max-value
  let max-val 0
  foreach test-set [
   foreach last ? [
    let curr-value max ?
    if curr-value > max-val [ set max-val curr-value ] 
   ]
  ]
  report max-val
end

to-report min-value
  let min-val max-value
  foreach test-set [
    foreach last ? [
      let curr-value min ?
      if min-val > curr-value [ set min-val curr-value ]
    ]
  ]
  report min-val
end

to-report random-activation
  report (random max-activation) + min-activation
end

to-report column-normalization [colm]
  ;;colm is of the form [a b c d]
  let colm-max max colm
  let colm-min min colm
  let xij map [ ? - colm-min ] colm
  
  let out []
  
  foreach xij [
    set out lput (? / ( colm-max - colm-min )) out
  ]
  
  report out
end

; Copyright 2006 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
233
11
549
276
8
-1
18.0
1
10
1
1
1
0
0
0
1
-8
8
-5
7
1
1
1
ticks
30.0

BUTTON
135
10
220
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
135
50
220
85
train
train
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
235
280
392
325
Classification Accuracy
test-set-CA
3
1
11

SLIDER
14
128
220
161
learning-rate
learning-rate
0.0
1.0
0.5
1.0E-4
1
NIL
HORIZONTAL

PLOT
13
209
220
364
Error vs. Epochs
Epochs
Error
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot epoch-error"

TEXTBOX
10
20
127
38
1. Setup neural net:
11
0.0
0

TEXTBOX
10
60
119
88
2. Train neural net:
11
0.0
0

SWITCH
235
330
395
363
show-weights?
show-weights?
1
1
-1000

BUTTON
135
90
220
123
train once
train
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This is a model of a very small neural network.  It is based on the Perceptron model, but instead of one layer, this network has two layers of "perceptrons".  Furthermore, the layers activate each other in a nonlinear way. These two additions means it can learn operations a single layer cannot.

The goal of a network is to take input from its input nodes on the far left and classify those inputs appropriately in the output nodes on the far right.  It does this by being given a lot of examples and attempting to classify them, and having a supervisor tell it if the classification was right or wrong.  Based on this information the neural network updates its weight until it correctly classifies all inputs correctly.

## HOW IT WORKS

Initially the weights on the links of the networks are random.  

The nodes on the left are the called the input nodes, the nodes in the middle are called the hidden nodes, and the node on the right is called the output node.

The activation values of the input nodes are the inputs to the network. The activation values of the hidden nodes are equal to the activation values of inputs nodes, multiplied by their link weights, summed together, and passed through the [sigmoid function](http://en.wikipedia.org/wiki/Sigmoid_function). Similarly, the activation value of the output node is equal to the activation values of hidden nodes, multiplied by the link weights, summed together, and passed through the sigmoid function. The output of the network is 1 if the activation of the output node is greater than 0.5 and 0 if it is less than 0.5.

The sigmoid function maps negative values to values between 0 and 0.5, and maps positive values to values between 0.5 and 1.  The values increase nonlinearly between 0 and 1 with a sharp transition at 0.5. 

To train the network a lot of inputs are presented to the network along with how the network should correctly classify the inputs.  The network uses a back-propagation algorithm to pass error back from the output node and uses this error to update the weights along each link.

## HOW TO USE IT

To use it press SETUP to create the network and initialize the weights to small random numbers.

Press TRAIN ONCE to run one epoch of training.  The number of examples presented to the network during this epoch is controlled by EXAMPLES-PER-EPOCH slider.

Press TRAIN to continually train the network.

In the view, the larger the size of the link the greater the weight it has.  If the link is red then it has a positive weight.  If the link is blue then it has a negative weight.

If SHOW-WEIGHTS? is on then the links will be labeled with their weights.

To test the network, set INPUT-1 and INPUT-2, then press the TEST button.  A dialog box will appear telling you whether or not the network was able to correctly classify the input that you gave it.

LEARNING-RATE controls how much the neural network will learn from any one example.

TARGET-FUNCTION allows you to choose which function the network is trying to solve.

## THINGS TO NOTICE

Unlike the Perceptron model, this model is able to learn both OR and XOR.  It is able to learn XOR because the hidden layer (the middle nodes) and the nonlinear activation allows the network to draw two lines classifying the input into positive and negative regions.  A perceptron with a linear activation can only draw a single line. As a result one of the nodes will learn essentially the OR function that if either of the inputs is on it should be on, and the other node will learn an exclusion function that if both of the inputs or on it should be on (but weighted negatively).

However unlike the perceptron model, the neural network model takes longer to learn any of the functions, including the simple OR function.  This is because it has a lot more that it needs to learn.  The perceptron model had to learn three different weights (the input links, and the bias link).  The neural network model has to learn ten weights (4 input to hidden layer weights, 2 hidden layer to output weight and the three bias weights).

## THINGS TO TRY

Manipulate the LEARNING-RATE parameter.  Can you speed up or slow down the training?

Switch back and forth between OR and XOR several times during a run.  Why does it take less time for the network to return to 0 error the longer the network runs?

## EXTENDING THE MODEL

Add additional functions for the network to learn beside OR and XOR.  This may require you to add additional hidden nodes to the network.

Back-propagation using gradient descent is considered somewhat unrealistic as a model of real neurons, because in the real neuronal system there is no way for the output node to pass its error back.  Can you implement another weight-update rule that is more valid?

## NETLOGO FEATURES

This model uses the link primitives.  It also makes heavy use of lists.

## RELATED MODELS

This is the second in the series of models devoted to understanding artificial neural networks.  The first model is Perceptron.

## CREDITS AND REFERENCES

The code for this model is inspired by the pseudo-code which can be found in Tom M. Mitchell's "Machine Learning" (1997).

Thanks to Craig Brozefsky for his work in improving this model.


## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Rand, W. and Wilensky, U. (2006).  NetLogo Artificial Neural Net - Multilayer model.  http://ccl.northwestern.edu/netlogo/models/ArtificialNeuralNet-Multilayer.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2006 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bias-node
false
0
Circle -16777216 true false 0 0 300
Circle -7500403 true true 30 30 240
Polygon -16777216 true false 120 60 150 60 165 60 165 225 180 225 180 240 135 240 135 225 150 225 150 75 135 75 150 60

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0

output-node
false
1
Circle -7500403 true false 0 0 300
Circle -2674135 true true 30 30 240
Polygon -7500403 true false 195 75 90 75 150 150 90 225 195 225 195 210 195 195 180 210 120 210 165 150 120 90 180 90 195 105 195 75

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
setup repeat 100 [ train ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0

small-arrow-shape
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 135 180
Line -7500403 true 150 150 165 180

@#$#@#$#@
1
@#$#@#$#@
