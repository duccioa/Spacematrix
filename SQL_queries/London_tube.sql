UPDATE london.tube_stations 
SET print=FALSE;
UPDATE london.tube_stations 
SET print=TRUE 
WHERE name IN ('Aldgate', 'Angel', 'Archway', 'Baker Street', 'Bank', 'Bethnal Green', 'Bow Church', 'Brixton',
		'Bromley', 'Camden Town', 'Canary Wharf', 'Charing Cross', 'Clapham Junction', 'Earls Court',
		'East Acton', 'East Croydon', 'Elephant and Castle', 'Finchley Central', 'Finsbury Park', 'Golders Green',
		'Greenwich', 'Hammersmith (District)', 'Hapstead Heath', 'Harringay', 'Heathrow Terminal 5', 'Highbury and Islington',
		'Holborn', 'Euston', 'Leyton', 'Liverpool Street', 'London Bridge','Mile End', 'Moorgate', 'New Cross Gate', 'Oxford Circus',
		'Piccadilly Circus', 'Putney', 'Redbridge', 'Richmond', 'Shepherds Bush', 'Southwark','Sutton', 'Swiss Cottage', 'Tottenham Court Road',
		'Tottenham Hale', 'Uxbridge', 'Vauxhall', 'Victoria', 'Wapping', 'Waterloo', 'Watfrod Junction', 'Wembley Central', 'Westminister',
		'Stratford',
		'Cockfosters',
		'Upminister',
		'East Ham',
		'Luton',
		'London City Airport',
		'Morden',
		'Wimbledon',
		'Ealing Broadway',
		'Edgware',
		'Emerson Park'
		 );

