# Summary - 14/15

# Description
The goal of the task is to create a shell script for the analysis of records of persons with proven infection with the coronavirus causing the disease COVID-19 in the territory of the Czech Republic. The script will filter records and provide basic statistics based on user input.

## USE

corona [-h] [FILTERS] [COMMAND] [LOG [LOG2 [...]]

## Choices

COMMAND může být jeden z: <br />
- infected — counts the number of infected <br />
- merge — merges several files with records into one, preserving the original order (the header will be output only once). <br />
- gender — lists the number of infected for each gender. <br />
- age — lists the statistics of the number of infected persons by age (a more detailed description is below). <br />
- daily — lists the statistics of infected persons for individual days. <br />
- monthly — lists the statistics of infected persons for individual months. <br />
- yearly — lists the statistics of infected persons for individual years. <br />
- countries — lists the statistics of infected persons for individual countries of infection (without the Czech Republic, i.e. code CZ). <br />
- districts — lists the statistics of infected persons for individual districts. <br />
- regions — lists the statistics of infected persons for individual regions. <br />
- FILTERS can be a combination of the following (each at most once): <br />
  -a DATETIME — after: only records AFTER this date (including this date) are considered. DATETIME is in YYYY-MM-DD format. <br />
-b DATETIME — before: only records BEFORE this date (including this date) are considered. <br />
-g GENDER — only records of infected persons of the given gender are considered. GENDER can be M (male) or Z (female). <br />
-s [WIDTH] for the commands gender, age, daily, monthly, yearly, countries, districts and regions displays the data not numerically, but graphically in the form of histograms. The optional WIDTH parameter sets the width of the histograms, i.e. the length of the longest row, to WIDTH. Thus, WIDTH must be a positive integer. If the WIDTH parameter is not specified, the line widths are governed by the requirements listed below. <br />
(optional) -d DISTRICT_FILE — for the districts command, instead of LAU 1 of the district code, print its name. The mapping of codes to names is in the file DISTRICT_FILE <br />
(optional) -r REGIONS_FILE — for the regions command, instead of the NUTS 3 region code, it prints its name. The mapping of codes to names is in the file REGIONS_FILE <br />
- h — print help with a short description of each command and switch. <br />
