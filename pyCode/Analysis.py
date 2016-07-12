# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to fetch the data from the database and run the analysis
from subprocess import run
import os
import datetime
import psycopg2
import pandas as pd

conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: succesful")
cur = conn.cursor()
dt = datetime.datetime.now()
print("Start conversion to typology")
print('Starting Time: '+str(dt.hour).zfill(2) + ':' + str(dt.minute).zfill(2))
cur.execute('''