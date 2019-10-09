from collections import defaultdict
import requests
import csv
import time
from datetime import datetime
import ipdb
from decimal import *
import simplejson as json
import json
import boto3



def check_empty(input):
	if len(str(input)) == 0:
		return 'N/A'
	else:
		return input


#define api key, define the endpoint, and define the header
API_KEY = '' # add youer personal key to use this script 
ENDPOINT = 'https://api.yelp.com/v3/businesses/search'
ENDPOINT_ID = 'https://api.yelp.com/v3/businesses/' # + {id}
HEADERS = {'Authorization': 'bearer %s' % API_KEY}

#define parameters
PARAMETERS = {'term': 'food', 
			  'limit': 50,
			  'radius': 15000,
			  'offset': 200,
			  'location': 'Manhattan'}


#make request to yelp API
#response = requests.get(url = ENDPOINT, params =  PARAMETERS, headers=HEADERS)
#convert JSON string to a dictionary
#business_data = response.json()
#print(business_data)


cuisines = ['italian', 'chinese', 'mexican', 'american', 'japanese', 'pizza', 'healthy', 'brunch', 'korean', 'thai', 'vietnamese', 'indian', 'seafood', 'dessert']

manhattan_nbhds = 	['Lower East Side, Manhattan',
					'Upper East Side, Manhattan',
					'Upper West Side, Manhattan',
					'Washington Heights, Manhattan',
					'Central Harlem, Manhattan',
					'Chelsea, Manhattan',
					'Manhattan',
					'East Harlem, Manhattan',
					'Gramercy Park, Manhattan',
					'Greenwich, Manhattan',
					'Lower Manhattan, Manhattan']

start = time.time()

all_data = []
for nbhd in manhattan_nbhds:
	PARAMETERS['location'] = nbhd
	for cuisine in cuisines: 
		PARAMETERS['term'] = cuisine
		
		#make request to yelp API for specified cuisine + location
		response = requests.get(url = ENDPOINT, params =  PARAMETERS, headers=HEADERS)
		business_data = response.json()['businesses']
		for business in business_data:
			now = datetime.now()
			dt_string = now.strftime("%d/%m/%Y %H:%M:%S")

			restauraunt_data= {
				'Business_ID':check_empty(business['id']),
				'insertedAtTimestamp': check_empty(dt_string),
				'Name':  check_empty(business['name']),
				'Cuisine': check_empty(cuisine),
				'Rating': check_empty(Decimal(business['rating'])),
				'Number of Reviews' : check_empty(Decimal(business['review_count'])),
				'Address': check_empty(business['location']['address1']),
				'Zip Code': check_empty(business['location']['zip_code']),
				'Latitude': check_empty(str(business['coordinates']['latitude'])),
				'Longitude': check_empty(str(business['coordinates']['longitude'])),
				'Open': 'N/A'
			}
			

			all_data.append(restauraunt_data)

	print('Fin ',nbhd, time.time()- start)


with open('yelp_api_data.csv', 'b') as output_file:
    dict_writer = csv.DictWriter(all_data, keys)
    dict_writer.writeheader()
    dict_writer.writerows(toCSV)