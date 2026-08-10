`timescale 1ns / 1ps

module tb_stopwatch_watch_uart ();

    //1비트 구간
    parameter BAUD_TICK = (100_000_000 / 9600) * 10;
    parameter TICK_DELAY = 1_000_000 * 10;  // 10ms = tick 1주기


    reg clk, reset;
    reg btn_L, btn_R, btn_UP, btn_DOWN;
    reg [2:0] sw;
    reg rx;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire led;
    wire tx;

    integer i;

    top_stopwatch dut (
        .clk(clk),
        .reset(reset),
        .btn_L(btn_L),  // runstop(s) / 자리변경(w) 
        .btn_R(btn_R),  // clear(s) / 자리변경(w)
        .btn_UP(btn_UP),  // mode(s) / up(w)
        .btn_DOWN(btn_DOWN),  // option(s) / down(w)
        .rx(rx),
        .sw(sw),        // sw[0]: 0-초:밀리초/1-시:분 sw[1]: 0-stopwatch/1-watch, sw[2] : watch의 12시간제
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led),  // indicator
        .tx(tx)
    );

    //freq 100mhz
    always #5 clk = ~clk;

    //PC->FPGA 
    task SENDER_FOR_UART_RX(input [7:0] send_data);
        begin
            //start
            rx = 0;
            #(BAUD_TICK);
            //data
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(BAUD_TICK);
            end
            //stop
            rx = 1;
            #(BAUD_TICK);
        end
    endtask
    task PRESS_BTN_TASK(input integer which);  // 0:L 1:R 2:UP 3:DOWN
        begin
            case (which)
                0: btn_L = 1;
                1: btn_R = 1;
                2: btn_UP = 1;
                3: btn_DOWN = 1;
            endcase
            #10_000;
            btn_L = 0;
            btn_R = 0;
            btn_UP = 0;
            btn_DOWN = 0;
            #10_000;
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        btn_L = 0;
        btn_R = 0;
        btn_UP = 0;
        btn_DOWN = 0;
        sw = 3'b000;
        rx = 1;
        #100;
        reset = 0;
        #100;

        sw[1] = 0;  // 스톱워치 선택
        #100;


        SENDER_FOR_UART_RX("r");  // Run
        #(TICK_DELAY * 3);  // 약 30ms 대기 → msec가 3번 정도 올라가는 게 보임         
        SENDER_FOR_UART_RX("s");  // Stop
        #500;
        SENDER_FOR_UART_RX("m");  // Mode
        #500;
        SENDER_FOR_UART_RX("c");  // Clear
        #500;
        SENDER_FOR_UART_RX(
            "r");  // 여기 추가 -> 이제 감소 방향으로 run
        #(TICK_DELAY * 3);         // 여기 추가 -> msec가 여러 번 감소하는 시간 확보
        SENDER_FOR_UART_RX("s");  // 여기 추가 -> stop
        #500;

        //watch
        sw[1] = 1;  // 시계 선택
        #100;

        SENDER_FOR_UART_RX("U");
        #500;
        SENDER_FOR_UART_RX("U");  // 추가로 2번 더
        #500;
        SENDER_FOR_UART_RX("U");
        #500;
        SENDER_FOR_UART_RX("D");  // 이제 감소도 보여주기
        #500;

        sw[1] = 0;  // 스톱워치 모드로 복귀
        #100;

        PRESS_BTN_TASK(0);  // btn_L -> run
        #(TICK_DELAY * 3);  // msec 여러 번 오르는 거 확인
        PRESS_BTN_TASK(0);  // btn_L -> stop
        #500;

        PRESS_BTN_TASK(3);  // btn_DOWN 첫 번째 -> save
        #500;

        PRESS_BTN_TASK(3);  // btn_DOWN 두 번째 -> load
        #500;

        PRESS_BTN_TASK(1);  // btn_R -> clear
        #500;

        PRESS_BTN_TASK(2);  // btn_UP -> mode 토글
        #500;

        sw[1] = 1;  // 시계 모드
        #100;

        PRESS_BTN_TASK(1);  // btn_R -> 상태전환
        #500;
        PRESS_BTN_TASK(2);  // btn_UP -> 값 증가
        #500;
        PRESS_BTN_TASK(3);  // btn_DOWN -> 값 감소
        #500;

        sw[1] = 0;
        #100;

        SENDER_FOR_UART_RX("r");  // UART로 run
        #500;
        // 여기서 w_ascii_out[7]=1, w_runstop=1 이어야 함

        PRESS_BTN_TASK(
            0);  // 그 상태에서 btn_L 눌러보기 (핵심 관찰 지점)
        #500;
        // w_runstop이 그대로 1인지, 0으로 바뀌는지 확인

        SENDER_FOR_UART_RX("c");  // 다른 명령으로 ascii bit7 해제
        #500;

        PRESS_BTN_TASK(0);  // 이제 btn_L이 정상 반응하는지 재확인
        #500;

        $stop;

    end


endmodule
