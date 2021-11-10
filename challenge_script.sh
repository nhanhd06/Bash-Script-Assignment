# !/bin/bash

# Declare global variable
FIRST_TIME_CHECK=0
FINAL_TIME_CHECK=0

PREVIOUS_DATE_TIME=0
PREVIOUS_HOUR=0
PREVIOUS_FIRST_MINUTE=0

DATE_TIME=0
HOUR=0
MINUTE=0
SECOND=0

NUMBER_COUNT=0
FIRST_MINUTE=0

COMPARE_CHECK=0

# Check and intialize necessary files
start_files() {
    
    if [ ! -f interview.log ]
    then
        echo  "Interview Log File is not found";
    fi

    rm -f compared_values.txt && touch compared_values.txt 
    rm -f values.txt && touch values.txt
    rm -f unique_output.txt && touch unique_output.txt
    rm -f standard_output.txt && touch standard_output.txt

}

# Main option command line
main_gui() {
    
    while true; do

        options=("Unique ID" "Total ID" "Quit")

        echo "Choose an option: "

        select opt in "${options[@]}"; do
            case $REPLY in
                1) main_process; break ;;
                2) main_process2; break ;;
                3) exit 1 ;;
                *) echo "Invalid option - $REPLY" ;;

            esac
        done

    done

}

# Method for unique proces
main_process() {

    NUM_POSITION=1

    cat interview.log | (while read line 
    do
        
        # Take out hour and minute to check for each line
        INPUT_TIME_CHECK=$(echo "${line}" | cut -b 9-12)

        # Check to see if current position of the line is first
        if [ $NUM_POSITION == 1 ]
        then 
            echo "--------FIRST TEN MINUTES OUTPUT--------">>unique_output.txt
            

            PREVIOUS_DATE_TIME=$(echo "${line}" | cut -b 1-8)
            PREVIOUS_HOUR=$(echo "${line}" | cut -b 9-10)
            PREVIOUS_FIRST_MINUTE=$(echo "${line}" | cut -b 11)


            HOUR=$(echo "${line}" | cut -b 9-10)
            MINUTE=$(echo "${line}" | cut -b 11-12)
            SECOND=$(echo "${line}" | cut -b 13-14)

            FIRST_VALUE=$INPUT_TIME_CHECK
            FINAL_VALUE=$(date -d ""${PREVIOUS_DATE_TIME}" "${HOUR}":"${MINUTE}":"${SECOND}" 10min" +'%Y%m%d%H%M%S' | cut -b 9-12)

            NUMBER_COUNT=$(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')

            echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>compared_values.txt    



        # Check to see if first minute <= current hour and minute <= next 10 minutes     
        elif [ $INPUT_TIME_CHECK -le $FINAL_VALUE ] && [ $INPUT_TIME_CHECK -ge $FIRST_VALUE ]
        then

            # Take out first letter of minute
            FIRST_MINUTE=("$(echo "${line}" | cut -b 11)")

            # Check if first letter of minute is equal to previous one
            if [ $PREVIOUS_FIRST_MINUTE -eq $FIRST_MINUTE ]
            then
                echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>values.txt

                DIFFERENCE_COUNT=$(grep -xvFf compared_values.txt values.txt | grep -v ^$ | wc -l)

                ACTUAL_COUNT=$(grep -xvFf compared_values.txt values.txt | grep -v ^$)
                NUMBER_COUNT=$(($NUMBER_COUNT + $DIFFERENCE_COUNT))

                if [ $DIFFERENCE_COUNT != 0 ]
                then
                    grep -xvFf compared_values.txt values.txt>>compared_values.txt 
                fi


            # Check if first letter of minute is greater than previous one
            elif [ $PREVIOUS_FIRST_MINUTE -lt $FIRST_MINUTE ]
            then   
                
                echo "$PREVIOUS_DATE_TIME$PREVIOUS_HOUR$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT">>unique_output.txt

                PREVIOUS_FIRST_MINUTE=$FIRST_MINUTE

                NUMBER_COUNT=0

                echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>values.txt

                DIFFERENCE_COUNT=$(grep -xvFf compared_values.txt values.txt | grep -v ^$ | wc -l)

                ACTUAL_COUNT=$(grep -xvFf compared_values.txt values.txt | grep -v ^$)
                NUMBER_COUNT=$(($NUMBER_COUNT + $DIFFERENCE_COUNT))

                if [ $DIFFERENCE_COUNT != 0 ]
                then
                    grep -xvFf compared_values.txt values.txt>>compared_values.txt 
                fi

            
            # Check if first letter of minute is less than to previous one
            elif [ $PREVIOUS_FIRST_MINUTE -gt $FIRST_MINUTE ] 
            then
                HOUR=$(echo "${line}" | cut -b 9-10)
                    
                PREVIOUS_HOUR=("$(echo "${line}" | cut -b 9-10)")
                
                echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>values.txt

                DIFFERENCE_COUNT=$(grep -xvFf compared_values.txt values.txt | grep -v ^$ | wc -l)

                ACTUAL_COUNT=$(grep -xvFf compared_values.txt values.txt | grep -v ^$)
                NUMBER_COUNT=$(($NUMBER_COUNT + $DIFFERENCE_COUNT))

                if [ $DIFFERENCE_COUNT != 0 ]
                then
                    grep -xvFf compared_values.txt values.txt>>compared_values.txt 
                fi


            else

                echo "Error at if [ PREVIOUS_FIRST_MINUTE -eq FIRST_MINUTE ]"
            fi 
        
        elif [ $INPUT_TIME_CHECK -ge $FINAL_VALUE ]
        then

            echo "$PREVIOUS_DATE_TIME$PREVIOUS_HOUR$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT">>unique_output.txt 
   
            echo "--------NEXT TEN MINUTES OUTPUT--------">>unique_output.txt

            FIRST_VALUE=$FINAL_VALUE
            HOUR=$(echo "${FINAL_VALUE}" | cut -b 1-2)
            MINUTE=$(echo "${FINAL_VALUE}" | cut -b 3-4)
            FINAL_VALUE=$(date -d ""${PREVIOUS_DATE_TIME}" "${HOUR}":"${MINUTE}":"${SECOND}" 10min" +'%Y%m%d%H%M%S' | cut -b 9-12)
            
            PREVIOUS_DATE_TIME=$(echo "${line}" | cut -b 1-8)
            PREVIOUS_HOUR=$(echo "${line}" | cut -b 9-10)
            PREVIOUS_FIRST_MINUTE=$(echo "${line}" | cut -b 11)

            NUMBER_COUNT=0
        
            NUMBER_COUNT=$(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')        
            echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>compared_values.txt   

        fi
                 
        NUM_POSITION=$((NUM_POSITION + 1))

        
    done

    echo "$PREVIOUS_DATE_TIME$PREVIOUS_HOUR$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT">>unique_output.txt)
    cat unique_output.txt
}

# Method for standard output process
main_process2() {

    NUM_POSITION=1

    cat interview.log | (while read line 
    do

        INPUT_TIME_CHECK=$(echo "${line}" | cut -b 9-12)


        if [ $NUM_POSITION == 1 ]
        then 

            echo "--------FIRST TEN MINUTES OUTPUT--------">>standard_output.txt
            
            PREVIOUS_DATE_TIME=$(echo "${line}" | cut -b 1-8)
            PREVIOUS_HOUR=$(echo "${line}" | cut -b 9-10)
            PREVIOUS_FIRST_MINUTE=$(echo "${line}" | cut -b 11)

            HOUR=$(echo "${line}" | cut -b 9-10)
            MINUTE=$(echo "${line}" | cut -b 11-12)
            SECOND=$(echo "${line}" | cut -b 13-14)

            FIRST_VALUE=$INPUT_TIME_CHECK
            FINAL_VALUE=$(date -d ""${PREVIOUS_DATE_TIME}" "${HOUR}":"${MINUTE}":"${SECOND}" 10min" +'%Y%m%d%H%M%S' | cut -b 9-12)

            NUMBER_COUNT=$(($NUMBER_COUNT + $(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')))
            
        elif [ $INPUT_TIME_CHECK -le $FINAL_VALUE ] && [ $INPUT_TIME_CHECK -ge $FIRST_VALUE ]
        then

            FIRST_MINUTE=("$(echo "${line}" | cut -b 11)")
            

            if [ $PREVIOUS_FIRST_MINUTE -eq $FIRST_MINUTE ]
            then
                NUMBER_COUNT=$(($NUMBER_COUNT + $(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')))

            elif [ $PREVIOUS_FIRST_MINUTE -lt $FIRST_MINUTE ]
            then   
                
               
                echo "$PREVIOUS_DATE_TIME$PREVIOUS_HOUR$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT">>standard_output.txt     

                PREVIOUS_FIRST_MINUTE=$FIRST_MINUTE
                NUMBER_COUNT=0
                NUMBER_COUNT=$(($NUMBER_COUNT + $(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')))

                

            elif [ $PREVIOUS_FIRST_MINUTE -gt $FIRST_MINUTE ] 
            then
                HOUR=$(echo "${line}" | cut -b 9-10)
               
                PREVIOUS_HOUR=("$(echo "${line}" | cut -b 9-10)")
                NUMBER_COUNT=$(($NUMBER_COUNT + $(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')))
                  
            else

                echo "Error at if [ PREVIOUS_FIRST_MINUTE -eq FIRST_MINUTE ]"
            fi 
        
        elif [ $INPUT_TIME_CHECK -ge $FINAL_VALUE ]
        then

            echo "$PREVIOUS_DATE_TIME$PREVIOUS_HOUR$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT">>standard_output.txt  
           
            echo "--------NEXT TEN MINUTES OUTPUT--------">>standard_output.txt

            FIRST_VALUE=$FINAL_VALUE
            HOUR=$(echo "${FINAL_VALUE}" | cut -b 1-2)
            MINUTE=$(echo "${FINAL_VALUE}" | cut -b 3-4)
            FINAL_VALUE=$(date -d ""${PREVIOUS_DATE_TIME}" "${HOUR}":"${MINUTE}":"${SECOND}" 10min" +'%Y%m%d%H%M%S' | cut -b 9-12)
            

            PREVIOUS_DATE_TIME=$(echo "${line}" | cut -b 1-8)
            PREVIOUS_HOUR=("$(echo "${line}" | cut -b 9-10)")
            PREVIOUS_FIRST_MINUTE=("$(echo "${line}" | cut -b 11)")

            NUMBER_COUNT=0
            NUMBER_COUNT=$(($NUMBER_COUNT + $(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')))
        
        fi
                 
        NUM_POSITION=$((NUM_POSITION + 1))

        
    done

    echo "$PREVIOUS_DATE_TIME$PREVIOUS_HOUR$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT">>standard_output.txt)

    cat standard_output.txt

}

# Declare
start_files
main_gui


    