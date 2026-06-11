options obs=100;

/* --- jenner-check setup ---------------------------------------------------
 * The upstream 01-merge-omop-vocab.sas reads the OMOP Vocabulary CSV exports
 * that Athena produces and loads them into the vocab library. So a single
 * self-contained script.sas reproduces the load end to end, this autoexec
 * stands up small concept_temp and vocabulary_temp samples inline (the same
 * columns and informats the upstream INFILE/INPUT steps read), and maps the
 * vocab library to work. The %sysfunc(exist(...)) first-run logic and the
 * PROC DATASETS table swap in script.sas then run exactly as written upstream.
 * ------------------------------------------------------------------------- */
data concept_temp;
  length concept_id 8 concept_code $50 concept_name $255 vocabulary_id $20 concept_class_id $20 standard_concept $1;
  infile datalines dsd dlm='09'x;
  input concept_id :11. concept_code :$50. concept_name :$255. vocabulary_id :$20. concept_class_id :$20. standard_concept :$1.;
  output;
  datalines;
617314	617314	Atorvastatin 10 MG Oral Tablet	RxNorm	Clinical Drug	S
861007	861007	Metformin 500 MG Oral Tablet	RxNorm	Clinical Drug	S
44819	NDFRT0001	HMG-CoA Reductase Inhibitors	NDFRT	Mechanism of Action	C
;
run;

data vocabulary_temp;
  length vocabulary_id $20 vocabulary_name $255 vocabulary_reference $255 vocabulary_version $255 vocabulary_concept_id 8;
  infile datalines dsd dlm='09'x;
  input vocabulary_id :$20. vocabulary_name :$255. vocabulary_reference :$255. vocabulary_version :$255. vocabulary_concept_id :11.;
  output;
  datalines;
RxNorm	RxNorm	https://www.nlm.nih.gov/research/umls/rxnorm/	RxNorm 20230904	44819104
NDFRT	National Drug File - Reference Terminology	https://www.nlm.nih.gov/	NDFRT 2018	44819114
;
run;
