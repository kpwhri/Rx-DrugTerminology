# Rx-DrugTerminology
Code to create a view of Rx Drug relationships from the OMOP Vocabulary

## Prerequisites
### An HCSRN-VDW Common Data Model
- You'll need an HCSRN-VDW Common Data Model in order for the Code Management Interface to be useful. The code itself can be run without an HCSRN VDW.

### The ability to download the OHDSI OMOP Vocabulary files
- If you can connect with OHDSI OMOP Vocabulary by going to [Athena](https://athena.ohdsi.org/vocabulary/list) then you have the ability to get OHDSI OMOP Vocabulary data.

## Implementation Directions
1. Clone HCSRN-VDW-CMI ... this project.
2. Download OHDSI OMOP Vocabulary from Athena
   1. Unzip the CSV files into the omop_vocab folder
3. Edit Runtime Parameter Variables
   1. Save the file "./sas_etl/0-edit-run-main.sas" to "0-run-main.sas"
   2. Edit the file "./sas_etl/0-run-main.sas" to use your local settings
   3. Edit the file "./sas_etl/rcm_std_vars.sas" to point to local VDW
4. Run the file "0-run-main.sas" that you have edited.
