---
title: "Run_analysis"
author: "Davvolio"
date: "Sunday, January 25, 2015"
output: html_document
---

Step zero: Installing dplyr package to manipulate data frames
```
install.packages("dplyr")
library(dplyr)
```


First step is reading data from files. The working directory contains folders with test and train data, and feature files:

```
url_variables <- "features.txt"
var_names <- read.table(url_variables,  stringsAsFactors=TRUE)

test_setY_url <- "./test/y_test.txt"
test_setX_url <- "./test/X_test.txt"
test_setSubj_url <- "./test/subject_test.txt"

test_setY <- read.table(test_setY_url,  stringsAsFactors=FALSE)
test_setX <- read.table(test_setX_url,  stringsAsFactors=FALSE)
test_setSubj <- read.table(test_setSubj_url,  stringsAsFactors=FALSE)

train_setY_url <- "./train/y_train.txt"
train_setX_url <- "./train/X_train.txt"
train_setSubj_url <- "./train/subject_train.txt"

train_setY <- read.table(train_setY_url,  stringsAsFactors=FALSE)
train_setX <- read.table(train_setX_url,  stringsAsFactors=FALSE)
train_setSubj <- read.table(train_setSubj_url,  stringsAsFactors=FALSE)
```

Here we bind the data by rows, making three data frames. Activities, Subjects and Measurements

```
completesetActivity<-rbind(test_setY,train_setY)
completeset<-rbind(test_setX,train_setX)
completesubjects<-rbind(test_setSubj,train_setSubj)
```

Using function grep,we choose all measurements with mean and std in description, as was told in course assignment. First vector contains number of position of measurement, we will use it to filter all 561 type of measurement. Second vector contains names of chosen measurements, we will use it later on step where we will label the data set with descriptive variable names.

As was written in assighment:
**Extracts only the measurements on the mean and standard deviation for each measurement**
So I decided to extract only measurements contains words *mean()* of *std()*. At the end, 66 variables was extracted.

```
mean_and_std_vector<-grep("mean\\(|std\\(", var_names[,2], value=F)
vector_names<-grep("mean\\(|std\\(", var_names[,2], value=TRUE)
```

Here we filter the set, leaving only 66 variables.

```
filteredset<-subset(completeset, select=mean_and_std_vector)
```

Here we read the activity_labels file, so we can join it to the measurements data frame. Also, we rename columns in Activity and Subject frames, so we can bind it without error.

```
activity_labels<-read.table("activity_labels.txt",  stringsAsFactors=FALSE)
activity_labels<-select(activity_labels, ActNum=V1, Activity=V2)
completesetActivity<-select(completesetActivity, ActNum=V1)
completesubjects<-select(completesubjects, Subjects=V1)
```

Here we bind together sets with activities, subjects and measurements

```
totalset<-cbind(completesetActivity,completesubjects,filteredset)
```

Here we merge activity labels to the set of all measurements and subject.
The merge function rearranges the rows, so to keep the row order, I've introduced the tempId column. After the merge, we order the frame by this column. After ordering we exclude this temporary column with the activity column (we have now the descriptive activity column, digital code of activity needed no more)

```
totalset$tempId <- 1:nrow(totalset)
rtotal<-merge(activity_labels,totalset,by="ActNum")
rtotal <- rtotal[order(rtotal$tempId),]
rtotal<-rtotal[,-1]
rtotal<-rtotal[,-69]
```

Here we using the vector of filtered col names, renaming them in our data frame. Since the name extracting two column was added (activity and subject), so we fist add them to vector of names, to avoid name shifting

```
Fullvectornames <-c("Activity","Subject",vector_names)
colnames(rtotal)<-Fullvectornames
```

Here we first group the data frame by subject and activity and then summarise each non-grouped column by mean function to get average of each variable for each activity and each subject

```
grouped_set<-group_by(rtotal, Subject, Activity)
summary_result<-summarise_each(grouped_set,funs(mean))
```

And at last! We write the txt file with clean data set, that contains 180 observations of 68 variables (Subject, Activity and 66 measurements)

```
write.table(summary_result, file="tidy_data.txt", row.names=FALSE) 
```