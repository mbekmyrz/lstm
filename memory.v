module memory #
(
  parameter integer DATA_WIDTH	= 32,
  parameter integer LUT_DEPTH	= 16,

  parameter integer BFC_DEPTH	= 1,
  parameter integer WFC_DEPTH	= 4,
  parameter integer BLSTM_DEPTH	= 16,
  parameter integer ULSTM_DEPTH	= 32,
  parameter integer WLSTM_DEPTH	= 64,
)
();

reg [DATA_WIDTH-1:0] sigmoid_lut[0:LUT_DEPTH-1];
reg [DATA_WIDTH-1:0] tanh_lut[0:LUT_DEPTH-1];

reg [DATA_WIDTH-1:0] bfc_lut[0:BFC_DEPTH-1];
reg [DATA_WIDTH-1:0] wfc_lut[0:WFC_DEPTH-1];

reg [DATA_WIDTH-1:0] blstm_lut[0:BLSTM_DEPTH-1];
reg [DATA_WIDTH-1:0] ulstm_lut[0:ULSTM_DEPTH-1];
reg [DATA_WIDTH-1:0] wlstm_lut[0:WLSTM_DEPTH-1];

initial begin
  $readmemb("memory/luts_bin/sigmoid_lut.mem", sigmoid_lut);
  $readmemb("memory/luts_bin/tanh_lut.mem", tanh_lut);

  $readmemb("memory/weights_bin/b_fc.mem", bfc_lut);
  $readmemb("memory/weights_bin/w_fc.mem", wfc_lut);

  $readmemb("memory/weights_bin/b_lstm.mem", blstm_lut);
  $readmemb("memory/weights_bin/u_lstm.mem", ulstm_lut);
  $readmemb("memory/weights_bin/w_lstm.mem", wlstm_lut);
end

endmodule
