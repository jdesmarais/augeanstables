#!/bin/bash

get_st_dir(){
    projectDir=/home/jdesmarais/projects
    dir="$projectDir/dim2d_"$1"_ca"$2"_vap"
    echo "$dir"
}

generate_st_contours(){
    pythonDir=/home/jdesmarais/Code/augeanstables/scripts_py

    cd $pythonDir
    cd wall_steady_state_automatization/contours_extraction

    inputDir=$( get_st_dir $1 $2)
    ca=$2

    ./extract_bubble_contours.py -i $inputDir -c $ca -t $3 -p -g > cur_st_contours.out 2>&1
    #./extract_bubble_contours.py -i $inputDir -c $ca -t $3 -s > cur_st_contours.out 2>&1
}

T=0.999

#22.5 45.0 67.5 90.0 112.5 130.0
for ca in 22.5 45.0 67.5 90.0
do
    generate_st_contours $T $ca [0,1010,10]
    echo "generate_st_contours( "$T" , "$ca" ) : done"
done


for ca in 112.5 #135.0
do
    generate_st_contours $T $ca [0,2424,24]
    echo "generate_st_contours( "$T" , "$ca" ) : done"
done


#for ca in 135.0
#do
#    generate_st_contours $T $ca [0,2424,24]
#    echo "generate_st_contours( "$T" , "$ca" ) : done"
#done