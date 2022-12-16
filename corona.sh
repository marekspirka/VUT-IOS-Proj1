#!/bin/sh

#--------------------------------------------------#
# Author : Marek Spirka, xspirk01@stud.fit.vutbr.cz
# #1 project IOS -> Operating Systems VUT FIT 
#--------------------------------------------------#

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8

printhelp(){
    echo "Help : corona [-h|--help]"
    echo ""
    echo ""
    echo "Usage: [FILTERS] [COMMAND] [LOG [LOG2 [...]]]"
    echo ""
    echo ""
    echo "Commands:"
    echo "infected   ---   counts the number of infected"
    echo "merge      ---   merges several files with records into one, preserving the original order"
    echo "gender     ---   lists the number of infected for each gender"
    echo "age        ---   lists statistics on the number of infected people by age"
    echo "daily      ---   lists statistics of infected persons for individual days"
    echo "monthly    ---   lists statistics of infected persons for individual months"
    echo "yearly     ---   lists statistics on infected people for each year"
    echo "countries  ---   lists statistics of infected persons for individual countries of the disease"
    echo "districts  ---   lists statistics on infected persons for individual districts"
    echo "regions    ---   lists statistics of infected persons for individual regions"
    echo ""
    echo ""
    echo "Filters:"
    echo "-a DATETIME  --- after: only records after this date (including this date) are considered. DATETIME is the format YYYY-MM-DD"
    echo "-b DATETIME  --- before: only records BEFORE this date (including this date) are considered"
    echo "-g GENDER    --- only records of infected persons of a given gender are considered. GENDER can be M (men) or Z (women)"
    echo "-w WIDTH     --- for the commands gender, age, daily, monthly, yearly, countries, districts and regions, it displays the data not numerically, but graphically in the form of histograms. The optional WIDTH parameter sets the width of the histograms, that is, the length of the longest line, to WIDTH. This, WIDTH must be a positive integer."
    echo ""
}

commands=""
width=""
gender=""
invalid_date=""
invalid_age=""
dateTimeAfter="0000-00-00 00:00:00"
dateTimeBefore="9999-12-31 23:59:59"
GENDER_FLAG=0
WIDTH_FLAG=0
found_csv=0


while [ "$#" -gt 0 ] ; do
    case "$1" in
      infected | merge | age | gender | daily | monthly | yearly | countries | districts | regions)
        commands="$1"
        shift
        ;;
      -a)
        dateTimeAfter="$2"
        shift
        shift
        ;;
      -b)
        dateTimeBefore="$2"
        shift
        shift
        ;;
      -g)
        GENDER_FLAG=1
        gender="$2"
        shift
        shift
        ;;
      -w)
        WIDTH_FLAG=1
        width="$2"
        shift
        shift
        ;;
      -h | --help)
        printhelp
        exit 0
        ;;

      *.csv.gz)
        csvFiles="$csvFiles$(gzip -d -c "$1")\n"
        found_csv=$((found_csv+1))
        shift
        ;;
       *.csv)
        csvFiles="$csvFiles$(cat "$1")\n"
        found_csv=$((found_csv+1))
        shift
        ;;
      *)
        echo "Invalid argument or filters."
        exit 1
      esac
done

if [ "$found_csv" = 0 ]; then  #if no logs loaded, read logs from input
    stdin_flag=1
fi

if [ "$stdin_flag" = 1 ]; then  #loading from stdin
        csvFiles=$(gawk -F ','  '{
        {if ( cnt == 0 ) {cnt=1} } {for (i = cnt; i > 0; i--) { print $line }}}' | sort | uniq )

fi

############################################# Printing Invalid line to output #############################################
invalid_age=$(echo "$csvFiles" | awk  -F "," '
  {if(NR>1){
    if(!((($3 <= 120) && ($3 >= 0 )) || ($3 == ""))){print("Invalid age: " $0)}
    else{next}}}')

invalid_date=$(echo "$csvFiles" | awk  -F, ' BEGIN { FS = OFS = "," }
{if(NR>1){{split($2, date, /\-/)
  if((date[3] < 1 || date[3] > 31 ) || (date[2] < 1 || date[2] > 12) || (date[1] < 2020 || date[1] > 2022)){print("Invalid date: " $0)}
    if(date[3] == 31 && (date[2]  == 4 ||  date[2]  == 6 || date[2]  == 9 || date[2] == 11)){print("Invalid date: " $0)}
      if(date[2] == 2 && date[3] > 29){print("Invalid date: " $0)}
        if(date[2] == 02 && date[3] == 29  && ! (date[1] % 4 == 0 && (date[1] % 100 != 0 || date[1] % 400 == 0))){print("Invalid date: " $0)}
        }}}'| uniq )

##################################################### Sort input for commands #####################################################

if [ $GENDER_FLAG = 1 ] ; then
csvFiles=$(echo "$csvFiles" | awk  -F "," -v "g=$gender" '{
if(NR==1){print}
  if(NR>1){
    if(g=="M"){if($4=="M"){print $0}}
    if(g== "Z"){if($4=="Z"){print $0}}
    }}')
fi

valid_age=$(echo "$csvFiles" | awk  -F "," '
  {if(NR>1){
    if((($3 <= 120) && ($3 >= 0 )) || ($3 == "")){print}
    else{invalid_age=1}
    }}')

valid_date_age=$(echo "$valid_age" | awk  -F, ' BEGIN { FS = OFS = "," }
{split($2, date, /\-/)
  if((1 <= date[3] && date[3] <= 31) && (1 <= date[2] && date[2] <= 12) && (date[1] > 2019 && date[1] < 2023)){
    if (date[3] == 31 && (date[2]  == 4 ||  date[2]  == 6 || date[2]  == 9 || date[2] == 11)){}
      else if(date[3] >= 30 && date[2] == 2){}
        else if(date[2] == 02 && date[3] == 29  && ! (date[1] % 4 == 0 && (date[1] % 100 != 0 || date[1] % 400 == 0))){}
          else {print}}}')

######################################################### Commands #########################################################
if [ "$commands" = "infected" ]; then
  csvFiles=$(echo "$valid_date_age" | awk '{n+=1} END {print n}')
fi
if [ "$commands" = "merge" ]; then
  echo
fi
if [ "$commands" = "age" ]; then
 csvFiles=$(echo "$valid_date_age" | awk -F "," '{
       if(0 <= $3 && $3 <= 5 ){count_0_5++} else if(6 <= $3 && $3 <= 15 ){count_6_15++} else if(16 <= $3 && $3 <= 25 ){count_16_25++} else if(26 <= $3 && $3 <= 35 ){count_26_35++} else if(36 <= $3 && $3 <= 45 ){count_36_45++}
       else if(46 <= $3 && $3 <= 55 ){count_46_55++} else if(56 <= $3 && $3 <= 65 ){count_56_65++} else if(66 <= $3 && $3 <= 75 ){count_66_75++} else if(76 <= $3 && $3 <= 85 ){count_76_85++} else if(86 <= $3 && $3 <= 95 ){count_86_95++}
       else if(96 <= $3 && $3 <= 105 ){count_96_105++} else if($3 > 105 ){count_105++} else if($3 == "" ){count_none++}
       }
       END{printf("0-5   : %d\n",count_0_5)
           printf("6-15  : %d\n",count_6_15)
           printf("16-25 : %d\n",count_16_25)
           printf("26-35 : %d\n",count_26_35)
           printf("36-45 : %d\n",count_36_45)
           printf("46-55 : %d\n",count_46_55)
           printf("56-65 : %d\n",count_56_65)
           printf("66-75 : %d\n",count_66_75)
           printf("76-85 : %d\n",count_76_85)
           printf("86-95 : %d\n",count_86_95)
           printf("96-105: %d\n",count_96_105)
           printf(">105  : %d\n",count_105)
           printf("None  : %d\n",count_none)
       }')
fi
if [ "$commands" = "gender" ]; then
     csvFiles=$(echo "$valid_date_age" | awk -F "," '{
       if($4=="M"){count_m=count_m+1}
       if($4=="Z"){count_z=count_z+1}
       if($4==""){count_none++}}
        END{printf("M: %d\n",count_m)
          printf("Z: %d\n",count_z)
           if($4==""){
              printf("None: %d\n",count_none)}
       }')
fi
if [ "$commands" = "daily" ]; then
  csvFiles=$(echo "$valid_date_age" |  awk -F "," '{
    if($2==""){count_none++}
      districts[$2]++;}
        END{for (infected in districts) { print infected ": " districts[infected]}
           if($2==""){printf("None: %d\n",count_none)}}'|  sort -k1.1)
fi

if [ "$commands" == "monthly" ]; then
    csvFiles=$(echo "$valid_date_age" |awk  -F, ' {
      split($2,d,"-");
        monthly[d[1]"-"d[2]];
        output[d[1]"-"d[2]]++;}
          END{for (infected in monthly) print infected ":", output[infected] }'|  sort -k1.1)
fi

if [ "$commands" = "yearly" ]; then
   csvFiles=$(echo "$valid_date_age" |awk  -F, ' {
     split($2,d,"-");
       yearly[d[1]];
       output[d[1]]++;}
         END{for (infected in yearly) print infected ":", output[infected] }'|  sort -k1.1)
fi

if [ "$commands" = "countries" ]; then
     csvFiles=$(echo "$valid_date_age" | awk -F "," '{
       if($8 == "" || $8 == "CZ" ){next}
        countries[$8]++;}
          END{for (infected in countries) { print infected ": " countries[infected]} }' |  sort -k1.1)
fi

if [ "$commands" = "districts" ]; then
    csvFiles=$(echo "$valid_date_age" | awk -F "," '{
      if($6 == ""){count_none=count_none+1}
        if($6 == ""){next}
          districts[$6]++;}
          END{for (infected in districts) { print infected ": " districts[infected]}
          printf("None: %d\n",count_none)}' |  sort -k1.1)
fi
if [ "$commands" = "regions" ]; then
   csvFiles=$(echo "$valid_date_age" | awk -F "," -v "w=$width" '{
    if($5 == ""){count_none=count_none+1}
      if($5 == ""){next}
        regions[$5]++;}
          END{for (infected in regions) { print infected ": " regions[infected]}
          if($WIDTH_FLAG == 1){print ahoj}
           printf("None: %d\n",count_none)}' |  sort -k1.1,1.1)
fi

echo "$csvFiles"
if [ "$invalid_date" != "" ]; then
echo "$invalid_date"
fi
if [ "$invalid_age" != "" ]; then
echo "$invalid_age"
fi
exit 0