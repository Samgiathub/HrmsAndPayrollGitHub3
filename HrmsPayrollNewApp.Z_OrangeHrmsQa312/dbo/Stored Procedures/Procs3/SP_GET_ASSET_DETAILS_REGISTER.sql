

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_ASSET_DETAILS_REGISTER]
	 @cmp_Id numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	varchar(MAX)
	--,@Cat_ID 		numeric 
	--,@Grd_ID 		numeric
	--,@Type_ID 		numeric
	--,@Dept_ID 		numeric
	--,@Desig_ID 		numeric
	--,@Emp_ID 		numeric
	--,@constraint 	varchar(MAX)
As
  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
    DECLARE @qry1 as nvarchar(max)
	DECLARE @columns VARCHAR(Max)
	
	
IF @Branch_ID = '' or @Branch_ID = '0'           
	  SET @Branch_ID = Null   
--	IF @Branch_ID = 0  
--		set @Branch_ID = null
		
--	IF @Cat_ID = 0  
--		set @Cat_ID = null

--	IF @Grd_ID = 0  
--		set @Grd_ID = null

--	IF @Type_ID = 0  
--		set @Type_ID = null

--	IF @Dept_ID = 0  
--		set @Dept_ID = null

--	IF @Desig_ID = 0  
--		set @Desig_ID = null

--	IF @Emp_ID = 0  
--		set @Emp_ID = null

--Declare @Emp_Cons Table
--	(
--		Emp_ID	numeric
--	)
	
--	if @Constraint <> ''
--		begin
--			Insert Into @Emp_Cons
--			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
--		end
--	else 
--		begin
--			Insert Into @Emp_Cons

--			select I.Emp_Id from T0095_Increment I inner join 
--					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
--					where Increment_Effective_date <= @To_Date
--					and Cmp_ID = @Cmp_ID
--					group by emp_ID  ) Qry on
--					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
--			Where Cmp_ID = @Cmp_ID 
--			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
--			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
--			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
--			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
--			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
--			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
--			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
--			and I.Emp_ID in 
--				( select Emp_Id from
--				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
--				where cmp_ID = @Cmp_ID   and  
--				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
--				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
--				or Left_date is null and @To_Date >= Join_Date)
--				or @To_Date >= left_date and  @From_Date <= left_date ) 
			
--		end	

	CREATE TABLE #asset_details 
		(
			Asset_ID numeric(18,0),
			AssetM_ID numeric(18,0),
			Asset_Code varchar(100),     
			asset_Name varchar(max),
			Type_of_Asset varchar(25), 
			[Description] varchar(max),
			Serial_No  varchar(50),   
			brand_name varchar(200), 
			Model varchar(200),
			Purchase_Date varchar(25),
			Warranty_Starts varchar(25),
			Warranty_Ends varchar(25),
			Purchase_Order_No varchar(25),  
			Invoice_No varchar(25),  
			Invoice_Amount NUMERIC(18,2),
			Invoice_Date varchar(25),
			Asset_Status varchar(25),  
			Vendor_name varchar(500),
			Vendor_Address varchar(max),
			Branch_Name varchar(200),
			City varchar(250),
			Contact_Person varchar(500),
			Contact_Number varchar(500),
			Installation_Name varchar(200),			
			Asset_Title varchar(200),
			Is_Allocated varchar(5),
			Asset_Approval_ID INT 			
		)
		--select @Branch_ID
		--select Data from dbo.Split(isnull(@Branch_ID,0), '#') PB Where PB.Data <> 0
		insert into #asset_details 
		SELECT  distinct ad.Asset_ID,ad.AssetM_ID,ad.Asset_Code,am.asset_Name,
        ad.Type_of_Asset,ad.[Description],ad.SerialNo,br.brand_name,
        ad.Model,
        CASE WHEN ad.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11),ad.Purchase_date, 103)END AS Purchase_date,
        CASE WHEN ad.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11),ad.Warranty_Starts, 103)END AS Warranty_Starts,
        CASE WHEN ad.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11),ad.Warranty_Ends, 103)END AS Warranty_Ends,     
        ad.PONO,ad.Invoice_No,ad.Invoice_Amount,      
        CASE WHEN ad.Invoice_Date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11),ad.Invoice_Date, 103)END AS Invoice_Date,
        CASE WHEN ad.Asset_Status = 'W' THEN 'Working' when ad.Asset_Status = 'D' THEN 'Damage' when ad.Asset_Status = 'Dispose' THEN 'Dispose' END AS Asset_Status,        
        vm.Vendor_name,vm.[Address],BM.Branch_Name,vm.City,vm.Contact_Person,vm.Contact_Number,
        ai.Installation_Name,aid.Asset_Title,case when ad.allocation =1 then 'Yes' else 'No' end,ad1.Asset_Approval_ID       
		FROM t0040_asset_details ad WITH (NOLOCK) inner join 
					T0040_ASSET_MASTER AM WITH (NOLOCK) ON ad.asset_id=am.asset_id and am.cmp_id=ad.cmp_id left join
					t0040_brand_master br WITH (NOLOCK) on br.brand_id=ad.brand_id and ad.cmp_id=br.cmp_id left join
					T0040_Vendor_Master VM WITH (NOLOCK) ON VM.Vendor_Id=ad.vendor_id and VM.cmp_id=ad.cmp_id left JOIN
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID=ad.Branch_ID and ad.cmp_id=BM.cmp_id left JOIN
					T0030_Asset_Installation ai WITH (NOLOCK) on ai.Asset_Id=ad.Asset_ID and ai.Cmp_Id=ad.Cmp_ID and ai.Installation_Type=1 left join 
					T0110_Asset_Title_Details aid WITH (NOLOCK) on aid.AssetM_Id=ad.AssetM_ID and ai.Asset_Installation_Id=aid.Asset_Installation_Id and aid.Cmp_Id=ai.Cmp_Id left JOIN
					(SELECT Max(Asset_Approval_ID)Asset_Approval_ID,ISNULL(AssetM_ID,0)AssetM_ID 
					 FROM T0130_Asset_Approval_Det WITH (NOLOCK) group by AssetM_ID)ad1 on ad1.AssetM_ID=ad.AssetM_ID 
		where ad.Cmp_Id=@Cmp_ID and (YEAR(ad.Purchase_date)=1900 or  ad.Purchase_date BETWEEN @From_Date and @To_Date) 
		and	isnull(ad.BRANCH_ID,0) IN (select Data from dbo.Split(isnull(@Branch_ID,ad.BRANCH_ID), '#') PB Where PB.Data <> '')
		order by AssetM_ID
		
		
			SELECT @columns = COALESCE(@columns + ',[' + cast(Installation_Name as varchar) + ']',
					'[' + cast(Installation_Name as varchar)+ ']')
					FROM #asset_details
					GROUP BY Installation_Name
					order by Installation_Name asc
		--select substring(asset_code,0, charindex('/',asset_code)) + '/' + 
		--		right('0000000' + substring(asset_code,charindex('/',asset_code)+1, len(asset_code)), 7), *
		--from #asset_details	
		--ORDER BY 
		--substring(asset_code,0, charindex('/',asset_code)) + '/' + 
		--		right('0000000' + substring(asset_code,charindex('/',asset_code)+1, len(asset_code)), 7)
		
		set @qry1 = 'SELECT ROW_NUMBER() Over (Order by AssetM_ID) As [Sr.No],*
			     FROM (
						SELECT Asset_Approval_ID,Asset_Code,Asset_Name,Type_of_Asset,[Description],Serial_No,Brand_name,Model,Purchase_Date,
						Warranty_Starts,Warranty_Ends,Purchase_Order_No,Invoice_No,Invoice_Amount,Invoice_Date,Asset_Status,
						Vendor_Name,Vendor_Address,Branch_Name,City,Contact_Person,Contact_Number,Is_Allocated,Asset_Title,AssetM_ID,Installation_Name
			FROM #asset_details 
		) as s
		PIVOT
		(
			Max(Asset_Title)
			FOR [Installation_Name] IN (' + @columns + ') 
		)AS m5'
		
		print @qry1
EXEC (@qry1 + ' order by substring(asset_code,0, charindex(''/'',asset_code)) + ''/'' + 
				right(''0000000'' + substring(asset_code,charindex(''/'',asset_code)+1, len(asset_code)), 7)')
