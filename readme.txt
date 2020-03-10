Weights of LSTM layer: w_lstm (for X), u_lstm (for hidden unit H) , b_lstm (biases).
Weights of fully connected layer: w_fc , b_fc .
Order of gates in Keras: i, f, c, o (in w_lstm, u_lstm, b_lstm).
.txt files contain binary representation of the weights.

Fixed point representation: [sign bit, integer bits, fractional bits].
Sign bit: 0 - positive, 1 - negative.

Multiplier outputs binary multiplication of data and weight.
The width of data = DATA_WIDTH.
The width of weight = WEIGHT_WIDTH.
The width of output = DATA_WIDTH.