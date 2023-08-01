##WRDS DATABASE##

##To clear the existing environment###
rm(list=ls())
##to make the result similar while running many times##
set.seed(123)

##Installing WRDS package##
library(RPostgres)
wrds <- dbConnect(Postgres(),
                  host='wrds-pgdata.wharton.upenn.edu',
                  port=9737,
                  dbname='wrds',
                  sslmode='require',
                  user='razasohailalig')
###Extracting data files names from the wrds####
res <- dbSendQuery(wrds, "select distinct table_schema
                   from information_schema.tables
                   where table_type ='VIEW'
                   or table_type ='FOREIGN TABLE'
                   order by table_schema")
dataset_WRDS <- dbFetch(res, n=-1)
dbClearResult(res)
dataset_WRDS


##Find the variables (column headers) within a given dataset##
res <- dbSendQuery(wrds, "select column_name
                   from information_schema.columns
                   where table_schema='comp'
                   and table_name='dsf'
                   order by column_name")
data <- dbFetch(res, n=-1)
dbClearResult(res)
data

##A bit efficient query from crsp.dsf##
res1 <- dbSendQuery(wrds, "select cusip,permno,date,bidlo,askhi,prc
                   from crsp.dsf
                   where date between '2000-01-01'
                   and '2002-01-01'
                   and prc >= 1")
data_CRSP_DSF <- dbFetch(res1, n=-1)
dbClearResult(res1)
View(data_CRSP_DSF)

##Number of rows in full dataset##
nrow(data_CRSP_DSF)

##Summary  of the data##
mean(data_CRSP_DSF$prc)
summary(data_CRSP_DSF$prc)
summary(data_CRSP_DSF)


##Joining Data from Two Datasets###

##Often we need to collect data from multiple WRDS datasets, 
##in such cases, data from separate datasets can be joined and 
##analyzed together, as long as both datasets have atleast 
##one common data identifier. The following example shows how 
##to join the Compustat Fundamentals data set (comp.funda) 
##with Compustat’s pricing dataset (comp.secm), and then query 
##for total assets(at) and liabilities (lt) 
##(variables from comp.funda) along with monthly close price 
##and shares outstanding (variables from comp.secm).



res2 <- dbSendQuery(wrds, "select a.gvkey, a.datadate, a.tic,
                   a.conm, a.at, a.lt, b.prccm, b.cshoq
                   from comp.funda a join comp.secm b
                   on a.gvkey = b.gvkey
                   and a.datadate = b.datadate
                   where a.tic = 'IBM'
                   and a.datafmt = 'STD'
                   and a.consol = 'C'
                   and a.indfmt = 'INDL'")
data_Merge <- dbFetch(res2, n = -1)
dbClearResult(res2)
View(data_Merge)
##Number of rows in full dataset##
nrow(data_Merge)

# Exclude rows that have missing data in ANY variable
data_Merge_omit <- na.omit(data_Merge)
View(data_Merge_omit)

##Number of rows in full dataset##
nrow(data_Merge_omit)


##Exercise##
##Q1##
res4 <- dbSendQuery(wrds, "select gvkey, datadate, tic,conm,fyear,REVT,GP,
                     AT,DLTT,TEQ,EXCHG
                     from comp.funda
                   where fyear between '2000'
                   and '2020'
                   and datafmt = 'STD'
                   and consol = 'C'
                   and indfmt = 'INDL'
                    and EXCHG = 11") 
data_Comp1<- dbFetch(res4, n=-1)
dbClearResult(res4)
View(data_Comp1)                   
                     
##Number of rows in full dataset##
nrow(data_Comp1)

# Exclude rows that have missing data in ANY variable
data_COMP_Merge_omit <- na.omit(data_Comp1)
View(data_COMP_Merge_omit)

##Number of rows in full dataset##
nrow(data_COMP_Merge_omit)

##Q2##
res5<- dbSendQuery(wrds, "select CONAME, GVKEY, exchange,year,
                     total_curr,total_sec,age,gender
                     FROM comp_execucomp.anncomp
                      where year between '2000'
                        and '2020'
                        and exchange= 'NYS'")
                  
                       
                    
data_Comp2<- dbFetch(res5, n=-1)
dbClearResult(res5)
View(data_Comp2) 

##Number of rows in full dataset##
nrow(data_Comp1)

# Exclude rows that have missing data in ANY variable
data_COMP_Merge_omit <- na.omit(data_Comp1)
View(data_COMP_Merge_omit)

##Number of rows in full dataset##
nrow(data_COMP_Merge_omit)                  


##Q3##

res6 <- dbSendQuery(wrds, "select gvkey, datadate,fyear,
                     conm,FYR,REVT,GP,
                     AT,DLTT,TEQ,EXCHG
                     from comp.funda
                   where fyear between '2000'
                   and '2020'
                   and datafmt = 'STD'
                   and consol = 'C'
                    and EXCHG = 11") 
data_Comp3.1<- dbFetch(res6, n=-1)
dbClearResult(res6)
View(data_Comp3.1) 


res7 <- dbSendQuery(wrds, "select a.gvkey, a.fyear,
                     a.conm, a.FYR,a.REVT,a.GP,
                     a.AT,a.DLTT,a.TEQ,a.EXCHG
                     from comp.funda a join comp_execucomp.anncomp b
                   on a.gvkey = b.gvkey
                  and a.fyear = b.year
                   where a.datafmt = 'STD'
                   and a.consol = 'C'
                   and a.indfmt = 'INDL'")
                   
data_Comp3.2<- dbFetch(res7, n = -1)
dbClearResult(res7)
View(data_Comp3.2)

    
