

module testbench;

  bit clk;
  initial begin forever #10 clk = ~clk; end

  bit rst_n;
  initial begin rst_n = 1; #10 rst_n = 0; end

  localparam name_lp = "dmi0";
  localparam listen_port_lp = 44853;
 
  bit dmi_req_valid;
  bit dmi_req_ready;
  bit [6:0] dmi_req_addr;
  bit [1:0] dmi_req_op;
  bit [31:0] dmi_req_data;
  bit dmi_rsp_valid;
  bit dmi_rsp_ready;
  bit [31:0] dmi_rsp_data;
  bit [1:0] dmi_rsp_resp;
  bit dmi_rst_n;

  dmidpi
   #(.Name(name_lp), .ListenPort(listen_port_lp))
   dmi
    (.clk_i(clk)
     ,.rst_ni(rst_n)

     ,.dmi_req_valid(dmi_req_valid)
     ,.dmi_req_ready(dmi_req_ready)
     ,.dmi_req_addr(dmi_req_addr)
     ,.dmi_req_op(dmi_req_op)
     ,.dmi_req_data(dmi_req_data)
     ,.dmi_rsp_valid(dmi_rsp_valid)
     ,.dmi_rsp_ready(dmi_rsp_ready)
     ,.dmi_rsp_data(dmi_rsp_data)
     ,.dmi_rsp_resp(dmi_rsp_resp)
     ,.dmi_rst_n(dmi_rst_n)
     );

  assign dmi_req_ready = 1'b1;
  assign dmi_rsp_valid = 1'b0;
  assign dmi_rsp_data = 32'b0;
  assign dmi_rsp_resp = 2'b0;

endmodule

