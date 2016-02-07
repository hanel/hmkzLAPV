# hmkzLAPV

R balík pro výuku předmětu Hydrologické dopady klimatické změny (FŽP, ČZU) v roce 2016.

## Instalace

```
library(devtools)
install_github("hanel/hmkzLAPV")
```

nebo

```
library(devtools)
install_git("https://github.com/hanel/hmkzLAPV.git")
```

## Úvod

Data pro jednotlivá LAPV načtete pomocí

```
get_data_lapv(ID)
```

kde `ID` je identifikátor povodí.
