# By Duccio Aiazzi as part of the MSc Smart Cities adn Urban Analytics at CASA - UCL
# This script is used to fetch the data from the database and run the analysis
from subprocess import run
import os
import datetime
import psycopg2
import pandas as pd

conn = psycopg2.connect(database="msc", user="postgres", password="postgres", host="localhost", port="5432")
print("Open conncetion: successful")
plots = pd.DataFrame()
cur = conn.cursor()
cur.execute('''

            ''')
rows = cur.fetchall()