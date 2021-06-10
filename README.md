# NYC Youth Crime
ETL Project Report

> Created by Dale Currigan and Amin Ali  
> June 2021  
  
![ETL](/Resources/crime.jpg)    

## Table of contents  
* [Introduction](#Project-Intro)  
* [Motivation](#Motivation)  
* [Extract](#Extract)  
* [Transform](#Tranform)
* [Load](#Load)
* [Datasets](#Datasets)  
* [Project Structure](#Project-Structure)  
* [Setup](#Setup)
* [Contributors](#Contributors)  
* [Status](#Status)     

# Introduction
This project required demonstration of Extract, Transform, Load (ETL) processes on real world datasets. The following report outlines the results of our project work.  
  
Set-up details for the notebook and database can be found at the bottom of this document or via the link above    
  
    
# Motivation  
  
Reports of high rates of crime are ever present in the media today. We were particularly interested to what extend youth crime contributes to crime rates, and the factors associated with youth crime. We investigated crime datasets and came upon the <a href="https://www.kaggle.com/ajkarella/nyc-crime-stats">2006-2019 NYC Crime Dataset</a>, originally accessed from <a href="https://opendata.cityofnewyork.us/">New York Open Data</a>, and available in CSV format from Kaggle. Our motivations for using this dataset were:  
  
* Use the crime data from a well known, large urban city to model potential factors contributing to youth crime  
* It would allow analysis of demographic factors (e.g. race, location, gender) contributing to crime  
* CSV format allowing easy integration with Python Pandas  

The dataset itself is large (615MB CSV) and contains datapoints on every arrest in NYC bewtween 2006 and 2019. There are 19 columns in total, relating to demographic of offenders, locations of offence, type of offence and information relating to legal procedings. Not all of these would be required for the intended project, the transformation process would requite filtering and truncating the original dataset.  
  
To investigate this problem further we sought to see what influence educational factors might have on crime rates. The <a href="https://www.newyorkfed.org/data-and-statistics/data-visualization/nyc-school-spending">New York Federal Reserve Bank</a> provides data on school spending per student, which we accessed via a web scrape. Our motivations for utilising this data were:  
  
* Allow analysis of the influence of school spending on crime rates  
* Allow analysis of how school spending differs between NYC districts and if this affects the crime rate  

This dataset set contains a table of spending, on a per student basis, broken down by NYC district (or 'borough'). This would allow those using the data to analayse whether school spending in the different districts was correlated with higher crime rates or not. The data contains total school spending as well as spending on building services, leadership support services, and other key areas related to education.   

The Intention of the project was to create a database containing data on youth crime (definined as age <18yrs) in NYC, which would link to data for school spending in the NYC area. Such a database could potentially be used by organisations such as the NYPD, NYC Education department, as well as NGO’s to reduce crime and improve outcomes in communities.   
  
  

# Extract  
##### NYC Crime Dataset  

* The dataset was download from <a href="https://www.kaggle.com/ajkarella/nyc-crime-stats">Kaggle</a> in csv format and extracted into a Jupyter Notebook using the Pandas read_csv function.   
  
##### New York Federal Reserve Bank   

* A web scrape was used to access the values from the interactive table of available on the <a href=https://www.newyorkfed.org/data-and-statistics/data-visualization/nyc-school-spending>NY Federal Reserve Website</a>.  
* As the table is initially not visible when the page loads, and requires the user to click on an interactive tab, Splinter library was used
* This was initiated and used to click on the 'Comparative View' data tab to access for the table   
* Beautiful soup was used to scrape the data and the html collected was then passed to Pandas read_html function to convert to a useable form
* Sample code and images of the NY Federal Reserve data source

```
# Visit the New York Federal Reserve and click on 'COMPARATIVE VIEW' tab 
url = "https://www.newyorkfed.org/data-and-statistics/data-visualization/nyc-school-spending"
browser.visit(url)
browser.links.find_by_partial_text('Comparative view').click()

# Scrape the data
html = browser.html
soup = bs(html, 'html.parser')

# Access the div with the interactive table 
results = soup.find('div', {'id' : 'interactive-table'})

# Convert the html to table with Pandas read_html
schools_data = pd.read_html(str(results))

```  
  
![ETL](/Resources/ny_fed.png)    
  
  
# Transform  
##### NYC Crime Dataset  
* Firstly the relevant columns were selected from the larger total dataframe  
* The following columns were chosen, as well as a rationale for their selection:  
  - **arrest_key**: Unique to each entry. Can act as a primary key  
  - **arrest_date**: Allows for temporal analysis  
  - **ofns_desc**: The type of offence. Allows for subgroup analysis by offence types   
  - **age_group**: Required to filter to age <18y.o. Once data is filtered this column is dropped as is redundant (the data doesn't differentiate ages further below age 18)  
  - **perp_sex**: Allows for analysis by demographic variable of gender  
  - **perp_race**: Allows for analysis by demographic variable of ethnicity  
  - **arrest_boro**: Which of the 5 main NYC districs (or boroughs) the arrest occurs. Allows for geospatial analysis  
  - **arrest_precict**: Would allow for more precise geospacial analysis based on the location of each precinct   
  
* Columns not thought to be relevant to the subject matter (i.e. an analysis of factors affecting youth crime) were excluded (for example, latitude, longitude, law code, offense sub-category).  
* The dataframe was then filtered to keep only those offenders aged <18y.o., and the age column removed from the final table  
  
##### New York Federal Reserve Bank  
* The schools data was first converted to a data frame  
* Column titles required re-naming  
* Columns containing NaN values were present in the HTML converted table and these were removed with Pandas dropna function  
* As the NYC Crime was only divided into the 5 Boroughs, not 31 districts, the summarised data for each Borough had to be selected for the table   
* Finally, as a different naming system was used for the Boroughs between datasets this had to be updated to allow future users of the database to perform joins when querying  the database  

  
# Load    
A new database was created (youth_crime_db) in PostpreSQL and table schemata defined for crime_table and school_table.
The entity relationship diagrom for the database can be seen below. 
Both tables have primary keys (arrest_key for crime_table, nyc_district for school_table). Crime table also has a foreign key (arrest_boro), which references the 'nyc_district' column in the schools_table

![ETL](/Resources/ERD.jpg) 

SQL was chosen as the data was in a relational structure which lends itself well to SQL, as well as making it easy to access and query the dataset in the future.  

Python SQLAlchemy was used to load the data into the database  
* A connection was established to the database with the create_engine function.   
* Each table was sequentially loaded into the database with the to_sql function.   

# Datasets 

|No|Source|Link|
|-|-|-|
|1|2006-2019 NYC Crime Dataset                |https://www.kaggle.com/ajkarella/nyc-crime-stats| 
|2|New York Federal Reserve - School Spending |https://www.newyorkfed.org/data-and-statistics/data-visualization/nyc-school-spending|
  


# Project Structure  
```
ETL-Project   
|  
|    
|__ NY Crime.ipynb                        # Jupyter Notebook for the project
|__ schema.sql                            # Table schemata for the database 
|__ README.md                             # This file, the project report
|
|__ Resources/                            # Directory for images contained in the report   
|   |__ crime.jpg                    
|   |__ ERD.png 
|   |__ 
|
|    

``` 
  
# Setup 
  
* Step 1  
* Step 2   
* Step 3  
  
* Step 4 
* Step 5    



# Contributors  
- Dale Currigan [@dcurrigan](https://github.com/dcurrigan) - <dcurrigan@gmail.com>
- Amin Ali 


## Status
Project is: 
````diff 
+ Completed
````
