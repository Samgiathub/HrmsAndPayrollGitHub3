

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_ASSET_APPROVAL_FORMAT3]
	 @Cmp_ID 		numeric,
	 @From_Date  DATETIME,
	 @To_date	DATETIME,
	 @constraint 	varchar(MAX),
	 @branch1 		numeric
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@RC_ID			numeric(18,0) = 0
	,@Asset_Code1   Varchar(250)
	,@Dept_Id1		numeric 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  --  if @Branch_ID = 0
		--set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Type_ID = 0
		set @Type_ID = null
	--if @Dept_ID = 0
	--	set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
	If @Desig_ID = 0
		set @Desig_ID = null
	if @Branch1 = 0
		set @Branch1 = null
	if @Asset_Code1='--Select--'
		set @Asset_Code1=''
		
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
	 		Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else 
		begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch1 ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_Id1 ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date and  @From_Date <= left_date ) 
			
		end
		
	declare @Asset_Approval_ID as numeric(18,0)
	declare @application_type as numeric(18,0)
	declare @AssetM_ID as numeric(18,0)
	declare @Asset_Name as varchar(250)
	declare @BRAND_Name as varchar(250)
	declare @Asset_Code as varchar(250)
	declare @SerialNo as varchar(250)
	declare @Allocation_Date as  varchar(50)
	declare @Vendor as varchar(250)
	declare @Type_of_Asset as varchar(250)
	declare @Model as varchar(250)
	declare @Return_Date  as  varchar(50)
	declare @Alpha_Emp_Code as varchar(250)
	declare @Brand_Id as numeric(18,0) 
	declare @Asset_Status as varchar(250)
	declare @Asset_ID as numeric(18,0)
	declare @Emp_Full_Name as varchar(250)
	declare @Pending_amount as numeric(18,2)
	declare @Branch_Name varchar(250)
	declare @Dept_Name varchar(250)
	declare @Cmp_Name varchar(250)
	declare @Cmp_Address varchar(max)
	declare @Transfer_Emp_Id numeric(18,0)
	declare @Branch_Id numeric(18,0)
	declare @Transfer_Branch_Id numeric(18,0)
	declare @Dept_Id numeric(18,0)
	declare @Transfer_Dept_Id numeric(18,0)
	declare @Return_Asset_Approval_Id numeric(18,0)

	CREATE table #ASSET_EMP
	(
	 Asset_Name  varchar(250),
	 BRAND_Name  varchar(250),
	 Asset_Code  varchar(250),
	 Serial_No  varchar(250),
	 Allocation_Date  varchar(50),
	 Return_Date  varchar(50),
	 Type_of_Asset  varchar(250),
	 Model  varchar(250),
	 AssetM_Id numeric(18,0) ,
	 Asset_Id numeric(18,0) ,
	 Brand_Id numeric(18,0) ,
	 Asset_Approval_ID numeric(18,0) ,
	 Emp_Id  numeric(18,0) ,
	 Alpha_Emp_Code varchar(250),
	 Emp_Full_Name varchar(250),
	 Branch_Name  varchar(250),
	 Asset_Status  varchar(25),
	 Dept_Name varchar(250),
	 Cmp_Name varchar(250),
	 Cmp_Address varchar(max),
	 Application_Type numeric(18,0),
	 Transfer_Emp_Id numeric(18,0),
	 Branch_Id numeric(18,0),
	 Transfer_Branch_Id numeric(18,0),
	 Dept_Id numeric(18,0),
	 Transfer_Dept_Id numeric(18,0)
	)
	
	 
	DECLARE ASSET_DETAILS CURSOR FOR
				select apd.Asset_Approval_ID,apd.application_type,apd.assetm_id,ap.emp_id,ap.Transfer_Emp_Id,ap.Branch_Id,ap.Transfer_Branch_Id,ap.Dept_Id,ap.Transfer_Dept_Id
				from T0130_Asset_Approval_Det apd WITH (NOLOCK)
				inner join T0120_Asset_Approval ap WITH (NOLOCK) on apd.Asset_Approval_ID=ap.Asset_Approval_ID and apd.cmp_id=ap.cmp_id
				where ap.cmp_id=@cmp_id and ap.Asset_Approval_Date between @From_Date and @To_date
				-- and ((ap.emp_id in (select Emp_ID From @Emp_Cons)) or (ap.Transfer_emp_id in (select Emp_ID From @Emp_Cons)))  
				OPEN ASSET_DETAILS
							fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id
								while @@fetch_status = 0
									Begin
										if @application_type=1 --fill asset while return
											begin
												SELECT DISTINCT 
													 @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
												     @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
												     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
												     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Emp_Full_Name+'-'+E.Alpha_Emp_Code,
												     @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Branch_Name=B.Branch_Name,@Dept_Name=D.dept_name,
												     @Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,
												     @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address,@Return_Asset_Approval_Id=Return_Asset_Approval_Id
												 FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																		  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join
																		  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID left JOIN
																		  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID left JOIN
																		  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																		  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																		  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID																	 
												WHERE     isnull(Return_asset_approval_id, 0) > 0 and   isnull(Return_Date, '') <> '1900-01-01 00:00:00.000'   and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID 
												and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID 																	 										 
												
												
											if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3)
												begin
													select @Transfer_Branch_Id=Transfer_Branch_Id,@Transfer_Emp_Id=Transfer_Emp_Id,@Transfer_Dept_Id=Transfer_Dept_Id from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3
													
													if isnull(@Transfer_Emp_Id,0)>0 
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date
															where Transfer_Emp_Id=@Transfer_Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
													
													 if isnull(@Transfer_Branch_Id,0) >0 
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date
															where Transfer_Branch_Id=@Transfer_Branch_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
													 if isnull(@Transfer_Dept_Id,0) >0  
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date
															where Transfer_Dept_Id=@Transfer_Dept_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
												end
											else
												begin
													select @Branch_Id=Branch_Id,@Emp_Id=Emp_Id,@Dept_Id=Dept_Id from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=0
													
													if isnull(@Emp_Id,0)>0 
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date
															where Emp_Id=@Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
													
													 if isnull(@Branch_Id,0) >0 
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date
															where Branch_Id=@Branch_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
													 if isnull(@Dept_Id,0) >0  
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date
															where Dept_Id=@Dept_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
												end
											end
										else if @application_type=3 --fill asset while Transfer
											begin
													SELECT DISTINCT 
													 @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
												     @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
												     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
												     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Alpha_Emp_Code + '-' + E.Emp_Full_Name,
												     @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Branch_Name=B.Branch_Name,
												     @Dept_Name=D.dept_name,						     
   												     @Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,
   												     @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address
											FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																		  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join
																		  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
																		  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
																		  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																		  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																		  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID																		 
												WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID
												and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID 
											
												INSERT INTO #ASSET_EMP(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Asset_Status,Dept_Name,Cmp_Name,Cmp_Address,application_type,Transfer_Emp_Id,Branch_Id,Transfer_Branch_Id,Dept_Id,Transfer_Dept_Id)
										    	VALUES(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@AssetM_Id,@Asset_Id,@Brand_Id,@Asset_Approval_ID,@Alpha_Emp_Code,@Emp_Full_Name,@Branch_Name,@Asset_Status,@Dept_Name,@Cmp_Name,@Cmp_Address,@application_type,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id)
											
											end
										else
											begin
												SELECT DISTINCT 
													 @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
												     @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
												     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
												     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Alpha_Emp_Code + '-' + E.Emp_Full_Name,
												     @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Branch_Name=B.Branch_Name,
												     @Dept_Name=D.dept_name,@Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,
   												     @Cmp_Name=co.Cmp_Name,@Cmp_Address=co.Cmp_Address
											FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																		  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T0130_Asset_Approval_Det.Cmp_ID inner join
																		  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
																		  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
																		  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																		  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																		  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID																		 
												WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID
												and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID 
												
												INSERT INTO #ASSET_EMP(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Asset_Status,Dept_Name,Cmp_Name,Cmp_Address,application_type,Transfer_Emp_Id,Branch_Id,Transfer_Branch_Id,Dept_Id,Transfer_Dept_Id)
												VALUES(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@AssetM_Id,@Asset_Id,@Brand_Id,@Asset_Approval_ID,@Alpha_Emp_Code,@Emp_Full_Name,@Branch_Name,@Asset_Status,@Dept_Name,@Cmp_Name,@Cmp_Address,@application_type,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id)
								
											end										
							
							fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id
							End
					close ASSET_DETAILS	
					deallocate ASSET_DETAILS
					
				
			if @Asset_Code1 <>'' --to fill Asset Code wise
				begin		
					select * from #ASSET_EMP where Asset_Code=@Asset_Code1 
					--emp_id in (select Emp_ID From @Emp_Cons) and Asset_Code=@Asset_Code1
				end
			else
				begin	
					select * from #ASSET_EMP 
					--where emp_id in (select Emp_ID From @Emp_Cons)       
				end 

