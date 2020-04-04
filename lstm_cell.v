module lstm_cell
#(
  parameter integer DATA_WIDTH	= 32,
  parameter integer LUT_DEPTH	= 16,
  parameter integer UNITS       = 4
)
(
  input   [DATA_WIDTH-1:0] xt,                      //input X = 0.0157
  input   [DATA_WIDTH-1:0] ht_prev[0:UNITS-1],      //ht-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] b[0:UNITS-1],            //bias = [1 1 1 1]
  input   [DATA_WIDTH-1:0] ct_prev[0:UNITS-1],      //Ct-1 = [0 0 0 0]
  input   [DATA_WIDTH-1:0] sig_lut[0:LUT_DEPTH-1],  //sigmoid lut
  input   [DATA_WIDTH-1:0] tanh_lut[0:LUT_DEPTH-1], //tanh lut
  input   [DATA_WIDTH-1:0] w_lstm[0:15],            //weights for X
  input   [DATA_WIDTH-1:0] u_lstm[0:63],            //weights for ht-1
  input   [DATA_WIDTH-1:0] b_lstm[0:15],            //bias

  output  [DATA_WIDTH-1:0] ct[0:UNITS-1],           //Ct = [_ _ _ _]
  output  [DATA_WIDTH-1:0] ht[0:UNITS-1]            //ht = [_ _ _ _]
);

  reg [DATA_WIDTH-1:0] it[0:UNITS-1];               //input gate
  reg [DATA_WIDTH-1:0] ft[0:UNITS-1];               //forget gate
  reg [DATA_WIDTH-1:0] gt[0:UNITS-1];               //candidate gate
  reg [DATA_WIDTH-1:0] ot[0:UNITS-1];               //output gate
  reg [DATA_WIDTH-1:0] temp[0:15];                  //temporary memory for dot product

  initial begin
    temp = 0;
  end

  always @(*) begin
    for(i = 0; i < 16; i = i+1) begin
      for(j = 0; j < 4; j = j+1) begin
        temp[i] <= temp[i] + multiply(ht_prev[j], u_lstm[16*j+i]);
      end
    end
    for(i = 0; i < 4; i = i+1) begin
      it[i] <= sig_lut[multiply(xt,w_lstm[i]) + temp[i] + b_lstm[i]];
      ft[i] <= sig_lut[multiply(xt,w_lstm[4+i]) + temp[4+i] + b_lstm[4+i]];
      gt[i] <= tanh_lut[multiply(xt,w_lstm[8+i]) + temp[8+i] + b_lstm[8+i]];
      ot[i] <= sig_lut[multiply(xt,w_lstm[12+i]) + temp[12+i] + b_lstm[12+i]];
      ct[i] <= multiply(ft[i],ct_prev[i]) + multiply(it[i], gt[i]);
      ht[i] <= multiply(tanh_lut[ct[i]], ot[i]);
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

endmodule : lstm_cell
