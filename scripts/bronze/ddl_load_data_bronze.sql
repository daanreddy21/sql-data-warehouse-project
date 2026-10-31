
--import data into the tables-- using the Full Load trun and load method
 
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @start_time DATETIME,
            @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    
    BEGIN TRY
          SET @batch_start_time = GETDATE(); 
          print '------------------------------------';
          print 'Loading data into bronze layer...';
          print '------------------------------------';


          print '------------------------------------';
          print 'loading crm_data into bronze layer...';
          print '------------------------------------';

        -- CRM Customer Information
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\daanr\Documents\SQL\project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        print '>>> Time taken to load crm_cust_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
        
        print '>>>> -------------------------------------------------------';

        SET @start_time = GETDATE();
        -- CRM Product Information
        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\daanr\Documents\SQL\project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        print '>>> Time taken to load crm_prd_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

        print '>>>> -------------------------------------------------------';


        SET @start_time = GETDATE();
        -- CRM Sales Details
        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\daanr\Documents\SQL\project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        print '>>> Time taken to load crm_sales_details: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

        
        print '>>>> -------------------------------------------------------';

          print '------------------------------------';
          print 'loading erp_data into bronze layer...';
          print '------------------------------------';

          SET @start_time = GETDATE();
        -- ERP Location
        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\daanr\Documents\SQL\project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        print '>>> Time taken to load erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

        print '>>>> -------------------------------------------------------';

        -- ERP Customer
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\daanr\Documents\SQL\project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        print '>>> Time taken to load erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

        print '>>>> -------------------------------------------------------';

        -- ERP Product Category
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\daanr\Documents\SQL\project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        print '>>> Time taken to load erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

        print '>>>> -------------------------------------------------------';
        SET @batch_end_time = GETDATE();
        Print 'Loading completed.';
        print '>>> Total time taken to load data into bronze layer: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(10)) + ' seconds';
        print '>>>> -------------------------------------------------------';

    
    END TRY
    Begin CATCH
        print '-------------------------------------------------';
        print 'Error occurred while loading data into bronze layer.';
        print 'Error Message' + ERROR_MESSAGE();
        Print 'Error Number' + cast(ERROR_NUMBER() as varchar(10));
        print 'Error Severity' + cast(ERROR_SEVERITY() as varchar(10));
        print 'Error State' + cast(ERROR_STATE() as varchar(10));
        print '--------------------------------------------------';
    END CATCH
      

END;
