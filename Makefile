# Desired Output Format
# Disease|GeneID|prediction-p|PMIDs (max 10)
PRED_DIR=../digenei1

# Current Results
CURR_DIR=../digenei2

REF_SOURCE=generif

DIRECT_GD_PREFIX=txt/direct_gene_disease
PROFILE_GD_PREFIX=txt/profile_gene_disease

OUTPUT_DIR=txt

BIGTMP_DIR=tmp

SQL_CMD=mysql-dbrc wcdb

# Location of the CTD gene_disease_relations.tsv
CTD_DIR=CTD

# Put options you want to change in a new file called config.mk
-include config.mk

default:	$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.wikidot \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p-histogram.pdf \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-auc.txt \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-training-auc.txt \
		$(OUTPUT_DIR)/CTD-$(REF_SOURCE)-hum-disease-validation-auc.txt
#		$(OUTPUT_DIR)/rev-all-$(REF_SOURCE)-hum-disease-validation-auc.txt 

# Take the results from the direct in 2
# compare to the results in the profile from 1
# Generate Master dataset which lists gene-disease pairs, 
# presence/absence from each dataset,  and scores in each dataset

# Want "New Predictions" ... So do the difference between Pred and Curr for
# Direct relations

# Take Direct predictions and expand via mesh-child
# cut the direct predictions and reorder via term 
# expand using join

# Current
$(OUTPUT_DIR)/curr-$(REF_SOURCE)-hum-disease-validation-tuples.txt: \
		$(CURR_DIR)/$(DIRECT_GD_PREFIX)/hum-$(REF_SOURCE)-gene-mesh-p.txt \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt \
		filter_file.py
	cat $(CURR_DIR)/$(DIRECT_GD_PREFIX)/hum-$(REF_SOURCE)-gene-mesh-p.txt | awk -F"|" '{print $$2 "|" $$1 }' | python filter_file.py $(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp
	mv $@.tmp $@

# Previous
$(OUTPUT_DIR)/pred-$(REF_SOURCE)-hum-disease-validation-tuples.txt: \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/hum-$(REF_SOURCE)-gene-mesh-p.txt \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt 
	cat $(PRED_DIR)/$(DIRECT_GD_PREFIX)/hum-$(REF_SOURCE)-gene-mesh-p.txt  | awk -F"|" '{print $$2 "|" $$1 }' | python filter_file.py $(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples.txt: $(OUTPUT_DIR)/curr-$(REF_SOURCE)-hum-disease-validation-tuples.txt $(OUTPUT_DIR)/pred-$(REF_SOURCE)-hum-disease-validation-tuples.txt 
	comm -23 $(OUTPUT_DIR)/curr-$(REF_SOURCE)-hum-disease-validation-tuples.txt $(OUTPUT_DIR)/pred-$(REF_SOURCE)-hum-disease-validation-tuples.txt > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt: $(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(REF_SOURCE)-profiles.txt
	python filter_file.py $(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(REF_SOURCE)-profiles.txt 2 > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.wikidot: \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt \
		wikiformat-results.sh
	sort -n -t "|" -k 12,2 $(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt | head -n 100 > $@.tmp
	export REF_SOURCE=$(REF_SOURCE) && cat $@.tmp | sh wikiformat-results.sh > $@.tmp2
	rm $@.tmp ; mv $@.tmp2 $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p-histogram.txt: \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt \
		histogram.py
	cat $(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt |  python histogram.py 2 > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p-histogram.pdf: \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p-histogram.txt \
		plot-histogram.R
	export PROCESS_INFILE=$< ; export PROCESS_OUTFILE=$@.tmp ; PROCESS_LABEL="$REF_SOURCE Profile Prediction Score Histogram" ; R CMD BATCH --no-save plot-histogram.R $@.log
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt: $(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py $(OUTPUT_DIR)/new-$(REF_SOURCE)-hum-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp
	sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-graph-score roc.py
	rm -f $(BIGTMP_DIR)/*
	rm -f $@.tmp.sort
	mv $@.tmp $@

#$(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt \
#		auc.sh \
#		cum_gains_auc.py 
#	rm -f $@.tmp
#	sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-graph-score cum_gains_auc.py
#	rm -f $(BIGTMP_DIR)/*
#	rm -f $@.tmp.sort
#	mv $@.tmp $@

#$(OUTPUT_DIR)/rev-all-$(REF_SOURCE)-hum-disease-validation-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt \
#		rev_cum_gains_auc.sh \
#		cum_gains_auc.py 
#	rm -f $@.tmp
#	sh rev_cum_gains_auc.sh $< $@.tmp $(OUTPUT_DIR)/rev-all-$(REF_SOURCE)-hum-disease-validation-graph
#	rm -f $(BIGTMP_DIR)/*
#	rm -f $@.tmp.sort
#	mv $@.tmp $@

# Training Set (Old) AUC

$(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-training-tuples-pred-p.txt:  $(OUTPUT_DIR)/pred-$(REF_SOURCE)-hum-disease-validation-tuples.txt  $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py  $(OUTPUT_DIR)/pred-$(REF_SOURCE)-hum-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-training-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-training-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp
	sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-hum-disease-training-graph-score roc.py
	rm -f $(BIGTMP_DIR)/*
	rm -f $@.tmp.sort
	mv $@.tmp $@


# Extract and connect the prediction values?  Above formats should be made conducive to grep

# then take the difference

# Then compare to predictions and look for prediction rate using our scoring system

# Also compare to direct gene-disease

# Also compare to validation sets

#### Validation (Separate Dataset? Extract validation data)

# CTD Validation

$(OUTPUT_DIR)/CTD-validation-tuples.txt: $(CTD_DIR)/gene_disease_relations.tsv
	grep -v inferred $< | grep "MESH:D" | sed "y/\t/\|/" | cut -f 2,3 -d "|" | awk -F"|" '{print  $$2 "|" $$1}' | sort -k 1,2 -t "|" > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt: $(OUTPUT_DIR)/CTD-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py $(OUTPUT_DIR)/CTD-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/CTD-$(REF_SOURCE)-hum-disease-validation-auc.txt: $(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-hum-disease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp
	sh auc.sh $< $@.tmp $(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-hum-disease-validation-graph-score roc.py
	rm -f $(BIGTMP_DIR)/*
	rm -f $@.tmp.sort
	mv $@.tmp $@
# OMIM references
# MIM2MeSH mapping

clean:
	rm txt/*.txt
