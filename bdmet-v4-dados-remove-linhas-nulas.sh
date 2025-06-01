#!/bin/bash

# Remove linhas sem valores para qualquer campo. 
#   OBS: caso o arquivo contenha muitas colunas de
#   dados e algumas contenham dados importantes, sugere-se
#   executar esse comando somente em arquivos com colunas
#   isoladas de dados

#  Dados alterados são copiados para ./v4/


# Comando:
# ./bdmet-v4-dados-remove-linhas-nulas.sh   DIRETORIO
# Parâmetro: diretório onde estão os arquivos
#   de dados de entrada
# OBS.: sugere-se usar dados oriundos de extração de COLUNAS (v3)



# Checa se o diretório foi passado como parâmetro
if [ -z $1 ]; then
    echo "Erro. Faltou parâmetro de diretório."
    echo "./$0 DIRETORIO"
    exit
fi


# Diretório de origem
DIRETORIO_DADOS_ORIGEM="$1"

# Diretório de destino
mkdir -p v4


for fname in $(ls $DIRETORIO_DADOS_ORIGEM/dados*.csv)
do
    /bin/ls $fname
    fname_new=$(echo $fname | sed "s/$DIRETORIO_DADOS_ORIGEM/v4/g")
    echo $fname_new
    /bin/cat $fname | grep -s -v ";;" > ${fname_new}
done

