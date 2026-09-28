/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure imports data from external CSV files into the
    'bronze' schema. It performs the following steps:
    - Clears existing data from the bronze tables.
    - Loads fresh data from CSV files using the BULK INSERT command.
    - Displays the loading status and duration for each table.

Parameters:
    None.
    This procedure does not require any input parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

create or alter procedure bronze.load_bronze as
begin
    declare @start_time datetime, @end_time datetime;
	declare @whole_bronze_start_time datetime, @whole_bronze_end_time datetime;
    begin try
        print '===============================================';
        print 'Loading Bronze Layer';
        print '===============================================';

        print '-----------------------------------------------';
        print 'Loading CRM Tables';
        print '-----------------------------------------------';

		set @whole_bronze_start_time = GETDATE();
        -- crm_cust_info
        set @start_time = getdate();

        print '>> Truncating Table: bronze.crm_cust_info';
        truncate table bronze.crm_cust_info;

        print '>> Inserting Data Into: bronze.crm_cust_info';
        bulk insert bronze.crm_cust_info
        from 'C:\Users\goura\OneDrive - Simon Fraser University (1sfu)\Desktop\SFU\Data-Analysis-Using-SQL\datasets\source_crm\cust_info.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();
        print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';


        -- crm_prd_info
        set @start_time = getdate();

        print '>> Truncating Table: bronze.crm_prd_info';
        truncate table bronze.crm_prd_info;

        print '>> Inserting Data Into: bronze.crm_prd_info';
        bulk insert bronze.crm_prd_info
        from 'C:\Users\goura\OneDrive - Simon Fraser University (1sfu)\Desktop\SFU\Data-Analysis-Using-SQL\datasets\source_crm\prd_info.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();
        print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';


        -- crm_sales_details
        set @start_time = getdate();

        print '>> Truncating Table: bronze.crm_sales_details';
        truncate table bronze.crm_sales_details;

        print '>> Inserting Data Into: bronze.crm_sales_details';
        bulk insert bronze.crm_sales_details
        from 'C:\Users\goura\OneDrive - Simon Fraser University (1sfu)\Desktop\SFU\Data-Analysis-Using-SQL\datasets\source_crm\sales_details.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();
        print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';


        print '-----------------------------------------------';
        print 'Loading ERP Tables';
        print '-----------------------------------------------';


        -- erp_cust_az12
        set @start_time = getdate();

        print '>> Truncating Table: bronze.erp_cust_az12';
        truncate table bronze.erp_cust_az12;

        print '>> Inserting Data Into: bronze.erp_cust_az12';
        bulk insert bronze.erp_cust_az12
        from 'C:\Users\goura\OneDrive - Simon Fraser University (1sfu)\Desktop\SFU\Data-Analysis-Using-SQL\datasets\source_erp\CUST_AZ12.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();
        print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';


        -- erp_loc_a101
        set @start_time = getdate();

        print '>> Truncating Table: bronze.erp_loc_a101';
        truncate table bronze.erp_loc_a101;

        print '>> Inserting Data Into: bronze.erp_loc_a101';
        bulk insert bronze.erp_loc_a101
        from 'C:\Users\goura\OneDrive - Simon Fraser University (1sfu)\Desktop\SFU\Data-Analysis-Using-SQL\datasets\source_erp\LOC_A101.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();
        print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';


        -- erp_px_cat_g1v2
        set @start_time = getdate();

        print '>> Truncating Table: bronze.erp_px_cat_g1v2';
        truncate table bronze.erp_px_cat_g1v2;

        print '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        bulk insert bronze.erp_px_cat_g1v2
        from 'C:\Users\goura\OneDrive - Simon Fraser University (1sfu)\Desktop\SFU\Data-Analysis-Using-SQL\datasets\source_erp\PX_CAT_G1V2.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();
        set @whole_bronze_end_time = GETDATE();
		print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';


        print '===============================================';
        print 'Bronze Layer Loaded Successfully in '+ cast(datediff(second,@whole_bronze_start_time,@whole_bronze_end_time)as nvarchar) + ' seconds.';
        print '===============================================';

    end try

    begin catch
        print '===============================================';
        print 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        print 'Error Message: ' + error_message();
        print 'Error Number: ' + cast(error_number() as nvarchar);
        print 'Error State: ' + cast(error_state() as nvarchar);
        print '===============================================';
    end catch
end;
