#!/bin/bash
#
# Função para remover espaços de nomes de arquivos

# Comando:
# ./bdmet-remove-espacos-em-nomes-de-arquivos.sh  DIRETORIO
# Parâmetro: diretório onde estão os arquivos


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


cd $DIRETORIO_DADOS_ORIGEM

find . -depth -name '* *' | while read fname 
do
    fname_new=$(echo $fname | tr -s ' ' | tr ' ' '_')
    if [ -e $fname_new ]; then
        echo "Arquivo $fname_new já existe. Não será substituído pelo $fname"
    else
        echo "Arquivo $fname será renomeado para $fname_new"
        mv "$fname" "$fname_new"
    fi
done

cd $DIRETORIO_ATUAL


