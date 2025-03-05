budget=120
a_budget=20
D4J_SEED=42 #Three trials were run with seeds 100, 42, and 47

exec_cmd() {
    local cmd=$1

    echo
    echo "Executing command:"
    echo "$cmd"

    $cmd
}

#Flag to select whether to use plain EvoSuite or our modification
#OG=true
OG=false

if [ "$proj" = "1_tullibee" ]; then 
    project_cp=SF100/1_tullibee/tullibee.jar
    classfiles=$(find SF100/1_tullibee/ -type f -name "*.class")
elif [ "$proj" = "2_a4j" ]; then
    project_cp=SF100/2_a4j/a4j.jar:SF100/2_a4j/lib/jox116.jar:SF100/2_a4j/lib/log4j-1.2.4.jar
    classfiles=$(find SF100/2_a4j/ -type f -name "*.class")
elif [ "$proj" = "3_jigen" ]; then
    project_cp=SF100/3_jigen/jigen.jar:SF100/3_jigen/jix.jar:SF100/3_jigen/lib/ant-1.5.1.jar:SF100/3_jigen/lib/filedrop.jar:SF100/3_jigen/lib/jigen-xml-schema.jar:SF100/3_jigen/lib/jsr173_1.0_api.jar:SF100/3_jigen/lib/swing-worker-1.1.jar:SF100/3_jigen/lib/xbean.jar:SF100/3_jigen/lib/xmlpublic.jar
    classfiles=$(find SF100/3_jigen/ -type f -name "*.class")

elif [ "$proj" = "4_rif" ]; then
    project_cp=SF100/4_rif/rif.jar:$(echo SF100/4_rif/lib/*.jar | tr ' ' ':')
    classfiles=$(find SF100/4_rif/ -type f -name "*.class")

elif [ "$proj" = "5_templateit" ]; then
    project_cp=SF100/5_templateit/templateit-1.0-beta4.jar:$(echo SF100/5_templateit/lib/*.jar | tr ' ' ':')
    classfiles=$(find SF100/5_templateit/ -type f -name "*.class")

else 
    echo "project $proj not recognized"
    exit
fi



for classfile in $classfiles; do

    methods=($(java -cp lib/asm-9.5.jar:lib/asm-tree-9.5.jar:src/ MethodExtractor $classfile))

    trimmed_file=$(echo "$classfile" | sed 's|^SF100/$proj/||; s|\.class$||')

    # Replace all slashes with dots
    class=$(echo "$trimmed_file" | sed 's|/|.|g')

    DIR_OUTPUT_PREFIX="output/$proj/$class"

    echo $classfile
    echo $class
    echo $DIR_OUTPUT_PREFIX
    #echo $project_cp

    for TARGET_METHOD in "${methods[@]}"; do
        echo "$TARGET_METHOD"
        DIR_OUTPUT=$DIR_OUTPUT_PREFIX/$(echo "$TARGET_METHOD" | sed 's/\//_/g')/

        if [ -d "$DIR_OUTPUT" ]; then
            continue
        fi

        if [ "$OG" = true ]; then 
            cmd="java -cp /home/edinella/SF100-eval/evosuite-original-1.1.0.jar shaded.org.evosuite.EvoSuite"

        else
            cmd="java -cp /home/edinella/SF100-eval/evosuite-shaded-1.1.0.jar shaded.org.evosuite.EvoSuite"
        fi

        cmd=$cmd"
        -class $class \
            -projectCP $project_cp \
            -seed $D4J_SEED \
            -Dsearch_budget=$budget \
            -Dassertion_timeout=$a_budget \
            -Dtest_dir=$DIR_OUTPUT \
            -Dtarget_method=$TARGET_METHOD \
            -criterion branch \
            -Dstopping_condition=MaxTime \
            -Dshow_progress=false \
            -Djunit_check=false \
            -Dfilter_assertions=false \
            -Dtest_comments=false \
            -Dtimeline_interval=15000 \
            -mem 1500 \
            -Dreport_dir=evosuite-report"

        if ! exec_cmd "$cmd"; then
            exit 1
        fi 

        mv evosuite-report/statistics.csv $DIR_OUTPUT/
    done
done
