#' Vybere data pro jednu LAPV
#'
#' @param ID identifikátor lokality
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

#' Vytvoří agregované řady
#'
#' @param x číselný vektor
#' @param upto požadovaný počet agregací
#'
#' @return \code{list} s jednotlivými položkami odpovídajícími jednotlivým agregacím se sloupci \code{DTM} (datum), \code{x} (agregovaná veličina), \code{k} (úroveň agregace)
#' @export agg2
#'
#' @examples
#' dta = get_lapv_data('AMERIKA')
#' agg2(dta[, .(DTM, sim_P)])
agg2 = function(x, upto = 8){

  on = names(x)
  setnames(x, names(x), c('DTM', 'x'))
  res = list()
  res[[1]] = data.table(x, k = 1)

  for (i in 2:upto){

      pom = data.table(res[[i-1]], id =  (1:nrow(res[[i-1]]))%/%2 )
      pom[, L:= .N, by = id]
      res[[i]] = pom[L==2, .(DTM = DTM[1] + diff(DTM), x = sum(x), k = i), by = id]
      res[[i]][, id:=NULL]
      setnames(res[[i]], 'x', on[2])
    }
  return(res)
}

#' Agreguj na roky
#'
#' @param dta data pro LAPV
#'
#' @return \code{data.table} s agregovaným datasetem
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


#' Generátor náhodných veličin
#'
#' @param x číselný vektor - generovaná data mají stejný průměr a směrodatnou odchylku jako tato veličina
#' @param n délka generovaného vektoru, výchozí \code{n = length(x)}
#' @param proces specifikace procesu generující náhodnou veličinu - jedno z \code{WN} - bílý šum, \code{ARi} - autoregresní proces, kde \code{i} je řád procesu (tedy např. \code{AR1}, \code{AR2}, atd.), \code{FGN} - fractional Gaussian noise
#'
#' @return vygenerovaný vektor
#' @export toyGen
#'
#' @examples
#' dta = get_lapv_data('AMERIKA')
#' x = dta[, .(obs_RM)]
#' toyGen(x, proces = 'WN')
#' toyGen(x, proces = 'AR2')
#' toyGen(x, proces = 'FGN')
toyGen = function(x, n = length(x), proces = 'WN'){

  if (grepl('AR', proces)) {
    ord = as.integer(gsub('AR', '', proces))
    proces = 'AR'
  }

  res = switch(proces,
         'WN' = {
           rnorm(n, mean(x), sd(x))
         },
         'AR' = {
           a = arima(x, order = c(ord, 0, 0))
           arima.sim(list(ar = a$coef[grepl('ar', names(a$coef))]), n = 100, sd = sqrt(a$sigma2)) + a$coef['intercept']
         },
         'FGN' = {
           f = FitFGN(x)
           mean(x) + SimulateFGN(n, HurstK(x)) * sqrt(f$sigsqHat)
         })
  return(res)
  }
