import sys,json,logging
#from ConfigParser import SafeConfigParser
import pprint
 
 
# AWS
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql import SQLContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
import boto3
 
# PySpark
from pyspark.sql import DataFrame
from pyspark.context import SparkContext
from pyspark.sql.functions import *
 

print("Import completed here")

args = getResolvedOptions(sys.argv,
                    ['artifacts_bucket',
                     's3_bucket_360',
                     'db_host_360',
                     'db_name_360',
                     'db_port_360',
                     'cluster_id_360',
                     'db_user_360',
                     'assumed_rolearn_360',
                     'database',
                     'redshift_cluster_name'])

artifacts_bucket = args['artifacts_bucket']
s3_bucket_360 = args['s3_bucket_360']
db_host_360 = args['db_host_360']
db_name_360 = args['db_name_360']
db_port_360 = args['db_port_360']
cluster_id_360 = args['cluster_id_360']
db_user_360 = args['db_user_360']
assumed_rolearn_360 = args['assumed_rolearn_360']
database = args['database']
redshift_cluster_name = args['redshift_cluster_name']

redshift_temp_dir = "s3://"+artifacts_bucket+"/redshiftTmpDir"
s3_location_360 = "s3://"+s3_bucket_360+"/sempre/Pharmacy"
reddshift_url_360 = "jdbc:redshift://"+db_host_360+":5439/"+db_name_360


sc = SparkContext()
#sc._jsc.hadoopConfiguration().set("fs.s3a.credentialsType", "AssumeRole")
#sc._jsc.hadoopConfiguration().set("fs.s3a.stsAssumeRole.arn", "arn:aws:iam::228281547536:role/Enterprise/GLUESEMPETL")
glueContext = GlueContext(sc)
glueContext._jsc.hadoopConfiguration().set("fs.s3.canned.acl", "BucketOwnerFullControl")
spark = glueContext.spark_session

print("Spark context initialized here")

# Retrieve Redshift Connection Creds
def get_token(dbuser,dbname,clustername):
    sts_client = boto3.client('sts')
    assumed_role_object = sts_client.assume_role(RoleArn=assumed_rolearn_360, RoleSessionName="CDCSession")
    credentials = assumed_role_object['Credentials']
    redshift = boto3.client('redshift', 'us-east-1', verify=False,aws_access_key_id=credentials['AccessKeyId'],aws_secret_access_key=credentials['SecretAccessKey'],aws_session_token=credentials['SessionToken'])
    credentials = redshift.get_cluster_credentials(DbUser=dbuser,DbName=dbname,ClusterIdentifier=clustername,DurationSeconds=3600)
    return credentials
    

dbhost = db_host_360
database = db_name_360
db_username = db_user_360
redshift_port = 5439
redshift_cluter_name = cluster_id_360
table = "DA_ENT360_RX.CLM_LN_PHRM_V"

# Define Redshift Connection
credentials = get_token(dbuser=db_username,dbname=database,clustername=redshift_cluter_name)
db_user = credentials['DbUser']
db_password = credentials['DbPassword']



print("************Now creating dynamic frame**************")
print("XXX about to call create_dyanmic_frame XXX")

pharmacy_sql = """ WITH phrm AS  (		
SELECT 		
SVC_BEG_YR_MTH,		
BILL_PROV_NT_ID,		
FINANCL_SEG_ID,		
CLIENT_CNTRCT_ST_CD,		
FUND_ARNGMT_TY_CD,		
BUS_SEG_ID,		
CLIENT_ID,		
CLIENT_NM,		
CLIENT_BEN_KEY,		
CLIENT_ACCT_NUM,		
CLIENT_ACCT_NM,		
CUST_ELGBTY_ACCT_KEY,		
INDIV_ENTPR_ID,		
ENTPR_CUST_ID,		
--PHRM_AFLTN_ID,		
--PHRM_CHAIN_ID,		
BILL_PROV_ID,		
CLM_SYS_CLM_ID,		
LGCY_MBR_NUM,		
RX_NUM,		
CLM_SVC_BEG_DT,		
clm_key,		
METRC_QTY,		
DAYS_SUPLY_QTY,		
NDC,		
BRND_NM,		
LABEL_NM,		
GCN,		
CLM_NDC_PRODT_CD,		
AWP_INGRDNT_COST_AMT,		
UC_AMT,		
PHRM_INGRDNT_COST_AMT,		
PHRM_DISPNS_FEE_AMT,		
DERV_COINS_AMT,		
DERV_COPAY_AMT,		
DERV_DDCTBL_AMT,		
PHRM_PD_AMT,		
SBMT_CMPD_CD,		
INGRDNT_COST_AMT,		
DISPNS_FEE_AMT,		
BILL_PROV_NM,		
BILL_PROV_ADDR_LN_1,		
BILL_PROV_ADDR_LN_2,		
BILL_PROV_CITY_NM,		
BILL_PROV_ST_CD,		
BILL_PROV_POSTL_CD,		
BILL_PROV_POSTL_EXT_CD,		
'999-999-9999' AS prov_ph_num,  --this will be available in future in clm_ln_phrm_mv		
'' AS nt_product_id,		
'' AS voluntory_ind,		
'' AS thirty_vs_nighty_supply_ind,		
'' as csn_ind,		
'' AS specialty_drug,		
'' AS price_source		
FROM clm_ln_phrm_mv 		
--WHERE SVC_BEG_YR_MTH >= '201901'		
),		
		
mbr as (SELECT 		
CVRG_PER_YR_MTH_NUM,		
CUST_ELGBTY_ACCT_KEY,		
CUST_FRST_NM, 		
CUST_LAST_NM,		
CUST_ADDR_LN_1,		
CUST_ADDR_LN_2,		
CUST_CITY_NM,		
CUST_ST_CD,		
CUST_POSTL_CD,		
CUST_ELGBTY_CVRG_EFF_DT		
FROM mbr_mth_comprs		
QUALIFY ROW_NUMBER() OVER (PARTITION BY  CUST_ELGBTY_ACCT_KEY, CVRG_PER_YR_MTH_NUM ORDER BY CUST_ELGBTY_CVRG_EFF_DT DESC) =1		
WHERE cvrg_phrm_ind = 'Y'		
),		
 		
drug as ( SELECT NDC, DRUG_METRC_STRNG_TXT, GCN FROM drug_dtl_sv		
                QUALIFY ROW_NUMBER() OVER (PARTITION BY GCN, NDC ORDER BY DRUG_EFF_DT DESC) =1 ),		
		
ldd as ( SELECT NDC, NDC_EFF_DT, NDC_TERM_DT  FROM DRUG_LIST_PBM		
             WHERE curr_rcd_ind ='Y' AND DRUG_LIST_ID = '571499'  		
             QUALIFY ROW_NUMBER() OVER (PARTITION BY ndc ORDER BY ndc_eff_dt DESC) = 1)		
		
/*prov as (SELECT clm_key, prov_id, prov_ph_num		
FROM clm_prov)*/		
		
SELECT phrm.* ,		
mbr.*,		
drug.*,		
case when LDD.NDC IS NOT NULL THEN 'Y' ELSE 'N' end as LDD_IND		
		
FROM phrm 		
LEFT JOIN mbr  ON phrm.CUST_ELGBTY_ACCT_KEY = mbr.CUST_ELGBTY_ACCT_KEY AND phrm.SVC_BEG_YR_MTH = mbr.CVRG_PER_YR_MTH_NUM		
LEFT JOIN drug ON phrm.ndc = drug.ndc AND phrm.gcn = drug.gcn		
LEFT JOIN ldd   ON phrm.ndc = ldd.ndc		
"""


CLM_PHRM_DF  = spark.read \
                  .format("com.databricks.spark.redshift") \
                  .option("url", reddshift_url_360) \
                  .option("user", db_user)\
                  .option("password", db_password) \
                  .option("query", pharmacy_sql)\
                  .option("forward_spark_s3_credentials", "true") \
                  .option("tempdir", redshift_temp_dir) \
                  .load() 

#CLM_PHRM_DF.show(20)
CLM_PHRM_DF.printSchema()

CLM_PHRM_DF_COALESCE=CLM_PHRM_DF.coalesce(1)
ALL_CLAIMS_INFO_DYF = DynamicFrame.fromDF(CLM_PHRM_DF_COALESCE, glueContext, "ALL_CLAIMS_INFO_DYF")
datasink_S3=glueContext.write_dynamic_frame.from_options(frame = ALL_CLAIMS_INFO_DYF, connection_type = "s3", connection_options = {"path": s3_location_360}, format ="csv", transformation_ctx = "datasink_S3")
