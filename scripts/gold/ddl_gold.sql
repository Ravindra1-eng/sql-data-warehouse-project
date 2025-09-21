/* We are creating Views for the Gold layer in the data Warehouse, whihc represnts the final Dimensions and facts table */

** FACT VIEW **
CREATE VIEW gold.fact_sales AS

SELECT 
sd.sls_ord_num AS Order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt As shipping_date,
sd.sls_due_dt As due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id


  ** VIEW for Products **
CREATE VIEW Gold.dim_product AS

SELECT
  ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
  pn.prd_id AS Product_id,
  pn.prd_key As Product_number,
  pn.prd_nm AS Product_name,
  pn.cat_id AS category_id,
  pc.cat AS category,
  pc.subcat AS sub_category,
  pc.maintenance,
  pn.prd_cost AS cost,
  pn.prd_line AS Product_line,
  pn.prd_start_dt AS startdate
  FROM silver.crm_prd_info pn 
  LEFT JOIN silver.erp_px_cat_g1v2 pc
  ON pn.cat_id = pc.id
  WHERE prd_end_dt IS NULL


** VIEW FOR Customer DATA **

CREATE VIEW gold.dim_customers AS
SELECT
        ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
        ci.cst_id AS Customer_id,
        ci.cst_key AS Customer_number,
        la.cntry AS Country,
        ci.cst_firstname AS First_name,
        ci.cst_lastname AS Last_name,
        ci.cst_material_status AS Marital_status,
        CASE WHEN ci.cst_gndr ! = 'n/a' THEN ci.cst_gndr
             ELSE COALESCE(ca.gen, 'n/a')
        END AS gender,
        ci.cst_create_date AS Create_date,
        ca.bdate AS Birthdate
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON  ci.cst_key = la.cid
