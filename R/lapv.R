#' Vybere data pro jednu LAPV
#'
#' @param ID identifikator lokality
#'
#' @return \code{data.table} s daty pro zvolenou LAPV
#' @export get_lapv_data
#'
#' @examples
#' get_lapv_data('AMERIKA')
get_lapv_data = function(ID){

  data(lapv_data)
  if (!ID %in% names(lapv_data)) stop('ID nenalezeno! Musi byt jedno z:\n', paste(names(lapv_data), sep = ',\t'))
  lapv_data[[ID]]
}

#' Vytvori agregovane rady
#'
#' @param x ciselny vektor
#' @param upto pozadovany pocet agregaci
#'
#' @return \code{list} s jednotlivymi polozkami odpovidajicimi jednotlivym agregacim se sloupci \code{DTM} (datum), \code{x} (agregovana velicina), \code{k} (uroven agregace)
#' @export agg2
#'
#' @examples
#' dta = get_lapv_data('AMERIKA')
#' agg2(dta[, .(DTM, sim_P)])
agg2 = function(x, upto = 8){

  on = names(x)
  setnames(x, names(x), c('DTM', 'x'))
  res = list()
  res[[1]] = data.table(x, idx = 1, k = 1)

  for (i in 2:upto){

      pom = data.table(res[[i-1]], id =  (1:nrow(res[[i-1]]))%/%2 )
      pom[, L:= .N, by = id]
      res[[i]] = pom[L==2, .(DTM = DTM[1] + diff(DTM), x = sum(x), idx = i, k = 2 ^ (i-1) ), by = id]
      res[[i]][, id:=NULL]
      setnames(res[[i]], 'x', on[2])
    }
  return(res)
}

#' Agreguj na roky
#'
#' @param dta data pro LAPV
#'
#' @return \code{data.table} s agregovanym datasetem
#' @export mon2yr
#'
#' @examples
#' dta = get_lapv_data('AMERIKA')
#' mon2yr(dta)
mon2yr = function(dta){
  sm = dta[, lapply(.SD, sum), .SDcols = c('sim_P', 'obs_P', 'obs_RM'), by = .(ID, GCM, RUN, SID, DTM = year(DTM))]
  me = dta[, lapply(.SD, mean), .SDcols = c('sim_T', 'obs_T'), by = .(ID, GCM, RUN, SID, DTM = year(DTM))]
  out = sm[me, on = c('DTM', 'ID', 'GCM', 'RUN', 'SID')]
  out[, DTM:=as.Date(paste0(DTM, '-01-01'))]
  copy(out)
}


#' Generator nahodnych velicin
#'
#' @param x ciselny vektor - generovana data maji stejny prumer a smerodatnou odchylku jako tato velicina
#' @param n delka generovaneho vektoru, vychozi \code{n = length(x)}
#' @param seed seed nahodneho generatoru
#' @param proces specifikace procesu generujiciho nahodnou velicinu - jedno z \code{WN} - bily sum, \code{ARi} - autoregresni proces, kde \code{i} je rad procesu (tedy napr. \code{AR1}, \code{AR2}, atd.), \code{FGN} - fractional Gaussian noise
#'
#' @return vygenerovany vektor
#' @export toyGen
#'
#' @examples
#' dta = get_lapv_data('AMERIKA')
#' x = dta[, .(obs_RM)]
#' toyGen(x, proces = 'WN')
#' toyGen(x, proces = 'AR2')
#' toyGen(x, proces = 'FGN')
toyGen = function(x, n = length(x), proces = 'WN', seed = NULL, burnin = 100){

  if (grepl('AR', proces)) {
    ord = as.integer(gsub('AR', '', proces))
    proces = 'AR'
  }
  if (!is.null(seed)) set.seed(seed)

  res = switch(proces,
         'WN' = {
           rnorm(n + burnin, mean(x), sd(x))[1:n + burnin]
         },
         'AR' = {
           a = arima(x, order = c(ord, 0, 0))
           arima.sim(list(ar = a$coef[grepl('ar', names(a$coef))]), n = n, sd = sqrt(a$sigma2), n.start = burnin) + a$coef['intercept']
         },
         'FGN' = {
           f = FitFGN(x)
           #Boot(f, 1)
           f$muHat + SimulateFGN(n + burnin, f$H)[1:n + burnin] * sqrt(f$sigsqHat)
           #mean(x) + SimulateFGN(n + burnin, HurstK(x))[1:n + burnin] * sqrt(f$sigsqHat)
         })
  return(res)
  }


#' Spocíta statistiky dle Hursta
#'
#' @param x vektor pro vypocet statistik
#' @param N vektor resamplovanych delek
#'
#' @return data.frame s vysledky
#' @export hurst
#'
#' @examples
hurst = function(x, N = 10:100){
  res = data.frame(N = N)
  cx = cumsum(x - mean(x))

  for (i in 1:nrow(res) ) {

    N = res[i, "N"]
    sx = sample(1:(length(x) - N + 1), 1)
    sx = cx[sx + 1:N - 1]

    R = diff(range(sx))
    s = sd(x)
    res[i, "R"] = R
    res[i, "sigma"] = s
    res[i, "k1"] = R / s / (N^.5)
    res[i, "k2"] = log(R/s) / log(N/2)
  }

  structure(res, h = unname(lm( log(R/sigma) ~ log(N/2) - 1, data = res)$coe[1]))
}


#' Vykresli casovou radu a kumulativni sumu pro generovane rady
#'
#' @param x vzro pro generatory
#' @param seed seed pro generatory
#' @param ylim rozsah
#'
#' @return nic
#' @export plotGen
#'
#' @examples
plotGen = function(x, seed = NULL, ylim = c(-3000, 3000)){

  par(mfrow = c(2, 1), mar = c(3, 3, .5, .5))
  toyGen(x, proces = 'WN', seed = seed) %>% -mean(.) %>% cumsum %>% plot(., type = 'l', ylim = ylim)
  toyGen(x, proces = 'AR1', seed = seed) %>% -mean(.) %>% cumsum %>% lines(., col = 'blue')
  toyGen(x, proces = 'FGN', seed = seed) %>% -mean(.) %>% cumsum %>% lines(., col = 'red')
  legend('topright', col = c('black', 'blue', 'red'), legend = c('WN', 'AR1', 'FGN'), lty =1)

  toyGen(x, proces = 'WN', seed = seed)  %>% plot(., type = 'l', ylim = extendrange(range(x), f = 0.2))
  toyGen(x, proces = 'AR1', seed = seed)  %>% lines(., col = 'blue')
  toyGen(x, proces = 'FGN', seed = seed)  %>% lines(., col = 'red')
  legend('topright', col = c('black', 'blue', 'red'), legend = c('WN', 'AR1', 'FGN'), lty =1)

}


#' Vytvori Bilan model s parametry ziskanymi kalibraci pro vybrane LAPV
#'
#' @param ID ID lokality
#' @param type Typ modelu, vetsinou mesicni (tj. vychozi hodnota)
#' @param ... ostatni parametry - predano do funkce \code{bil.new}
#'
#' @return bilan model objekt
#' @export bil.lapv
#'
#' @examples
#' dta  = get_lapv_data("AMERIKA")
#'b = bil.lapv("AMERIKA")
#'
#'bil.set.values(b, dta[, .(DTM, P = obs_P, T = obs_T)])
#'bil.pet(b)
#'res = bil.run(b)
bil.lapv = function(ID, type = 'm', ...){
  data(bil_pars)
  b = bil.new(type = type, ...)
  bil.set.params(b, B[[ID]])
  return(b)
}

#' Proved korekci systematickych chyb pomoci kvantilove metody 
#'
#' @param dta data pro LAPV - typicky vysledek volani \code{get_lapv_data}
#' @param ... ostatni parametry - predane do funkce \code{loess} slouzici k vyhlazeni odchylek
#'
#' @return data s korigovanymi sloupci (sloupce \code{cor_P} a \code{cor_T})
#' @export correct
#'
#' @examples
#' dta = get_lapv_data("AMERIKA")
#' cdta = correct(dta)
correct = function(dta, ...){
  
  dta[, eP := loess(sort(sim_P)/sort(obs_P) ~ I(1:.N), ...)$fitted[rank(sim_P)], by = month(DTM)]
  dta[, cor_P:= sim_P / eP, by = month(DTM)]
  
  dta[, eT := loess(sort(sim_T)-sort(obs_T) ~ I(1:.N), ...)$fitted[rank(sim_T)], by = month(DTM)]
  dta[, cor_T:= sim_T - eT, by = month(DTM)]
  copy(dta)
  
}