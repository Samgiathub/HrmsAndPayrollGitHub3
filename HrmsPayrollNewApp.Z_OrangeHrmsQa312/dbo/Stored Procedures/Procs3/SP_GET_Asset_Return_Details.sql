
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_Asset_Return_Details]
	 @Cmp_ID	 numeric
	,@emp_id   numeric
	,@branch_id numeric
	,@dept_id numeric
	,@approval_id numeric
	,@status varchar(5)
	,@Type varchar(20)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Type='Transfer'
		begin
			if @emp_id >0
				begin
					select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model, SerialNO, Allocation_Date, 
					Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date, 
					Approval_status,Return_Date,Asset_Status,asset_approval_id,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1
					where Cmp_ID =@Cmp_ID and  Emp_Id=@emp_id and  asset_approval_id=@approval_id  order by Asset_Name
				end  
			else if @branch_id >0 and @dept_id >0
				begin	
			 print '333'
			        select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model,  SerialNO, Allocation_Date,asset_approval_id, 
					Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date,Return_Date, 
					Approval_status,Asset_Status,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1
					where Cmp_ID =@Cmp_ID and Dept_Id=@dept_id and Branch_For_Dept=ISNULL(@branch_id,0) and asset_approval_id=@approval_id  order by Asset_Name
					END
			else if @branch_id >0
				begin
					select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model,  SerialNO, Allocation_Date,asset_approval_id,  
					Approval_status, Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date,
					Return_Date,Asset_Status,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1 
					where Cmp_ID =@Cmp_ID and Branch_Id=@branch_id  and  asset_approval_id=@approval_id  order by Asset_Name
				end
			else if @dept_id >0
				 begin				
					select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model,  SerialNO, Allocation_Date,asset_approval_id, 
					Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date,Return_Date, 
					Approval_status,Asset_Status,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1
					where Cmp_ID =@Cmp_ID and Dept_Id=@dept_id and asset_approval_id=@approval_id  order by Asset_Name
				 end          
		end
	else
		begin
			if @status='A'
				begin
					if @emp_id >0
						begin
							select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model, SerialNO, Allocation_Date, 
							Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date, 
							Approval_status,Return_Date,Asset_Status,asset_approval_id,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1
							where Cmp_ID =@Cmp_ID and  Emp_Id=@emp_id and  asset_approval_id=@approval_id and isnull(Return_asset_approval_id,0) >0 order by Asset_Name
						end          
					else if @branch_id >0
						begin
							select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model,  SerialNO, Allocation_Date,asset_approval_id,  
							Approval_status, Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date,
							Return_Date,Asset_Status,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1 
							where Cmp_ID =@Cmp_ID and Branch_Id=@branch_id  and  asset_approval_id=@approval_id and isnull(Return_asset_approval_id,0) >0 order by Asset_Name
						end
				  else if @dept_id >0
						 begin
							select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model,  SerialNO, Allocation_Date,asset_approval_id, 
							Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date,Return_Date, 
							Approval_status,Asset_Status,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1
							where Cmp_ID =@Cmp_ID and Dept_Id=@dept_id  and  asset_approval_id=@approval_id and isnull(Return_asset_approval_id,0) >0 order by Asset_Name
						 end                    
				 end
				 
    else if @status='R'
		begin
		     if @emp_id >0
					begin
						select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model, SerialNO, Allocation_Date,  
						Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date, 
						case when Approval_status='A' then 'Approve' else 'Reject' end as Approval_status, case when convert(varchar(10),Return_Date,103) ='01/01/1900' then '' else convert(varchar(10),Return_Date,103) end as Return_Date,Asset_Status,
						asset_approval_id,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1 
						where Cmp_ID =@Cmp_ID and  Emp_Id=@emp_id and  asset_approval_id= @approval_id order by Asset_Name
					end          
			else if @branch_id >0
					begin
						select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model,  SerialNO, Allocation_Date,asset_approval_id, 
						Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date, 
						case when Approval_status='A' then 'Approve' else 'Reject' end as Approval_status, case when convert(varchar(10),Return_Date,103) ='01/01/1900' then '' else convert(varchar(10),Return_Date,103) end as Return_Date,
						Asset_Status,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1 
						where Cmp_ID =@Cmp_ID and Branch_Id=@branch_id  and  asset_approval_id=@approval_id  order by Asset_Name
					end
			else if @dept_id >0
					 begin
						select BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name as Model,  SerialNO, Allocation_Date,asset_approval_id, 
						Asset_Code, Emp_ID, Cmp_ID, AssetM_ID,Branch_ID, Brand_ID, case when convert(varchar(10),Purchase_date,103) ='01/01/1900' then '' else convert(varchar(10),Purchase_date,103) end as Purchase_date,Return_Date, 
						Approval_status,Asset_Status,isnull(Return_asset_approval_id,0)Return_asset_approval_id,[Description] from V0040_Asset_Return_Details1
						where Cmp_ID =@Cmp_ID and Dept_Id=@dept_id  and  asset_approval_id=@approval_id  order by Asset_Name
					 end      
		end
 end                              




