
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
library(hmkzLAPV)
get_lapv_data(ID)
```


```r
library(hmkzLAPV)
```

```
## Loading required package: data.table
## Loading required package: ggplot2
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
```

```r
ID = 'AMERIKA'
dta = get_lapv_data(ID)
```


kde `ID` je identifikátor povodí.


