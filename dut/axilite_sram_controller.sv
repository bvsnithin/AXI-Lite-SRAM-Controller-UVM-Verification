module axilite_sram_controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter SRAM_DEPTH = 1024
)(
    input  logic                    clk,
    input  logic                    rst_n,

    // Write Address Channel (AW)
    input  logic [ADDR_WIDTH-1:0]   s_axi_awaddr,
    input  logic                    s_axi_awvalid,
    output logic                    s_axi_awready,

    // Write Data Channel (W)
    input  logic [DATA_WIDTH-1:0]   s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  logic                    s_axi_wvalid,
    output logic                    s_axi_wready,

    // Write Response Channel (B)
    input  logic                    s_axi_bready,
    output logic                    s_axi_bvalid,
    output logic [1:0]              s_axi_bresp,

    // Read Address Channel (AR)
    input  logic [ADDR_WIDTH-1:0]   s_axi_araddr,
    input  logic                    s_axi_arvalid,
    output logic                    s_axi_arready,

    // Read Data Channel (R)
    input  logic                    s_axi_rready,
    output logic [DATA_WIDTH-1:0]   s_axi_rdata,
    output logic [1:0]              s_axi_rresp,
    output logic                    s_axi_rvalid
);

    // AXI Response codes
    localparam RESP_OKAY   = 2'b00;
    localparam RESP_SLVERR = 2'b10;

    // Internal SRAM
    logic [DATA_WIDTH-1:0] sram_mem [0:SRAM_DEPTH-1];

    // Write State Machine
    typedef enum logic [1:0] {
        WR_IDLE,
        WR_DATA,
        WR_RESP
    } wr_state_t;

    wr_state_t wr_state, wr_next_state;

    // Read State Machine
    typedef enum logic [1:0] {
        RD_IDLE,
        RD_DATA
    } rd_state_t;

    rd_state_t rd_state, rd_next_state;

    // Internal registers
    logic [ADDR_WIDTH-1:0] wr_addr_reg;
    logic [DATA_WIDTH-1:0] wr_data_reg;
    logic [DATA_WIDTH/8-1:0] wr_strb_reg;
    logic [ADDR_WIDTH-1:0] rd_addr_reg;

    // Address decode (word-aligned)
    wire [$clog2(SRAM_DEPTH)-1:0] wr_sram_addr = wr_addr_reg[$clog2(SRAM_DEPTH)+1:2];
    wire [$clog2(SRAM_DEPTH)-1:0] rd_sram_addr = rd_addr_reg[$clog2(SRAM_DEPTH)+1:2];

    // Address valid check
    wire wr_addr_valid = (wr_addr_reg[ADDR_WIDTH-1:$clog2(SRAM_DEPTH)+2] == '0);
    wire rd_addr_valid = (rd_addr_reg[ADDR_WIDTH-1:$clog2(SRAM_DEPTH)+2] == '0);

    // =========================================================================
    // Write State Machine
    // =========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_state <= WR_IDLE;
        else
            wr_state <= wr_next_state;
    end

    always_comb begin
        wr_next_state = wr_state;
        case (wr_state)
            WR_IDLE: begin
                if (s_axi_awvalid && s_axi_wvalid)
                    wr_next_state = WR_RESP;
                else if (s_axi_awvalid)
                    wr_next_state = WR_DATA;
            end
            WR_DATA: begin
                if (s_axi_wvalid)
                    wr_next_state = WR_RESP;
            end
            WR_RESP: begin
                if (s_axi_bready)
                    wr_next_state = WR_IDLE;
            end
            default: wr_next_state = WR_IDLE;
        endcase
    end

    // Write address capture
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_addr_reg <= '0;
        else if (s_axi_awvalid && s_axi_awready)
            wr_addr_reg <= s_axi_awaddr;
    end

    // Write data capture and SRAM write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_data_reg <= '0;
            wr_strb_reg <= '0;
        end else if (s_axi_wvalid && s_axi_wready) begin
            wr_data_reg <= s_axi_wdata;
            wr_strb_reg <= s_axi_wstrb;
            // Perform byte-wise SRAM write
            if (wr_addr_valid || (wr_state == WR_IDLE && s_axi_awvalid)) begin
                for (int i = 0; i < DATA_WIDTH/8; i++) begin
                    if (s_axi_wstrb[i])
                        sram_mem[(wr_state == WR_IDLE) ? s_axi_awaddr[$clog2(SRAM_DEPTH)+1:2] : wr_sram_addr][i*8 +: 8] <= s_axi_wdata[i*8 +: 8];
                end
            end
        end
    end

    // Write channel outputs
    assign s_axi_awready = (wr_state == WR_IDLE);
    assign s_axi_wready  = (wr_state == WR_IDLE) || (wr_state == WR_DATA);
    assign s_axi_bvalid  = (wr_state == WR_RESP);
    assign s_axi_bresp   = wr_addr_valid ? RESP_OKAY : RESP_SLVERR;

    // =========================================================================
    // Read State Machine
    // =========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_state <= RD_IDLE;
        else
            rd_state <= rd_next_state;
    end

    always_comb begin
        rd_next_state = rd_state;
        case (rd_state)
            RD_IDLE: begin
                if (s_axi_arvalid)
                    rd_next_state = RD_DATA;
            end
            RD_DATA: begin
                if (s_axi_rready)
                    rd_next_state = RD_IDLE;
            end
            default: rd_next_state = RD_IDLE;
        endcase
    end

    // Read address capture
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_addr_reg <= '0;
        else if (s_axi_arvalid && s_axi_arready)
            rd_addr_reg <= s_axi_araddr;
    end

    // Read channel outputs
    assign s_axi_arready = (rd_state == RD_IDLE);
    assign s_axi_rvalid  = (rd_state == RD_DATA);
    assign s_axi_rdata   = rd_addr_valid ? sram_mem[rd_sram_addr] : '0;
    assign s_axi_rresp   = rd_addr_valid ? RESP_OKAY : RESP_SLVERR;

endmodule: axilite_sram_controller
