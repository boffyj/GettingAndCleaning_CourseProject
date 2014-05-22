#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive activity names. 
#5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


#Subject: Combine test/train
subTest = read.table("./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/subject_test.txt")
subTrain = read.table("./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/subject_train.txt")
subject = data.frame(idx=c(subTest$V1,subTrain$V1))


#labels: walking etc. Combine test/train and substitute numerics with descriptive labels.
activityLabels = read.table("./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/activity_labels.txt")
yTest = read.table("./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/y_test.txt")
yTrain = read.table("./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/y_train.txt")
y = rbind(yTest,yTrain)
y = merge(y,activityLabels,by = intersect("V1","V1"),sort=F)


#function headers: we only want to import x data relating to mean and std. Clean headers.
features = read.table("./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/features.txt")
featuresIdx = grep("mean|std",features$V2)
featuresHead = features$V2[featuresIdx]
featuresHead = gsub("-","_",featuresHead)
featuresHead = gsub("\\(\\)","",featuresHead)

#Read in x data, trim unwanted feature columns, rbind together, 
xTest = read.table("./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/x_test.txt",colClasses = "numeric")
xTrain = read.table("./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/x_train.txt",colClasses = "numeric")
xTest = xTest[,featuresIdx]
xTrain = xTrain[,featuresIdx]
x = rbind(xTest,xTrain)

#x to become our [first] tidy data set
names(x) = featuresHead
x$subject = subject$idx
x$activity = y$V2

#Create a second, independent tidy data set with the average of each variable for each activity and each subject.

#make subject a factor
x$subject = factor(x$subject)

require(reshape2)
xmelt = melt(x, id=c("subject","activity"))
xcast = dcast(xmelt,subject+activity~variable,mean)

#write to comma-separated text file
write.table(xcast,file="SmartphoneTidy.txt",sep=",")

