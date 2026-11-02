CREATE OR ALTER PROCEDURE gold.v_load_gold AS

BEGIN 
    BEGIN TRY 

        IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
        BEGIN 
	        EXEC('CREATE SCHEMA gold;')
        END

        -- =============================================================
        -- Create View for Dim Customer Table 
        -- Exp: USE MyDataWarehouse; SELECT * FROM gold.dim_customers;
        -- =============================================================

        -- Begin create view:
        EXEC('
            CREATE OR ALTER VIEW gold.dim_customers AS
            SELECT ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
                   ci.cst_id AS customer_id,
                   ci.cst_key AS customer_number,
                   ci.cst_firstname AS first_name,
                   ci.cst_lastname AS last_name,
                   lo.cntry AS country,
                   CASE 
                    WHEN ci.cst_gndr != ''Unknown'' THEN ci.cst_gndr 
                    ELSE ca.gen 
                   END AS gender,
                   ci.cst_marital_status AS marital_status,
                   ca.bdate AS birthdate,
                   ci.cst_create_date AS create_date
            FROM   silver.crm_cust_info AS ci
                   LEFT OUTER JOIN
                   silver.erp_loc_a101 AS lo
                   ON ci.cst_key = lo.cid
                   LEFT OUTER JOIN
                   silver.erp_cust_az12 AS ca
                   ON ci.cst_key = ca.cid'
        );

        -- ===================================================================================
        -- Create View for Dim Product Table (derived from crm_prd_info and erp_px_cat_g1v2) 
        -- Exp: USE MyDataWarehouse; SELECT * FROM gold.dim_products;
        -- ===================================================================================

        -- Begin create view:
        EXEC(
            'CREATE OR ALTER VIEW gold.dim_products AS
            SELECT ROW_NUMBER() OVER (ORDER BY pi.prd_id) AS product_number,
                   pi.prd_id AS product_id,
                   pi.prd_key AS product_key,
                   pi.prd_nm AS product_name,
                   pi.prd_line AS product_line,
                   pi.prd_cost AS cost,
                   pi.category_id AS category_id,
                   pc.cat category,
                   pc.subcat AS sub_category,
                   pc.maintenance,
                   pi.prd_start_dt AS start_date
            FROM   silver.crm_prd_info AS pi
                   LEFT OUTER JOIN
                   silver.erp_px_cat_g1v2 AS pc
                   ON pi.category_id = pc.id
            WHERE  prd_end_dt IS NULL'
        );
       

        -- ===================================================================================
        -- Create View for Fact Table crm_sales_details
        -- Exp: USE MyDataWarehouse; SELECT * FROM gold.fact_sales;
        -- ===================================================================================

        EXEC('
            CREATE OR ALTER VIEW gold.fact_sales AS
            SELECT ROW_NUMBER() OVER (ORDER BY sls_ord_num) AS sales_id,
                   sls_ord_num AS order_number,
                   sls_cust_id AS customer_id,
                   sls_prd_key AS product_key,
                   sls_sales AS sales,
                   sls_quantity AS quantity,
                   sls_price AS price,
                   sls_order_dt AS order_date,
                   sls_ship_dt AS ship_date,
                   sls_due_dt AS due_date
            FROM   silver.crm_sales_details'
        )

    END TRY

    BEGIN CATCH
        PRINT 'Error happens' + ERROR_MESSAGE();
    END CATCH
END

