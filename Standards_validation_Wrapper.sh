WAG_TALEND_JOB=/home/bitwise1/utility/test_job
WAG_TALEND_JOB_ZIP=/home/bitwise1/utility/zip
BKP=/home/bitwise1/utility/bkp
DIR=$(date +"%Y%m%d")
MY_HOME=/home/bitwise1/utility/script
MODULE_DIR=/home/bitwise1/utility
                
current_dir()
{
if [[ -d "${MODULE_DIR}/work/${DIR}" ]]
        then
                                cd ${MODULE_DIR}/work/${DIR}
                                                                rm -f *
                                                                cd -
                                                                echo "${MODULE_DIR}/work/${DIR} exists."
                else
                                mkdir ${MODULE_DIR}/work/${DIR}
                                echo " Directory not present created resultant directory "
                fi

}

Validation()
{ 

JOB_COUNTER=0
FAILED_FLAG=0
PASSED_FLAG=0


cd ${WAG_TALEND_JOB_ZIP}
ZIP_FILE=`find . -name "*.zip" 2>/dev/null | awk -F "/" '{print $2}'`
for Line in ${ZIP_FILE}
do
                
               export job=`echo $Line | sed 's/\(.*\)......../\1/'`
                unzip -o ${job}_0.1.zip
                echo "job :"$job
                export ITEM_FILES1=`find ${WAG_TALEND_JOB_ZIP} -name "${job}_run.sh" 2>/dev/null`
                cp ${ITEM_FILES1} ${WAG_TALEND_JOB}
                
                export ITEM_FILES2=`find ${WAG_TALEND_JOB_ZIP}/${job}/items/*/process -name "*.item" 2>/dev/null`
                for FILES in ${ITEM_FILES2} 
                do
                        cp ${FILES} ${WAG_TALEND_JOB}
                done                                                                                                                                                                                 
                
done 
                

export ITEM_FILES=`find ${WAG_TALEND_JOB} -name "*.item" 2>/dev/null`
echo "ITEM_FILES :" $ITEM_FILES

for CURRENT_ITEM_FILE in $ITEM_FILES
do
        FULL_JOB_NAME=${CURRENT_ITEM_FILE}
        . ${MY_HOME}/Job_Std_Val.sh $FULL_JOB_NAME

        JOB_COUNTER=`expr $JOB_COUNTER + 1`

        JOB_NAME=`echo $FULL_JOB_NAME | awk -F "/" '{print $NF}' |sed 's/_0.1.item//g'`

        
        echo $JOB_NAME >> ${MY_HOME}/Job_Name.txt

        
        cat ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv | awk -F "," '{print $NF}' > FLAG.csv

        grep "Failed" FLAG.csv 1>/dev/null
        if [[ $? == 0 ]]
        then
                FAILED_FLAG=`expr $FAILED_FLAG + 1`
        else
                PASSED_FLAG=`expr $PASSED_FLAG + 1`
        
        fi
        rm FLAG.csv

### Display Output on Screen

echo "Please find below snapshot of Failed Validations : "

awk -F"|" '
BEGIN {
print "\n"
print "Component Standards"
print "================================================================================================================================================================================"
printf "%-30s %-30s %-30s %-50s %-50s\n","Component Type","Component Label","Component Property","Desired Value","Current Value"
print "================================================================================================================================================================================"
}
{ printf "%-30s %-30s %-30s %-50s %-50s\n",$1,$2,$3,$4,$5 } ' ${MODULE_DIR}/work/${DIR}/Components_Standards.txt

rm ${MODULE_DIR}/work/${DIR}/Components_Standards.txt

awk -F"|" '
BEGIN {
print "\n"
print "Peripheral Standards"
print "================================================================================================================================================================================"
printf "%-30s %-30s %-30s %-50s %-50s\n","Component Type","Component Label"," ","Desired Value","Current Value"
print "================================================================================================================================================================================"
}
{ printf "%-30s %-30s %-30s %-50s %-50s\n",$1,$2,$3,$4,$5 } ' ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt

rm ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt

awk -F"|" '
BEGIN {
print "\n"
print "Memory Standards"
print "================================================================================================================================================================================"
printf "%-30s %-30s %-30s %-50s %-50s\n","Component Type","Component Label"," ","Desired Value","Current Value"
print "================================================================================================================================================================================"
}
{ printf "%-30s %-30s %-30s %-50s %-50s\n",$1,$2,$3,$4,$5 } ' ${MODULE_DIR}/work/${DIR}/Memory_Standards.txt

rm ${MODULE_DIR}/work/${DIR}/Memory_Standards.txt

done


echo "<html>
<style>
table {
border-collapse:collapse;
}
table, td {
        border-width: 1px;
        border-style: solid;
        border-color: #000000;
}                                                                                                                                                                                                    
th {
backgroung-color: #F0B27A;
border-color: #000000;
color: #000000;
}                                                                                                                                                                                                    
</style>
<body>
<p>Please find below list of JOBS REVIEWED in this Execution:- </p> </br>
<table border ="1">
<tr><th>Job Name</th></tr>" > sample.html

while read line
do
   JOB=$line
   echo "<tr><td>$JOB</td></tr>" >> sample.html 
done < ${MY_HOME}/Job_Name.txt
echo "</table></body>" >> sample.html


echo "<style>
table {
border-collapse:collapse;
}
table, td {
        border-width: 1px;
        border-style: solid;
        border-color: #000000;
}
th {
backgroung-color: #F0B27A;
border-color: #000000;
color: #000000;
}
</style>
<body>
<p>Please find Ulitily Execution Summary as below:- </p> </br>
<table border ="1">
<tr><th>#Job Executed</th><th>#Job Passed</th><th>#Job Failed</th></tr>
<tr><td>$JOB_COUNTER</td><td>${PASSED_FLAG}</td><td>${FAILED_FLAG}</td></tr>" >> sample.html
echo "</table></body>" >> sample.html

echo "<body>
<p>Please find respective job's csv file for more details at below path :- </br>
        /home/bitwise1/utility/work </p>" >> sample.html
echo "</body></html>" >> sample.html

. ${MY_HOME}/send_mail.sh

test -s ${MY_HOME}/Job_Name.txt  && rm -rf  ${MY_HOME}/Job_Name.txt
}                                                                                                                                                                                                    


bkp()
{ 
         if [[ -d "${BKP}/${DIR}" ]]
                then
                     echo "Directory ${BKP}/${DIR} exists."
                     rm -r ${BKP}/${DIR}
         fi
                                
                mkdir  ${BKP}/${DIR}
                mv ${WAG_TALEND_JOB_ZIP}/* ${BKP}/${DIR}
                mv ${WAG_TALEND_JOB}/*.item ${BKP}/${DIR}
                mv ${WAG_TALEND_JOB}/*.sh ${BKP}/${DIR}
                echo "Taking backup of input jobs in : ${BKP}/${DIR}"
                rm -f ${WAG_TALEND_JOB}/*.info                                                                                                                                                       
                echo "***************************************************************************"
                echo " Please find result directory path :  " ${MODULE_DIR}/work/${DIR}
                echo "***************************************************************************"
                
}


main()
{
        current_dir
        Validation
        bkp
                
        
}

main
