/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Builds Rx Code Views
* Date Created:: 2025-02-18
*********************************************/


*map vdw ndc codes to omop ndc codes;

proc sql;
create table dat.rcm_rx_ndc as
	select cb.code_id as vdw_code_id, cb.code as vdw_code, cb.code_desc as vdw_cd_desc, cb.code_type as vdw_cd_type,
		cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from dat.vdw_codebucket cb
	left join vocab.concept cp
	on cb.code = cp.concept_code
	where lower(cb.code_type) = 'ndc'
	and lower(cp.vocabulary_id) = 'ndc'
;
quit;

*map ndc codes to rxnorm codes;

proc sql;
  create table dat.rcm_rx_x_ndc_rxnorm as
    select cp.concept_id as omop_code_id, cp.concept_code as rxnorm_cd, cp.concept_name as rxnorm_cd_desc,
      cr.concept_id_2, cr.relationship_id, rn.vdw_code as ndc_code, rn.vdw_cd_desc as ndc_cd_desc
    from vocab.concept cp
    inner join vocab.concept_relationship cr
    on cp.concept_id = cr.concept_id_1
    inner join dat.rcm_rx_ndc rn
    on cr.concept_id_2 = rn.omop_code_id
    where lower(cp.vocabulary_id) = 'rxnorm'
  ;
quit;
    


