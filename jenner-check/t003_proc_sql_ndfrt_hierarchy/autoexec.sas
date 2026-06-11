options obs=100;

/* --- jenner-check setup ---------------------------------------------------
 * The upstream rx_ndfrt_tx_grp query walks the NDFRT therapeutic-class
 * hierarchy through repeated self-joins of vocab.concept and
 * vocab.concept_relationship. This autoexec seeds a minimal but complete
 * NDFRT chain so every join level resolves to at least one row:
 *
 *   Therapeutic Class --Subsumes--> (category concept)
 *     --Therap class of--> Pharmacologic Class
 *       --Subsumes--> Pharma Preparation / Chemical Structure (the group)
 *
 * Columns match exactly what the nested query selects:
 *   concept(concept_id, concept_code, concept_name, concept_class_id, vocabulary_id)
 *   concept_relationship(concept_id_1, concept_id_2, relationship_id)
 * ------------------------------------------------------------------------- */

data concept;
  length concept_id 8 concept_code $50 concept_name $255 concept_class_id $40 vocabulary_id $20;
  infile datalines dsd dlm='|';
  input concept_id concept_code concept_name concept_class_id vocabulary_id;
  datalines;
100|N0000029143|Cardiovascular Agents|Therapeutic Class|NDFRT
200|N0000029144|Antihyperlipidemic Agents|Therapeutic Category|NDFRT
300|N0000175562|HMG-CoA Reductase Inhibitors|Pharmacologic Class|NDFRT
400|N0000007553|atorvastatin|Pharma Preparation|NDFRT
500|N0000146232|Statin Chemical Structure|Chemical Structure|NDFRT
;
run;

data concept_relationship;
  length concept_id_1 8 concept_id_2 8 relationship_id $30;
  infile datalines dsd dlm='|';
  input concept_id_1 concept_id_2 relationship_id;
  datalines;
100|200|Subsumes
200|300|Therap class of
300|400|Subsumes
300|500|Has chem structure
;
run;
