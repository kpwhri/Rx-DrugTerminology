/*********************************************
* Adapted from sas_etl/01-merge-omop-vocab.sas
* Original author: John Weeks, Kaiser Permanente Washington
*                  Health Research Institute
* Purpose:: Load the CSV files produced by OHDSI Athena
*
* This keeps the upstream pattern for two of the nine OMOP tables (concept
* and vocabulary): the %sysfunc(exist(...)) first-run vs incremental-load
* branch, and the PROC DATASETS table-swap that promotes the _in table to
* the final name. The vocab. libname is redirected to work; the concept_temp
* and vocabulary_temp inputs are stood up in autoexec.sas. The SAS logic
* itself is unchanged.
*********************************************/

/* Process and Load New Concepts into Concept table  */
%if %sysfunc( exist(concept) ) %then %do;
  proc sql;
  create table concept_in as
    select cp.* from concept cp
    union
    select ctp.*
    from concept_temp ctp
    left outer join concept oct
    on ctp.concept_id = oct.concept_id
      where oct.concept_id is null;
  quit;
%end;
%else %do;
  proc sql;
    create table concept_in as
    select ctp.*
      from concept_temp ctp;
  quit;
%end;

/* Process and Load New vocabulary records into Vocabulary table */
%if %sysfunc( exist(vocabulary) ) %then %do;
proc sql;
  create table vocabulary_in as
    select cp.* from vocabulary cp
    union
    select ctp.*
    from vocabulary_temp ctp
    left outer join vocabulary oct
    on ctp.vocabulary_id = oct.vocabulary_id
    where oct.vocabulary_id is null;
    quit;
    %end;
%else %do;
proc sql;
  create table vocabulary_in as
    select ctp.*
    from vocabulary_temp ctp;
quit;
%end;

/* Delete the temp files */
proc datasets library=work;
  delete vocabulary_temp concept_temp;
run;

/* Move input files into OMOP Vocabulary files */
proc datasets library=work;
  change vocabulary_in=vocabulary concept_in=concept;
run;

proc print data=concept;
  title "OMOP concept table after load";
run;

proc print data=vocabulary;
  title "OMOP vocabulary table after load";
run;
