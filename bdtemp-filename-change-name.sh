#!/bin/bash

if [ -z $1 ]; then
	echo "Erro. Faltou parâmetro de diretório."
	echo "./$0 DIRETORIO"
	exit
fi

# Precisa ir para o diretório destino
cd $1

find . -type f -name 'dados-*.[cC][sS][vV]' | xargs ls {}


for f in $(ls dados-*.csv); do
    echo $f | sed '1 s/-v4.csv//1' | xargs -i mv $f {}
done

find . -type f -name '*.csv' | xargs ls {}

# Volta ao diretório inicial
cd -
