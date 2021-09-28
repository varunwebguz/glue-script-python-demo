import sys,json,logging

import pprint

import datetime 
import dateutil.relativedelta

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
 
# cPDF Python Library
#from test_im_provider_cpdf_spark_models.model import SparkModel

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
                     'redshift_cluster_name',
					 'rds_secret_name', 
					 'rds_region_name', 
					 'rds_dbname', 
					 'rds_host',
					 'rds_port', 
					 'rds_artifacts_bucket',
					 'rds_artifacts_bucket_key'])

#Aurora connection details
SECRET_NAME = args['rds_secret_name']
REGION_NAME = args['rds_region_name']
DBNAME = args['rds_dbname']
#HOST = args['rds_host']
HOST = "jdbc:mysql://" + args['rds_host'] +":3306/db"
PORT = args['rds_port']
ARTIFACTS_BUCKET = args['rds_artifacts_bucket']
ARTIFACTS_BUCKET_KEY = args['rds_artifacts_bucket_key']

#redshift 360 connection details
artifacts_bucket = args['artifacts_bucket']
s3_bucket_360 = args['s3_bucket_360']
db_host_360 = args['db_host_360']
db_name_360 = args['db_name_360']
db_port_360 = args['db_port_360']
cluster_id_360 = args['cluster_id_360']
db_user_360 = args['db_user_360']
assumed_rolearn_360 = args['assumed_rolearn_360']
database_360 = args['database']
redshift_cluster_name = args['redshift_cluster_name']

redshift_temp_dir = "s3://"+artifacts_bucket+"/redshiftTmpDir"
s3_location_360 = "s3://"+s3_bucket_360+"/sempre/members"
reddshift_url_360 = "jdbc:redshift://"+db_host_360+":5439/"+db_name_360
#"jdbc:redshift://da-ent360-views-redshift-cluster-ra3-dev.csy0gkop8fp9.us-east-1.redshift.amazonaws.com:5439/da_ent360_ra3_db_dev"

# "now" will allways be the first day of current month :eg: Feb 28th will be  Feb 1
now = datetime.datetime.now().replace(day=1, hour=00, minute=00, second=00, microsecond=000000)
print ("First day of Current month: ", now)
# 12 months before 1st day of every month with be in the range Day 1,2 even if its leap year or not.
begining_month = now + dateutil.relativedelta.relativedelta(months=-12)
first_day_of_month = begining_month.replace(day=1, hour=00, minute=00, second=00, microsecond=000000).strftime("%Y-%m-%d")
print("\nFirst day of last 12th month: ", first_day_of_month, "\n")
 

sc = SparkContext()
glueContext = GlueContext(sc)
glueContext._jsc.hadoopConfiguration().set("fs.s3.canned.acl", "BucketOwnerFullControl")
spark = glueContext.spark_session


print("Spark context initialized here")

# Retrieve Redshift Connection Creds
def get_token(dbuser,dbname,clustername):
    print("XXX calling get_token XXX")
    # Assume role
    sts_client = boto3.client('sts')
    # Call the assume_role method of the STSConnection object and pass the   role
    # ARN and a role session name.
    assumed_role_object = sts_client.assume_role(RoleArn=assumed_rolearn_360,RoleSessionName="CDCSession")
    
    # From the response that contains the assumed role, get the temporary
    # credentials that can be used to make subsequent API calls
    credentials = assumed_role_object['Credentials']
    #print("Printing credentials:",credentials)
    redshift = boto3.client('redshift', 'us-east-1', verify=False,aws_access_key_id=credentials['AccessKeyId'],aws_secret_access_key=credentials['SecretAccessKey'],aws_session_token=credentials['SessionToken'])
    #print("redshift variable printed here:-",redshift)
    
    credentials = redshift.get_cluster_credentials(DbUser=dbuser,DbName=dbname,ClusterIdentifier=clustername,DurationSeconds=3600)
    #print("XXX Redshift credentials from get_token: {} XXX".format(credentials))
    return credentials


dbhost = db_host_360
database = db_name_360
db_username = db_user_360
redshift_port = 5439
redshift_cluter_name = cluster_id_360
#table = "DA_ENT360_CUSTOMER.CUST_INTGRD_DTL_V"
table = "DA_ENT360_RX.CLM_LN_PHRM_V"



# Define Redshift Connection
credentials = get_token(dbuser=db_username,dbname=database,clustername=redshift_cluter_name)
#print("XXX get_token returned {} XXX".format(credentials))
#print("Above is the token")
db_user = credentials['DbUser']
db_password = credentials['DbPassword']


#####SQL##############################################################################################
df_members_data_sql =  """ WITH phrm AS  (		
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


#Pharmacy_data_df.printSchema()
##########################################GETTING CLAIMS INFO FOR EACH MEMBERS#########################################################
#joined_data_df=CLM_PHRM_df.join(df_members_data,CLM_PHRM_df.member_id == df_members_data.member_id)

joined_data_df  = spark.read \
                  .format("com.databricks.spark.redshift") \
                  .option("url", reddshift_url_360) \
                  .option("user", db_user)\
                  .option("password", db_password) \
                  .option("query", df_members_data_sql)\
                  .option("forward_spark_s3_credentials", "true") \
                  .option("tempdir", redshift_temp_dir) \
                  .load() 

#print("below is the joined data")
#joined_data_df.show(20) 

joined_data=joined_data_df.coalesce(1)


#df_members_data.printSchema()

Members_claims_data_dyf = DynamicFrame.fromDF(joined_data, glueContext, "Members_claims_data_dyf")
print("Converted df to dyf Members_data_dyf:",Members_claims_data_dyf)

secret_name = SECRET_NAME
region_name = REGION_NAME

    # Create a Secrets Manager client
print("Secret retrieving process")
session = boto3.session.Session()
client = session.client(service_name='secretsmanager', region_name=region_name)
get_secret_value_response = client.get_secret_value(SecretId=secret_name)
secret = get_secret_value_response['SecretString']
secret_credentials = json.loads(secret)
username = secret_credentials['username']
password = secret_credentials['password']
#glueContext.write_dynamic_frame.from_options(frame = Members_claims_data_dyf, connection_type = "s3", connection_options = {"path": "s3://cdc-da-rx-artifacts-dev/sempre/output/members"}, format ="csv")
#print("without gluecontext")
#Writting Data to S3bucket for only Tesing purpose
#datasink_S3=glueContext.write_dynamic_frame.from_options(frame = Members_claims_data_dyf, connection_type = "s3", connection_options = {"path": s3_location_360}, format ="csv", transformation_ctx = "datasink_S3")

datasink_S3=glueContext.write_dynamic_frame.from_options(frame = Members_claims_data_dyf, connection_type = "postgresql", connection_options = {"url": HOST,"dbtable":"datasink","user": username,"password": password})

print("Data loaded into RX bucket members folder successfully")
