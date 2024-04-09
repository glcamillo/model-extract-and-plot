#!/bin/bash

if [ -z $1 ]; then
	echo "Erro. Faltou parâmetro de diretório."
	echo "./$0 DIRETORIO"
	exit
fi

#find $1 -type f -name 'dados*.csv' | xargs ls $1 


# Função para troca de nome de arquivo, retirando caracteres/sinais
#  Nome: SAO GABRIEL DA CACHOEIRA(UAUPES)  para 
#                dados-82106-SAOGABRIELDACACHOEIRA-UAUPES

# Precisa ir para o diretório destino
cd $1

# dados-83813-CASTRO.r2.csv-prp.csv
# dados-83813-CASTRO.r2.csv-tmax.csv
# dados-83813-CASTRO.r2.csv-tmediac.csv
# dados-83813-CASTRO.r2.csv-tmin.csv 

for f in $(ls dados-*.r2.csv-prp.csv); do
    echo $f | sed '1 s/csv-prp.csv/prp.csv/1' | xargs -i mv $f {}
done

for f in $(ls dados-*.r2.csv-tmax.csv); do
    echo $f | sed '1 s/csv-tmax.csv/tmax.csv/1' | xargs -i mv $f {}
done

for f in $(ls dados-*.r2.csv-tmediac.csv); do
    echo $f | sed '1 s/csv-tmediac.csv/tmediac.csv/1' | xargs -i mv $f {}
done

for f in $(ls dados-*.r2.csv-tmin.csv); do
    echo $f | sed '1 s/csv-tmin.csv/tmin.csv/1' | xargs -i mv $f {}
done




# Volta ao diretório inicial
cd -
