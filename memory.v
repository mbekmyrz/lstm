module memory #
(
  parameter integer DATA_WIDTH	= 32,
  parameter integer LUT_DEPTH	= 16
)
();

reg [DATA_WIDTH-1:0] sigmoid_lut[0:LUT_DEPTH-1];
reg [DATA_WIDTH-1:0] tanh_lut[0:LUT_DEPTH-1];

initial begin
  $readmemb("memory/luts_bin/sigmoid_lut.mem", sigmoid_lut);
  $readmemb("memory/luts_bin/tanh_lut.mem", tanh_lut);
end

endmodule
