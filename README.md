# ------------------------------------------------------
# Peer graded assignment - Getting and Cleaning Data Course - John Hopkins University
# Sébastien Brevet - 2021 - Course from coursera.org
# ------------------------------------------------------

This assignment is from the Getting and Cleaning Data course from JH University and followed online on coursera.org website.

This document explains how the script run_analysis.R is constructed and what transformations were done to the initial data to get the final tidyDataset.txt file.

The reviewing criteria of this assignment were:
1- Create a tidy data set as described in the assignment 
2- Share a link to a Github repository with your script for performing the analysis 
3- Add a code book and a readme file that describes the variables, the data, and any transformations or work that you performed to clean up the data

Therefore, there are 4 files in this project:
run_analysis.R - The main script of the project where the data is transformed
README.md - The file you are currently reading
CodeBook.md - The file which explains what are the variables of the data
tidyDataset.txt - The final tidied dataset of 180 observations and 88 variables

## ------------------------------------------------------
## Initial data
## ------------------------------------------------------

The data linked to the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The data for the project was here:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  

## ------------------------------------------------------
## Instructions to transform the data
## ------------------------------------------------------

1- Merges the training and the test sets to create one data set.
2- Extracts only the measurements on the mean and standard deviation for each measurement. 
3- Uses descriptive activity names to name the activities in the data set.
4- Appropriately labels the data set with descriptive variable names. 
5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## ------------------------------------------------------
## Packages needed (loaded in the run_analysis.R script)
## ------------------------------------------------------

data.table
dplyr

## ------------------------------------------------------
## Data transformations scripted in run_analysis.R
## ------------------------------------------------------

### ------------------------------------------------------
### 0- Data preparation
### ------------------------------------------------------

Here the packages are loaded, the data is downloaded into the filename GettingCleaningDataset.zip and then the file is unzipped

```
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

```

Then the dataframes are created

```
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

```
### ------------------------------------------------------
### 1- Merges the training and the test sets to create one data set
### ------------------------------------------------------

In the next steps, the test and train dataframes are merged

```
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
```

### ------------------------------------------------------
### 2- Extracts only the measurements on the mean and standard deviation for each measurement
### ------------------------------------------------------

The next lines show how the data containing measurements of mean and standard deviation is extracted. Also, at the end, the "id" column is renamed as "activity" for clarity

```
### ------------------------------------------------------
### Extracting measurements on the mean and standard deviation for each measurement

#extractData <- grep(".*Mean.*|.*Std.*", names(mergedDataset), ignore.case=TRUE)
extractData <- mergedDataset %>% select(subject, id, grep(".*Mean.*|.*Std.*", names(mergedDataset), ignore.case=TRUE))

```

### ------------------------------------------------------
### 3- Uses descriptive activity names to name the activities in the data set
### ------------------------------------------------------

Here we associate the activity labels we have in activity_labels.txt with the observations

```
### ------------------------------------------------------
### Replacing the variable "id" by the label of the activity in activityLabels

extractData$id <- activityLabels[extractData$id, 2]

### Renaming the variable name "id" by "activity"
extractData <- extractData %>% rename("activity" = "id")
```

### ------------------------------------------------------
### 4- Appropriately labels the data set with descriptive variable names
### ------------------------------------------------------

Below we substitute some parts of the variables names with names found in the readme and features_info files of the project (included in the zip file). This allows us to have more descriptive column names.

```
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
```

### ------------------------------------------------------
### 5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
### ------------------------------------------------------

The last transformation groups the data by activity and subject and calculate the mean for each group

```
### ------------------------------------------------------
### Creating final tidy dataset by grouping data by activity and calculating mean

### Grouping
groupedActivity <- extractData %>% group_by(subject, activity)

### Using dplyr summarise function to calculate mean on groups
tidyDataset <- groupedActivity %>% summarise(across(everything(), mean))
```

### ------------------------------------------------------
### Finally
### ------------------------------------------------------

At last, we create the tidyDataset.txt file

```
### ------------------------------------------------------
### Saving dataframe as a txt file

write.table(tidyDataset, "tidyDataset.txt", row.name=FALSE)
```

Thanks for reading.

