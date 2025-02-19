


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_ASSET_APPROVAL]
	 @Cmp_ID 		numeric,
	 @allocation1 varchar(20),
	 @format varchar(20),
	 @From_Date  DATETIME,
	 @To_date	DATETIME,
	 @constraint 	varchar(MAX),
	 @branch1 		numeric
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@RC_ID			numeric(18,0) = 0
	,@Asset_ID    	numeric  
	,@Dept_Id1		numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
	If @Desig_ID = 0
		set @Desig_ID = null
	if @Branch1 = 0
		set @Branch1 = null
		
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	--BEGIN
		--select * from T0040_Asset_Details
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
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
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
	if @Asset_ID > 0
	begin
		IF @allocation1='Branch Asset' and @format='All'
			begin
				if @branch1 >0	
					begin
						SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_Full_Name ,'' as Emp_code,'' as ename,@format as allocation1,apd.allocation_date,
						b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
						case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name   
						FROM         dbo.T0040_Asset_Details ad WITH (NOLOCK)  INNER JOIN
												  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
												  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
												  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
												  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
												  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 
												  inner join T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and ap.Branch_ID=b.Branch_ID and b.Branch_ID=@branch1
												  where ap.Cmp_ID=@Cmp_ID and apd.asset_id=@Asset_ID
												  and ap.Asset_Approval_Date between @From_Date and @To_date
												  --and apd.Allocation_Date between @From_Date and @To_date
					 end
				else
					begin
						SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_Full_Name ,'' as Emp_code,'' as ename,@format as allocation1,apd.allocation_date,
						b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
						case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name   
						FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
												  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
												  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
												  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
												  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
												  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 
												  inner join T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and ap.Branch_ID=b.Branch_ID 
												  where ap.Cmp_ID=@Cmp_ID  and apd.asset_id=@Asset_ID
												  --and apd.Allocation_Date between @From_Date and @To_date
												  and ap.Asset_Approval_Date between @From_Date and @To_date
					 end
			end
		 else if @format='Allocation' and @allocation1='Branch Asset'
			begin
				if @branch1 >0	
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name        
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 left outer join
								T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and  b.Branch_ID=@branch1 and b.Branch_ID=ap.Branch_ID 
								where ap.Cmp_ID=@Cmp_ID and ap.Branch_ID=@branch1 
								--and apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date	AND apd.Application_Type=0 and apd.asset_id=@Asset_ID
					end
				else
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],'' as Dept_Name,
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status     
								FROM         dbo.T0040_Asset_Details ad WITH (NOLOCK)  INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 left outer join
								T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and b.Branch_ID=ap.Branch_ID 
								where ap.Cmp_ID=@Cmp_ID and ap.Branch_ID=@branch1 
								--and apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=0 and apd.asset_id=@Asset_ID
					end
			end
	else if @format='Return' and @allocation1='Branch Asset'
		begin
				if @branch1 >0	
					begin
								SELECT  distinct ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,ap.*,apd.allocation_date,						
								CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name        
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 left outer join
								T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and  b.Branch_ID=@branch1 and b.Branch_ID=ap.Branch_ID  
								where ap.Cmp_ID=@Cmp_ID and ap.Branch_ID=@branch1  
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 and apd.asset_id=@Asset_ID
					end
				else
					begin
								SELECT  distinct ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,ap.*,apd.allocation_date,						
								CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],'' as Dept_Name,   
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status     
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 left outer join
								T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and b.Branch_ID=ap.Branch_ID  
								where ap.Cmp_ID=@Cmp_ID and ap.Branch_ID=@branch1  
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 and apd.asset_id=@Asset_ID
					end
			end
	else if @allocation1='Department Asset' and @format='All'
			begin
				if @Dept_Id1 >0	
					begin
					
						SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_Full_Name ,'' as Emp_code,'' as ename,@format as allocation1,apd.allocation_date,
						d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
						case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Branch_Name   
						FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
												  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
												  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
												  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
												  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
												  T0120_Asset_Approval ap WITH (NOLOCK)  on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 inner join 
												  T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id and d.Dept_Id=@Dept_Id1
												  where ap.Cmp_ID=@Cmp_ID 
												  --and apd.Allocation_Date between @From_Date and @To_date 
												  and ap.Asset_Approval_Date between @From_Date and @To_date
												  and apd.asset_id=@Asset_ID
					 end
				else
					begin
						SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_Full_Name ,'' as Emp_code,'' as ename,@format as allocation1,apd.allocation_date,
						d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
						case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status ,'' as Branch_Name 
						FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
												  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
												  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
												  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
												  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
												  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 inner join
												  T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id 
												  where ap.Cmp_ID=@Cmp_ID 
												  --and apd.Allocation_Date between @From_Date and @To_date 
												  and ap.Asset_Approval_Date between @From_Date and @To_date
												  and apd.asset_id=@Asset_ID
					 end
			end
		 else if @format='Allocation' and @allocation1='Department Asset'
			begin
				if @Dept_Id1 >0	
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Branch_Name     
								FROM         dbo.T0040_Asset_Details ad WITH (NOLOCK)  INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 left outer join
								T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id and d.Dept_Id=@Dept_Id1
								where ap.Cmp_ID=@Cmp_ID 
								--and	apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=0 and apd.asset_id=@Asset_ID
					end
				else
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Branch_Name     
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK)  ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK)  on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 left outer join
								T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id 
								where ap.Cmp_ID=@Cmp_ID 
								--and apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=0 and apd.asset_id=@Asset_ID
					end
			end
	else if @format='Return' and @allocation1='Department Asset'
		begin
				if @Dept_Id1 >0	
					begin
								SELECT  distinct ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,ap.*,apd.allocation_date,						
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status  ,'' as Branch_Name   
								FROM         dbo.T0040_Asset_Details ad WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 left outer join
								T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id and d.Dept_Id=@Dept_Id1
								where ap.Cmp_ID=@Cmp_ID  
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 and apd.asset_id=@Asset_ID
					end
				else
					begin
								SELECT  distinct ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,ap.*,apd.allocation_date,						
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status ,'' as Branch_Name    
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK)  on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 left outer join
								T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id 
								where ap.Cmp_ID=@Cmp_ID  
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 and apd.asset_id=@Asset_ID
					end
			end
			
	else if @allocation1='Employee Asset' and @format='All'
			begin
				SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,e.alpha_emp_code as Emp_code,e.Emp_Full_Name,(CONVERT(nvarchar(20),ISNULL( e.Alpha_Emp_code,0))  + '-' + e.Emp_Full_Name)as ename,
				@format as allocation1,'' as Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
				CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
				case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' when apd.Asset_status='D' then 'Damage' end as Asset_status,'' as Dept_Name        
				FROM         dbo.T0040_Asset_Details ad WITH (NOLOCK)  INNER JOIN
										  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
										  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
										  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
										  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
										  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Emp_ID <> 0 left outer join
										 -- inner join  T0030_BRANCH_MASTER b on b.Cmp_ID=ap.Cmp_ID and  b.Branch_Name=@branch1 and b.Branch_ID=ap.Branch_ID  inner join
										  T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Emp_ID
										  where ap.Cmp_ID=@Cmp_ID and ap.Emp_ID <> 0 
										 -- and apd.Allocation_Date between @From_Date and @To_date 
										  and ap.Asset_Approval_Date between @From_Date and @To_date
										  AND E.Emp_ID in (select Emp_ID From @Emp_Cons) and apd.asset_id=@Asset_ID   
										  order by Asset_Name asc
					
			 end
			
				else if @format='Allocation' and @allocation1='Employee Asset' 
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,e.Emp_code,e.Emp_Full_Name,(CONVERT(nvarchar(20),ISNULL( e.Alpha_Emp_code,0))  + '-' + e.Emp_Full_Name)as ename,
								@format as allocation1,'' as Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name        
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Emp_ID <> 0 left outer join
								--T0030_BRANCH_MASTER b on b.Cmp_ID=ap.Cmp_ID and  b.Branch_Name=@branch1 and b.Branch_ID=ap.Branch_ID  inner join
								T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Emp_ID
								where ap.Cmp_ID=@Cmp_ID and ap.Emp_ID <> 0 
								--and apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=0 and	E.Emp_ID in (select Emp_ID From @Emp_Cons) and apd.asset_id=@Asset_ID
					
					end

				else if @format='Return' and @allocation1='Employee Asset'
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,e.Emp_code,e.Emp_Full_Name,(CONVERT(nvarchar(20),ISNULL( e.Alpha_Emp_code,0))  + '-' + e.Emp_Full_Name)as ename,
								ap.*,apd.allocation_date,
								@format as allocation1,'' as Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,
								CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name        
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Emp_ID <> 0 left outer join
								--T0030_BRANCH_MASTER b on b.Cmp_ID=ap.Cmp_ID and  b.Branch_Name=@branch1 and b.Branch_ID=ap.Branch_ID  inner join
								T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Emp_ID
								where ap.Cmp_ID=@Cmp_ID and ap.Emp_ID <> 0 
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 and	E.Emp_ID in (select Emp_ID From @Emp_Cons) and apd.asset_id=@Asset_ID
					end
	end
else
	begin
		IF @allocation1='Branch Asset' and @format='All' 
			begin
			if @branch1 >0	
				begin
					SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_Full_Name ,'' as Emp_code,'' as ename,@format as allocation1,apd.allocation_date,
					b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
					case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name      
					FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
											  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
											  dbo.T0040_ASSET_MASTER am WITH (NOLOCK)  ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
											  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
											  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
											  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 
											  inner join T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and   b.Branch_ID=@branch1  and ap.Branch_ID=b.Branch_ID 
											  where ap.Cmp_ID=@Cmp_ID 
											  --and apd.Allocation_Date between @From_Date and @To_date 
											  and ap.Asset_Approval_Date between @From_Date and @To_date
				end
			else
				begin
					SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_Full_Name ,'' as Emp_code,'' as ename,@format as allocation1,apd.allocation_date,
					b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
					case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status ,'' as Dept_Name     
					FROM         dbo.T0040_Asset_Details ad WITH (NOLOCK)  INNER JOIN
											  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
											  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
											  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
											  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
											  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 
											  inner join T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and ap.Branch_ID=b.Branch_ID 
											 -- CASE when @branch1 <> '' then b.Branch_Name=@branch1 else b.Branch_ID=ap.Branch_ID end
											  --inner join T0080_Emp_Master e on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Emp_ID
											  where ap.Cmp_ID=@Cmp_ID 
											  --and apd.Allocation_Date between @From_Date and @To_date 	
											  and ap.Asset_Approval_Date between @From_Date and @To_date
				end
		
		 end
		 else if @format='Allocation' and @allocation1='Branch Asset'
			begin
				if @branch1 >0	
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name       
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK)  ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 left outer join
								T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and  b.Branch_ID=@branch1 and b.Branch_ID=ap.Branch_ID 
								where ap.Cmp_ID=@Cmp_ID and ap.Branch_ID=@branch1 
								--and apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=0 
					end
				else
					begin
				
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status ,'' as Dept_Name       
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK)  ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 left outer join
								T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and b.Branch_ID=ap.Branch_ID 
								where ap.Cmp_ID=@Cmp_ID 
								--and apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=0 
					end
			end		

	else if @format='Return' and @allocation1='Branch Asset'
			begin
				if @branch1 >0	
					begin
								SELECT  distinct ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,ap.*,apd.allocation_date,						
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name        
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 left outer join
								T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and  b.Branch_ID=@branch1 and b.Branch_ID=ap.Branch_ID  
								where ap.Cmp_ID=@Cmp_ID and ap.Branch_ID=@branch1  
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 
					end
				else
						begin
								SELECT  distinct ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,b.Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,ap.*,apd.allocation_date,						
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],'' as Dept_Name,   
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status     
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Branch_ID <> 0 left outer join
								T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Cmp_ID=ap.Cmp_ID and b.Branch_ID=ap.Branch_ID  
								where ap.Cmp_ID=@Cmp_ID  
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 
					end
			end
			
	else if @allocation1='Department Asset' and @format='All'
			begin
				if @Dept_Id1 >0	
					begin
						SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_Full_Name ,'' as Emp_code,'' as ename,@format as allocation1,apd.allocation_date,
						d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
						case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Branch_Name   
						FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
												  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
												  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
												  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
												  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
												  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 inner join 
												  T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id and d.Dept_Id=@Dept_Id1
												  where ap.Cmp_ID=@Cmp_ID 
												  --and apd.Allocation_Date between @From_Date and @To_date 
												  and ap.Asset_Approval_Date between @From_Date and @To_date
					 end
				else
					begin
						SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_Full_Name ,'' as Emp_code,'' as ename,@format as allocation1,apd.allocation_date,
						'' as Branch_Name,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
						case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status
						FROM         dbo.T0040_Asset_Details ad WITH (NOLOCK)  INNER JOIN
												  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
												  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
												  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
												  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
												  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 inner join
												  T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id 
												  where ap.Cmp_ID=@Cmp_ID 
												  --and apd.Allocation_Date between @From_Date and @To_date 
												  and ap.Asset_Approval_Date between @From_Date and @To_date
					 end
			end
		 else if @format='Allocation' and @allocation1='Department Asset'
			begin
				if @Dept_Id1 >0	
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Branch_Name     
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 left outer join
								T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id and d.Dept_Id=@Dept_Id1
								where ap.Cmp_ID=@Cmp_ID 
								--and apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=0 
					end
				else
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Branch_Name     
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 left outer join
								T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id 
								where ap.Cmp_ID=@Cmp_ID 
								--and apd.Allocation_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=0 
					end
			end
	else if @format='Return' and @allocation1='Department Asset'
		begin
				if @Dept_Id1 >0	
					begin
								SELECT  distinct ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,ap.*,apd.allocation_date,						
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Branch_Name     
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK)  ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 left outer join
								T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id and d.Dept_Id=@Dept_Id1
								where ap.Cmp_ID=@Cmp_ID  
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 
					end
				else
					begin
								SELECT  distinct ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,'' as Emp_code,'' as Emp_Full_Name,'' as ename,
								@format as allocation1,d.Dept_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,ap.*,apd.allocation_date,						
								CASE when apd.Application_Type = 0 then 'Allocation' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Branch_Name     
								FROM         dbo.T0040_Asset_Details ad WITH (NOLOCK)  INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Dept_Id <> 0 left outer join
								T0040_Department_Master d WITH (NOLOCK) on d.Cmp_ID=ap.Cmp_ID and ap.Dept_Id=d.Dept_Id 
								where ap.Cmp_ID=@Cmp_ID  
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 
					end
			end
 else if @allocation1='Employee Asset' and @format='All'
			begin
				SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,e.Emp_code,e.Emp_Full_Name,(CONVERT(nvarchar(20),ISNULL( e.Alpha_Emp_code,0))  + '-' + e.Emp_Full_Name)as ename,
				@format as allocation1,'' as Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
				CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
				case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' when apd.Asset_status='D' then 'Damage' end as Asset_status,'' as Dept_Name        
				FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
										  dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
										  dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
										  Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
										  T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID inner join
										  T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Emp_ID <> 0 left outer join
										 -- inner join  T0030_BRANCH_MASTER b on b.Cmp_ID=ap.Cmp_ID and  b.Branch_Name=@branch1 and b.Branch_ID=ap.Branch_ID  inner join
										  T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Emp_ID
										  where ap.Cmp_ID=@Cmp_ID and ap.Emp_ID <> 0 
										  --and apd.Allocation_Date between @From_Date and @To_date 
										  and ap.Asset_Approval_Date between @From_Date and @To_date
										  AND E.Emp_ID in (select Emp_ID From @Emp_Cons)   
					
			 end
			
				else if @format='Allocation' and @allocation1='Employee Asset' 
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,ap.*,e.Emp_code,e.Emp_Full_Name,(CONVERT(nvarchar(20),ISNULL( e.Alpha_Emp_code,0))  + '-' + e.Emp_Full_Name)as ename,
								@format as allocation1,'' as Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,apd.allocation_date,
								CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status,'' as Dept_Name        
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=0 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Emp_ID <> 0 left outer join
								--T0030_BRANCH_MASTER b on b.Cmp_ID=ap.Cmp_ID and  b.Branch_Name=@branch1 and b.Branch_ID=ap.Branch_ID  inner join
								T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Emp_ID
								where ap.Cmp_ID=@Cmp_ID and ap.Emp_ID <> 0 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								--and apd.Allocation_Date between @From_Date and @To_date 
								AND apd.Application_Type=0 and	E.Emp_ID in (select Emp_ID From @Emp_Cons) 
					
					end

				else if @format='Return' and @allocation1='Employee Asset'
					begin
								SELECT distinct  ad.*,br.BRAND_Name,am.Asset_Name,co.Cmp_Name,co.Cmp_Address,e.Emp_code,e.Emp_Full_Name,(CONVERT(nvarchar(20),ISNULL( e.Alpha_Emp_code,0))  + '-' + e.Emp_Full_Name)as ename,
								ap.*,apd.allocation_date,
								@format as allocation1,'' as Branch_Name,apd.Application_Type,apd.Return_Date,apd.Asset_Status,
								CASE when apd.Application_Type = 0 then 'Allocation' when apd.Application_Type = 2 then 'Sell' else 'Return' end as [Application_Type1],
								case when apd.Asset_status='W' then 'Working' when apd.Asset_status='Dispose' then 'Dispose' else 'Damage' end as Asset_status ,'' as Dept_Name       
								FROM         dbo.T0040_Asset_Details ad  WITH (NOLOCK) INNER JOIN
								dbo.T0040_BRAND_MASTER br WITH (NOLOCK) ON ad.BRAND_ID = br.BRAND_ID and ad.Cmp_ID=br.Cmp_ID INNER JOIN
								dbo.T0040_ASSET_MASTER am WITH (NOLOCK) ON ad.Asset_ID = am.Asset_ID  and ad.Cmp_ID=am.Cmp_ID inner join 
								Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=ad.Cmp_ID inner join
								T0130_Asset_Approval_Det apd WITH (NOLOCK) on apd.Cmp_ID=ad.Cmp_ID and apd.AssetM_ID=ad.AssetM_ID and apd.Application_Type=1 inner join
								T0120_Asset_Approval ap WITH (NOLOCK) on ap.Cmp_ID=apd.Cmp_ID and ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.Emp_ID <> 0 left outer join
								--T0030_BRANCH_MASTER b on b.Cmp_ID=ap.Cmp_ID and  b.Branch_Name=@branch1 and b.Branch_ID=ap.Branch_ID  inner join
								T0080_Emp_Master e WITH (NOLOCK) on e.Cmp_ID=ap.Cmp_ID and e.Emp_ID=ap.Emp_ID
								where ap.Cmp_ID=@Cmp_ID and ap.Emp_ID <> 0 
								--and apd.Return_Date between @From_Date and @To_date 
								and ap.Asset_Approval_Date between @From_Date and @To_date
								AND apd.Application_Type=1 and	E.Emp_ID in (select Emp_ID From @Emp_Cons) 
					end
	end
	
























