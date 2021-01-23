library(jsonlite)
library(httr)

#label="PN01770AM"
label="PD04722MM"
per="/1994-1/2019-12"  ####NO DARÁ TODA, PUES LA DATA SOLO HAY DESDE EL 2003
formato="/json"
web<-paste0("https://estadisticas.bcrp.gob.pe/estadisticas/series/api/",label,formato, per)
web
jsn<- GET(web)
jsn<-rawToChar(jsn$content)  #De unicode a texto
data<- fromJSON(jsn)

data<-data[[2]]
names(data)[1]<-"PERIODO"
names(data)[2]<-"ÍNDICE DE PRECIOS y PBI"
data

