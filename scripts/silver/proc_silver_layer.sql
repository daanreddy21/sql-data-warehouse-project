-- 

-- SQL Query to insert data into silver.crm_cust_info table from bronze.crm_cust_info table with data cleansing and transformation
-- cleaning and transformation of marital status and gender fields using case statements

create or alter procedure insert_into_silver as
Begin 
    DECLARE @start_time DATETIME,
            @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    Begin Try
            set @batch_start_time = getdate();
          print '------------------------------------';
          print 'Loading data into Silver layer...';
          print '------------------------------------';


          print '------------------------------------';
          print 'loading crm_data into silver layer...';
          print '------------------------------------';


          print '>> truncating silver.crm_cust_info';
          set @start_time = getdate();
          truncate table silver.crm_cust_info;
          print '>> load crm_cust_info into silver layer...';
        insert into silver.crm_cust_info(
	        cst_id,
	        cst_key,
	        cst_firstname,
	        cst_lastname,
	        cst_material_status,
	        cst_gndr,
	        cst_create_date)
        select cst_id,
        cst_key,
        TRIM(cst_firstname) as cst_first_name, -- removing leading and trailing spaces from first name
        TRIM(cst_lastname) as cst_last_name,
        case 
        when trim(upper(cst_material_status))='M' then 'Married'
        when trim(upper(cst_material_status))='S' then 'Single'
        when trim(upper(cst_material_status))='D' then 'Divorced'
        when trim(upper(cst_material_status))='W' then 'Widowed'
        when trim(upper(cst_material_status))='O' then 'Other'
        else 'Unknown' end as cst_material_status, -- data cleansing for marital status using case statement
        case
        when trim(upper(cst_gndr))='M' then 'Male'
        when trim(upper(cst_gndr))='F' then 'Female'
        else 'Unknown' end as cst_gender, -- replaacing null values with 'Unknown' for gender field using case statement
        cst_create_date
        from
        (select *,
        row_number() over (partition by cst_id order by cst_create_date desc) as flag
        from bronze.crm_cust_info where cst_id is not null) t 
        where t.flag = 1; -- removed duplicates based on cst_id and keeping the latest record based on cst_create_date
        set @end_time = getdate();
        print '>> silver.crm_cust_info loaded successfully';
        print '------------------------------------';
        print 'time taken to load crm_cust_info into silver layer: ' + cast(datediff(second, @start_time, @end_time) as varchar(10)) + ' seconds';



        print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'




          print '>> truncating silver.crm_prd_info';
          set @start_time = getdate();
          truncate table silver.crm_prd_info;

          print '------------------------------------';
          print 'loading crm.prd_info into silver layer...';
          print '------------------------------------';


        -- SQL Query to insert data into silver.crm_prd_info table from bronze.crm_prd_info table with data cleansing and transformation

        insert into silver.crm_prd_info(
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
          )
        SELECT prd_id,
               REPLACE(substring(prd_key,1,5), '-', '_') AS cat_id -- replacing '-' with '_' in the first 5 characters of prd_key to create cat_id
              ,substring(prd_key,7,len(prd_key)) AS prd_key  -- extracting the substring from 7th character to the end of prd_key to create prd_key
              ,prd_nm
              ,isnull(prd_cost, 0) AS prd_cost
              ,case when trim(upper(prd_line)) = 'R' then 'Road'
                    when trim(upper(prd_line)) = 'M' then 'Mountain'
                    when trim(upper(prd_line)) = 'T' then 'Touring'
                    when trim(upper(prd_line)) = 'S' then 'Specialty'
                    else 'unknown'
               end AS prd_line -- data cleansing for prd_line using case statement, data consistency check for prd_line values and replacing null values with 'unknown'
              ,cast(prd_start_dt AS DATE) AS prd_start_dt -- converting prd_start_dt to date format
              ,cast(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 as DATE) AS prd_end_dt -- calculating prd_end_dt as the day before the next prd_start_dt for the same prd_key using LEAD function, if there is no next prd_start_dt, then prd_end_dt will be null
          FROM [DataWarehouse].[bronze].[crm_prd_info]
          set @end_time = getdate();
          print '>> silver.crm_prd_info loaded successfully';
          print '------------------------------------';
          print 'time taken to load crm_prd_info into silver layer: ' + cast(datediff(second, @start_time, @end_time) as varchar(10)) + ' seconds';



          print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'





          print '>> truncating silver.crm_sales_details';
          set @start_time = getdate();
          truncate table silver.crm_sales_details;

          print '------------------------------------';
          print 'loading crm.sales_details into silver layer...';
          print '------------------------------------';


          -- SQL Query to insert data into silver.crm_sales_details table from bronze.crm_sales_details table with data cleansing and transformation
          insert into silver.crm_sales_details(
                  sls_ord_num,
                  sls_prd_key,
                  sls_cust_id,
                  sls_order_dt,
                  sls_ship_dt,
                  sls_due_dt,
                  sls_sales,
                  sls_quantity,
                  sls_price
                  )
        SELECT sls_ord_num
              ,sls_prd_key
              ,sls_cust_id
              ,case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null 
              else cast(cast(sls_order_dt as varchar(8)) as date) 
              end as sls_order_dt -- converting sls_order_dt to date format, if the value is 0 or not 8 characters long, then it will be set to null
              ,case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null 
              else cast(cast(sls_ship_dt as varchar(8)) as date) 
              end as sls_ship_dt -- converting sls_ship_dt to date format, if the value is 0 or not 8 characters long, then it will be set to null
              ,case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null 
              else cast(cast(sls_due_dt as varchar(8)) as date) 
              end as sls_due_dt     
              ,case when sls_sales = 0 or sls_sales is null or sls_sales != abs(sls_price) * sls_quantity then
               sls_quantity * abs(sls_price)
               else sls_sales
               end as sls_sales -- data cleansing for sls_sales using case statement, if sls_sales is 0, null or not equal to the absolute value of sls_price multiplied by sls_quantity, then it will be calculated as sls_quantity multiplied by the absolute value of sls_price
              ,sls_quantity
              ,case when sls_price is null or sls_sales <=0 then
                sls_sales/ nullif(sls_quantity,0)
                else sls_price
               end as sls_price -- data cleansing for sls_price using case statement, if sls_price is null or sls_sales is less than or equal to 0, then it will be calculated as sls_sales divided by sls_quantity, using nullif to avoid division by zero
          FROM [DataWarehouse].[bronze].[crm_sales_details];
          set @end_time = getdate();
          print '>> silver.crm_sales_details loaded successfully';
          print '------------------------------------';
          print 'time taken to load crm_sales_details into silver layer: ' + cast(datediff(second, @start_time, @end_time) as varchar(10)) + ' seconds';



          print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'




          print '>> truncating silver.erp_cust_az12';
          set @start_time = getdate();
          truncate table silver.erp_cust_az12;

          print '------------------------------------';
          print 'loading erp_cust_az12 into silver layer...';
          print '------------------------------------';

          -- SQL Query to insert data into silver.erp_cust_az12 table from bronze.erp_cust_az12 table with data cleansing and transformation
        insert into silver.erp_cust_az12 (cid, bdate, gen)
        SELECT
			        CASE
				        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) -- Remove 'NAS' prefix if present
				        ELSE cid
			        END AS cid, -- Clean up customer ID by removing 'NAS' prefix if present fro making relation with crm_cust_info table
			        CASE
				        WHEN bdate > GETDATE() THEN NULL
				        ELSE bdate
			        END AS bdate, -- Set future birthdates to NULL
			        CASE
				        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				        ELSE 'n/a'
			        END AS gen -- Normalize gender values and handle unknown cases
		        FROM bronze.erp_cust_az12;
        set @end_time = getdate();
        print '>> silver.erp_cust_az12 loaded successfully';
        print '------------------------------------';
        print 'time taken to load erp_cust_az12 into silver layer: ' + cast(datediff(second, @start_time, @end_time) as varchar(10)) + ' seconds';



        print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'


  
            print '>> truncating silver.erp_loc_a101';
            set @start_time = getdate();
            truncate table silver.erp_loc_a101;

            print '------------------------------------';
            print 'loading erp_loc_a101 into silver layer...';
            print '------------------------------------';

          -- insert into silver.erp_loc_a101 table from bronze.erp_loc_a101 table with data cleansing and transformation
          insert into silver.erp_loc_a101(
                        cid,cntry
            )
        SELECT replace(cid, '-','') as cid -- removing '-' from cid to make it consistent with crm_cust_info table
              ,case when trim(cntry) = 'DE' then 'Germany'
                    when trim(cntry) in('US','USA') then 'United States'
                    when trim(cntry) = '' or cntry is null then 'Unknown'
                    else trim(cntry)
               end as cntry -- data cleansing for cntry using case statement, replacing 'DE' with 'Germany', 'US' or 'USA' with 'United States', and empty or null values with 'Unknown'
          FROM [DataWarehouse].[bronze].[erp_loc_a101];
          set @end_time = getdate();
          print '>> silver.erp_loc_a101 loaded successfully';
          print '------------------------------------';
          print 'time taken to load erp_loc_a101 into silver layer: ' + cast(datediff(second, @start_time, @end_time) as varchar(10)) + ' seconds';



          print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'



  
           print '>> truncating silver.erp_px_cat_g1v2';
           set @start_time = getdate();
           truncate table silver.erp_px_cat_g1v2;
           print '------------------------------------';
           print 'loading erp_px_cat_g1v2 into silver layer...';
           print '------------------------------------';
        -- insert into silver.erp_px_cat_g1v2 table from bronze.erp_px_cat_g1v2 table with data cleansing and transformation

        insert into silver.erp_px_cat_g1v2(
                id,
                cat,
                subcat,
                maintenance)
        SELECT [id]
              ,[cat]
              ,[subcat]
              ,[maintenance]
          FROM [DataWarehouse].[bronze].[erp_px_cat_g1v2]
          set @end_time = getdate();
          print '>> silver.erp_px_cat_g1v2 loaded successfully';

        print '------------------------------------';
        print 'time taken to load erp_px_cat_g1v2 into silver layer: ' + cast(datediff(second, @start_time, @end_time) as varchar(10)) + ' seconds';

        set @batch_end_time = getdate();
        print ' silver layer data load completed successfully';
        print '------------------------------------';
        print 'Total time taken to load data into silver layer: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as varchar(10)) + ' seconds';
    end Try
    Begin CATCH
        print '-------------------------------------------------';
        print 'Error occurred while loading data into bronze layer.';
        print 'Error Message' + ERROR_MESSAGE();
        Print 'Error Number' + cast(ERROR_NUMBER() as varchar(10));
        print 'Error Severity' + cast(ERROR_SEVERITY() as varchar(10));
        print 'Error State' + cast(ERROR_STATE() as varchar(10));
        print '--------------------------------------------------';
    END CATCH


end

exec insert_into_silver;













