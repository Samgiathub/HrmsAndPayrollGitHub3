

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_Asset_Approval_Return_Details]
	 @Cmp_ID	 numeric
	,@emp_id   numeric
	,@branch_id numeric
	,@dept_id numeric
	,@application_id numeric
	--,@AssetM_Id varchar(50)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

			if @emp_id >0
				begin
				--print @application_id
				--select replace(AssetM_Id,'#',',') from V0100_Asset_Application where cmp_id=@cmp_id and Asset_Application_ID=@application_id
					SELECT BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model, Serial_No as SerialNo, Allocation_Date, Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,  
                    Branch_ID, Brand_ID,case when convert(varchar(10),Purchase_date,103)='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end Purchase_date, '' AS Return_Date, asset_approval_id 
                    FROM dbo.V0040_Asset_Return 
                    WHERE isnull(Application_Type,0) = 0 and AssetM_Id in (select replace(AssetM_Id,'#',',')AssetM_Id from V0100_Asset_Application where cmp_id=@cmp_id and Asset_Application_ID=@application_id) and Emp_Id=@emp_id  and Cmp_ID =@cmp_id and  return_asset_approval_id is null AND 
                    (asset_approval_id NOT IN (SELECT Return_asset_approval_id FROM dbo.t0130_asset_approval_det AS V0040_Asset_Return_1 WHERE (Application_Type = 1)))
				end          
			else if @branch_id >0
				begin
					SELECT BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model, Serial_No as SerialNo, Allocation_Date, Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,  
                    Branch_ID, Brand_ID,case when convert(varchar(10),Purchase_date,103)='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end Purchase_date, '' AS Return_Date, asset_approval_id
                    FROM dbo.V0040_Asset_Return 
                    WHERE isnull(Application_Type,0) = 0 and AssetM_Id in (select replace(AssetM_Id,'#',',') from V0100_Asset_Application where cmp_id=@cmp_id and Asset_Application_ID=@application_id) and return_asset_approval_id is null and Branch_id=@branch_id and Emp_Id=@emp_id and Cmp_ID =@cmp_id
				end
		  else if @dept_id >0
				 begin
					SELECT BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model, Serial_No as SerialNo, Allocation_Date, Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,  
                    Branch_ID, Brand_ID,case when convert(varchar(10),Purchase_date,103)='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end Purchase_date, '' AS Return_Date, asset_approval_id 
                    FROM dbo.V0040_Asset_Return 
                    WHERE isnull(Application_Type,0) = 0 and AssetM_Id in (select replace(AssetM_Id,'#',',') from V0100_Asset_Application where cmp_id=@cmp_id and Asset_Application_ID=@application_id) and return_asset_approval_id is null and Dept_id=@dept_id and applied_by=@emp_id and Cmp_ID =@cmp_id
				 end                    












