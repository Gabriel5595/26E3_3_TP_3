`timescale 1ns/1ps

module nucleo_aritmetico_topo_tb;

localparam LIMITE = 16'd5;

reg clk;
reg reset_bruto;
reg avancar_numero_bruto;
reg avancar_processo_bruto;
wire [4:0] leds;
wire [6:0] segmentos;

nucleo_aritmetico_topo #(.LIMITE_ESTABILIDADE_BOTAO(LIMITE)) u_topo (
    .clk(clk),
    .reset_bruto(reset_bruto),
    .avancar_numero_bruto(avancar_numero_bruto),
    .avancar_processo_bruto(avancar_processo_bruto),
    .leds(leds),
    .segmentos(segmentos)
);

always #5 clk = ~clk;

task pressionar;
    input botao_numero;
    begin
        if (botao_numero) avancar_numero_bruto = 1'b0; else avancar_processo_bruto = 1'b0;
        repeat (4 * LIMITE) @(posedge clk);
        if (botao_numero) avancar_numero_bruto = 1'b1; else avancar_processo_bruto = 1'b1;
        repeat (4 * LIMITE) @(posedge clk);
    end
endtask

task mostrar;
    input [799:0] nome;
    begin
        $display("%0s | leds=%05b segmentos=%07b", nome, leds, segmentos);
    end
endtask

initial begin
    $display("=== Iniciando teste do nucleo_aritmetico_topo (v2, 3 botoes / 5 leds) ===");
    clk = 1'b0;
    reset_bruto = 1'b1;
    avancar_numero_bruto = 1'b1;
    avancar_processo_bruto = 1'b1;

    reset_bruto = 1'b0;
    repeat (4 * LIMITE) @(posedge clk);
    reset_bruto = 1'b1;
    repeat (4 * LIMITE) @(posedge clk);
    mostrar("apos reset -> campo FORMATO, indice 0 (inteiro)");

    pressionar(1'b1);
    pressionar(1'b1);
    mostrar("2x avancar numero -> formato indice 2 (ponto flutuante)");

    pressionar(1'b0);
    mostrar("avancar processo -> campo OPERACAO, indice 0 (soma)");

    pressionar(1'b0);
    mostrar("avancar processo -> campo OPERANDO_A, indice 0 (mantissa 100, exp 2 = 400)");

    pressionar(1'b0);
    mostrar("avancar processo -> campo OPERANDO_B, indice 0 (mantissa 100, exp 2 = 400)");

    pressionar(1'b1);
    mostrar("avancar numero -> operando B indice 1 (mantissa 50, exp 1 = 100)");

    pressionar(1'b0);
    mostrar("avancar processo -> campo RESULTADO, sub-estado 0 (flag estouro)");

    pressionar(1'b1);
    mostrar("avancar numero -> resultado sub-estado 1 (nibble 0, LSB)");

    pressionar(1'b1);
    mostrar("avancar numero -> resultado sub-estado 2 (nibble 1)");

    pressionar(1'b0);
    mostrar("avancar processo -> volta ao campo FORMATO");

    $display("=== Teste concluido ===");
    $finish;
end

endmodule