// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_tgl_excl.cfg generated by `topgen.py` tool

// [UNSUPPORTED] Exclude unused TL port signals at all hierarchies, wherever port toggle coverage is
// enabled. Exercising these reserved signals will result in assertion errors thrown by the design.
-node tb.dut*.u_* *tl_*.a_param
-node tb.dut*.u_* *tl_*.a_user.rsvd
-node tb.dut*.u_* *tl_*.d_param
-node tb.dut*.u_* *tl_*.d_opcode[2:1]
-node tb.dut*.u_* *tl_*.a_source[7:6]
-node tb.dut*.u_* *tl_*.d_source[7:6]
-node tb.dut.top_${top["name"]} *tl_*.a_param
-node tb.dut.top_${top["name"]} *tl_*.a_user.rsvd
-node tb.dut.top_${top["name"]} *tl_*.d_param
-node tb.dut.top_${top["name"]} *tl_*.d_opcode[2:1]
-node tb.dut.top_${top["name"]} *tl_*.a_source[7:6]
-node tb.dut.top_${top["name"]} *tl_*.d_source[7:6]

// [LOW_RISK] Exclude the full TL a_address signal on all pass-through hierarchies. We instead look
// at the full coverage of this signal directly at the host or at the device.
-node tb.dut.top_${top["name"]} *tl_*.a_address
-node tb.dut.top_${top["name"]}.u_xbar_* tl_*.a_address

<%
  import tlgen.lib as lib
%>\
// [UNR] Exclude unused address bits based on IP address range. It is not possible to cover this.
% for xbar in top["xbar"]:
  % for device in xbar["nodes"]:
    % if device["type"] == "device" and not device["xbar"]:
<%
    addr_ranges = []
    for addr in device["addr_range"]:
      start_addr = int(addr["base_addr"], 0)
      end_addr = start_addr + int(addr["size_byte"], 0) - 1
      addr_ranges.append((start_addr, end_addr))
    excl_bits = lib.get_toggle_excl_bits(addr_ranges)
    dev_name = device["name"]
    if_name = ""
    try:
        dev_name, if_name = device["name"].split(".")
        if_name += "_"
    except ValueError:
        pass
%>\
      % for bit_range in excl_bits:
-node tb.dut*.u_${dev_name} ${if_name}tl_*i.a_address[${bit_range[1]}:${bit_range[0]}]
      % endfor
    % endif
  % endfor
% endfor
