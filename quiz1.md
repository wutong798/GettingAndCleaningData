Week 1 Quiz
===========

The due date for this quiz is Sun 13 Apr 2014 4:30 PM PDT.

Load packages.


```r
packages <- c("data.table", "xlsx", "XML")
sapply(packages, require, character.only = TRUE, quietly = TRUE)
```

```
## data.table       xlsx        XML 
##       TRUE       TRUE       TRUE
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

How many housing units in this survey were worth more than $1,000,000?


```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf"
f <- file.path(getwd(), "PUMSDataDict06.pdf")
download.file(url, f, mode = "wb")
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
f <- file.path(getwd(), "ss06hid.csv")
download.file(url, f)
dt <- data.table(read.csv(f))
setkey(dt, VAL)
dt[, .N, key(dt)]
```

```
##     VAL    N
##  1:  NA 2076
##  2:   1   75
##  3:   2   42
##  4:   3   33
##  5:   4   30
##  6:   5   26
##  7:   6   29
##  8:   7   23
##  9:   8   70
## 10:   9   99
## 11:  10  119
## 12:  11  152
## 13:  12  199
## 14:  13  233
## 15:  14  495
## 16:  15  483
## 17:  16  486
## 18:  17  357
## 19:  18  502
## 20:  19  232
## 21:  20  312
## 22:  21  164
## 23:  22  159
## 24:  23   47
## 25:  24   53
##     VAL    N
```



Question 2
----------
Use the data you loaded from Question 1. Consider the variable FES in the code book. Which of the "tidy data" principles does this variable violate?


```r
setkey(dt, FES)
dt[, .N, key(dt)]
```

```
##    FES    N
## 1:  NA 2445
## 2:   1 1730
## 3:   2  826
## 4:   3  236
## 5:   4  638
## 6:   5  151
## 7:   6   40
## 8:   7  305
## 9:   8  125
```



Question 3
----------
Download the Excel spreadsheet on Natural Gas Aquisition Program here: 

https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx

Read rows 18-23 and columns 7-15 into R and assign the result to a variable called:

`dat`

What is the value of:

`sum(dat$Zip*dat$Ext,na.rm=T)`

(original data source: http://catalog.data.gov/dataset/natural-gas-acquisition-program)


```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx"
f <- file.path(getwd(), "DATA.gov_NGAP.xlsx")
download.file(url, f, mode = "wb")
rows <- 18:23
cols <- 7:15
dat <- read.xlsx(f, 1, colIndex = cols, rowIndex = rows)
sum(dat$Zip * dat$Ext, na.rm = T)
```

```
## [1] 36534720
```



Question 4
----------
Read the XML data on Baltimore restaurants from here: 

https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml

How many restaurants have zipcode 21231?

Use `http` instead of `https`, which caused the message *Error: XML content does not seem to be XML: 'https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml'*.


```r
url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
doc <- xmlInternalTreeParse(url)
rootNode <- xmlRoot(doc)
names(rootNode)
```

```
##   row 
## "row"
```

```r
# names(rootNode[[1]])
names(rootNode[[1]][[1]])
```

```
##              name           zipcode      neighborhood   councildistrict 
##            "name"         "zipcode"    "neighborhood" "councildistrict" 
##    policedistrict        location_1 
##  "policedistrict"      "location_1"
```

```r
zipcode <- xpathSApply(rootNode, "//zipcode", xmlValue)
table(zipcode == 21231)
```

```
## 
## FALSE  TRUE 
##  1200   127
```



Question 5
----------
The American Community Survey distributes downloadable data about United States communities. Download the 2006 microdata survey about housing for the state of Idaho using download.file() from here: 

https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv 

using the `fread()` command load the data into an R object

`DT` 

Which of the following is the fastest way to calculate the average value of the variable

`pwgtp15`

broken down by sex using the `data.table` package?


```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
f <- file.path(getwd(), "ss06pid.csv")
download.file(url, f)
DT <- fread(f)
check <- function(y, t) {
    message(sprintf("Elapsed time: %.10f", t[3]))
    print(y)
}
t <- system.time(y <- sapply(split(DT$pwgtp15, DT$SEX), mean))
check(y, t)
```

```
## Elapsed time: 0.0000000000
```

```
##     1     2 
## 99.81 96.67
```

```r
t <- system.time(y <- mean(DT$pwgtp15, by = DT$SEX))
check(y, t)
```

```
## Elapsed time: 0.0000000000
```

```
## [1] 98.22
```

```r
t <- system.time(y <- DT[, mean(pwgtp15), by = SEX])
check(y, t)
```

```
## Elapsed time: 0.0000000000
```

```
##    SEX    V1
## 1:   1 99.81
## 2:   2 96.67
```

```r
t <- system.time(y <- rowMeans(DT)[DT$SEX == 1]) + system.time(rowMeans(DT)[DT$SEX == 
    2])
```

```
## Error: 'x' must be numeric
```

```
## Timing stopped at: 1.76 0 1.76
```

```r
check(y, t)
```

```
## Elapsed time: 0.0000000000
```

```
##    SEX    V1
## 1:   1 99.81
## 2:   2 96.67
```

```r
t <- system.time(y <- mean(DT[DT$SEX == 1, ]$pwgtp15)) + system.time(mean(DT[DT$SEX == 
    2, ]$pwgtp15))
check(y, t)
```

```
## Elapsed time: 0.0400000000
```

```
## [1] 99.81
```

```r
t <- system.time(y <- tapply(DT$pwgtp15, DT$SEX, mean))
check(y, t)
```

```
## Elapsed time: 0.0200000000
```

```
##     1     2 
## 99.81 96.67
```

