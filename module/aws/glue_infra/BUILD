py_modules_dir="third_party/python/modules"
DDL_files_dir="module/aws/DDL"

# File group to find all files needed for other build rules, Augment if necessary.
filegroup(
    name = "projects_src",
    srcs = glob([
        "env-config/*",
        "python/*",
        "*.tf",
        "*/**.tmpl",
        "*.hcl",
        "**/*.py",
    ]),
    visibility = ["PUBLIC"]
)

genrule(
    cmd = [ f"echo ARTIFACTS_REPO: ${ARTIFACTS_REPO}",
        f"pwd;printenv",
        f"aws --profile saml s3 cp $(location python)/ s3://${ARTIFACTS_REPO}/hpn-netflex-dataservices/DDL/ | tee ddl_deploy_py.log",
        f"aws --profile saml s3 cp $(location ver0)/ s3://${ARTIFACTS_REPO}/hpn-netflex-dataservices/DDL/ | tee ddl_deploy_ver.log",
        f"aws --profile saml s3 cp $(location lib)/ s3://${ARTIFACTS_REPO}/hpn-netflex-dataservices/DDL/ | tee ddl_deploy_lib.log",
        f"echo Glue DDL files copied to S3",
        ],
    labels = ["xpublish"],
    name = f"uploadTos3",
    outs = [f"ddl_deploy_ver.log", f"ddl_deploy_py.log" , f"ddl_deploy_lib.log"],
)