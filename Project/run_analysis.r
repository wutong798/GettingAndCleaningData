## Preliminaries ##
###################
#Load packages
library("data.table")
library("reshape2")
library("RCurl")
library(tidyr)
#Set Path
setwd("C:/Users/wutong/Documents/GitHub/GettingAndCleaningData_Cousera/Project")
path <- as.character(getwd())


##Get the data ##
#################
#Download the file, and put it in the "data" folder
url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "Dataset.zip"
if(!file.exists(path)){
  dir.create(path)
}
if(!file.exists(f)){
  download.file(url, file.path(path, f))
}
#Unzip the file
executable  <- file.path("C:","Program Files", "7-Zip", "7z.exe")
parameters <- "x"
cmd <- paste(paste0("\"", executable, "\""), parameters, paste0("\"", file.path(path, f), "\""))
system(cmd)
path_data <- file.path(path, "UCI HAR Dataset")
if(!file.exists(path_data)){
  dir.create(path_data)
}


##Read the files##
##################
dtSubjectTrain <- fread(file.path(path_data, "train", "subject_train.txt"))
dtSubjectTest <- fread(file.path(path_data, "test", "subject_test.txt"))
dtActivityTrain <- fread(file.path(path_data, "train", "Y_train.txt"))
dtActivityTest <- fread(file.path(path_data, "test", "Y_test.txt"))
#The input data(x data) in format "ANSI",can't read by "fread"
#Use data table to read the file
fileToDataTable <- function(f) {
  df <- read.table(f)
  dt <- data.table(df)
}
dtTrain <- fileToDataTable(file.path(path_data, "train", "X_train.txt"))
dtTest <- fileToDataTable(file.path(path_data, "test", "X_test.txt"))


##Merge the training and testing data##
#######################################
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)
#set key for the subject
setkey(dt, subject, activityNum)


##Extract only the mean and standard deviation##
################################################
#read the feature.txt, this tell which variables in dt are measurements for the mean and standard deviation
dtFeatures <- fread(file.path(path_data, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
#select measurements for the mean and standard deviation
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
#Transfer the featureNum to the FeatureCode
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
#Subset these variables using variable names
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with = FALSE]


##Use descriptive activity names##
##################################
dtActivityNames <- fread(file.path(path_data, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))


##Label with descriptive activity names##
dt <- merge(dt, dtActivityNames, by = "activityNum", all.x = TRUE)
setkey(dt, subject, activityNum, activityName)
dt <- data.table(melt(dt, key(dt), variable.name = "featureCode"))
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by = "featureCode", all.x = TRUE)


dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)

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

##Create a tidy set##
#####################
#create a dataset with the average of each variable for each activity and subject
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by = key(dt)]
#write to a file
write.table(dtTidy,"tidy_data.txt")


