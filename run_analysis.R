### ------------------------------------------------------
### Loading required packages

library(data.table)
library(dplyr)


### ------------------------------------------------------
### Downloading the dataset in the repository


### Name of the file
filename <- "GettingCleaningDataset.zip"

### Checking if file already exists in the repo and if not downloading the file
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  

### Checking if folder "UCI HAR Dataset" already exists in the repo and if not unzipping file
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


### ------------------------------------------------------
### Dataframes

### Creating a dataframe for each txt file
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("id","functions"))
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("id", "activity"))
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
xTest <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
yTest <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "id")
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
xTrain <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
yTrain <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "id")


### ------------------------------------------------------
### Merging data and creating one dataset

### Merging X files
xFilesData <- rbind(xTrain, xTest)

### Mergin Y files
yFilesData <- rbind(yTrain, yTest)

### Merging "Subject" files
subjectFilesData <- rbind(subjectTrain, subjectTest)

### Creating one dataset
mergedDataset <- cbind(subjectFilesData, yFilesData, xFilesData)


### ------------------------------------------------------
### Extracting measurements on the mean and standard deviation for each measurement

#extractData <- grep(".*Mean.*|.*Std.*", names(mergedDataset), ignore.case=TRUE)
extractData <- mergedDataset %>% select(subject, id, grep(".*Mean.*|.*Std.*", names(mergedDataset), ignore.case=TRUE))


### ------------------------------------------------------
### Replacing the variable "id" by the label of the activity in activityLabels

extractData$id <- activityLabels[extractData$id, 2]

### Renaming the variable name "id" by "activity"
extractData <- extractData %>% rename("activity" = "id")


### ------------------------------------------------------
### Renaming variables names according to the readme and features_info files

names(extractData)<-gsub("Acc", "Accelerometer", names(extractData))
names(extractData)<-gsub("Gyro", "Gyroscope", names(extractData))
names(extractData)<-gsub("BodyBody", "Body", names(extractData))
names(extractData)<-gsub("Mag", "Magnitude", names(extractData))
names(extractData)<-gsub("^t", "Time", names(extractData))
names(extractData)<-gsub("^f", "Frequency", names(extractData))
names(extractData)<-gsub("tBody", "TimeBody", names(extractData))
names(extractData)<-gsub("-mean()", "Mean", names(extractData), ignore.case = TRUE)
names(extractData)<-gsub("-std()", "STD", names(extractData), ignore.case = TRUE)
names(extractData)<-gsub("-freq()", "Frequency", names(extractData), ignore.case = TRUE)
names(extractData)<-gsub("angle", "Angle", names(extractData))
names(extractData)<-gsub("gravity", "Gravity", names(extractData))


### ------------------------------------------------------
### Creating final tidy dataset by grouping data by activity and calculating mean

### Grouping
groupedActivity <- extractData %>% group_by(subject, activity)

### Using dplyr summarise function to calculate mean on groups
tidyDataset <- groupedActivity %>% summarise(across(everything(), mean))


### ------------------------------------------------------
### Saving dataframe as a txt file

write.table(tidyDataset, "tidyDataset.txt", row.name=FALSE)
