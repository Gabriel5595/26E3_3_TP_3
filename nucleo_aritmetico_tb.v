`timescale 1ns/1ps

module nucleo_aritmetico_tb;

localparam LARGURA_INTEIRO = 8;
localparam BITS_INTEIROS_PF = 3;
localparam BITS_FRACIONARIOS_PF = 5;
localparam LARGURA_EXPOENTE_FLUT = 4;
localparam LARGURA_MANTISSA_FLUT = 11;

reg [1:0] formato_numerico;
reg com_sinal;
reg [1:0] operacao;
reg [LARGURA_INTEIRO-1:0] operando_a_inteiro;
reg [LARGURA_INTEIRO-1:0] operando_b_inteiro;
reg signed [BITS_INTEIROS_PF+BITS_FRACIONARIOS_PF-1:0] operando_a_ponto_fixo;
reg signed [BITS_INTEIROS_PF+BITS_FRACIONARIOS_PF-1:0] operando_b_ponto_fixo;
reg sinal_a_flutuante;
reg [LARGURA_EXPOENTE_FLUT-1:0] expoente_a_flutuante;
reg [LARGURA_MANTISSA_FLUT-1:0] mantissa_a_flutuante;
reg sinal_b_flutuante;
reg [LARGURA_EXPOENTE_FLUT-1:0] expoente_b_flutuante;
reg [LARGURA_MANTISSA_FLUT-1:0] mantissa_b_flutuante;

wire [2*LARGURA_INTEIRO-1:0] resultado_inteiro;
wire signed [BITS_INTEIROS_PF+BITS_FRACIONARIOS_PF-1:0] resultado_ponto_fixo;
wire sinal_resultado_flutuante;
wire [LARGURA_EXPOENTE_FLUT-1:0] expoente_resultado_flutuante;
wire [LARGURA_MANTISSA_FLUT-1:0] mantissa_resultado_flutuante;
wire estouro;

nucleo_aritmetico #(
    .LARGURA_INTEIRO(LARGURA_INTEIRO),
    .BITS_INTEIROS_PF(BITS_INTEIROS_PF),
    .BITS_FRACIONARIOS_PF(BITS_FRACIONARIOS_PF),
    .LARGURA_EXPOENTE_FLUT(LARGURA_EXPOENTE_FLUT),
    .LARGURA_MANTISSA_FLUT(LARGURA_MANTISSA_FLUT)
) u_nucleo (
    .formato_numerico(formato_numerico),
    .com_sinal(com_sinal),
    .operacao(operacao),
    .operando_a_inteiro(operando_a_inteiro),
    .operando_b_inteiro(operando_b_inteiro),
    .operando_a_ponto_fixo(operando_a_ponto_fixo),
    .operando_b_ponto_fixo(operando_b_ponto_fixo),
    .sinal_a_flutuante(sinal_a_flutuante),
    .expoente_a_flutuante(expoente_a_flutuante),
    .mantissa_a_flutuante(mantissa_a_flutuante),
    .sinal_b_flutuante(sinal_b_flutuante),
    .expoente_b_flutuante(expoente_b_flutuante),
    .mantissa_b_flutuante(mantissa_b_flutuante),
    .resultado_inteiro(resultado_inteiro),
    .resultado_ponto_fixo(resultado_ponto_fixo),
    .sinal_resultado_flutuante(sinal_resultado_flutuante),
    .expoente_resultado_flutuante(expoente_resultado_flutuante),
    .mantissa_resultado_flutuante(mantissa_resultado_flutuante),
    .estouro(estouro)
);

initial begin
    $display("=== Iniciando testes de integracao do nucleo_aritmetico ===");

    formato_numerico = 2'b00; com_sinal = 1'b1; operacao = 2'b00;
    operando_a_inteiro = 8'sd100; operando_b_inteiro = 8'sd100;
    #10;
    $display("FORMATO INTEIRO | soma com sinal com estouro (100+100) -> resultado=%0d estouro=%0d",
                $signed(resultado_inteiro), estouro);

    formato_numerico = 2'b00; com_sinal = 1'b0; operacao = 2'b11;
    operando_a_inteiro = 8'd77; operando_b_inteiro = 8'd7;
    #10;
    $display("FORMATO INTEIRO | divisao sem sinal tipica (77/7) -> resultado=%0d estouro=%0d",
                resultado_inteiro, estouro);

    formato_numerico = 2'b01; operacao = 2'b00;
    operando_a_ponto_fixo = 8'sd112; operando_b_ponto_fixo = 8'sd32;
    #10;
    $display("FORMATO PONTO FIXO | soma com saturacao (3.5 + 1.0) -> resultado=%0d/32 estouro=%0d",
                resultado_ponto_fixo, estouro);

    formato_numerico = 2'b01; operacao = 2'b10;
    operando_a_ponto_fixo = 8'sd48; operando_b_ponto_fixo = 8'sd64;
    #10;
    $display("FORMATO PONTO FIXO | multiplicacao tipica (1.5 * 2.0) -> resultado=%0d/32 estouro=%0d",
                resultado_ponto_fixo, estouro);

    formato_numerico = 2'b10; operacao = 2'b00;
    sinal_a_flutuante = 1'b0; mantissa_a_flutuante = 11'd2000; expoente_a_flutuante = 4'd0;
    sinal_b_flutuante = 1'b0; mantissa_b_flutuante = 11'd2000; expoente_b_flutuante = 4'd0;
    #10;
    $display("FORMATO PONTO FLUTUANTE | soma com normalizacao (2000 + 2000) -> sinal=%0d mantissa=%0d expoente=%0d",
                sinal_resultado_flutuante, mantissa_resultado_flutuante, expoente_resultado_flutuante);

    formato_numerico = 2'b10; operacao = 2'b01;
    sinal_a_flutuante = 1'b0; mantissa_a_flutuante = 11'd300; expoente_a_flutuante = 4'd2;
    sinal_b_flutuante = 1'b0; mantissa_b_flutuante = 11'd100; expoente_b_flutuante = 4'd1;
    #10;
    $display("FORMATO PONTO FLUTUANTE | subtracao tipica (1200 - 200) -> sinal=%0d mantissa=%0d expoente=%0d",
                sinal_resultado_flutuante, mantissa_resultado_flutuante, expoente_resultado_flutuante);

    $display("=== Testes concluidos ===");
    $finish;
end

endmodule