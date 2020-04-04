`timescale 1ns / 1ps
module whole
#(
  parameter integer DATA_WIDTH	= 32,
  parameter integer WEIGHT_WIDTH = 32,
  parameter integer UNITS = 4,
  parameter integer LUT_DEPTH = 1024,

  parameter integer WLSTM_DEPTH	= 64,
  parameter integer ULSTM_DEPTH	= 32,
  parameter integer BLSTM_DEPTH	= 16,

  parameter integer WFC_DEPTH	= 4,
  parameter integer BFC_DEPTH	= 1
)
(
  input   [DATA_WIDTH-1:0] xt0,                     //input Xt0 = 0.0157
  input   [DATA_WIDTH-1:0] xt1,                     //input Xt1 = 0.0207
  input   [DATA_WIDTH-1:0] ht_prev0,                //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ht_prev1,                //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ht_prev2,                //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ht_prev3,                //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] b,                       //bias = 1
  input   [DATA_WIDTH-1:0] ct_prev0,                //Ct-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ct_prev1,                //Ct-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ct_prev2,                //Ct-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ct_prev3,                //Ct-1 = [0 0 0 0]
  output reg [DATA_WIDTH-1:0] pred                  //output pred
);
  reg [DATA_WIDTH-1:0] w_fc[0:WFC_DEPTH-1];
  reg [DATA_WIDTH-1:0] b_fc[0:BFC_DEPTH-1];
  
  wire [DATA_WIDTH-1:0] ht0, ht1, ht2, ht3;
  wire [DATA_WIDTH-1:0] ct0, ct1, ct2, ct3;
  wire [DATA_WIDTH-1:0] ht_next0, ht_next1, ht_next2, ht_next3;
  wire [DATA_WIDTH-1:0] ct_next0, ct_next1, ct_next2, ct_next3;
  reg [DATA_WIDTH-1:0] ht_next[0:UNITS-1];
  integer i;

  initial begin
    pred = 32'b0;
    $readmemb("w_fc.mem", w_fc);
    $readmemb("b_fc.mem", b_fc);
  end

  lstm_cell #(DATA_WIDTH, LUT_DEPTH, UNITS) lstm0(
    .xt(xt0),
    .ht_prev0(ht_prev0),
    .ht_prev1(ht_prev1),
    .ht_prev2(ht_prev2),
    .ht_prev3(ht_prev3),
    .ct_prev0(ct_prev0),
    .ct_prev1(ct_prev1),
    .ct_prev2(ct_prev2),
    .ct_prev3(ct_prev3),
    .b(b),
    .ht0(ht0),
    .ht1(ht1),
    .ht2(ht2),
    .ht3(ht3),
    .ct0(ct0),
    .ct1(ct1),
    .ct2(ct2),
    .ct3(ct3)
  );

  lstm_cell #(DATA_WIDTH, LUT_DEPTH, UNITS) lstm1(
    .xt(xt1),
    .ht_prev0(ht0),
    .ht_prev1(ht1),
    .ht_prev2(ht2),
    .ht_prev3(ht3),
    .ct_prev0(ct0),
    .ct_prev1(ct1),
    .ct_prev2(ct2),
    .ct_prev3(ct3),
    .b(b),
    .ht0(ht_next0),
    .ht1(ht_next1),
    .ht2(ht_next2),
    .ht3(ht_next3),
    .ct0(ct_next0),
    .ct1(ct_next1),
    .ct2(ct_next2),
    .ct3(ct_next3)
  );

  always @(*) begin
    {ht_next[0], ht_next[1], ht_next[2], ht_next[3]} <= {ht_next0, ht_next1, ht_next2, ht_next3};
    for(i = 0; i < 4; i = i+1) begin
      pred <= pred + multiply(ht_next[i], w_fc[i]);
    end
    pred <= pred + b_fc[0];
  end

  function automatic [DATA_WIDTH-1:0] multiply(
    input [DATA_WIDTH-1:0] i1,
    input [DATA_WIDTH-1:0] i2
  );
    reg [2*DATA_WIDTH-1:0] total;
    reg sign;
    begin
      // assuming 1 bit for sign, multiply integer+fractional parts
      total = i1[DATA_WIDTH-2:0] * i2[DATA_WIDTH-2:0];
      sign = i1[DATA_WIDTH-1] ^ i2[DATA_WIDTH-1];
      multiply = {sign, total[2*DATA_WIDTH-1:DATA_WIDTH+1]};
    end
  endfunction



endmodule
