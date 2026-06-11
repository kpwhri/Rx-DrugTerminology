/*********************************************
* Adapted from sas_etl/02-load-VDW-CB.sas
* Original author: John Weeks, Kaiser Permanente Washington
*                  Health Research Institute
* Purpose:: Create the VDW Codebucket from VDW Codes and OMOP Codes
*
* Only the libname prefixes were redirected to the work library so the
* sample data in autoexec.sas resolves; the monotonic() id column and the
* eight-way UNION over vocabulary_id filters are exactly as written upstream.
*********************************************/

proc sql;
  create table vdw_codebucket as
    select monotonic() as code_id, cds.* from (
    select code, code_type, code_desc, code_source from work.vdw_standard_codes
    union
    select concept_code as code, 'NDFRT' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from work.concept where lower(vocabulary_id) = 'ndfrt'
    union
    select concept_code as code, 'ATC' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from work.concept where lower(vocabulary_id) = 'atc'
    union
    select concept_code as code, 'NDC' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from work.concept where lower(vocabulary_id) = 'ndc'
    union
    select concept_code as code, 'RxNorm' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from work.concept where lower(vocabulary_id) = 'rxnorm'
    union
    select concept_code as code, 'RxNorm_Extension' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from work.concept where lower(vocabulary_id) = 'rxnorm extension'
    union
    select concept_code as code, 'SNOMED' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from work.concept where lower(vocabulary_id) = 'snomed'
    union
    select concept_code as code, 'GCN_SEQNO' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from work.concept where lower(vocabulary_id) = 'gcn_seqno'
    ) cds
    ;
quit;

proc print data=vdw_codebucket;
  title "VDW Codebucket (sample)";
run;
