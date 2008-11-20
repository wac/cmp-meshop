count=13
while [ $count -gt 2 ]
do
  echo Analysing score $count
  echo Sorting
  sort -n -k $count -t "|" -T tmp $1 > $2.sort
  echo "***Score $count***" >> $2
  echo Computing AUC
  python cum_gains_auc.py $2.sort $3-$count.txt >> $2 
  count=`expr $count - 1`
done
