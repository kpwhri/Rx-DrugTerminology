/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Create the VDW Codebucket from VDW Codes and OMOP Codes
* Date Created:: 20-10-05
*********************************************/

proc sql;
  create table dat.vdw_codebucket as
    select monotonic() as code_id, cds.* from (
    select code, code_type, code_desc, code_source from dat.vdw_standard_codes
    union
    select concept_code as code, 'HCPCS' as code_type, concept_name as code_desc, 'OMOP_DRUG' as code_source
    from vocab.concept where lower(vocabulary_id) = 'hcpcs' and lower(domain_id) = 'drug'
    union
    select concept_code as code, 'NDC' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from vocab.concept where lower(vocabulary_id) = 'ndc'
    union
    select concept_code as code, 'RxNorm' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from vocab.concept where lower(vocabulary_id) = 'rxnorm'
    union
    select concept_code as code, 'RxNorm_Extension' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from vocab.concept where lower(vocabulary_id) = 'rxnorm extension'
    ) cds
    ;
quit;
