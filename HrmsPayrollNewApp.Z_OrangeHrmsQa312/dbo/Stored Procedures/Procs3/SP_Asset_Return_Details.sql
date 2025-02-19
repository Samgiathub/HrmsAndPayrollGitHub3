
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Asset_Return_Details]
	 @Cmp_ID	 numeric
	,@Type   numeric
	,@Application_Type numeric
	,@Parameter_ID numeric
AS
--@type 0 employee,1 branch,2 department
--@Application_Type 1 Return else Transfer
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Application_Type=1
		begin
			if @Type=0 --for employee
				begin
					select A.Application_type, 
						A.asset_id,A.asset_name,A.brand_id,A.brand_name,A.asset_code,A.SerialNO,A.Model_name as Model,
					case when convert(varchar(10),A.Purchase_Date,103)='01/01/1900' then '' else convert(varchar(10),A.Purchase_Date,103) 
					end Purchase_Date,A.AssetM_Id,A.allocation_date,' 'as Return_Date,A.asset_approval_id,A.Return_asset_approval_id,A.[Description]
					from V0040_Asset_Return_Details1 A Left outer Join
					
					(Select Return_Asset_Approval_Id, AssetM_id 
						From V0040_Asset_Return_Details1 Where Return_Asset_Approval_Id is not null 
							And (Emp_Id=@Parameter_ID or Transfer_Emp_Id=@Parameter_ID) and Cmp_ID =@Cmp_ID ) Qry
					on A.Asset_Approval_Id = Qry.Return_Asset_Approval_Id and A.AssetM_id = Qry.AssetM_id
					
					where A.Cmp_ID =@Cmp_ID and A.status <> 'R' and
					((A.Emp_Id=@Parameter_ID And A.application_type=0 )or (A.Transfer_Emp_Id=@Parameter_ID And A.application_type=3)) and
					 A.transfer_id is null and A.approval_status <> 'R'  And Qry.Return_Asset_Approval_Id Is null
					order by Asset_Name
				end
			else if @Type=1  --for Branch
				begin
					select A.Application_type, 
						A.asset_id,A.asset_name,A.brand_id,A.brand_name,A.asset_code,A.SerialNO,A.Model_name as Model,
					case when convert(varchar(10),A.Purchase_Date,103)='01/01/1900' then '' else convert(varchar(10),A.Purchase_Date,103) 
					end Purchase_Date,A.AssetM_Id,A.allocation_date,' 'as Return_Date,A.asset_approval_id,A.Return_asset_approval_id,A.[Description] 
					from V0040_Asset_Return_Details1 A Left outer Join
					
					(Select Return_Asset_Approval_Id, AssetM_id 
						From V0040_Asset_Return_Details1 Where Return_Asset_Approval_Id is not null 
							And (Branch_Id=@Parameter_ID or Transfer_Branch_Id=@Parameter_ID) and Cmp_ID =@Cmp_ID ) Qry
					on A.Asset_Approval_Id = Qry.Return_Asset_Approval_Id and A.AssetM_id = Qry.AssetM_id
					
					where A.Cmp_ID =@Cmp_ID and A.status <> 'R' and
					((A.Branch_Id=@Parameter_ID And A.application_type=0 )or (A.Transfer_Branch_Id=@Parameter_ID And A.application_type=3)) and
					 A.transfer_id is null and A.approval_status <> 'R'  And Qry.Return_Asset_Approval_Id Is null
					order by Asset_Name
				end
			else if @Type=2  --for Department
				begin
					select A.Application_type, 
						A.asset_id,A.asset_name,A.brand_id,A.brand_name,A.asset_code,A.SerialNO,A.Model_name as Model,
					case when convert(varchar(10),A.Purchase_Date,103)='01/01/1900' then '' else convert(varchar(10),A.Purchase_Date,103) 
					end Purchase_Date,A.AssetM_Id,A.allocation_date,' 'as Return_Date,A.asset_approval_id,A.Return_asset_approval_id,A.[Description] 
					from V0040_Asset_Return_Details1 A Left outer Join
					(Select Return_Asset_Approval_Id, AssetM_id 
						From V0040_Asset_Return_Details1 Where Return_Asset_Approval_Id is not null 
							And (Dept_Id=@Parameter_ID or Transfer_Dept_Id=@Parameter_ID) and Cmp_ID =@Cmp_ID ) Qry
					on A.Asset_Approval_Id = Qry.Return_Asset_Approval_Id and A.AssetM_id = Qry.AssetM_id
					
					where A.Cmp_ID =@Cmp_ID and A.status <> 'R' and
					((A.Dept_Id=@Parameter_ID And A.application_type=0 )or (A.Transfer_Dept_Id=@Parameter_ID And A.application_type=3)) and
					 A.transfer_id is null and A.approval_status <> 'R'  And Qry.Return_Asset_Approval_Id Is null
					order by Asset_Name
				end
		end
    else
		begin
			if @Type=0 --for employee
				begin
					--select asset_id,asset_name,brand_id,brand_name,asset_code,SerialNO,Model_name as Model,
					--case when convert(varchar(10),Purchase_Date,103)='01/01/1900' then '' else convert(varchar(10),Purchase_Date,103) 
					--end Purchase_Date,AssetM_Id,'' as allocation_date,' 'as Return_Date,asset_approval_id,Return_asset_approval_id 
					--from V0040_Asset_Return_Details1 where Cmp_ID =@Cmp_ID and status <> 'R' and
					--(Emp_Id=@Parameter_ID or Transfer_Emp_Id=@Parameter_ID) and
					--Return_asset_approval_id is null AND (asset_approval_id NOT IN (SELECT isnull(Return_asset_approval_id,0)
					--FROM dbo.t0130_asset_approval_det AS V0040_Asset_Return_1 WHERE (Application_Type = 1))) and 
					--(asset_approval_id NOT IN (SELECT isnull(Transfer_id,0)FROM dbo.t0130_asset_approval_det  m1 
					--inner join t0120_asset_approval m2 on m1.asset_approval_id =m2.asset_approval_id 
					--WHERE m1.Application_Type = 1 and m2.Emp_Id=@Parameter_ID))and
					--(application_type=0 or application_type=3) and approval_status <> 'R' order by Asset_Name
					
					select A.Application_type, 
						A.asset_id,A.asset_name,A.brand_id,A.brand_name,A.asset_code,A.SerialNO,A.Model_name as Model,
					case when convert(varchar(10),A.Purchase_Date,103)='01/01/1900' then '' else convert(varchar(10),A.Purchase_Date,103) 
					end Purchase_Date,A.AssetM_Id,'' as allocation_date,' 'as Return_Date,A.asset_approval_id,A.Return_asset_approval_id,A.[Description] 
					from V0040_Asset_Return_Details1 A Left outer Join
					
					(Select Return_Asset_Approval_Id, AssetM_id 
						From V0040_Asset_Return_Details1 Where Return_Asset_Approval_Id is not null 
							And (Emp_Id=@Parameter_ID or Transfer_Emp_Id=@Parameter_ID) and Cmp_ID =@Cmp_ID ) Qry
					on A.Asset_Approval_Id = Qry.Return_Asset_Approval_Id and A.AssetM_id = Qry.AssetM_id
					
					where A.Cmp_ID =@Cmp_ID and A.status <> 'R' and
					((A.Emp_Id=@Parameter_ID And A.application_type=0 )or (A.Transfer_Emp_Id=@Parameter_ID And A.application_type=3)) and
					 A.transfer_id is null and A.approval_status <> 'R'  And Qry.Return_Asset_Approval_Id Is null
					order by Asset_Name
					
				end
			else if @Type=1  --for Branch
				begin
					select A.Application_type, 
						A.asset_id,A.asset_name,A.brand_id,A.brand_name,A.asset_code,A.SerialNO,A.Model_name as Model,
					case when convert(varchar(10),A.Purchase_Date,103)='01/01/1900' then '' else convert(varchar(10),A.Purchase_Date,103) 
					end Purchase_Date,A.AssetM_Id,'' as allocation_date,' 'as Return_Date,A.asset_approval_id,A.Return_asset_approval_id,A.[Description] 
					from V0040_Asset_Return_Details1 A Left outer Join
					
					(Select Return_Asset_Approval_Id, AssetM_id 
						From V0040_Asset_Return_Details1 Where Return_Asset_Approval_Id is not null 
							And (Branch_Id=@Parameter_ID or Transfer_Branch_Id=@Parameter_ID) and Cmp_ID =@Cmp_ID ) Qry
					on A.Asset_Approval_Id = Qry.Return_Asset_Approval_Id and A.AssetM_id = Qry.AssetM_id
					
					where A.Cmp_ID =@Cmp_ID and A.status <> 'R' and
					((A.Branch_Id=@Parameter_ID And A.application_type=0 )or (A.Transfer_Branch_Id=@Parameter_ID And A.application_type=3)) and
					 A.transfer_id is null and A.approval_status <> 'R'  And Qry.Return_Asset_Approval_Id Is null
					order by Asset_Name
				end
			else if @Type=2  --for Department
				begin
					select A.Application_type, 
						A.asset_id,A.asset_name,A.brand_id,A.brand_name,A.asset_code,A.SerialNO,A.Model_name as Model,
					case when convert(varchar(10),A.Purchase_Date,103)='01/01/1900' then '' else convert(varchar(10),A.Purchase_Date,103) 
					end Purchase_Date,A.AssetM_Id,'' as allocation_date,' 'as Return_Date,A.asset_approval_id,A.Return_asset_approval_id ,A.[Description]
					from V0040_Asset_Return_Details1 A Left outer Join
					
					(Select Return_Asset_Approval_Id, AssetM_id 
						From V0040_Asset_Return_Details1 Where Return_Asset_Approval_Id is not null 
							And (Dept_Id=@Parameter_ID or Transfer_Dept_Id=@Parameter_ID) and Cmp_ID =@Cmp_ID ) Qry
					on A.Asset_Approval_Id = Qry.Return_Asset_Approval_Id and A.AssetM_id = Qry.AssetM_id
					
					where A.Cmp_ID =@Cmp_ID and A.status <> 'R' and
					((A.Dept_Id=@Parameter_ID And A.application_type=0 )or (A.Transfer_Dept_Id=@Parameter_ID And A.application_type=3)) and
					 A.transfer_id is null and A.approval_status <> 'R'  And Qry.Return_Asset_Approval_Id Is null
					order by Asset_Name
				end
		end           
	



