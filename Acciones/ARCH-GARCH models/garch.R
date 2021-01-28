####BUENA PARTE DEL CÓDIGO USADO AQUÍ SIGUE A: http://eclr.humanities.manchester.ac.uk/index.php/R_GARCH

#install.packages(c("quantmod","rugarch","rmgarch"))   # only needed in case you have not yet installed these packages
library(quantmod)
library(rugarch)
library(rmgarch)

#Usaremos la data de getSymbols (del paquete quantmod), que nos sirve para obtener data.
#por defecto nos da la data de los stocks en Yahoo Finance.
startDate = as.Date("2015-01-03") #Specify period of time we are interested in
endDate = as.Date("2019-01-19")

##ENTONCES TRAIGAMOS LA DATA DE LAS ACCIONES DE ALGUNAS EMPRESAS
getSymbols("IBM", from = startDate, to = endDate)
getSymbols("GOOG", from = startDate, to = endDate)
getSymbols("BP", from = startDate, to = endDate)#
getSymbols("TSLA", from = startDate, to = endDate) 
getSymbols("BTC-USD", from = startDate, to = endDate)#
#getSymbols("TSLA", from = "2019-01-19", to = "2019-01-30") 
#head(TSLA)
tail(TSLA)
str(TSLA)  #Objeto tipo "xts": serie de tiempo
chartSeries(TSLA)



rTSLA <- dailyReturn(TSLA)
rBP <- dailyReturn(BP)
rGOOG <- dailyReturn(GOOG)
rBTC <- dailyReturn(`BTC-USD`)
str(rBTC)

#HAGAMOS UN DATA FRAME EXCEPTUANDO A BITCOIN(tiene más filas)
rX <- data.frame(rTSLA, rBP, rGOOG)
names(rX)[1] <- "rTSLA"
names(rX)[2] <- "rBP"
names(rX)[3] <- "rGOOG"
#names(rX)[3] <- "rBTC"
rX


###construyendo el modelo univariante


ug_spec = ugarchspec()
ug_spec

ug_spec <- ugarchspec(mean.model=list(armaOrder=c(1,0)))
ug_spec


ewma_spec = ugarchspec(variance.model=list(model="iGARCH", garchOrder=c(1,1)), 
                       mean.model=list(armaOrder=c(0,0), include.mean=TRUE),  
                       distribution.model="norm", fixed.pars=list(omega=0))


ugfit = ugarchfit(spec = ug_spec, data = rTSLA)
ugfit


paste("Elements in the @model slot")

names(ugfit@model)

paste("Elements in the @fit slot")

names(ugfit@fit)

ugfit@fit$coef


ug_var <- ugfit@fit$var   # save the estimated conditional variances
ug_res2 <- (ugfit@fit$residuals)^2   # save the estimated squared residuals

plot(ug_res2, type = "l")
lines(ug_var, col = "green")


ugfore <- ugarchforecast(ugfit, n.ahead = 10)
ugfore

names(ugfore@forecast) 

ug_f <- ugfore@forecast$sigmaFor
plot(ug_f, type = "l")

ug_var_t <- c(tail(ug_var,20),rep(NA,10))  # gets the last 20 observations
ug_res2_t <- c(tail(ug_res2,20),rep(NA,10))  # gets the last 20 observations
ug_f <- c(rep(NA,20),(ug_f)^2)

plot(ug_res2_t, type = "l")
lines(ug_f, col = "orange")
lines(ug_var_t, col = "green")
