options obs=100;

/* --- jenner-check setup ---------------------------------------------------
 * The upstream 02-load-VDW-CB.sas reads two external libnames:
 *   dat.vdw_standard_codes  (a local VDW Standard Codes SAS dataset)
 *   vocab.concept           (the OHDSI OMOP Vocabulary, downloaded from Athena)
 * Neither ships in the repo, so this autoexec stands up small in-memory
 * samples with the exact columns the PROC SQL below selects: code/code_type/
 * code_desc/code_source for the VDW side, and concept_code/vocabulary_id/
 * concept_name for the OMOP side. The UNION logic that follows is the author's,
 * unchanged.
 * ------------------------------------------------------------------------- */
data work.vdw_standard_codes;
  length code $50 code_type $20 code_desc $255 code_source $30;
  infile datalines dsd dlm='|';
  input code code_type code_desc code_source;
  datalines;
00071015523|NDC|Lipitor 10 MG Oral Tablet|VDW_LOCAL
00071015623|NDC|Lipitor 20 MG Oral Tablet|VDW_LOCAL
00378018201|NDC|Metformin 500 MG Oral Tablet|VDW_LOCAL
N0000146232|NDFRT|HMG-CoA Reductase Inhibitors|VDW_LOCAL
A10BA02|ATC|metformin|VDW_LOCAL
;
run;

data work.concept;
  length concept_code $50 vocabulary_id $20 concept_name $255;
  infile datalines dsd dlm='|';
  input concept_code vocabulary_id concept_name;
  datalines;
617314|RxNorm|Atorvastatin 10 MG Oral Tablet
617318|RxNorm|Atorvastatin 20 MG Oral Tablet
861007|RxNorm|Metformin 500 MG Oral Tablet
00071015523|NDC|atorvastatin calcium 10 MG tablet
00378018201|NDC|metformin hydrochloride 500 MG tablet
N0000146232|NDFRT|Hydroxymethylglutaryl-CoA Reductase Inhibitors
A10BA02|ATC|metformin
73178|SNOMED|Product containing atorvastatin
OMOP4821|RxNorm Extension|atorvastatin / ezetimibe Oral Tablet
012345|GCN_SEQNO|atorvastatin 10 MG
;
run;
