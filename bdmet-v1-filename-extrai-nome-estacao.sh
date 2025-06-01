#!/bin/bash -x

# Função para troca de nome de arquivo, retirando caracteres/sinais
#  Primeiro faz cópia de segurança em ./v0-original
#  Segundo, altera nome de arquivo e move para ./v1/

# Comando:
# ./bdmet-v1-filename-extrai-nome-estacao.sh   DIRETORIO
# Parâmetro: diretório onde estão os arquivos


# Script para extrair o nome da estação e usar para nomear
#  os arquivos usando o seguinte exemplo:

# De: 'INMET_CO_DF_A045_AGUAS EMENDADAS_01-01-2020_A_31-12-2020.CSV'
# Para: dados-AGUAS_EMENDADAS-A045-v1.csv

# De: 'INMET_CO_DF_A046_GAMA (PONTE ALTA)_01-01-2020_A_31-12-2020.CSV'
# Para: dados-GAMA_PONTE_ALTA-A046-v1.csv

# Checa se o diretório foi passado como parâmetro
if [ -z $1 ]; then
    echo "Erro. Faltou parâmetro de diretório."
    echo "./$0 DIRETORIO"
    exit
fi


# Diretório de origem
DIRETORIO_DADOS_ORIGEM="$1"

# Diretório atual do script
DIRETORIO_ATUAL=`pwd`

# Cria diretório de destino
mkdir -p v1

# Cria diretório para cópia dos dados originais
mkdir -p "v0-original"

cd $DIRETORIO_DADOS_ORIGEM
# Filtrar e mudar os nomes de arquivo das estações.
#  Os nomes das Estações e WMO comporao os nomes dos arquivos.
find . -maxdepth 1 -type f -name '* *.CSV' -print0 | while IFS= read -r -d $'\0' fname
do
    # Esta opção usa os dados extraídos do arquivo
    ESTACAO=$(cat "$fname" | grep -s 'ESTACAO' | cut -d';' -f 2 | tr -s ' ' | tr ' ' '_' | tr -d '[ .)]' | tr -d '[/(.\-]')
    COD_WMO=$(cat "$fname" | grep -s 'WMO' | cut -d';' -f 2)

    # Esta opção usa os dados do nome de arquivo
    # ESTACAO=$(echo $fname | cut -d_ -f 5 | tr ' ' '_' )  # tr -s ' ' | tr -d ' '
    # COD_WMO=$(grep $fname | head -4 | cut -d; -f 2)

    # Transforma para minusculo
    ESTACAO=$(echo "$ESTACAO" | tr [:upper:] [:lower:])
    
    echo "Nome antigo: "$fname""
    echo "Nome NOVO: $DIRETORIO_ATUAL/v1/dados-$ESTACAO-${COD_WMO}-v1.csv"

    # Faz cópia de segurança do original
    cp "$fname" "$DIRETORIO_ATUAL/v0-original"

    # Move o arquivo original, renomeado, para destino
    mv "$fname" "$DIRETORIO_ATUAL/v1/dados-$ESTACAO-${COD_WMO}-v1.csv"
done
# Obs.: no último tr, o símbolo - deve ser "escondido": \-


# Volta ao diretório inicial
cd $DIRETORIO_ATUAL
