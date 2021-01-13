# -*- coding: utf-8 -*-
"""
Created on Wed Jan 13 13:01:34 2021

@author: abner
"""

from bs4 import BeautifulSoup
from selenium import webdriver
import pandas as pd
import requests

'''
#FORMA 1:
URL = 'https://finance.yahoo.com/quote/AMZN/history?period1=1452643200&period2=1610496000&interval=1wk&filter=history&frequency=1wk&includeAdjustedClose=true'
page = requests.get(URL)
soup = BeautifulSoup(page.content, 'html.parser')
print(soup
prices_t = soup.find('table', class_ = "W(100%) M(0)") )'''

'''#FORMA 2'''
URL = 'https://finance.yahoo.com/quote/AMZN/history?period1=1452643200&period2=1610496000&interval=1wk&filter=history&frequency=1wk&includeAdjustedClose=true'
DRIVER_PATH = 'C:/chromedriver.exe'
driver = webdriver.Chrome(executable_path=DRIVER_PATH)
driver.get(URL)

'''Buscando un patrón'''
a=driver.find_element_by_xpath('//tr[@data-reactid=51]').text
b=driver.find_element_by_xpath('//tr[@data-reactid=66]').text

print(a, b)

'''Creando una lista de filas para cada semana'''
a=51
span=[]
for i in range(52):
    path='//tr[@data-reactid={num:}]'.format(num=a)
    x=driver.find_element_by_xpath(path).text
    a+=15
    span.append(x)

print(a)
print(span)

inicio=0
for i in span:
    j=i.split()
    span[inicio]=j
    inicio+=1

print(span)

df=pd.DataFrame(span)
print(df)






#soup = BeautifulSoup(page.content, 'html.parser')
#print(soup)
#prices_t = soup.find('table', class_ = "W(100%) M(0)")
#prices_t = soup.find_element_by_xpath('//span[@data-reactid=61]')
                                     


#precios=prices_t.text
#print(type(precios))
#prices_t = soup.find('tr', class_ = "BdT Bdc($seperatorColor) Ta(end) Fz(s) Whs(nw)")
#print(precios)

