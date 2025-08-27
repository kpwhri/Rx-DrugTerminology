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
create table dat.rx_ndc as
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
  create table dat.rx_ndc_rxnorm_xwalk as
    select cp.concept_id as omop_rxnorm_cd_id, cp.concept_code as rxnorm_code, cp.concept_name as rxnorm_cd_desc,
      cr.concept_id_2 as omop_ndc_cd_id, cr.relationship_id as omop_relationship_id, rn.vdw_code as ndc_code, rn.vdw_cd_desc as ndc_cd_desc
    from vocab.concept cp
    inner join vocab.concept_relationship cr
    on cp.concept_id = cr.concept_id_1
    inner join dat.rx_ndc rn
    on cr.concept_id_2 = rn.omop_code_id
    where lower(cp.vocabulary_id) = 'rxnorm'
  ;
quit;
    

*Rx Group Hierarchy for RxNorm Codes;
proc sql;
create table dat.rx_rxnorm_grp as
select cnn.concept_code as rxnorm_code, cnn.concept_name as rxnorm_desc, cnn.concept_class_id as rxnorm_omop_class, cdfggg.rxnorm_grp_cd, cdfggg.rxnorm_grp_desc, cdfggg.rxnorm_grp_omop_class, cdfggg.rxnorm_class_cd, cdfggg.rxnorm_class_desc, cdfggg.rxnorm_class_omop_class
from vocab.concept cnn
inner join
  (
  select crr.*, cdfgg.*
  from vocab.concept_relationship crr
  inner join
  (
    select cn.concept_id as cdfg_concept_id, cn.concept_code as rxnorm_grp_cd, cn.concept_name as rxnorm_grp_desc, cn.concept_class_id as rxnorm_grp_omop_class, cdfg.rxnorm_class_cd, cdfg.rxnorm_class_desc, cdfg.rxnorm_class_omop_class
    from vocab.concept cn
    inner join
    (
      select cr.*, dfg.*
      from vocab.concept_relationship cr
      inner join
      (
        select concept_id as dfg_concept_id, concept_code as rxnorm_class_cd, concept_name as rxnorm_class_desc, concept_class_id as rxnorm_class_omop_class
        from vocab.concept 
        where vocabulary_id = 'RxNorm'
        and concept_class_id = 'Dose Form Group'
      ) dfg
      on cr.concept_id_1 = dfg.dfg_concept_id
      where cr.relationship_id = 'Dose form group of'
    ) cdfg
    on cn.concept_id = cdfg.concept_id_2
    where cn.vocabulary_id = 'RxNorm'
  ) cdfgg
  on crr.concept_id_1 = cdfgg.cdfg_concept_id
) cdfggg
on cnn.concept_id = cdfggg.concept_id_2
where cnn.vocabulary_id = 'RxNorm'
and cnn.concept_class_id <> 'Branded Dose Group'
and cnn.concept_class_id <> 'Clinical Dose Group'
and cnn.concept_class_id <> 'Dose Form Group'
;
quit;


*Rx Group Hierarchy for National Drug File - Reference Terminology Therapeutic Classification;
proc sql;
  create table dat.rx_ndfrt_tx_grp as
    select ppc.*, ppcc.concept_code as ndfrt_group_cd, ppcc.concept_name as ndfrt_group_desc, ppcc.concept_class_id as ndfrt_group_omop_class
    from (
    select pp.*, ppcr.relationship_id as ndfrt_class_omop_rlt, ppcr.concept_id_2 as ndfrt_group_omop_cd_id
    from (
    select ccprr.*, cptf.concept_code as ndfrt_class_cd, cptf.concept_name as ndfrt_class_desc, cptf.concept_class_id as ndfrt_class_omop_class
    from (
    select cprr.*, cptr.relationship_id as ndfrt_category_omop_rlt, cptr.concept_id_2 as ndfrt_class_omop_cd_id
    from (
        select cpr.concept_id as ndfrt_domain_omop_cd_id, cpr.concept_code as ndfrt_domain_cd, cpr.concept_name as ndfrt_domain_desc, cpr.concept_class_id as ndfrt_domain_omop_class, cpr.relationship_id as ndfrt_domain_omop_rlt, 
        cpt.concept_id as ndfrt_category_omop_cd_id, cpt.concept_code as ndfrt_category_cd, cpt.concept_name as ndfrt_category_desc, cpt.concept_class_id as ndfrt_category_omop_class
        from (
          select cp.*, cr.concept_id_2, cr.relationship_id
          from vocab.concept cp
          inner join vocab.concept_relationship cr
          on cp.concept_id = cr.concept_id_1
          where cp.vocabulary_id = 'NDFRT'
          and cp.concept_class_id = 'Therapeutic Class'
          and cr.relationship_id = 'Subsumes' 
        ) cpr
         inner join vocab.concept cpt
        on cpr.concept_id_2 = cpt.concept_id
    ) cprr
    inner join vocab.concept_relationship cptr
    on cprr.ndfrt_category_omop_cd_id = cptr.concept_id_1
    where cptr.relationship_id = 'Therap class of'
    ) ccprr
    inner join vocab.concept cptf
    on ccprr.ndfrt_class_omop_cd_id = cptf.concept_id

    where cptf.concept_class_id = 'Pharmacologic Class'
    ) pp
    inner join vocab.concept_relationship ppcr
    on pp.ndfrt_class_omop_cd_id = ppcr.concept_id_1
    where ppcr.relationship_id = 'Subsumes'
    or ppcr.relationship_id = 'Prep to Chem eq'
    or ppcr.relationship_id = 'Has chem structure'
    ) ppc
    inner join vocab.concept ppcc
    on ppc.ndfrt_group_omop_cd_id = ppcc.concept_id
    where (ppcc.concept_class_id = 'Pharma Preparation'
    or ppcc.concept_class_id = 'Chemical Structure')
;
quit;


*Rx Group Hierarchy for National Drug File - Reference Terminology Mechanisms of Action;
proc sql;
create table dat.rx_ndfrt_mech_grp as
    select ppc.*, ppcc.concept_code as ndfrt_group_cd, ppcc.concept_name as ndfrt_group_desc, ppcc.concept_class_id as ndfrt_group_omop_class
    from (
    select pp.*, ppcr.relationship_id as ndfrt_class_omop_rlt, ppcr.concept_id_2 as ndfrt_group_omop_cd_id
    from (
    select ccprr.*, cptf.concept_code as ndfrt_class_cd, cptf.concept_name as ndfrt_class_desc, cptf.concept_class_id as ndfrt_class_omop_class
    from (
    select cprr.*, cptr.relationship_id as ndfrt_category_omop_rlt, cptr.concept_id_2 as ndfrt_class_omop_cd_id
    from (
        select cpr.concept_id as ndfrt_domain_omop_cd_id, cpr.concept_code as ndfrt_domain_cd, cpr.concept_name as ndfrt_domain_desc, cpr.concept_class_id as ndfrt_domain_omop_class, cpr.relationship_id as ndfrt_domain_omop_rlt, 
        cpt.concept_id as ndfrt_category_omop_cd_id, cpt.concept_code as ndfrt_category_cd, cpt.concept_name as ndfrt_category_desc, cpt.concept_class_id as ndfrt_category_omop_class
        from (
          select cp.*, cr.concept_id_2, cr.relationship_id
          from vocab.concept cp
          inner join vocab.concept_relationship cr
          on cp.concept_id = cr.concept_id_1
          where cp.vocabulary_id = 'NDFRT'
          and cp.concept_class_id = 'Mechanism of Action'
          and cr.relationship_id = 'Subsumes' 
        ) cpr
         inner join vocab.concept cpt
        on cpr.concept_id_2 = cpt.concept_id
    ) cprr
    inner join vocab.concept_relationship cptr
    on cprr.ndfrt_category_omop_cd_id = cptr.concept_id_1
    where cptr.relationship_id = 'MoA of'
    ) ccprr
    inner join vocab.concept cptf
    on ccprr.ndfrt_class_omop_cd_id = cptf.concept_id

    where cptf.concept_class_id = 'Pharmacologic Class'
    ) pp
    inner join vocab.concept_relationship ppcr
    on pp.ndfrt_class_omop_cd_id = ppcr.concept_id_1
    where ppcr.relationship_id = 'Subsumes'
    or ppcr.relationship_id = 'Prep to Chem eq'
    or ppcr.relationship_id = 'Has chem structure'
    ) ppc
    inner join vocab.concept ppcc
    on ppc.ndfrt_group_omop_cd_id = ppcc.concept_id
    where (ppcc.concept_class_id = 'Pharma Preparation'
    or ppcc.concept_class_id = 'Chemical Structure')
;

quit;


*Rx NDFRT and RxNorm Crosswalk;
proc sql;
create table dat.rx_ndfrt_rxnorm_xwalk as
  select cpr.*, cpt.concept_code as rxnorm_code, cpt.concept_name as rxnorm_desc, cpt.concept_class_id as rxnorm_omop_class
  from (
    select cp.concept_code as ndfrt_group_cd, cp.concept_name as ndfrt_group_desc, cp.concept_class_id as ndfrt_omop_class, cr.concept_id_1 as ndfrt_omop_code_id, cr.concept_id_2 as rxnorm_omop_code_id
    from vocab.concept_relationship cr
    inner join vocab.concept cp
    on cr.concept_id_1 = cp.concept_id
    where cr.relationship_id = 'NDFRT - RxNorm eq'
    and ( cp.concept_class_id = 'Pharma Preparation'
    or cp.concept_class_id = 'Chemical Structure' )
    ) cpr
inner join vocab.concept cpt
on cpr.rxnorm_omop_code_id = cpt.concept_id
;
quit;

