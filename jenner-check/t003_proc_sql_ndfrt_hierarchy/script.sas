/*********************************************
* Adapted from sas_etl/03-load-RCM.sas (NDFRT Therapeutic Classification grp)
* Original author: John Weeks, Kaiser Permanente Washington
*                  Health Research Institute
* Purpose:: Builds Rx Code Views
*
* The nested-subquery NDFRT therapeutic-class hierarchy query is exactly as
* written upstream; only the vocab. libname prefix was redirected to the work
* library so the sample data in autoexec.sas resolves.
*********************************************/

*Rx Group Hierarchy for National Drug File - Reference Terminology Therapeutic Classification;
proc sql;
  create table rx_ndfrt_tx_grp as
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
          from concept cp
          inner join concept_relationship cr
          on cp.concept_id = cr.concept_id_1
          where cp.vocabulary_id = 'NDFRT'
          and cp.concept_class_id = 'Therapeutic Class'
          and cr.relationship_id = 'Subsumes'
        ) cpr
         inner join concept cpt
        on cpr.concept_id_2 = cpt.concept_id
    ) cprr
    inner join concept_relationship cptr
    on cprr.ndfrt_category_omop_cd_id = cptr.concept_id_1
    where cptr.relationship_id = 'Therap class of'
    ) ccprr
    inner join concept cptf
    on ccprr.ndfrt_class_omop_cd_id = cptf.concept_id

    where cptf.concept_class_id = 'Pharmacologic Class'
    ) pp
    inner join concept_relationship ppcr
    on pp.ndfrt_class_omop_cd_id = ppcr.concept_id_1
    where ppcr.relationship_id = 'Subsumes'
    or ppcr.relationship_id = 'Prep to Chem eq'
    or ppcr.relationship_id = 'Has chem structure'
    ) ppc
    inner join concept ppcc
    on ppc.ndfrt_group_omop_cd_id = ppcc.concept_id
    where (ppcc.concept_class_id = 'Pharma Preparation'
    or ppcc.concept_class_id = 'Chemical Structure')
;
quit;

proc print data=rx_ndfrt_tx_grp;
  title "rx_ndfrt_tx_grp: NDFRT therapeutic-class hierarchy";
run;
