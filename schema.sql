-- Create the schools table -- 
CREATE TABLE schools_table(
	nyc_district VARCHAR(1) NOT NULL,
	school_spending FLOAT NOT NULL,
	instructional_spending FLOAT NOT NULL,
	instructional_support_services FLOAT NOT NULL,
	leadership_support_services FLOAT NOT NULL,
	ancillary_support_services FLOAT NOT NULL,
	building_services FLOAT NOT NULL,
	
	PRIMARY KEY (nyc_district)
);
	
-- Create the crime table -- 
CREATE TABLE crime_table(
	arrest_key INT NOT NULL, 
	arrest_date VARCHAR(30) NOT NULL,
	ofns_desc VARCHAR(200) NOT NULL,
	age_group VARCHAR(10),
	perp_sex VARCHAR(1),
	perp_race VARCHAR(30),
	arrest_boro VARCHAR(1) NOT NULL,
	arrest_precinct INT,
	
	PRIMARY KEY (arrest_key),
	FOREIGN KEY (arrest_boro) 
	REFERENCES schools_table(nyc_district)
);
	


	
	
	
	
	
	
	
	


