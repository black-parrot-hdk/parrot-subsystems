
// This module converts an AXI load/store into a store in the following format
//   {write_not_read, addr[22:0], data[7:0]}
//  Loads will then ready for data to come back as a blocking operation
// To avoid dealing with ordering transactions, only 1 req is outstanding
// We could very easily increase throughput here, but wait until it's a bottleneck

`include "bsg_defines.v"
`include "bp_me_defines.svh"

module bsg_axil_store_packer
 import bp_me_pkg::*;
 #(parameter `BSG_INV_PARAM(axil_addr_width_p)
   , parameter `BSG_INV_PARAM(axil_data_width_p)
   , parameter `BSG_INV_PARAM(payload_data_width_p)
   )
   (input clk_i
    , input reset_i

    //====================== AXI-4 LITE =========================
    // WRITE ADDRESS CHANNEL SIGNALS
    , input [axil_addr_width_p-1:0]              s_axil_awaddr_i
    , input axi_prot_type_e                      s_axil_awprot_i
    , input                                      s_axil_awvalid_i
    , output logic                               s_axil_awready_o

    // WRITE DATA CHANNEL SIGNALS
    , input [axil_data_width_p-1:0]              s_axil_wdata_i
    , input [(axil_data_width_p>>3)-1:0]         s_axil_wstrb_i
    , input                                      s_axil_wvalid_i
    , output logic                               s_axil_wready_o

    // WRITE RESPONSE CHANNEL SIGNALS
    , output axi_resp_type_e                     s_axil_bresp_o
    , output logic                               s_axil_bvalid_o
    , input                                      s_axil_bready_i

    // READ ADDRESS CHANNEL SIGNALS
    , input [axil_addr_width_p-1:0]              s_axil_araddr_i
    , input axi_prot_type_e                      s_axil_arprot_i
    , input                                      s_axil_arvalid_i
    , output logic                               s_axil_arready_o

    // READ DATA CHANNEL SIGNALS
    , output logic [axil_data_width_p-1:0]       s_axil_rdata_o
    , output axi_resp_type_e                     s_axil_rresp_o
    , output logic                               s_axil_rvalid_o
    , input                                      s_axil_rready_i

    , output logic [axil_data_width_p-1:0]       data_o
    , output logic                               v_o
    , input                                      ready_i

    , input [axil_data_width_p-1:0]              data_i
    , input                                      v_i
    , output logic                               ready_o
    );

  enum {e_ready, e_read_req, e_read_resp, e_write_resp} state_n, state_r;
  wire is_ready      = (state_r == e_ready);
  wire is_read_req   = (state_r == e_read_req);
  wire is_read_resp  = (state_r == e_read_resp);
  wire is_write_resp = (state_r == e_write_resp);

  // Ready for a request if we can send it out to the fifo
  assign s_axil_awready_o = is_ready & ready_i;
  assign s_axil_wready_o  = is_ready & ready_i;
  assign s_axil_arready_o = is_read_req & ready_i;

  // Don't support errors
  assign s_axil_bresp_o = e_axi_resp_okay;
  assign s_axil_rresp_o = e_axi_resp_okay;

  assign s_axil_rdata_o = data_i;
  assign ready_o = s_axil_rready_i;

  localparam payload_addr_width_lp = axil_data_width_p - payload_data_width_p - 1;
  wire [axil_data_width_p-1:0] read_cmd_lo =
    {1'b0, s_axil_araddr_i[0+:payload_addr_width_lp], {payload_data_width_p{1'b0}}};
  wire [axil_data_width_p-1:0] write_cmd_lo =
    {1'b1, s_axil_awaddr_i[0+:payload_addr_width_lp], s_axil_wdata_i[0+:payload_data_width_p]};

  always_comb
    begin
      s_axil_bvalid_o  = '0;
      s_axil_rvalid_o  = '0;

      data_o = '0;
      v_o    = '0;
      state_n = state_r;

      case (state_r)
        e_ready:
          begin
            v_o = (s_axil_awready_o & s_axil_awvalid_i & s_axil_wready_o & s_axil_wvalid_i);
            data_o = write_cmd_lo;

            state_n = v_o ? e_write_resp : s_axil_arvalid_i ? e_read_req : e_ready;
          end

        e_read_req:
          begin
            v_o = s_axil_arready_o & s_axil_arvalid_i;
            data_o = read_cmd_lo;

            state_n = v_o ? e_read_resp : e_read_req;
          end

        e_read_resp:
          begin
            s_axil_rvalid_o = v_i;

            state_n = (s_axil_rready_i & s_axil_rvalid_o) ? e_ready : e_read_resp;
          end

        e_write_resp:
          begin
            s_axil_bvalid_o = 1'b1;

            state_n = (s_axil_bready_i & s_axil_bvalid_o) ? e_ready : e_write_resp;
          end
      endcase
    end

  // synopsys sync_set_reset reset_i
  always_ff @(posedge clk_i)
    if (reset_i)
      state_r <= e_ready;
    else
      state_r <= state_n;

endmodule

`BSG_ABSTRACT_MODULE(bsg_axil_store_packer)

