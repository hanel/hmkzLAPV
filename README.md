



# hmkzLAPV 

R balík pro výuku předmětu Hydrologické dopady klimatické změny (FŽP, ČZU) v roce 2016.

### Instalace


```r
> library(devtools)
> install_github("hanel/hmkzLAPV")
```

nebo


```r
> library(devtools)
> install_git("https://github.com/hanel/hmkzLAPV.git")
```

## Úvod

Informace o jednotlivých LAPV jsou dostupné v tabulce `lapv_tab`:


```r
> library(hmkzLAPV)
> data(lapv_tab)
> head(lapv_tab)
```

```
         ID        A NAZEV_NADR Vpot
1:     FORT 30379718       Fořt 13.3
2:     BABI 10254929       Babí 11.1
3: LUKAVICE 15384980   Lukavice 14.1
4:    PECIN 38227478      Pěčín 17.1
5:  ZAMBERK 28315407    Žamberk 24.4
6:  PISECNA 13958154    Písečná  4.9
```


Data pro jednotlivá LAPV načtete pomocí funkce `get_lapv_data`, jejímž argumentem je `ID`, tj. identifikátor povodí:


```r
> dta = get_lapv_data("AMERIKA")
> head(dta)
```

```
          DTM      ID     sim_P     sim_T       GCM    RUN
1: 1901-01-15 AMERIKA  61.22721 -1.163763 GISS-E2-H r5i1p3
2: 1901-02-15 AMERIKA  47.17358  4.116205 GISS-E2-H r5i1p3
3: 1901-03-15 AMERIKA  85.45800  3.675195 GISS-E2-H r5i1p3
4: 1901-04-15 AMERIKA 120.38636  7.676691 GISS-E2-H r5i1p3
5: 1901-05-15 AMERIKA 167.56643 12.769983 GISS-E2-H r5i1p3
6: 1901-06-15 AMERIKA 170.42231 15.459894 GISS-E2-H r5i1p3
                SID    obs_P obs_T  obs_RM
1: GISS-E2-H_r5i1p3  36.2415 -7.64 35.7908
2: GISS-E2-H_r5i1p3  51.4596 -8.25 11.5360
3: GISS-E2-H_r5i1p3  76.6677 -0.72 12.8200
4: GISS-E2-H_r5i1p3  68.9088  5.67 94.3496
5: GISS-E2-H_r5i1p3  71.1843 11.03 47.8008
6: GISS-E2-H_r5i1p3 130.1480 14.23 45.6612
```

Data obsahují:


|název  |význam                                                |
|:------|:-----------------------------------------------------|
|DTM    |datum                                                 |
|ID     |ID povodí                                             |
|sim_P  |simulované srážky                                     |
|sim_T  |simulovaná teplota                                    |
|GCM    |globální klimatický model                             |
|RUN    |ID běhu modelu                                        |
|SID    |ID simulace                                           |
|obs_P  |pozorované srážky                                     |
|obs_T  |pozorovaná teplota                                    |
|obs_RM |odtok pro pozorované podmínky (simulace modelu Bilan) |


# Zadání:

### 1. CVIČENÍ

- V rychlosti prostudujte článek **Hurst, H. E. (1956). The Problem of long-term storage in reservoirs. International Association of Scientific Hydrology. Bulletin, 1:3, 13-27.** DOI: 10.1080/02626665609493644

(A).

- Zagregujte data do ročního časového kroku (využijte funkci `mon2yr`)
- Pro různá N z intervalu (10, 110) vypočtěte K1 = R / (sigma N^0.5) a K2 = log (R / sigma) / log  (N/2), kde R je rozpětí hodnot a sigma je směrodatná odchylka
- Pro různá N z intervalu (10, 110) vykreslete log(R/sigma) proti log(N/2)
- Vytvořte lineární model `lm(log(R/sigma) ~ log(N/2))`, zjistěte hodnotu regresního koeficientu (h) a dokreslete přímku do grafu
- opakujte pro bílý šum, AR(1) [případně AR(2), AR(3), atd.] proces a FGN proces - pro generování veličin použijte funkci `toyGen`
- výsledky porovnejte
- vytvořte funkci, která spočítá pro zadanou veličinu koeficient `h`
- **!! vše uložte !!**


(B)onus



```r
> devtools::install_github("jbkunst/highcharter")
> ydta = mon2yr(dta)
> library(highcharter)
> library(magrittr)
> highchart(type = "stock") %>% hc_tooltip(valueDecimals = 2) %>% 
+   hc_add_series_times_values(ydta$DTM, ydta$obs_P, name = "Pozorovaná srážka", showInLegend = TRUE) %>% 
+   hc_add_series_times_values(ydta$DTM, ydta$sim_P, name = "Simulovaná srážka") %>%
+   hc_add_theme(hc_theme_darkunica())
```

viz http://jkunst.com/highcharter

(*)

- S využitím funkce `agg2` postupně agregujte data po dvojicích
- Vykreslete graf log(k) proti log(sd(x) ^ 0.5), kde k je agregace a sd(x) je veličina agregovaná na k-té úrovni

