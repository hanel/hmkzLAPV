



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

---

### 2. CVIČENÍ

(A).

- funkce `hurst` je nyní součástí balíku, v čem spočívají zásadní rozdíly mezi touto funkcí a (chybnou) funkcí, kterou jsme používali minule? Tj. 


```r
> hurst = function(x, N){
+   res = data.frame(N = 10:100  )
+   for (i in 1:nrow(res) ) {
+     sx = sample(x, res[i, "N"])
+     R = diff(range(sx))
+     s = sd(sx)
+     N = res[i, "N"]
+     res[i, "R"] = R
+     res[i, "sigma"] = s
+     res[i, "k1"] = R / (s * N^.5)
+     res[i, "k2"] = log(R/s) / log(N/2)
+   }
+   return(res)
+ }
```

- na základě vybrané veličiny `x` (např. pozorovaný odtok) simulujte pomocí funkce `toyGen` veličiny s využitím bílého šumu (WN), autoregresního procesu prvního řádu (AR1), a fractional gaussian noise (FGN). Vykreslete tyto řady a řady kumulativních odchylek od průměru (použijte funkci `plotGen`)
- jaké jsou typické hodnoty Hurstova koeficientu pro WN, AR1 a FGN? (lze zjistit pomocí `attr(hurst(x), 'h')`)?
- pomocí opakovaného samplování určete 90% interval spolehlivosti pro odhady Hurstova koeficientu pro jednotlivé procesy

- vykreslete časovou řadu (ročních) pozorovaných a simulovaných srážek nebo teploty a jejich kumulativní odchylky od průměru
- jak se liší odhady Hurstova koeficientu? Jsou rozdíly statisticky významné?

(B)onus

Někdy by bylo výhodné, aby grafy v RStudiu umožňovaly alespoň omezenou interaktivitu. Jednou z možností je využítí balíku `manipulate`, který umožňuje velmi jednoduchou implementaci ovládacích prvků (`slider`, `picker`, `checkbox` a `button`)

Příklady s využitím dat z balíku `hmkzLAPV`:

př1:


```r
> library(manipulate)
> 
> dta = get_lapv_data('AMERIKA')
> mdta = mon2yr(dta)
> 
> manipulate(
+   plot(mdta$DTM, y, type = type),
+   y = picker("sim_P" = mdta$sim_P, "obs_P" = mdta$obs_P),
+   type = picker("Points" = "p", "Line" = "l", "Step" = "s")
+ )
```

př2:


```r
> manipulate(
+   {plot(mdta$DTM, y1, type = 'l', col = col1, ylim = range(y1, y2))
+    lines(mdta$DTM, y2, col = col2)  
+     },
+     y1 = picker("sim_P" = mdta$sim_P, "obs_P" = mdta$obs_P),
+     y2 = picker("sim_P" = mdta$sim_P, "obs_P" = mdta$obs_P),
+     col1 = slider(1, 650, initial = 300),
+     col2 = slider(1, 650, initial = 200)
+ )
```

př3:


```r
> manipulate(
+   plot(mdta$DTM, y, type = type, xlim = c(mdta$DTM[from], mdta$DTM[to])),
+   y = picker("sim_P" = mdta$sim_P, "obs_P" = mdta$obs_P),
+   type = picker("Points" = "p", "Line" = "l", "Step" = "s"), 
+   from = slider(1, nrow(mdta)),
+   to = slider(1, nrow(mdta), initial = nrow(mdta))
+ )
```


(*)

- S využitím funkce `agg2` postupně agregujte data po dvojicích
- Vykreslete graf log(k) proti log(sd(x) ^ 0.5), kde k je agregace a sd(x) je veličina agregovaná na k-té úrovni


---

### 3. CVIČENÍ - KOREKCE SYSTEMATICKÝCH CHYB

(A).

1. Zjistěte, jak se liší průměrné srážky a teplota v simulaci od pozorování
2. Vykreslete empirické distribuční funkce pozorovaných a simulovaných srážek/teploty pro všechny data a jednotlivé měsíce
3. Zjistěte, jaká je chyba v distribuční funkci simulovaných srážek a teploty pro měsíční (všechny vs jednotlivé měsíce) a roční data
4. Vyhlaďte rozdíly pomocí filtru loess
5. Opravte simulované veličiny
6. Vytvořte funkci umožňující korekci distribuční funkce pro jednotlivé měsíce


---

### 4. CVIČENÍ - HYDROLOGICKÝ MODEL A SYNTÉZA

#### Nové funkce v balíku:

- `correct` - provede korekci systematických chyb - viz `?correct`
- `bil.lapv` - vytvoří instanci modelu Bilan s parametry pro zadanou LAPV - viz `?bil.lapv`

### Stručný úvod do modelu Bilan

- [Bilan](http://bilan.vuv.cz/bilan/uzivatelska-prirucka-modelu-bilan/) je model hydrologické bilance vyvíjený ve Výzkumném ústavu vodohospodářském T. G. Masaryka, v.v.i.
- 2 verze (stejné jádro) - uživatelské rozhraní x balík pro R
- nainstalujte pomocí zipového souboru `bilan_2015-06-18.zip` ve složce materialy, verze pro linux a OS X viz `bilan_2015-06-18.tar.gz`
- základní postup práce relevantní pro naše účely je následující:


```r
> library(bilan)
> 
> # načti data
> dta = get_lapv_data("AMERIKA")
> 
> # vytvoř model 
> b = bil.lapv("AMERIKA")
> 
> # model existuje, má příslušné parametry:
> bil.get.params(b)
```

```
  name     current lower upper     initial
1  Spa 1.45620e+02     0 2e+02 1.45620e+02
2  Dgw 5.88764e+00     0 2e+01 5.88764e+00
3  Alf 1.74327e-03     0 3e-03 1.74327e-03
4  Dgm 5.79781e+00     0 2e+02 5.79781e+00
5  Soc 5.40708e-01     0 1e+00 5.40708e-01
6  Wic 2.20102e-01     0 1e+00 2.20102e-01
7  Mec 6.85181e-01     0 1e+00 6.85181e-01
8  Grd 7.06486e-01     0 1e+00 7.06486e-01
```

```r
> # ale žádná data
> bil.get.data(b)
```

```
 [1] DTM  P    R    RM   BF   B    I    DR   PET  ET   SW   SS   GS   INF 
[15] PERC RC   T    H    WEI 
<0 rows> (or 0-length row.names)
```

```r
> # Proto nahrajeme do modelu příslušná data z data.tablu dta
> bil.set.values(b, dta[, .(DTM, P = obs_P, T = obs_T)])
> 
> # poté stačí spočítat potenciální evapotranspiraci 
> bil.pet(b)
> 
> # a model spustit
> res = bil.run(b)
> 
> res
```

```
             DTM       P  R         RM           BF  B          I
   1: 1901-01-15 36.2415 NA 35.7908173 35.324300000 NA  0.4665173
   2: 1901-02-15 51.4596 NA 11.5360213 11.536021346 NA  0.0000000
   3: 1901-03-15 76.6677 NA 12.8199999  3.385983769 NA  9.4340161
   4: 1901-04-15 68.9088 NA 94.3496046 24.610249803 NA 69.7393548
   5: 1901-05-15 71.1843 NA 47.8007750 29.861403497 NA 17.9393715
  ---                                                            
1256: 2005-08-15 88.0452 NA 11.7690601  0.460872783 NA  0.0000000
1257: 2005-09-15 54.6231 NA  4.2980476  0.135272614 NA  0.0000000
1258: 2005-10-15 16.0395 NA  0.3883653  0.039704406 NA  0.0000000
1259: 2005-11-15 24.1092 NA  0.7421294  0.011653799 NA  0.0000000
1260: 2005-12-15 66.6222 NA  1.5646058  0.003420553 NA  1.5611852
              DR       PET        ET       SW        SS           GS
   1:  0.0000000  0.000000  0.000000 145.6200  34.12195 16.328733118
   2:  0.0000000  0.000000  0.000000 145.6200  85.58155  4.792711772
   3:  0.0000000 12.220326 12.220326 145.6200 107.16690 34.834731053
   4:  0.0000000 41.237383 41.237383 145.6200  33.05594 42.267509190
   5:  0.0000000 78.058293 78.058293 145.6200   0.00000 20.648679538
  ---                                                               
1256: 11.3081873 83.225574 82.047393 116.5431   0.00000  0.191472462
1257:  4.1627750 54.688036 53.795217 113.2082   0.00000  0.056199848
1258:  0.3486609 26.682549 23.921498 104.9776   0.00000  0.016495442
1259:  0.7304756  7.142156  7.142156 121.2141   0.00000  0.004841643
1260:  0.0000000  2.276500  2.276500 145.6200  32.84683  5.533243748
            INF       PERC        RC     T  H WEI
   1:   2.11955   2.119550  1.653033 -7.64 NA   1
   2:   0.00000   0.000000  0.000000 -8.25 NA   1
   3:  42.86202  42.862019 33.428003 -0.72 NA   1
   4: 101.78238 101.782383 32.043028  5.67 NA   1
   5:  26.18195  26.181945  8.242574 11.03 NA   1
  ---                                            
1256:  76.73701   0.000000  0.000000 14.37 NA   1
1257:  50.46032   0.000000  0.000000 12.56 NA   1
1258:  15.69084   0.000000  0.000000  7.65 NA   1
1259:  23.37872   0.000000  0.000000  0.69 NA   1
1260:  31.49887   7.093008  5.531823 -2.65 NA   1
```

#### Zadání:

- nahrajte data pro zvolenou LAPV
- pomocí funkce `correct` zkorigujte simulované srážky a teploty
- nainstalujte balík `bilan`
- nahrajte model pro zvolenou LAPV
- vytvořte data.frame, který bude obsahovat veličiny
    - `DTM` - datum
    - `obs_RM` - odtok modelovaný na základě pozorovaných srážek a teploty
    - `sim_RM` - odtok modelovaný na základě simulovaných srážek a teploty z klimatického modelu
    - `cor_RM` - odtok modelovaný na základě korigovaných srážek a teploty
- vykreslete odchylky `sim_RM`/`obs_RM` a `cor_RM`/`obs_RM` pro jednotlivé kvantily distribuční funkce a měsíce
- spočítejte hurstův koeficient pro tyto řady a vykreslete řady kumulativních odchylek od průměru

# PROTOKOL

viz protokol.Rmd
