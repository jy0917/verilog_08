`timescale 1ns / 1ps

module sr04_controller (
    input                            clk,
    input                            reset,
    input                            start,
    input                            echo,
    output [$clog2(40_000/58) - 1:0] distance,
    output                           trigger,
    output                           done
);

    parameter IDLE = 0, START = 1, ECHO_WAIT = 2, ECHO_COUNT = 3;

    reg [$clog2(40_000) - 1:0] count_reg, count_next;
    reg [1:0] state_c, state_n;
    reg done_reg, done_next;
    reg [$clog2(40_000) - 1:0] echo_pulse_width_reg, echo_pulse_width_next;
    reg run_stop_reg, run_stop_next;
    reg clear_reg, clear_next;
    reg trigger_reg, trigger_next;
    wire w_tick_us, w_clear, w_run_stop;

    assign trigger = (state_c == START);
    assign done = done_reg;
    assign distance = echo_pulse_width_reg / 58;
    assign w_run_stop = run_stop_reg;
    assign w_clear = clear_reg;

    tick_gen_us U_TICK_GEN_US (
        .clk(clk),
        .reset(reset),
        .run_stop(w_run_stop),
        .clear(w_clear),
        .tick_us(w_tick_us)
    );


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state_c <= IDLE;
            count_reg <= 0;
            done_reg <= 0;
            echo_pulse_width_reg <= 0;
            run_stop_reg <= 0;
            clear_reg <= 1;
            trigger_reg <= 0;
        end else begin
            state_c <= state_n;
            count_reg <= count_next;
            done_reg <= done_next;
            echo_pulse_width_reg <= echo_pulse_width_next;
            run_stop_reg <= run_stop_next;
            clear_reg <= clear_next;
            trigger_reg <= trigger_next;
        end
    end

    //  일단 runstop, clear는 무시
    always @* begin
        state_n = state_c;
        count_next = count_reg;
        done_next = 0;
        echo_pulse_width_next = echo_pulse_width_reg;
        run_stop_next = run_stop_reg;
        clear_next = clear_reg;
        trigger_next = 0;
        case (state_c)
            IDLE: begin
                count_next = 0;
                clear_next = 1;
                run_stop_next = 0;
                if (start) state_n = START;
            end
            START: begin
                clear_next = 0;
                run_stop_next = 1;
                trigger_next = 1;
                if (w_tick_us) begin
                    if (count_reg == 9) begin
                        count_next = 0;
                        state_n = ECHO_WAIT;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end
            ECHO_WAIT: begin
                if (w_tick_us && echo) begin
                    count_next = count_reg + 1;
                    state_n = ECHO_COUNT;
                end
            end
            ECHO_COUNT: begin
                if (w_tick_us) begin
                    if (echo) begin
                        if (count_reg == 36_000 - 1) begin // ← echo가 36ms까지도 안 떨어지면 0으로 침
                            echo_pulse_width_next = 0;
                            done_next = 1;
                            state_n = IDLE;
                        end
                        count_next = count_reg + 1;
                    end else begin
                        echo_pulse_width_next = count_reg; // ← echo가 정상적으로 떨어지면 실제 카운트값 사용
                        done_next = 1;
                        state_n = IDLE;
                    end
                end
            end
        endcase
    end

endmodule



module tick_gen_us (
    input  clk,
    input  reset,
    input  run_stop,
    input  clear,
    output tick_us
);
    reg tick_us_reg;
    reg [$clog2(100) - 1:0] count_reg;

    assign tick_us = tick_us_reg;

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            tick_us_reg <= 0;
            count_reg   <= 0;
        end else begin
            if (run_stop) begin
                if (count_reg == 99) begin
                    count_reg   <= 0;
                    tick_us_reg <= 1;
                end else begin
                    count_reg   <= count_reg + 1;
                    tick_us_reg <= 0;
                end

            end
        end
    end
endmodule