# Rx-DrugTerminology
Code to create a view of Rx Drug relationships from the OMOP Vocabulary

## Prerequisites
### An HCSRN-VDW Common Data Model
- You'll need an HCSRN-VDW Rx Data Model in order for the Code Management Interface with Rx-Drug Terminology to be useful. The code itself can be run without an HCSRN Rx table.

### The ability to download the OHDSI OMOP Vocabulary files
- If you can connect with OHDSI OMOP Vocabulary by going to [Athena](https://athena.ohdsi.org/vocabulary/list) then you have the ability to get OHDSI OMOP Vocabulary data.

## Implementation Directions
1. Clone Rx-DrugTerminology (... this project) to a local directory
2. Download OHDSI OMOP Vocabulary Rx related vocabularies from Athena
   1. The recommended vocabularies are:
      * 1-SNOMED
      * 7-NDFRT
      * 8-RxNorm
      * 9-NDC
      * 16-Multum
      * 21-ATC
      * 28-VANDF
      * 32-VA Class
      * 53-GCN_SEQNO
      * 82-RxNorm Extension
      * 109-MEDRT
      * 128-OMOP Extension
      * 148-OMOP Invest Drug
   2. After downloading zip file; unzip the CSV files into the omop_vocab folder
3. Edit Runtime Parameter Variables
   1. Save the file "./sas_etl/0-edit-run-main.sas" to "0-run-main.sas"
   2. Edit the file "./sas_etl/0-run-main.sas" to use your local settings
4. Run the file "0-run-main.sas" that you have edited to align with your SAS environment
