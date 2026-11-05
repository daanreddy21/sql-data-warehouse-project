use DataWarehouse;

create or alter view gold.dim_customer as
select 
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	ci.cst_material_status as material_status,
	case when ci.cst_gndr != 'Unknown' then ci.cst_gndr
		else coalesce(ca.gen, 'Unknown')
	end as gender,
	ca.bdate as Birth_date,
	la.cntry as country,
	ci.cst_create_date as created_date
	from silver.crm_cust_info ci
	left join silver.erp_cust_az12 ca
	on ci.cst_key = ca.cid
	left join silver.erp_loc_a101 la
	on ci.cst_key = la.cid;

select * from gold.dim_customer;


create or alter view gold.dim_products as
select	ROW_NUMBER()over(order by pr.prd_start_dt, pr.prd_key) as product_key,
		pr.prd_id as product_id,
		pr.prd_key as product_key_n,
		pr.prd_nm as product_name,
		pr.cat_id as category_id,
		px.cat as category,
		px.subcat as sub_category,
		px.maintenance as maintenance,
		pr.prd_cost as product_cost,
		pr.prd_line as line,
		pr.prd_start_dt as start_date
		from silver.crm_prd_info pr
		left join silver.erp_px_cat_g1v2 px
		on pr.cat_id = px.id
		where pr.prd_end_dt is null;

select * from gold.dim_products;



create or alter view gold.fact_sales as

select 
		sl.sls_ord_num as order_number,
		pr.product_key,
		cu.customer_key,
		sl.sls_order_dt as order_date,
		sl.sls_ship_dt as ship_date,
		sl.sls_due_dt as due_date,
		sl.sls_sales as sales,
		sl.sls_quantity as quantity,
		sl.sls_price as price
from silver.crm_sales_details sl
left join gold.dim_products pr
on sl.sls_prd_key = pr.product_key_n
left join gold.dim_customer cu
on sl.sls_cust_id = cu.customer_id;
