# Desired Output Format
# Disease|GeneID|prediction-p|PMIDs (max 10)
PRED_DIR=../digenei1

# Current Results
CURR_DIR=../digenei2

PRED_REF_SOURCE=generif
CURR_REF_SOURCE=generif

DIRECT_GD_PREFIX=txt/direct_gene_disease
PROFILE_GD_PREFIX=txt/profile_gene_disease

OUTPUT_DIR=txt

SQL_CMD=mysql-dbrc wcdb

default:	$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p.wikidot \
		$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p-histogram.pdf

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
$(OUTPUT_DIR)/curr-hum-disease-validation-tuples.txt: \
		$(CURR_DIR)/$(DIRECT_GD_PREFIX)/hum-$(CURR_REF_SOURCE)-gene-mesh-p.txt \
		$(PRED_DIR)/$(PROFILE_GD_PREFIX)/mesh-disease.txt \
		filter_file.py
	cat $(CURR_DIR)/$(DIRECT_GD_PREFIX)/hum-$(CURR_REF_SOURCE)-gene-mesh-p.txt | awk -F"|" '{print $$2 "|" $$1 }' | python filter_file.py $(PRED_DIR)/$(PROFILE_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp
	mv $@.tmp $@

# Previous
$(OUTPUT_DIR)/pred-hum-disease-validation-tuples.txt: \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/hum-$(PRED_REF_SOURCE)-gene-mesh-p.txt \
		$(PRED_DIR)/$(PROFILE_GD_PREFIX)/mesh-disease.txt 
	cat $(PRED_DIR)/$(DIRECT_GD_PREFIX)/hum-$(PRED_REF_SOURCE)-gene-mesh-p.txt  | awk -F"|" '{print $$2 "|" $$1 }' | python filter_file.py $(PRED_DIR)/$(PROFILE_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/new-hum-disease-validation-tuples.txt: $(OUTPUT_DIR)/curr-hum-disease-validation-tuples.txt $(OUTPUT_DIR)/pred-hum-disease-validation-tuples.txt 
	comm -23 $(OUTPUT_DIR)/curr-hum-disease-validation-tuples.txt $(OUTPUT_DIR)/pred-hum-disease-validation-tuples.txt > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p.txt: $(OUTPUT_DIR)/new-hum-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/disease-$(PRED_REF_SOURCE)-profiles.txt
	python filter_file.py $(OUTPUT_DIR)/new-hum-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/hum-disease-$(PRED_REF_SOURCE)-profiles.txt 2 > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p.wikidot: \
		$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p.txt \
		wikiformat-results.sh
	sort -n -t "|" -k 12,2 $(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p.txt | head -n 100 > $@.tmp
	export PRED_REF_SOURCE=$(PRED_REF_SOURCE) && cat $@.tmp | sh wikiformat-results.sh > $@.tmp2
	rm $@.tmp ; mv $@.tmp2 $@

$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p-histogram.txt: \
		$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p.txt
	cat $(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p.txt |  python histogram.py 2 > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p-histogram.pdf: \
		$(OUTPUT_DIR)/new-hum-disease-validation-tuples-pred-$(PRED_REF_SOURCE)-p-histogram.txt \
		plot-histogram.R
	export PROCESS_INFILE=$< ; export PROCESS_OUTFILE=$@.tmp ; PROCESS_LABEL="$PRED_REF_SOURCE Profile Prediction Score Histogram" ; R CMD BATCH --no-save plot-histogram.R $@.log
	mv $@.tmp $@


# Extract and connect the prediction values?  Above formats should be made conducive to grep

# then take the difference

# Then compare to predictions and look for prediction rate using our scoring system

# Also compare to direct gene-disease

# Also compare to validation sets

#### Validation (Separate Dataset? Extract validation data)

# OMIM references
# MIM2MeSH mapping

clean:
	rm txt/*.txt