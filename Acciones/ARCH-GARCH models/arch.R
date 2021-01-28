library(quantmod)
library(rugarch)
library(rmgarch)

startDate = as.Date("2015-01-03") #Specify period of time we are interested in
endDate = as.Date("2019-01-19")


##ENTONCES TRAIGAMOS LA DATA DE LAS ACCIONES DE ALGUNAS EMPRESAS
getSymbols("EPU", from = startDate, to = endDate)
#getSymbols("GOOG", from = startDate, to = endDate)
getSymbols("BAP", from = startDate, to = endDate)#
getSymbols("SPY", from = startDate, to = endDate)#BVN
getSymbols("BVN", from = startDate, to = endDate)
getSymbols("CPAC", from = startDate, to = endDate)
rEPU <- weeklyReturn(EPU)
rBAP <- weeklyReturn(BAP)
rBNV <- weeklyReturn(BVN)
rCPAC <- weeklyReturn(CPAC)
rSPY <- weeklyReturn(SPY)
chartSeries(EPUrent)   #YA ESUNA SERIE DE TIEMPO

rTodos <- data.frame(rEPU, rBAP, rBNV, rCPAC,rSPY)
names(rTodos)[1] <- "rEPU"
names(rTodos)[2] <- "rBAP"
names(rTodos)[3] <- "rBNV"
names(rTodos)[4] <- "rCPAC"
names(rTodos)[5] <- "rSPY"


# library(writexl)
#Guardandi en CSV podemos jalar la fecha:
write.csv(as.data.frame(rTodos),"D:/académicos 6to semestre/Sexto semestre/Econometría 2/Trabajo/stock2.csv")



# Convert to data.frame on export.
write.csv(as.data.frame(ysyms), file = "test.csv")
tail(EPU)
tail(BAP)
chartSeries(EPU)
chartSeries(BAP)


###RETORNOS DIARIOS####

EPUrent <- dailyReturn(EPU)
rBAP <- dailyReturn(BAP)
chartSeries(EPUrent)   #YA ESUNA SERIE DE TIEMPO

rTodos <- data.frame(rEPU, rBAP)
names(rTodos)[1] <- "rEPU"
names(rTodos)[2] <- "rBAP"

#####MODELIZANDO#######
#Le damos forma de serie de tiempo desde abril del 2015
# EPUrent<-ts(rEPU, start=c(2015,04))
# chartSeries(EPUrent)
####Observamos una varianza no constante (heterocedasticidad)####

#1. Estimamos la ecuación de la media
library("dynlm")

media_EPU<-dynlm(EPUrent~1, data=EPU)
summary(media_EPU)
arima22<-arima(EPUrent, order=c(2,0,2))


#2. Calculamos los residuales al cuadrado

resid_cuad<-resid(arima22)^2
chartSeries(resid_cuad)  ###LOS RESIDUALES AL CUADRADO NO SON CONSTANTES
                         #NO HAY VARIANZA CONSTANTE


#Arch model
library(FinTS)

arch_EPU<-dynlm(resid_cuad~ L(resid_cuad),data=EPU) #y=e^2, X=e(-1)^2
summary(arch_EPU)

#Usando el Archtest
EPUarchtest<-ArchTest(EPUrent, lags=1, demean=TRUE) #Lagrange Multiplier (LM) test for autoregressive conditional heteroscedasticity (ARCH)

EPUarchtest


acf_resEPU<-acf(resid_cuad, main="ACF de los residuos al cuadrado", lag.max = 20)
pacf_resEPU<-pacf(resid_cuad, main="PACF de los residuos al cuadrado", lag.max = 20)
#SE SALE DE LAS LÍNEAS, NO HAY RUIDO BLANCO, HAY ALGUN ESQUEMA DE ARMA EN LOS RESIDUOS
#ES DECIR, CORRELACIÓN

EPUarchtest2<-ArchTest(EPUrent, lags=2, demean=TRUE)
EPUarchtest2

#Al ser menor a 0.5, hay heterocedasticidad, usamos ARCH


#TRABAJAMOS CON UN ESQUEMA GARCHA (PRESUPONE UNA ESTRUCTURA ARMA)
ug_spec = ugarchspec()  #Por defecto da un Garch (1,1)
ug_spec

#Trabajamos con otro orden

ug_spec <- ugarchspec(mean.model=list(armaOrder=c(1,0))) #ARMA (1,0) sí da
ug_spec

###Estimamos el modelo

ugfit = ugarchfit(spec = ug_spec, data = rEPU) #Alfa(de los residuales alcuadrado) 
#y beta son del Garch (varianza de los residuales al cuadrado)
ugfit

ugfit@fit$coef
ugfit@fit$var

ug_var <- ugfit@fit$var   # save the estimated conditional variances
ug_res2 <- (ugfit@fit$residuals)^2   # save the estimated squared residuals

plot(ug_res2, type = "l")
lines(ug_var, col = "green")




#PRONÓSTICO DEL MODELO ARMA MÁS GARCH
ugfore <- ugarchforecast(ugfit, n.ahead = 10)
ugfore
