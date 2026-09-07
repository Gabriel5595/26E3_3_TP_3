module nucleo_aritmetico_topo #(
    parameter LIMITE_ESTABILIDADE_BOTAO = 16'd50000
)(
    input wire clk,
    input wire reset_bruto,
    input wire avancar_numero_bruto,
    input wire avancar_processo_bruto,
    output wire [4:0] leds,
    output wire [6:0] segmentos
);

localparam CAMPO_FORMATO = 3'd0;
localparam CAMPO_OPERACAO = 3'd1;
localparam CAMPO_OPERANDO_A = 3'd2;
localparam CAMPO_OPERANDO_B = 3'd3;
localparam CAMPO_RESULTADO = 3'd4;

wire reset_filtrado_n;
debounce #(.LIMITE_ESTABILIDADE(LIMITE_ESTABILIDADE_BOTAO)) u_debounce_reset (
    .clk(clk), .botao_bruto(reset_bruto), .botao_filtrado(reset_filtrado_n)
);
wire reset_filtrado = ~reset_filtrado_n;

wire avancar_numero_filtrado_n;
debounce #(.LIMITE_ESTABILIDADE(LIMITE_ESTABILIDADE_BOTAO)) u_debounce_numero (
    .clk(clk), .botao_bruto(avancar_numero_bruto), .botao_filtrado(avancar_numero_filtrado_n)
);
wire avancar_numero_filtrado = ~avancar_numero_filtrado_n;

wire avancar_processo_filtrado_n;
debounce #(.LIMITE_ESTABILIDADE(LIMITE_ESTABILIDADE_BOTAO)) u_debounce_processo (
    .clk(clk), .botao_bruto(avancar_processo_bruto), .botao_filtrado(avancar_processo_filtrado_n)
);
wire avancar_processo_filtrado = ~avancar_processo_filtrado_n;

reg avancar_numero_anterior;
reg avancar_processo_anterior;
always @(posedge clk) begin
    avancar_numero_anterior <= avancar_numero_filtrado;
    avancar_processo_anterior <= avancar_processo_filtrado;
end
wire avancar_numero_borda = avancar_numero_filtrado && !avancar_numero_anterior;
wire avancar_processo_borda = avancar_processo_filtrado && !avancar_processo_anterior;

reg [2:0] campo_atual;
reg [1:0] indice_formato;
reg [1:0] indice_operacao;
reg [1:0] indice_operando_a;
reg [1:0] indice_operando_b;
reg [2:0] indice_resultado_exibicao;

reg [1:0] limite_operacao;
always @(*) begin
    case (indice_formato)
        2'd0: limite_operacao = 2'd3;
        2'd1: limite_operacao = 2'd2;
        default: limite_operacao = 2'd1;
    endcase
end

always @(posedge clk) begin
    if (reset_filtrado) begin
        campo_atual <= CAMPO_FORMATO;
        indice_formato <= 2'd0;
        indice_operacao <= 2'd0;
        indice_operando_a <= 2'd0;
        indice_operando_b <= 2'd0;
        indice_resultado_exibicao <= 3'd0;
    end else begin
        if (avancar_numero_borda) begin
            case (campo_atual)
                CAMPO_FORMATO: begin
                    indice_formato <= (indice_formato == 2'd2) ? 2'd0 : (indice_formato + 1'b1);
                    indice_operacao <= 2'd0;
                    indice_operando_a <= 2'd0;
                    indice_operando_b <= 2'd0;
                end
                CAMPO_OPERACAO: indice_operacao <= (indice_operacao == limite_operacao) ? 2'd0 : (indice_operacao + 1'b1);
                CAMPO_OPERANDO_A: indice_operando_a <= (indice_operando_a == 2'd3) ? 2'd0 : (indice_operando_a + 1'b1);
                CAMPO_OPERANDO_B: indice_operando_b <= (indice_operando_b == 2'd3) ? 2'd0 : (indice_operando_b + 1'b1);
                CAMPO_RESULTADO: indice_resultado_exibicao <= (indice_resultado_exibicao == 3'd4) ? 3'd0 : (indice_resultado_exibicao + 1'b1);
                default: begin end
            endcase
        end

        if (avancar_processo_borda) begin
            if (campo_atual == CAMPO_RESULTADO) begin
                campo_atual <= CAMPO_FORMATO;
            end else begin
                campo_atual <= campo_atual + 1'b1;
            end
            if (campo_atual == CAMPO_OPERANDO_B)
                indice_resultado_exibicao <= 3'd0;
        end
    end
end

reg [7:0] operando_a_inteiro_sel;
reg [7:0] operando_b_inteiro_sel;
always @(*) begin
    case (indice_operando_a)
        2'd0: operando_a_inteiro_sel = 8'd10;
        2'd1: operando_a_inteiro_sel = 8'd15;
        2'd2: operando_a_inteiro_sel = 8'd100;
        default: operando_a_inteiro_sel = 8'd200;
    endcase
    case (indice_operando_b)
        2'd0: operando_b_inteiro_sel = 8'd10;
        2'd1: operando_b_inteiro_sel = 8'd15;
        2'd2: operando_b_inteiro_sel = 8'd100;
        default: operando_b_inteiro_sel = 8'd200;
    endcase
end

reg signed [7:0] operando_a_ponto_fixo_sel;
reg signed [7:0] operando_b_ponto_fixo_sel;
always @(*) begin
    case (indice_operando_a)
        2'd0: operando_a_ponto_fixo_sel = 8'sd32;
        2'd1: operando_a_ponto_fixo_sel = 8'sd48;
        2'd2: operando_a_ponto_fixo_sel = 8'sd64;
        default: operando_a_ponto_fixo_sel = 8'sd112;
    endcase
    case (indice_operando_b)
        2'd0: operando_b_ponto_fixo_sel = 8'sd32;
        2'd1: operando_b_ponto_fixo_sel = 8'sd48;
        2'd2: operando_b_ponto_fixo_sel = 8'sd64;
        default: operando_b_ponto_fixo_sel = 8'sd112;
    endcase
end

reg [3:0] expoente_a_flutuante_sel;
reg [10:0] mantissa_a_flutuante_sel;
reg [3:0] expoente_b_flutuante_sel;
reg [10:0] mantissa_b_flutuante_sel;
always @(*) begin
    case (indice_operando_a)
        2'd0: begin expoente_a_flutuante_sel = 4'd2; mantissa_a_flutuante_sel = 11'd100; end
        2'd1: begin expoente_a_flutuante_sel = 4'd1; mantissa_a_flutuante_sel = 11'd50; end
        2'd2: begin expoente_a_flutuante_sel = 4'd0; mantissa_a_flutuante_sel = 11'd2000; end
        default: begin expoente_a_flutuante_sel = 4'd2; mantissa_a_flutuante_sel = 11'd300; end
    endcase
    case (indice_operando_b)
        2'd0: begin expoente_b_flutuante_sel = 4'd2; mantissa_b_flutuante_sel = 11'd100; end
        2'd1: begin expoente_b_flutuante_sel = 4'd1; mantissa_b_flutuante_sel = 11'd50; end
        2'd2: begin expoente_b_flutuante_sel = 4'd0; mantissa_b_flutuante_sel = 11'd2000; end
        default: begin expoente_b_flutuante_sel = 4'd2; mantissa_b_flutuante_sel = 11'd300; end
    endcase
end

wire [15:0] resultado_inteiro;
wire signed [7:0] resultado_ponto_fixo;
wire sinal_resultado_flutuante;
wire [3:0] expoente_resultado_flutuante;
wire [10:0] mantissa_resultado_flutuante;
wire estouro;

nucleo_aritmetico u_nucleo (
    .formato_numerico(indice_formato),
    .com_sinal(1'b1),
    .operacao(indice_operacao),
    .operando_a_inteiro(operando_a_inteiro_sel),
    .operando_b_inteiro(operando_b_inteiro_sel),
    .operando_a_ponto_fixo(operando_a_ponto_fixo_sel),
    .operando_b_ponto_fixo(operando_b_ponto_fixo_sel),
    .sinal_a_flutuante(1'b0),
    .expoente_a_flutuante(expoente_a_flutuante_sel),
    .mantissa_a_flutuante(mantissa_a_flutuante_sel),
    .sinal_b_flutuante(1'b0),
    .expoente_b_flutuante(expoente_b_flutuante_sel),
    .mantissa_b_flutuante(mantissa_b_flutuante_sel),
    .resultado_inteiro(resultado_inteiro),
    .resultado_ponto_fixo(resultado_ponto_fixo),
    .sinal_resultado_flutuante(sinal_resultado_flutuante),
    .expoente_resultado_flutuante(expoente_resultado_flutuante),
    .mantissa_resultado_flutuante(mantissa_resultado_flutuante),
    .estouro(estouro)
);

wire [15:0] palavra_flutuante_empacotada;
representacao_ponto_flutuante #(.LARGURA_EXPOENTE(4), .LARGURA_MANTISSA(11)) u_empacotador (
    .empacotar(1'b1),
    .sinal_entrada(sinal_resultado_flutuante),
    .expoente_entrada(expoente_resultado_flutuante),
    .mantissa_entrada(mantissa_resultado_flutuante),
    .palavra_entrada(16'd0),
    .palavra_saida(palavra_flutuante_empacotada),
    .sinal_saida(),
    .expoente_saida(),
    .mantissa_saida()
);

reg [15:0] palavra_resultado;
always @(*) begin
    case (indice_formato)
        2'd0: palavra_resultado = resultado_inteiro;
        2'd1: palavra_resultado = {{8{resultado_ponto_fixo[7]}}, resultado_ponto_fixo};
        default: palavra_resultado = palavra_flutuante_empacotada[15:0];
    endcase
end

reg [3:0] valor_exibido;
always @(*) begin
    case (campo_atual)
        CAMPO_FORMATO: valor_exibido = {2'b00, indice_formato};
        CAMPO_OPERACAO: valor_exibido = {2'b00, indice_operacao};
        CAMPO_OPERANDO_A: valor_exibido = {2'b00, indice_operando_a};
        CAMPO_OPERANDO_B: valor_exibido = {2'b00, indice_operando_b};
        default: begin
            case (indice_resultado_exibicao)
                3'd0: valor_exibido = estouro ? 4'hE : 4'h0;
                3'd1: valor_exibido = palavra_resultado[3:0];
                3'd2: valor_exibido = palavra_resultado[7:4];
                3'd3: valor_exibido = palavra_resultado[11:8];
                default: valor_exibido = palavra_resultado[15:12];
            endcase
        end
    endcase
end

wire [6:0] segmentos_ativos;
decodificador_7_segmentos u_decodificador (
    .valor(valor_exibido),
    .segmentos_ativos(segmentos_ativos)
);
wire [6:0] segmentos_ativos_corrigido = {segmentos_ativos[0], segmentos_ativos[1], segmentos_ativos[2], segmentos_ativos[3], segmentos_ativos[4], segmentos_ativos[5], segmentos_ativos[6]};
assign segmentos = ~segmentos_ativos_corrigido;

assign leds = (5'b00001 << campo_atual);

endmodule