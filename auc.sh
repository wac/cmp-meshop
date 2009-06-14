#count=13
count=`head -n 1 $1 | awk -F "|" '{print NF}'`

while [ $count -gt 2 ]
do
  echo Analysing score $count
  echo Sorting
  sort -n -k $count -t "|" -T $BIGTMP_DIR $1 > $2.sort
  head -n 100 $2.sort > $3-$count.top100.txt
  tail -n 100 $2.sort > $3-$count.last100.txt
  echo "***Score $count***" >> $2
  echo Computing AUC
  python $4 $2.sort $3-$count.txt >> $2 
  rm $2.sort
  count=`expr $count - 1`
done
