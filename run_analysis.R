#import necessary libraries
library(data.table)
library(reshape2)

# Download and unzip the dataset
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "getdataFiles.zip"))
unzip(zipfile = "getdataFiles.zip")

# Load activity labels + features
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))

# Extracts only the measurements on the mean and standard deviation for each measurement.
featuresWanted <- grep(".*mean.*|.*std.*", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[-()]', '', measurements)

# Load training datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
# Load test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]

setnames(train, colnames(train), measurements)
setnames(test, colnames(test), measurements)

trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))

trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))

# Merges the training and the test sets to create one data set.
train <- cbind(trainSubjects, trainActivities, train)
test <- cbind(testSubjects, testActivities, test)
final <- rbind(train, test)

# Appropriately labels the data set with descriptive variable names.
final[["Activity"]] <- factor(final[, Activity], levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])

#Converts activities and subjects to factors
final[["SubjectNum"]] <- as.factor(final[, SubjectNum])
final <- melt(data = final, id = c("SubjectNum", "Activity"))
final <- dcast(data = final, SubjectNum + Activity ~ variable, fun.aggregate = mean)

fwrite(x = final, file = "tidyData.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)
