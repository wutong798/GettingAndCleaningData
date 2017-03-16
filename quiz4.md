Week 4 Quiz
===========

The due date for this quiz is Sun 4 May 2014 4:30 PM PDT.

Load packages.


```r
packages <- c("data.table", "quantmod")
sapply(packages, require, character.only = TRUE, quietly = TRUE)
```

```
## Warning: package 'quantmod' was built under R version 3.0.3
```

```
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
## 
## 
## Attaching package: 'xts'
## 
## The following object is masked from 'package:data.table':
## 
##     last
```

```
## Warning: package 'TTR' was built under R version 3.0.3
```

```
## Version 0.4-0 included new data defaults. See ?getSymbols.
```

```
## data.table   quantmod 
##       TRUE       TRUE
```


Fix URL reading for knitr. See [Stackoverflow](http://stackoverflow.com/a/20003380).


```r
setInternet2(TRUE)
```



Question 1
----------
The American Community Survey distributes downloadable data about United States communities. Download the 2006 microdata survey about housing for the state of Idaho using download.file() from here: 

https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv 

and load the data into R. The code book, describing the variable names is here: 

https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf 

Apply strsplit() to split all the names of the data frame on the characters "wgtp". What is the value of the 123 element of the resulting list?


```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
f <- file.path(getwd(), "ss06hid.csv")
download.file(url, f)
dt <- data.table(read.csv(f))
varNames <- names(dt)
varNamesSplit <- strsplit(varNames, "wgtp")
varNamesSplit[[123]]
```

```
## [1] ""   "15"
```



Question 2
----------
Load the Gross Domestic Product data for the 190 ranked countries in this data set: 

https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv 

Remove the commas from the GDP numbers in millions of dollars and average them. What is the average? 

Original data sources: http://data.worldbank.org/data-catalog/GDP-ranking-table


```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
f <- file.path(getwd(), "GDP.csv")
download.file(url, f)
dtGDP <- data.table(read.csv(f, skip = 4, nrows = 215, stringsAsFactors = FALSE))
dtGDP <- dtGDP[X != ""]
dtGDP <- dtGDP[, list(X, X.1, X.3, X.4)]
setnames(dtGDP, c("X", "X.1", "X.3", "X.4"), c("CountryCode", "rankingGDP", 
    "Long.Name", "gdp"))
gdp <- as.numeric(gsub(",", "", dtGDP$gdp))
```

```
## Warning: NAs introduced by coercion
```

```r
mean(gdp, na.rm = TRUE)
```

```
## [1] 377652
```



Question 3
----------
In the data set from Question 2 what is a regular expression that would allow you to count the number of countries whose name begins with "United"? Assume that the variable with the country names in it is named countryNames. How many countries begin with United?


```r
isUnited <- grepl("^United", dtGDP$Long.Name)
summary(isUnited)
```

```
##    Mode   FALSE    TRUE    NA's 
## logical     211       3       0
```



Question 4
----------
Load the Gross Domestic Product data for the 190 ranked countries in this data set: 

https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv 

Load the educational data from this data set: 

https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv 

Match the data based on the country shortcode. Of the countries for which the end of the fiscal year is available, how many end in June? 

Original data sources: 
http://data.worldbank.org/data-catalog/GDP-ranking-table 
http://data.worldbank.org/data-catalog/ed-stats


```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
f <- file.path(getwd(), "EDSTATS_Country.csv")
download.file(url, f)
dtEd <- data.table(read.csv(f))
dt <- merge(dtGDP, dtEd, all = TRUE, by = c("CountryCode"))
isFiscalYearEnd <- grepl("fiscal year end", tolower(dt$Special.Notes))
isJune <- grepl("june", tolower(dt$Special.Notes))
table(isFiscalYearEnd, isJune)
```

```
##                isJune
## isFiscalYearEnd FALSE TRUE
##           FALSE   203    3
##           TRUE     19   13
```

```r
dt[isFiscalYearEnd & isJune, Special.Notes]
```

```
##  [1] Fiscal year end: June 30; reporting period for national accounts data: FY.
##  [2] Fiscal year end: June 30; reporting period for national accounts data: FY.
##  [3] Fiscal year end: June 30; reporting period for national accounts data: FY.
##  [4] Fiscal year end: June 30; reporting period for national accounts data: FY.
##  [5] Fiscal year end: June 30; reporting period for national accounts data: CY.
##  [6] Fiscal year end: June 30; reporting period for national accounts data: CY.
##  [7] Fiscal year end: June 30; reporting period for national accounts data: CY.
##  [8] Fiscal year end: June 30; reporting period for national accounts data: FY.
##  [9] Fiscal year end: June 30; reporting period for national accounts data: FY.
## [10] Fiscal year end: June 30; reporting period for national accounts data: CY.
## [11] Fiscal year end: June 30; reporting period for national accounts data: CY.
## [12] Fiscal year end: June 30; reporting period for national accounts data: FY.
## [13] Fiscal year end: June 30; reporting period for national accounts data: CY.
## 70 Levels:  ...
```



Question 5
----------
You can use the quantmod (http://www.quantmod.com/) package to get historical stock prices for publicly traded companies on the NASDAQ and NYSE. Use the following code to download data on Amazon's stock price and get the times the data was sampled.

> library(quantmod)
> amzn = getSymbols("AMZN",auto.assign=FALSE)
> sampleTimes = index(amzn) 

How many values were collected in 2012? How many values were collected on Mondays in 2012?


```r
amzn <- getSymbols("AMZN", auto.assign = FALSE)
```

```
##     As of 0.4-0, 'getSymbols' uses env=parent.frame() and
##  auto.assign=TRUE by default.
## 
##  This  behavior  will be  phased out in 0.5-0  when the call  will
##  default to use auto.assign=FALSE. getOption("getSymbols.env") and 
##  getOptions("getSymbols.auto.assign") are now checked for alternate defaults
## 
##  This message is shown once per session and may be disabled by setting 
##  options("getSymbols.warning4.0"=FALSE). See ?getSymbol for more details
```

```
## Warning: downloaded length 96069 != reported length 200
```

```r
sampleTimes <- index(amzn)
addmargins(table(year(sampleTimes), weekdays(sampleTimes)))
```

```
##       
##        Friday Monday Thursday Tuesday Wednesday  Sum
##   2007     51     48       51      50        51  251
##   2008     50     48       50      52        53  253
##   2009     49     48       51      52        52  252
##   2010     50     47       51      52        52  252
##   2011     51     46       51      52        52  252
##   2012     51     47       51      50        51  250
##   2013     51     48       50      52        51  252
##   2014     15     14       16      16        16   77
##   Sum     368    346      371     376       378 1839
```

