module whole
#(
  parameter integer DATA_WIDTH	= 32,
  parameter integer WEIGHT_WIDTH = 32,
  parameter integer UNITS = 4,
  parameter integer LUT_DEPTH	= 16,

  parameter integer WLSTM_DEPTH	= 64,
  parameter integer ULSTM_DEPTH	= 32,
  parameter integer BLSTM_DEPTH	= 16,

  parameter integer WFC_DEPTH	= 4,
  parameter integer BFC_DEPTH	= 1
)
(
  input   [DATA_WIDTH-1:0] xt0,                     //input Xt0 = 0.0157
  input   [DATA_WIDTH-1:0] xt1,                     //input Xt1 = 0.0207
  input   [DATA_WIDTH-1:0] ht_prev[0:UNITS-1],      //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] b[0:UNITS-1],            //bias = [1 1 1 1]
  input   [DATA_WIDTH-1:0] ct_prev[0:UNITS-1],      //Ct-1 = [0 0 0 0]
  output  [DATA_WIDTH-1:0] pred                     //output pred
);

  reg [DATA_WIDTH-1:0] sigmoid_lut[0:LUT_DEPTH-1];
  reg [DATA_WIDTH-1:0] tanh_lut[0:LUT_DEPTH-1];

  reg [DATA_WIDTH-1:0] w_lstm[0:WLSTM_DEPTH-1];
  reg [DATA_WIDTH-1:0] u_lstm[0:ULSTM_DEPTH-1];
  reg [DATA_WIDTH-1:0] b_lstm[0:BLSTM_DEPTH-1];

  reg [DATA_WIDTH-1:0] w_fc[0:WFC_DEPTH-1];
  reg [DATA_WIDTH-1:0] b_fc[0:BFC_DEPTH-1];

  reg [DATA_WIDTH-1:0] ht[0:UNITS-1];
  reg [DATA_WIDTH-1:0] ct[0:UNITS-1];
  reg [DATA_WIDTH-1:0] ht_next[0:UNITS-1];
  reg [DATA_WIDTH-1:0] ct_next[0:UNITS-1];

  initial begin
    pred = 0;
    $readmemb("memory/luts_bin/sigmoid_lut.mem", sigmoid_lut);
    $readmemb("memory/luts_bin/tanh_lut.mem", tanh_lut);

    $readmemb("memory/weights_bin/w_lstm.mem", w_lstm);
    $readmemb("memory/weights_bin/u_lstm.mem", u_lstm);
    $readmemb("memory/weights_bin/b_lstm.mem", b_lstm);

    $readmemb("memory/weights_bin/w_fc.mem", w_fc);
    $readmemb("memory/weights_bin/b_fc.mem", b_fc);
  end

  lstm_cell #(DATA_WIDTH, LUT_DEPTH, UNITS) lstm0(
    .xt(xt0),
    .ht_prev(ht_prev),
    .b(b),
    .ct_prev(ct_prev),
    .sig_lut(sigmoid_lut),
    .tanh_lut(tanh_lut),
    .w_lstm(w_lstm),
    .u_lstm(u_lstm),
    .b_lstm(b_lstm),
    .ct(ct),
    .ht(ht)
  );

  lstm_cell #(DATA_WIDTH, LUT_DEPTH, UNITS) lstm1(
    .xt(xt1),
    .ht_prev(ht),
    .b(b),
    .ct_prev(ct),
    .sig_lut(sigmoid_lut),
    .tanh_lut(tanh_lut),
    .w_lstm(w_lstm),
    .u_lstm(u_lstm),
    .b_lstm(b_lstm),
    .ct(ct_next),
    .ht(ht_next)
  );

  always @(*) begin
    for(i = 0; i < 4; i = i+1) begin
      pred <= pred + multiply(ht_next[i], w_fc[i]) + b_fc;
    end
  end

  function automatic [DATA_WIDTH-1:0] multiply(
    input [DATA_WIDTH-1:0] i1,
    input [DATA_WIDTH-1:0] i2
  );
    reg   [2*DATA_WIDTH-1:0] total;
    reg sign;
    begin
      // assuming 1 bit for sign, multiply integer+fractional parts
      total = i1[DATA_WIDTH-2:0] * i2[DATA_WIDTH-2:0];
      sign = i1[DATA_WIDTH-1] ^ i2[DATA_WIDTH-1];
      multiply = {sign, total[2*DATA_WIDTH-1:DATA_WIDTH+1]};
    end
  endfunction



endmodule : whole
