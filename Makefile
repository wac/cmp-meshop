# Put options you want to change in a new file called config.mk
include config.mk.default
sinclude config.mk

# Desired Output Format
# Disease|GeneID|prediction-p|PMIDs (max 10)

default:	$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.wikidot \
		$(OUTPUT_DIR)/new-nejm-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.wikidot \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p-histogram.pdf \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-auc.txt \
		$(OUTPUT_DIR)/CTD-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/new-CTD-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-cancer-validation-auc.txt \
		$(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-auc.txt \
		$(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/$(REF_SOURCE)-biomart-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/CTD-biomart-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/CTD-gene-stats-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-training-auc.txt \
		$(OUTPUT_DIR)/$(REF_SOURCE)-gene-gci-$(TAXON_NAME)-disease-validation-auc.txt \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-training-auc.txt \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-validation-auc.txt \
		$(OUTPUT_DIR)/all-pharma-chem-disease-validation-auc.txt
#		$(OUTPUT_DIR)/curr-old-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt \
#		$(OUTPUT_DIR)/rev-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt 
	rm -f $(BIGTMP_DIR)/*

# Take the results from the direct in 2
# compare to the results in the profile from 1
# Generate Master dataset which lists gene-disease pairs, 
# presence/absence from each dataset,  and scores in each dataset

# Want "New Predictions" ... So do the difference between Pred and Curr for
# Direct relations

# Take Direct predictions and expand via mesh-child
# cut the direct predictions and reorder via term 
# expand using join

# Use date filter instead of direct validation tuples to construct new tuples
# Still need pred tuples to filter for predictions


#$(OUTPUT_DIR)/curr-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt: \
#		$(CURR_DIR)/$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
#		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt \
#		filter_file.py
#	cat $(CURR_DIR)/$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt | awk -F"|" '{print $$2 "|" $$1 }' | python filter_file.py $(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp
#	mv $@.tmp $@

#$(OUTPUT_DIR)/curr-old-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt:
#	echo "SELECT DISTINCT pubmed_mesh_parent.mesh_parent, gene.gene_id FROM gene, $(REF_SOURCE), pubmed, pubmed_mesh_parent WHERE gene.taxon_id=$(TAXON_ID) AND gene.gene_id=$(REF_SOURCE).gene_id AND $(REF_SOURCE).pmid=pubmed.pmid AND pubmed.pmid=pubmed_mesh_parent.pmid AND pubmed.pubyear <= $(FILTER_YEAR)" | $(SQL_CMD2) | sed "y/\t/\|/" | python filter_file.py $(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp

# Directly only take term-gene refs involving year > FILTER_YEAR
$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt: $(CURR_DIR)/$(SQL_PREFIX)/load-mesh-parent.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-gene.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-titles.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-$(REF_SOURCE).txt \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt
	echo "SELECT DISTINCT pubmed_mesh_parent.mesh_parent, gene.gene_id FROM gene, $(REF_SOURCE), pubmed, pubmed_mesh_parent WHERE gene.taxon_id=$(TAXON_ID) AND gene.gene_id=$(REF_SOURCE).gene_id AND $(REF_SOURCE).pmid=pubmed.pmid AND pubmed.pmid=pubmed_mesh_parent.pmid GROUP BY gene.gene_id, pubmed_mesh_parent.mesh_parent HAVING MIN(pubmed.pubyear) > $(FILTER_YEAR)" | $(SQL_CMD2) | sed "y/\t/\|/" | python filter_file.py $(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp && \
	mv $@.tmp $@

# Previous
$(OUTPUT_DIR)/pred-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt: \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt 
	cat $(PRED_DIR)/$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt  | awk -F"|" '{print $$2 "|" $$1 }' | python filter_file.py $(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp && \
	mv $@.tmp $@

#$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt: $(OUTPUT_DIR)/curr-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(OUTPUT_DIR)/curr-old-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt
#	comm -23 $(OUTPUT_DIR)/curr-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(OUTPUT_DIR)/curr-old-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt > $@.tmp
#	mv $@.tmp $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt: $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt
	python filter_file.py $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.wikidot: \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		wikiformat-results.sh
	sort -n -t "|" -k 12,2 $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | head -n 100 > $@.tmp && \
	export REF_SOURCE=$(REF_SOURCE) && export SQL_CMD2=$(SQL_CMD2) && cat $@.tmp | sh wikiformat-results.sh > $@.tmp2 && \
	rm $@.tmp ; mv $@.tmp2 $@

$(OUTPUT_DIR)/new-nejm-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.wikidot: \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		nejm-wikiformat-results.sh
	sort -n -t "|" -k 12,2 $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt > $@.tmp && \
	export REF_SOURCE=$(REF_SOURCE) && export SQL_CMD2=$(SQL_CMD2) && cat $@.tmp | sh nejm-wikiformat-results.sh | grep -v "|| ||" > $@.tmp2 && \
	rm $@.tmp ; mv $@.tmp2 $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p-histogram.txt: \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		histogram.py
	cat $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt |  python histogram.py 2 > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p-histogram.pdf: \
		$(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p-histogram.txt \
		plot-histogram.R
	export PROCESS_INFILE=$< ; export PROCESS_OUTFILE=$@.tmp ; PROCESS_LABEL="$REF_SOURCE Profile Prediction Score Histogram" ; R CMD BATCH --no-save plot-histogram.R $@.log && \
	mv $@.tmp $@

# Filter the prediction file using the new tuples
# some won't map because of new genes or genes without literature at 
# prediction time
$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt: $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# Filtered output
$(OUTPUT_DIR)/mesh-cancer.txt: \
		$(CURR_DIR)/$(SQL_PREFIX)/load-mesh-parent.txt
	echo "SELECT child FROM mesh_child WHERE term='Neoplasms'" | $(SQL_CMD) | tail -n +2 > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-cancer-validation-tuples-pred-p.txt: \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		$(OUTPUT_DIR)/mesh-cancer.txt \
		tf-list.txt 
	cat $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | python filter_file.py $(OUTPUT_DIR)/mesh-cancer.txt -f 1 | python filter_file.py tf-list.txt -f 2 > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-cancer-validation-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-cancer-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-cancer-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

$(OUTPUT_DIR)/mesh-braindisease.txt: \
		$(CURR_DIR)/$(SQL_PREFIX)/load-mesh-parent.txt
	echo "SELECT child FROM mesh_child WHERE term='Brain Diseases'" | $(SQL_CMD) | tail -n +2 > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-braindisease-validation-tuples-pred-p.txt: \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		$(OUTPUT_DIR)/mesh-braindisease.txt \
		tf-list.txt 
	cat $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | python filter_file.py $(OUTPUT_DIR)/mesh-braindisease.txt -f 1 | python filter_file.py tf-list.txt -f 2 > $@.tmp
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-braindisease-validation-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-braindisease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-tf-braindisease-validation-graph-score roc.py
#	rm -f $(BIGTMP_DIR)/*
	rm -f $@.tmp.sort
	mv $@.tmp $@


# Tuples from the Prediction Set only (Training Set)

$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-tuples-pred-p.txt:  $(OUTPUT_DIR)/pred-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt  $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py  $(OUTPUT_DIR)/pred-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# BG predictions
$(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt: $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py $(OUTPUT_DIR)/new-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt: $(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort
	mv $@.tmp $@

#BG Training

$(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-tuples-pred-p.txt:  $(OUTPUT_DIR)/pred-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt  $(PRED_DIR)/$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py  $(OUTPUT_DIR)/pred-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-auc.txt: $(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/BG-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-graph-score roc.py && \
	rm -f $@.tmp.sort
	mv $@.tmp $@

# REF_SOURCE / BioMart validation
# Use awk to put the join field in the right place
$(OUTPUT_DIR)/$(REF_SOURCE)-biomart-$(TAXON_NAME)-disease-validation-tuples-pred.txt:  $(BIOMART_FILE) \
		 $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt 
	cut -f 1,2,3 -d "|" $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | sort -k 3,3 -t "|" -T $(BIGTMP_DIR) > $@.tmp1 && \
	sort -k 1,1 -u -t "|" -T $(BIGTMP_DIR) $(BIOMART_FILE) > $@.tmp2 && \
	join -t "|" -1 3 -2 1 $@.tmp1 $@.tmp2 |  awk -F "|"  '{printf "%s|%s|%s", $$2, $$3, $$1; for (i=4; i <= NF; i++) {printf "|%s", $$i}; print "" } ' > $@.tmp && \
	rm -f $@.tmp1 $@.tmp2 && \
	mv $@.tmp $@

$(OUTPUT_DIR)/$(REF_SOURCE)-biomart-$(TAXON_NAME)-disease-validation-auc.txt:  $(OUTPUT_DIR)/$(REF_SOURCE)-biomart-$(TAXON_NAME)-disease-validation-tuples-pred.txt \
		auc.sh roc.py
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/$(REF_SOURCE)-biomart-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# CTD / Biomart
# Use awk to put the join field in the right place
$(OUTPUT_DIR)/CTD-biomart-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred.txt:  $(BIOMART_FILE) \
		$(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt
	cut -f 1,2,3 -d "|" $(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | sort -k 3,3 -t "|" -T $(BIGTMP_DIR) > $@.tmp1 && \
	sort -u -k 1,1 -t "|" -T $(BIGTMP_DIR) $(BIOMART_FILE) > $@.tmp2 && \
	join -t "|" -1 3 -2 1 $@.tmp1 $@.tmp2 |  awk -F "|"  '{printf "%s|%s|%s", $$2, $$3, $$1; for (i=4; i <= NF; i++) {printf "|%s", $$i}; print "" } ' > $@.tmp && \
	rm -f $@.tmp1 $@.tmp2 && \
	mv $@.tmp $@

$(OUTPUT_DIR)/CTD-biomart-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt:  $(OUTPUT_DIR)/CTD-biomart-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred.txt \
		auc.sh roc.py
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/CTD-biomart-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# Validate gene stats
# Use awk to put the join field in the right place

$(OUTPUT_DIR)/CTD-gene-stats-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred.txt:  $(PRED_DIR)/$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-stats.txt  \
		$(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt
	cut -f 1,2,3 -d "|" $(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | sort -k 3,3 -t "|" -T $(BIGTMP_DIR) > $@.tmp1 && \
	cat $< | sed "y/\t/\|/" | sort -k 1,1 -t "|" -T $(BIGTMP_DIR) > $@.tmp2 && \
	join -t "|" -1 3 -2 1 $@.tmp1 $@.tmp2 |  awk -F "|"  '{printf "%s|%s|%s", $$2, $$3, $$1; for (i=4; i <= NF; i++) {printf "|%s", $$i}; print "" } ' > $@.tmp && \
	rm -f $@.tmp1 $@.tmp2 && \
	mv $@.tmp $@

$(OUTPUT_DIR)/CTD-gene-stats-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt:  $(OUTPUT_DIR)/CTD-gene-stats-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred.txt \
		auc.sh roc.py
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/CTD-biomart-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# REF_SOURCE / pubmed stats
#FIXED sort numeric
# Use awk to put the join field in the right place
$(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-validation-tuples-pred.txt:  $(PRED_DIR)/$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-stats.txt \
		 $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt 
	cut -f 1,2,3 -d "|" $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | sort -k 3,3 -t "|" -T $(BIGTMP_DIR) > $@.tmp1 && \
	cat $< | sed "y/\t/\|/" | sort -k 1,1 -t "|" -T $(BIGTMP_DIR) > $@.tmp2 && \
	join -t "|" -1 3 -2 1 $@.tmp1 $@.tmp2 |  awk -F "|"  '{printf "%s|%s|%s", $$2, $$3, $$1; for (i=4; i <= NF; i++) {printf "|%s", $$i}; print "" } ' > $@.tmp && \
	rm -f $@.tmp1 $@.tmp2 && \
	mv $@.tmp $@

$(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-validation-auc.txt:  $(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-validation-tuples-pred.txt \
		auc.sh roc.py
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

## Stats on training set
$(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-training-tuples-pred.txt:  $(PRED_DIR)/$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-stats.txt \
		 $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-tuples-pred-p.txt 
	cut -f 1,2,3 -d "|" $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-training-tuples-pred-p.txt | sort -k 3,3 -t "|" -T $(BIGTMP_DIR) > $@.tmp1 && \
	cat $< | sed "y/\t/\|/" | sort -k 1,1 -t "|" -T $(BIGTMP_DIR) > $@.tmp2 && \
	join -t "|" -1 3 -2 1 $@.tmp1 $@.tmp2 |  awk -F "|"  '{printf "%s|%s|%s", $$2, $$3, $$1; for (i=4; i <= NF; i++) {printf "|%s", $$i}; print "" } ' > $@.tmp && \
	rm -f $@.tmp1 $@.tmp2 && \
	mv $@.tmp $@

$(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-training-auc.txt:  $(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-training-tuples-pred.txt \
		auc.sh roc.py
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-training-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

$(OUTPUT_DIR)/$(REF_SOURCE)-hum-gene-stats2.txt: \
		$(PRED_DIR)/$(SQL_PREFIX)/load-gene.txt \
		$(PRED_DIR)/$(SQL_PREFIX)/load-$(REF_SOURCE).txt  \
		$(PRED_DIR)/$(SQL_PREFIX)/load-titles.txt
	echo "SELECT gene.gene_id, COUNT(DISTINCT pubmed.pmid) FROM gene, pubmed, $(REF_SOURCE) WHERE gene.gene_id=$(REF_SOURCE).gene_id AND gene.taxon_id=$(TAXON_ID) AND $(REF_SOURCE).pmid=pubmed.pmid AND pubmed.pubyear>=$(FILTER_YEARMIN) GROUP BY gene.gene_id" | $(SQL_CMD) > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats2-$(TAXON_NAME)-disease-validation-tuples-pred.txt: \
		$(OUTPUT_DIR)/$(REF_SOURCE)-hum-gene-stats2.txt \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt 
	cut -f 1,2,3 -d "|" $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | sort -k 3,3 -t "|" -T $(BIGTMP_DIR) > $@.tmp1 && \
	cat $< | sed "y/\t/\|/" | sort -k 1,1 -t "|" -T $(BIGTMP_DIR) > $@.tmp2 && \
	join -t "|" -1 3 -2 1 $@.tmp1 $@.tmp2 |  awk -F "|"  '{printf "%s|%s|%s", $$2, $$3, $$1; for (i=4; i <= NF; i++) {printf "|%s", $$i}; print "" } ' > $@.tmp && \
	rm -f $@.tmp1 $@.tmp2 && \
	mv $@.tmp $@

$(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats2-$(TAXON_NAME)-disease-validation-auc.txt:  $(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats2-$(TAXON_NAME)-disease-validation-tuples-pred.txt \
		auc.sh roc.py
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/$(REF_SOURCE)-gene-stats-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@


# GCI scoring
$(OUTPUT_DIR)/$(REF_SOURCE)-gene-gci-$(TAXON_NAME)-disease-validation-tuples-pred.txt:  $(GCI_FILE) \
		 $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt 
	cut -f 1,2,3 -d "|" $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt | sort -k 3,3 -t "|" -T $(BIGTMP_DIR) > $@.tmp1 && \
	cat $< | sed "y/,/\|/" | sort -k 1,1 -t "|" -T $(BIGTMP_DIR) > $@.tmp2 && \
	join -t "|" -1 3 -2 1 $@.tmp1 $@.tmp2 |  awk -F "|"  '{printf "%s|%s|%s", $$2, $$3, $$1; for (i=4; i <= NF; i++) {printf "|%s", $$i}; print "" } ' > $@.tmp && \
	rm -f $@.tmp1 $@.tmp2 && \
	mv $@.tmp $@

$(OUTPUT_DIR)/$(REF_SOURCE)-gene-gci-$(TAXON_NAME)-disease-validation-auc.txt:  $(OUTPUT_DIR)/$(REF_SOURCE)-gene-gci-$(TAXON_NAME)-disease-validation-tuples-pred.txt \
		auc.sh roc.py
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/$(REF_SOURCE)-gene-gci-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# Extract and connect the prediction values?  Above formats should be made conducive to grep

# then take the difference

# Then compare to predictions and look for prediction rate using our scoring system

# Also compare to direct gene-disease

# Also compare to validation sets

#### Validation (Separate Dataset? Extract validation data)

# CTD Validation

$(OUTPUT_DIR)/pred-CTD-validation-tuples.txt: $(CTD_FILE1)
	grep -v inferred $< | grep "MESH:" | sed "y/\t/\|/" | cut -f 2,4 -d "|"  |  sed "s/MESH://" | sort -k 2 -t "|" | join -1 1 -2 2 -t "|" $(CURR_DIR)/$(MESH_PREFIX)/mesh_ids.txt - | cut -f 2,3 -d "|" | sort > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/curr-CTD-validation-tuples.txt: $(CTD_FILE2)
	grep -v inferred $< | grep "MESH:" | sed "y/\t/\|/" | cut -f 2,4 -d "|"  |  sed "s/MESH://" | sort -k 2 -t "|" | join -1 1 -2 2 -t "|" $(CURR_DIR)/$(MESH_PREFIX)/mesh_ids.txt - | cut -f 2,3 -d "|" | sort > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/new-CTD-validation-tuples.txt: \
		$(OUTPUT_DIR)/pred-CTD-validation-tuples.txt \
		$(OUTPUT_DIR)/curr-CTD-validation-tuples.txt
	comm -23 $(OUTPUT_DIR)/curr-CTD-validation-tuples.txt $(OUTPUT_DIR)/pred-CTD-validation-tuples.txt >$@.tmp && \
	mv $@.tmp $@

# CTD AUC for "pred" set

$(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt: $(OUTPUT_DIR)/pred-CTD-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py $(OUTPUT_DIR)/pred-CTD-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/CTD-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt: $(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# CTD AUC for "new" set

$(OUTPUT_DIR)/new-CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt: $(OUTPUT_DIR)/new-CTD-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py $(OUTPUT_DIR)/new-CTD-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/new-CTD-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-auc.txt: $(OUTPUT_DIR)/new-CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/new-CTD-all-$(REF_SOURCE)-$(TAXON_NAME)-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# OMIM references
# MIM2MeSH mapping
$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-training-tuples-pred-p.txt: $(MIM2GENE_FILE1) $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py $< $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-training-auc.txt: $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-training-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-training-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# MIM2Gene Difference Set
$(OUTPUT_DIR)/new-mim2gene-validation-tuples.txt: \
		$(MIM2GENE_FILE1) $(MIM2GENE_FILE2)
	sort $(MIM2GENE_FILE1) > $@.tmp1 && \
	sort $(MIM2GENE_FILE2) > $@.tmp2 && \
	comm -23 $@.tmp2 $@.tmp1 > $@.tmp && \
	rm $@.tmp1 $@.tmp2 && \
	mv $@.tmp $@ 

$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-validation-tuples-pred-p.txt: \
		$(OUTPUT_DIR)/new-mim2gene-validation-tuples.txt \
		$(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 
	python filter_file.py $< $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-validation-auc.txt: \
		$(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-$(REF_SOURCE)-$(TAXON_NAME)-mim2gene-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# Directly only take term-gene refs involving year > FILTER_YEAR
$(OUTPUT_DIR)/new-chem-disease-validation-tuples.txt: $(CURR_DIR)/$(SQL_PREFIX)/load-mesh-parent.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-gene.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-titles.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-$(REF_SOURCE).txt \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt
	echo "SELECT DISTINCT pubmed_mesh_parent.mesh_parent, pubmed_chem.term FROM pubmed_chem, pubmed, pubmed_mesh_parent WHERE pubmed_chem.pmid=pubmed.pmid AND pubmed.pmid=pubmed_mesh_parent.pmid GROUP BY pubmed_chem.term, pubmed_mesh_parent.mesh_parent HAVING MIN(pubmed.pubyear) > $(FILTER_YEAR)" | $(SQL_CMD2) | sed "y/\t/\|/" | python filter_file.py $(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-chem-disease-validation-tuples-pred-p.txt: \
		$(OUTPUT_DIR)/new-chem-disease-validation-tuples.txt \
		$(PRED_DIR)/$(PROFILE_GD_PREFIX)/disease-chem-profiles.txt 
	python filter_file.py $< $(PRED_DIR)/$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-chem-disease-validation-auc.txt: \
		$(OUTPUT_DIR)/all-chem-disease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-chem-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# Directly only take chem-disease refs involving year > FILTER_YEAR
$(OUTPUT_DIR)/new-pharma-chem-disease-validation-tuples.txt: $(CURR_DIR)/$(SQL_PREFIX)/load-mesh-parent.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-chem.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-titles.txt \
		$(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt
	echo "SELECT DISTINCT pubmed_mesh_parent.mesh_parent, pubmed_chem.term FROM pubmed_chem, pubmed, pubmed_mesh_parent WHERE pubmed_chem.pmid=pubmed.pmid AND pubmed.pmid=pubmed_mesh_parent.pmid GROUP BY pubmed_chem.term, pubmed_mesh_parent.mesh_parent HAVING MIN(pubmed.pubyear) > $(FILTER_YEAR)" | $(SQL_CMD2) | sed "y/\t/\|/" | python filter_file.py $(PRED_DIR)/$(DIRECT_GD_PREFIX)/mesh-disease.txt | sort > $@.tmp && \
	mv $@.tmp $@

# Chem-disease AUC
$(OUTPUT_DIR)/all-pharma-chem-disease-validation-tuples-pred-p.txt: \
		$(OUTPUT_DIR)/new-pharma-chem-disease-validation-tuples.txt 
	python filter_file.py $(OUTPUT_DIR)/new-pharma-chem-disease-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/disease-pharma-chem-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-pharma-chem-disease-validation-auc.txt: $(OUTPUT_DIR)/all-pharma-chem-disease-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-pharma-chem-disease-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

# MeSH Term Attachment
# Directly only take mesh-mesh refs involving year > FILTER_YEAR
$(OUTPUT_DIR)/new-comesh-validation-tuples.txt: $(CURR_DIR)/$(SQL_PREFIX)/load-mesh-parent.txt \
		$(CURR_DIR)/$(SQL_PREFIX)/load-titles.txt 
	echo "SELECT DISTINCT pubmed_mesh_parent.mesh_parent, pmp2.mesh_parent FROM pubmed_mesh_parent as pmp2, pubmed, pubmed_mesh_parent WHERE pmp2.pmid=pubmed.pmid AND pubmed.pmid=pubmed_mesh_parent.pmid GROUP BY pmp2.mesh_parent, pubmed_mesh_parent.mesh_parent HAVING MIN(pubmed.pubyear) > $(FILTER_YEAR)" | $(SQL_CMD2) | sed "y/\t/\|/" | sort > $@.tmp && \
	mv $@.tmp $@

# comesh AUC
$(OUTPUT_DIR)/all-comesh-validation-tuples-pred-p.txt: \
		$(OUTPUT_DIR)/new-comesh-validation-tuples.txt \
		$(PRED_DIR)/$(PROFILE_GD_PREFIX)/all-comesh-profiles.txt
	python filter_file.py $(OUTPUT_DIR)/new-comesh-validation-tuples.txt $(PRED_DIR)/$(PROFILE_GD_PREFIX)/all-comesh-profiles.txt 2 YN > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/all-comesh-validation-auc.txt: $(OUTPUT_DIR)/all-comesh-validation-tuples-pred-p.txt \
		auc.sh roc.py 
	rm -f $@.tmp && \
	export BIGTMP_DIR=$(BIGTMP_DIR) ; sh auc.sh $< $@.tmp $(OUTPUT_DIR)/all-comesh-validation-graph-score roc.py && \
	rm -f $@.tmp.sort && \
	mv $@.tmp $@

$(OUTPUT_DIR)/pred-CTD-chem-validation-tuples.txt: $(CTD_CHEM_FILE1)
	cat $< | awk '$$6 ~ /therapeutic|marker\/mechanism/' | grep "MESH:" | sed "y/\t/\|/" | cut -f 1,5 -d "|"  |  sed "s/MESH://" | sort -k 2 -t "|" | join -1 1 -2 2 -t "|" $(CURR_DIR)/$(MESH_PREFIX)/mesh_ids.txt - | cut -f 2,3 -d "|" | sort > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/curr-CTD-chem-validation-tuples.txt: $(CTD_CHEM_FILE2)
	cat $< | awk '$$6 ~ /therapeutic|marker\/mechanism/' | grep "MESH:" | sed "y/\t/\|/" | cut -f 1,5 -d "|"  |  sed "s/MESH://" | sort -k 2 -t "|" | join -1 1 -2 2 -t "|" $(CURR_DIR)/$(MESH_PREFIX)/mesh_ids.txt - | cut -f 2,3 -d "|" | sort > $@.tmp && \
	mv $@.tmp $@

$(OUTPUT_DIR)/new-CTD-chem-validation-tuples.txt: \
		$(OUTPUT_DIR)/pred-CTD-chem-validation-tuples.txt \
		$(OUTPUT_DIR)/curr-CTD-chem-validation-tuples.txt
	comm -23 $(OUTPUT_DIR)/curr-CTD-chem-validation-tuples.txt $(OUTPUT_DIR)/pred-CTD-chem-validation-tuples.txt >$@.tmp && \
	mv $@.tmp $@


clean:
	rm -f txt/*.txt
	rm -f txt/*.tmp
	rm -f $(BIGTMP_DIR)/*

