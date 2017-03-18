run_analysis
============



Instructions for project
------------------------

> The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  
> 
> One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
> 
> http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
> 
> Here are the data for the project: 
> 
> https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
> 
> You should create one R script called run_analysis.R that does the following. 
> 
> 1.Merges the training and the test sets to create one data set.
> 2.Extracts only the measurements on the mean and standard deviation for each measurement.
> 3.Uses descriptive activity names to name the activities in the data set.
> 4.Appropriately labels the data set with descriptive activity names.
> 5.Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
> 
> Good luck!

**The codebook is at the end of this document.**


Preliminaries
-------------

Load packages.


```r
library("data.table")
library("reshape2")
library("RCurl")
library("tidyr")
```



Set path.


```r
path <- getwd()
path
```

```
setwd("C:/Users/wutong/Documents/GitHub/GettingAndCleaningData_Cousera/Project")
path <- as.character(getwd())
```



Get the data
------------

Download the file. Put it in the `Project` folder. 


```r
url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "Dataset.zip"
if(!file.exists(path)){
  dir.create(path)
}
if(!file.exists(f)){
  download.file(url, file.path(path, f))
}
```


Unzip the file. 


```r
executable  <- file.path("C:","Program Files", "7-Zip", "7z.exe")
parameters <- "x"
cmd <- paste(paste0("\"", executable, "\""), parameters, paste0("\"", file.path(path, f), "\""))
system(cmd)
path_data <- file.path(path, "UCI HAR Dataset")
if(!file.exists(path_data)){
  dir.create(path_data)
}
```




Read the files
--------------

Read the subject files.



```r
dtSubjectTrain <- fread(file.path(path_data, "train", "subject_train.txt"))
dtSubjectTest <- fread(file.path(path_data, "test", "subject_test.txt"))
```


Read the activity files. 


```r
dtActivityTrain <- fread(file.path(path_data, "train", "Y_train.txt"))
dtActivityTest <- fread(file.path(path_data, "test", "Y_test.txt"))
```
The archive put the files in a folder named `UCI HAR Dataset`. Set this folder as the data path. 


```r
path_data <- file.path(path, "UCI HAR Dataset")
if(!file.exists(path_data)){
  dir.create(path_data)
}
```

The input data(x data) in format "ANSI",can't read by "fread"


```r
fileToDataTable <- function(f) {
  df <- read.table(f)
  dt <- data.table(df)
}
dtTrain <- fileToDataTable(file.path(path_data, "train", "X_train.txt"))
dtTest <- fileToDataTable(file.path(path_data, "test", "X_test.txt"))
```



Merge the training and the test sets
------------------------------------

Concatenate the data tables.


```r
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)
```



Set key.


```r
setkey(dt, subject, activityNum)
```



Extract only the mean and standard deviation
--------------------------------------------

Read the `features.txt` file. This tells which variables in `dt` are measurements for the mean and standard deviation.


```r
dtFeatures <- fread(file.path(path_data, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
```


Subset only measurements for the mean and standard deviation.


```r
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
```


Convert the column numbers to a vector of variable names matching columns in `dt`.


```r
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
head(dtFeatures)
```



```
##  [1] "V1"   "V2"   "V3"   "V4"   "V5"   "V6"   "V41"  "V42"  "V43"  "V44" 
## [11] "V45"  "V46"  "V81"  "V82"  "V83"  "V84"  "V85"  "V86"  "V121" "V122"
## [21] "V123" "V124" "V125" "V126" "V161" "V162" "V163" "V164" "V165" "V166"
## [31] "V201" "V202" "V214" "V215" "V227" "V228" "V240" "V241" "V253" "V254"
## [41] "V266" "V267" "V268" "V269" "V270" "V271" "V345" "V346" "V347" "V348"
## [51] "V349" "V350" "V424" "V425" "V426" "V427" "V428" "V429" "V503" "V504"
## [61] "V516" "V517" "V529" "V530" "V542" "V543"
```


Subset these variables using variable names.


```r
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with = FALSE]
```



Use descriptive activity names
------------------------------

Read `activity_labels.txt` file. This will be used to add descriptive names to the activities.


```r
dtActivityNames <- fread(file.path(path_data, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
```



Label with descriptive activity names
-----------------------------------------------------------------

Merge activity labels.


```r
dt <- merge(dt, dtActivityNames, by = "activityNum", all.x = TRUE)
```


Add `activityName` as a key.


```r
setkey(dt, subject, activityNum, activityName)
```


Melt the data table to reshape it from a short and wide format to a tall and narrow format.


```r
dt <- data.table(melt(dt, key(dt), variable.name = "featureCode"))
```


Merge activity name.


```r
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by = "featureCode", 
    all.x = TRUE)
```


Create a new variable, `activity` that is equivalent to `activityName` as a factor class.
Create a new variable, `feature` that is equivalent to `featureName` as a factor class.


```r
dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)
```


Seperate features from `featureName` using the helper function `grepthis`.


```r
separate()
greprows <- function(regex) {
  grepl(regex, dt$feature)
}
n <- 2
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(greprows("^t"), greprows("^f")), ncol = nrow(y))
dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
x <- matrix(c(greprows("Acc"), greprows("Gyro")), ncol = nrow(y))
dt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
x <- matrix(c(greprows("BodyAcc"), greprows("GravityAcc")), ncol = nrow(y))
dt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
x <- matrix(c(greprows("mean()"), greprows("std()")), ncol = nrow(y))
dt$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))
## Features with 1 category
dt$featJerk <- factor(greprows("Jerk"), labels = c(NA, "Jerk"))
dt$featMagnitude <- factor(greprows("Mag"), labels = c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1,5,by =2), nrow = n)
x <- matrix(c(greprows("-X"), greprows("-Y"), greprows("-Z")), ncol = nrow(y))
dt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))
#compare the row number to check all feature has been counted
row_check1 <- nrow(dt[, .N, by = c("feature")])
row_check2 <- nrow(dt[, .N, by = c("featDomain", "featAcceleration", "featInstrument", "featJerk", "featMagnitude", "featVariable", "featAxis")])

```


Check to make sure all possible combinations of `feature` are accounted for by all possible combinations of the factor class variables.


```r
r1 <- nrow(dt[, .N, by = c("feature")])
r2 <- nrow(dt[, .N, by = c("featDomain", "featAcceleration", "featInstrument", 
    "featJerk", "featMagnitude", "featVariable", "featAxis")])
r1 == r2
```

```
## [1] TRUE
```


Yes, I accounted for all possible combinations. `feature` is now redundant.



Create a tidy data set
----------------------

Create a data set with the average of each variable for each activity and each subject.


```r
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by = key(dt)]
#write to a file
write.table(dtTidy,"tidy_data.txt")
```

####**Done**


