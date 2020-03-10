//module always assumes 1 bit for sign
module multiplier #
(
  parameter integer DATA_WIDTH	= 32,
  parameter integer WEIGHT_WIDTH	= 32
)
(
  input [DATA_WIDTH-1:0] data,
  input [WEIGHT_WIDTH-1:0] weight,
  output [DATA_WIDTH-1:0] out
);

wire [DATA_WIDTH+WEIGHT_WIDTH-1:0] total;
wire sign;

// assuming always 1 bit for sign, multiply integer+fractional parts
assign total = data[DATA_WIDTH-2:0] * weight[WEIGHT_WIDTH-2:0];
assign sign = data[DATA_WIDTH-1] ^ weight[WEIGHT_WIDTH-1];
assign out = {sign, total[DATA_WIDTH+WEIGHT_WIDTH-1:WEIGHT_WIDTH+1]};

endmodule // multiplier
