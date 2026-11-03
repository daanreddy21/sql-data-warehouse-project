use DataWarehouse;

DROP TABLE IF EXISTS silver.crm_cust_info;
create Table silver.crm_cust_info(
cst_id int,
cst_key varchar(50),
cst_firstname varchar(50),
cst_lastname varchar(50),
cst_material_status varchar(50),
cst_gndr varchar(50),
cst_create_date date,
dhw_create_date datetime2 default getdate(),
);


DROP TABLE IF EXISTS silver.crm_prd_info;
  create table silver.crm_prd_info (
    prd_id int,
    cat_id varchar(50),
    prd_key varchar(50),
    prd_nm varchar(255),
    prd_cost decimal(18,2),
    prd_line varchar(50),
    prd_start_dt date,
    prd_end_dt date,
    dwh_create_dt datetime default getdate()
  );


DROP TABLE IF EXISTS silver.crm_sales_details;
create Table silver.crm_sales_details(
sls_ord_num varchar(50),
sls_prd_key varchar(50),
sls_cust_id int,
sls_order_dt date,
sls_ship_dt date,
sls_due_dt date,
sls_sales int,
sls_quantity int,
sls_price int,
dhw_create_date datetime2 default getdate(),
);


DROP TABLE IF EXISTS silver.erp_loc_a101;
create table silver.erp_loc_a101(
cid varchar(50),
cntry varchar(50),
dhw_create_date datetime2 default getdate(),
);


DROP TABLE IF EXISTS silver.erp_cust_az12;
Create table silver.erp_cust_az12(
cid varchar(50),
bdate date,
gen varchar(50),
dhw_create_date datetime2 default getdate(),
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2(
id varchar(50),
cat varchar(50),
subcat varchar(50),
maintenance varchar(50),
dhw_create_date datetime2 default getdate(),
);
