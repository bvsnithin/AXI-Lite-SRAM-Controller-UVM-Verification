interface axilite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst_n
);

    // Write Address Channel (AW)
    logic [ADDR_WIDTH-1:0]   awaddr;
    logic                    awvalid;
    logic                    awready;

    // Write Data Channel (W)
    logic [DATA_WIDTH-1:0]   wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                    wvalid;
    logic                    wready;

    // Write Response Channel (B)
    logic                    bready;
    logic                    bvalid;
    logic [1:0]              bresp;

    // Read Address Channel (AR)
    logic [ADDR_WIDTH-1:0]   araddr;
    logic                    arvalid;
    logic                    arready;

    // Read Data Channel (R)
    logic                    rready;
    logic [DATA_WIDTH-1:0]   rdata;
    logic [1:0]              rresp;
    logic                    rvalid;

    // Clocking block for driver (master)
    clocking drv_cb @(posedge clk);
        default input #1 output #1;
        output awaddr, awvalid;
        input  awready;
        output wdata, wstrb, wvalid;
        input  wready;
        output bready;
        input  bvalid, bresp;
        output araddr, arvalid;
        input  arready;
        output rready;
        input  rdata, rresp, rvalid;
    endclocking

    // Clocking block for monitor
    clocking mon_cb @(posedge clk);
        default input #1;
        input awaddr, awvalid, awready;
        input wdata, wstrb, wvalid, wready;
        input bready, bvalid, bresp;
        input araddr, arvalid, arready;
        input rready, rdata, rresp, rvalid;
    endclocking

    // Modports
    modport DRIVER  (clocking drv_cb, input clk, rst_n);
    modport MONITOR (clocking mon_cb, input clk, rst_n);

endinterface: axilite_if
