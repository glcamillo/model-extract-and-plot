#!/bin/bash

# Função para troca de nome de arquivo, retirando caracteres/sinais
#  Primeiro faz cópia de segurança em ./v0-original
#  Segundo, altera nome de arquivo e move para ./v1/

# Comando:
# ./bdmet-v5-dados-altera-ponto-decimal.sh   DIRETORIO
# Parâmetro: diretório onde estão os arquivos de dados
#   de entrada. Pode ser qualquer diretório de origem

# Exemplo de duas linhas parciais de dados do arquivo original
#     INMET_S_SC_A898_CAMPOS NOVOS_01-01-2020_A_31-12-2020.CSV
# Data;Hora UTC;PRECIPITAÇÃO TOTAL, HORÁRIO (mm);PRESSAO ATMOSFERICA AO NIVEL DA ESTACAO, HORARIA (mB)
# 2020/01/01;0000 UTC;1,6;906
# 2020/01/01;0100 UTC;,2;906
# Resultado (em v5)
# 2020/01/01;0000 UTC;1.6;906
# 2020/01/01;0100 UTC;0.2;906


# Checa se o diretório foi passado como parâmetro
if [ -z $1 ]; then
    echo "Erro. Faltou parâmetro de diretório."
    echo "./$0 DIRETORIO"
    exit
fi

# Diretório de origem dos dados
DIRETORIO_DADOS_ORIGEM="$1"

# Diretório de destino
mkdir -p v5


for fname in $(ls $DIRETORIO_DADOS_ORIGEM/dados*.csv)
do
    /bin/ls $fname
    fname_new=$(echo $fname | sed "s/$DIRETORIO_DADOS_ORIGEM/v5/g")
    echo $fname_new
    /bin/cat $fname | sed 's/;,/;0,/g' | tr ',' '.' > ${fname_new}
done


