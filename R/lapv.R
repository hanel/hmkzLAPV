get_lapv_data = function(ID){

  data(lapv_data)
  if (!ID %in% names(lapv_data)) stop('ID nenalezeno! Musi byt jedno z:\n', paste(names(lapv_data), sep = ',\t'))
  lapv_data[[ID]]
}
