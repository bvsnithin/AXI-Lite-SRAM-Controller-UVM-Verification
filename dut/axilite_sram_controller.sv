module sram_lite_controller (
    input logic clk;
    input logic rst_n;
    
    // Write Address Channel - Address & Control (AW)
    input  logic [31:0] s_axi_awaddr;
    input  logic        s_axi_awvalid;
    output logic        s_axi_awready;

    // Write Data Channel - Write Data (W)
    input  logic [31:0] s_axi_wdata;
    input  logic [3:0]  s_axi_wstrb;
    input  logic        s_axi_wvalid;
    output logic        s_axi_wready;

    // Write Response Channel - Write Response (B)
    input  logic       s_axi_bready;
    output logic       s_axi_bvalid;
    output logic [1:0] s_axi_bresp;

    // Read Address Channel - Address & Control (AR)
    input  logic [31:0] s_axi_araddr;
    input  logic        s_axi_arvalid;
    output logic        s_axi_arready;

    // Read Data Channel - Read Data (R)
    input  logic        s_axi_rready;
    output logic [31:0] s_axi_rdata;
    output logic [1:0]  s_axi_rresp;
    output logic        s_axi_rvalid;

    // SRAM Interface
    input  logic [31:0] sram_data_out;
    input  logic        sram_write_done;
    input  logic        sram_read_done;
    output logic [31:0] sram_addr;
    output logic [31:0] sram_data_in;
    output logic        wr_en;
    output logic        rd_en;

);
    // ----- Write operation -----
    // Internal registers for write operation

    logic [31:0] internal_awaddr;     // To store address
    logic [31:0] internal_wdata;      // To store the data  
    logic [3:0]  internal_wstrb;      // To store the strobes

    logic aw_received_flag;           // Flag: to show we have received a valid address
    logic w_received_flag;            // Flag: to show we have received a valid data

    // Write operation state machine

    // State Definitions
    typedef enum logic[1:0] {
        WR_IDLE,
        WR_EXEC,
        WR_RESP
    } wr_state_t;

    wr_state_t wr_present_state, wr_next_state;

    always_ff @( posedge clk or negedge rst_n ) begin : resetCheck
        if(!rst_n) begin
            wr_present_state <= WR_IDLE;
        end else begin 
            wr_present_state <= wr_next_state;
        end
    end


    always_comb begin
        s_axi_awready = 0;
        s_axi_wready = 0;
        s_axi_bvalid = 0;
        sram_wr_en = 0;

        wr_next_state = wr_present_state;

        case(wr_present_state)
            WR_IDLE: begin
                // Controller is ready for new requests if the flags are 0
                s_axi_awready = ~aw_received_flag;
                s_axi_wready = ~w_received_flag;
                
                // If we have both the address and data ready we will move to execute state
                if(aw_received_flag && w_received_flag) begin
                    wr_next_state = WR_EXEC;
                    wr_en = 1;
                end
            end

            WR_EXEC:begin
                internal_awaddr = s_axi_awaddr;
                internal_wdata = s_axi_wdata;
                internal_wstrb = s_axi_wstrb;

                if(sram_write_done) begin
                    wr_next_state = WR_RESP
                end

            end

            WR_RESP: begin
                s_axi_bvalid = 1;

                if(s_axi_bready) begin
                    wr_next_state = WR_IDLE;
                end
            end
        endcase
    end



    

    


endmodule: sram_lite_controller