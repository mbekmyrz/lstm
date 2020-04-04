`timescale 1ns / 1ps
module lstm_cell
#(
  parameter integer DATA_WIDTH	= 32,
  parameter integer WEIGHT_WIDTH = 32,
  parameter integer UNITS = 4,
  parameter integer LUT_DEPTH	= 1024,

  parameter integer WLSTM_DEPTH	= 64,
  parameter integer ULSTM_DEPTH	= 32,
  parameter integer BLSTM_DEPTH	= 16
)
(
  input   [DATA_WIDTH-1:0] xt,                      //input X = 0.0157
  input   [DATA_WIDTH-1:0] ht_prev0,                //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ht_prev1,                //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ht_prev2,                //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ht_prev3,                //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ct_prev0,                //Ct-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ct_prev1,                //Ct-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ct_prev2,                //Ct-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] ct_prev3,                //Ct-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] b,                       //bias = 1
  output reg [DATA_WIDTH-1:0] ht0,                   //ht = [_ _ _ _]
  output reg [DATA_WIDTH-1:0] ht1,                   //ht = [_ _ _ _]
  output reg [DATA_WIDTH-1:0] ht2,                   //ht = [_ _ _ _]
  output reg [DATA_WIDTH-1:0] ht3,                   //ht = [_ _ _ _]
  output reg [DATA_WIDTH-1:0] ct0,                   //Ct = [_ _ _ _]
  output reg [DATA_WIDTH-1:0] ct1,                   //Ct = [_ _ _ _]
  output reg [DATA_WIDTH-1:0] ct2,                   //Ct = [_ _ _ _]
  output reg [DATA_WIDTH-1:0] ct3                    //Ct = [_ _ _ _]
);

  reg [DATA_WIDTH-1:0] sig_lut[0:LUT_DEPTH-1];
  reg [DATA_WIDTH-1:0] tanh_lut[0:LUT_DEPTH-1];
  reg [DATA_WIDTH-1:0] w_lstm[0:WLSTM_DEPTH-1];     //weights for X
  reg [DATA_WIDTH-1:0] u_lstm[0:ULSTM_DEPTH-1];     //weights for ht-1
  reg [DATA_WIDTH-1:0] b_lstm[0:BLSTM_DEPTH-1];     //weights for bias

  reg [DATA_WIDTH-1:0] it[0:UNITS-1];               //input gate
  reg [DATA_WIDTH-1:0] ft[0:UNITS-1];               //forget gate
  reg [DATA_WIDTH-1:0] gt[0:UNITS-1];               //candidate gate
  reg [DATA_WIDTH-1:0] ot[0:UNITS-1];               //output gate
  reg [DATA_WIDTH-1:0] temp[0:15];                  //temporary memory for dot product
  reg [DATA_WIDTH-1:0] ht_prev[0:UNITS-1];
  reg [DATA_WIDTH-1:0] ct_prev[0:UNITS-1];
  reg [DATA_WIDTH-1:0] ht[0:UNITS-1];
  reg [DATA_WIDTH-1:0] ct[0:UNITS-1];
  reg [DATA_WIDTH-1:0] it_addr[0:UNITS-1], ft_addr[0:UNITS-1], gt_addr[0:UNITS-1], ot_addr[0:UNITS-1];
  integer i, j;
  
  initial begin
    for(i = 0; i < 16; i = i+1) begin
        temp[i] = 0;
    end
    $readmemb("sigmoid_lut.mem", sig_lut);
    $readmemb("tanh_lut.mem", tanh_lut);

    $readmemb("w_lstm.mem", w_lstm);
    $readmemb("u_lstm.mem", u_lstm);
    $readmemb("b_lstm.mem", b_lstm);
  end
  
  always @(*) begin
    {ht_prev[0], ht_prev[1], ht_prev[2], ht_prev[3]} <= {ht_prev0, ht_prev1, ht_prev2, ht_prev3};
    {ct_prev[0], ct_prev[1], ct_prev[2], ct_prev[3]} <= {ct_prev0, ct_prev1, ct_prev2, ct_prev3};
    
    for(i = 0; i < 16; i = i+1) begin
      for(j = 0; j < 4; j = j+1) begin
        temp[i] <= temp[i] + multiply(ht_prev[j], u_lstm[16*j+i]);
      end
    end
    for(i = 0; i < 4; i = i+1) begin
      it_addr[i] <= multiply(xt,w_lstm[i]) + temp[i] + b_lstm[i];
      it[i] <= sig_lut[it_addr[i][DATA_WIDTH-1:DATA_WIDTH-10]];
      
      ft_addr[i] <= multiply(xt,w_lstm[4+i]) + temp[4+i] + b_lstm[4+i];
      ft[i] <= sig_lut[ft_addr[i][DATA_WIDTH-1:DATA_WIDTH-10]];
      
      gt_addr[i] <= multiply(xt,w_lstm[8+i]) + temp[8+i] + b_lstm[8+i];
      gt[i] <= tanh_lut[gt_addr[i][DATA_WIDTH-1:DATA_WIDTH-10]];
      
      ot_addr[i] <= multiply(xt,w_lstm[12+i]) + temp[12+i] + b_lstm[12+i];
      ot[i] <= sig_lut[ot_addr[i][DATA_WIDTH-1:DATA_WIDTH-10]];
      
      ct[i] <= multiply(ft[i],ct_prev[i]) + multiply(it[i], gt[i]);
      ht[i] <= multiply(tanh_lut[ct[i][DATA_WIDTH-1:DATA_WIDTH-10]], ot[i]);
    end
    
    {ht0, ht1, ht2, ht3} <= {ht[0], ht[1], ht[2], ht[3]};
    {ct0, ct1, ct2, ct3} <= {ct[0], ct[1], ct[2], ct[3]};
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
