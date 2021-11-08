#!/bin/bash

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

start_files() {
    
    if [ ! -f interview.log ]
    then
        echo  "Interview Log File is not found";
    fi

    touch compared_values.txt 
    touch values.txt
}

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

main_process() {

    NUM_POSITION=1

    cat interview.log | (while read line 
    do

        INPUT_TIME_CHECK=$(echo "${line}" | cut -b 9-12)


        if [ $NUM_POSITION == 1 ]
        then 
            echo "----FIRST TEN MINUTES OUTPUT-------"
            
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
            
        elif [ $INPUT_TIME_CHECK -le $FINAL_VALUE ] && [ $INPUT_TIME_CHECK -ge $FIRST_VALUE ]
        then

            FIRST_MINUTE=("$(echo "${line}" | cut -b 11)")
            

            if [ $PREVIOUS_FIRST_MINUTE -eq $FIRST_MINUTE ]
            then
                echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>values.txt

                DIFFERENCE_COUNT=$(grep -xvFf compared_values.txt values.txt | wc -l)
                NUMBER_COUNT=$(($NUMBER_COUNT + $DIFFERENCE_COUNT))

                if [ $DIFFERENCE_COUNT != 0 ]
                then
                    grep -xvFf compared_values.txt values.txt>>compared_values.txt 
                fi


            elif [ $PREVIOUS_FIRST_MINUTE -lt $FIRST_MINUTE ]
            then   
                
                echo "----------------------------------------------------------"
                echo "$PREVIOUS_DATE_TIME.$PREVIOUS_HOUR.$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT"  
                echo "----------------------------------------------------------"

                PREVIOUS_FIRST_MINUTE=$FIRST_MINUTE

                NUMBER_COUNT=0

                echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>values.txt

                DIFFERENCE_COUNT=$(grep -xvFf compared_values.txt values.txt | wc -l)
                NUMBER_COUNT=$(($NUMBER_COUNT + $DIFFERENCE_COUNT))

                if [ $DIFFERENCE_COUNT != 0 ]
                then
                    grep -xvFf compared_values.txt values.txt>>compared_values.txt 
                fi


            elif [ $PREVIOUS_FIRST_MINUTE -gt $FIRST_MINUTE ] 
            then
                HOUR=$(echo "${line}" | cut -b 9-10)

                if [ $PREVIOUS_HOUR < $HOUR ] 
                then
                    
                    PREVIOUS_HOUR=("$(echo "${line}" | cut -b 9-10)")
                    
                    echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>values.txt

                    echo $line | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,//g' | sed 's/-//g' | awk 'BEGIN{RS=" "}{$1=$1}1'>values.txt

                    DIFFERENCE_COUNT=$(grep -xvFf compared_values.txt values.txt | wc -l)
                    NUMBER_COUNT=$(($NUMBER_COUNT + $DIFFERENCE_COUNT))

                    if [ $DIFFERENCE_COUNT != 0 ]
                    then
                        grep -xvFf compared_values.txt values.txt>>compared_values.txt 
                    fi

                else

                    echo "Error at if[ PREVIOUS_HOUR < HOUR ]"
                fi
            else

                echo "Error at if [ PREVIOUS_FIRST_MINUTE -eq FIRST_MINUTE ]"
            fi 
        
        elif [ $INPUT_TIME_CHECK -ge $FINAL_VALUE ]
        then

            echo "----------------------------------------------------------"
            echo "$PREVIOUS_DATE_TIME.$PREVIOUS_HOUR.$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT"  
            echo "----------------------------------------------------------"



            echo "----NEXT TEN MINUTES OUTPUT-------"

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

    echo "----------------------------------------------------------"
    echo "$PREVIOUS_DATE_TIME.$PREVIOUS_HOUR.$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT"  
    echo "----------------------------------------------------------")
}

main_process2() {

    NUM_POSITION=1

    cat interview.log | (while read line 
    do

        INPUT_TIME_CHECK=$(echo "${line}" | cut -b 9-12)


        if [ $NUM_POSITION == 1 ]
        then 
            echo "----FIRST TEN MINUTES OUTPUT-------"
            
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
                
                echo "----------------------------------------------------------"
                echo "$PREVIOUS_DATE_TIME.$PREVIOUS_HOUR.$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT"  
                echo "----------------------------------------------------------"

                PREVIOUS_FIRST_MINUTE=$FIRST_MINUTE
                NUMBER_COUNT=0
                NUMBER_COUNT=$(($NUMBER_COUNT + $(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')))

                

            elif [ $PREVIOUS_FIRST_MINUTE -gt $FIRST_MINUTE ] 
            then
                HOUR=$(echo "${line}" | cut -b 9-10)

                if [ $PREVIOUS_HOUR < $HOUR ] 
                then
                    
                    PREVIOUS_HOUR=("$(echo "${line}" | cut -b 9-10)")
                    NUMBER_COUNT$(($NUMBER_COUNT + $(echo ${line} | awk '{split($0,a,":"); print a[2]}' | sed 's/[[]//' | sed 's/[]]//' | sed 's/,/ /g' | sed 's/-/ /g' | awk 'BEGIN{RS=" "}{$1=$1}1' | grep -cve '^\s*$')))
                else

                    echo "Error at if[ PREVIOUS_HOUR < HOUR ]"
                fi
            else

                echo "Error at if [ PREVIOUS_FIRST_MINUTE -eq FIRST_MINUTE ]"
            fi 
        
        elif [ $INPUT_TIME_CHECK -ge $FINAL_VALUE ]
        then

            echo "----------------------------------------------------------"
            echo "$PREVIOUS_DATE_TIME.$PREVIOUS_HOUR.$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT"  
            echo "----------------------------------------------------------"



            echo "----NEXT TEN MINUTES OUTPUT-------"

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

    echo "----------------------------------------------------------"
    echo "$PREVIOUS_DATE_TIME.$PREVIOUS_HOUR.$PREVIOUS_FIRST_MINUTE: $NUMBER_COUNT"  
    echo "----------------------------------------------------------")
}

# Declare

start_files
main_gui


    