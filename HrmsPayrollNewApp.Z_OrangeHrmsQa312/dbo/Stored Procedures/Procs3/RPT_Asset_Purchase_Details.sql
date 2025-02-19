




---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_Asset_Purchase_Details]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)	
	,@Asset_ID		int
	,@flag			int=0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
	
	IF @Asset_ID=0
		SET @Asset_ID = NULL		
		
		IF @flag=0 --for Asset Purchase Details Report
			BEGIN
				SELECT DISTINCT am.Asset_Name,AD.Asset_Code,AD.Type_of_Asset,bm.BRAND_Name,model,CONVERT(varchar(11),AD.Purchase_date,103)Purchase_date,PONO,
					CONVERT(varchar(11),pono_Date,103)pono_Date,
					Invoice_No,Invoice_Amount,CONVERT(varchar(11),Invoice_Date,103)Invoice_Date,AD.SerialNo,AD.AssetM_ID,
					CM.Cmp_Name,CM.Cmp_Address,@From_Date as From_Date,@To_Date as To_Date,VM.Vendor_Name AS VENDOR,
					CASE WHEN ad.Asset_Status = 'D' THEN 'Broken/Damage' WHEN Asset_Status = 'W' THEN 'Working' 
					WHEN Asset_Status = 'Dispose' THEN 'Dispose' WHEN Asset_Status = 'Spare' THEN 'Spare'
					WHEN Asset_Status = 'Not Repairable' THEN 'Not Repairable'  END AS Asset_Status,
					CASE WHEN allocation = 1 THEN 'Yes' ELSE 'No' END AS Allocation,ISNULL(BR.Branch_Name,'')Branch_Name,BR.Branch_ID
				INTO #Asset_Det 
				FROM T0040_Asset_details AD WITH (NOLOCK)
				inner join T0040_ASSET_MASTER am WITH (NOLOCK) on am.Asset_ID=ad.Asset_ID
				inner join T0040_BRAND_MASTER bm WITH (NOLOCK) on bm.BRAND_ID=AD.BRAND_ID
				INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id=AD.Cmp_ID
				LEFT JOIN T0040_Vendor_Master VM WITH (NOLOCK) ON VM.Vendor_Id=AD.VENDOR_ID
				LEFT outer JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK)ON BR.Branch_ID=AD.Branch_ID 

				WHERE AD.Cmp_ID = @Cmp_ID And AD.Purchase_date >=@From_Date and  AD.Purchase_date <=@To_Date 
				and AD.Asset_ID=ISNULL(@Asset_ID,AD.Asset_ID) --ORDER by AD.allocation
				
				if @Branch_ID > 0
					select * from #Asset_Det where Branch_name<>'' and Branch_ID=@Branch_ID 
				ELSE
					select * from #Asset_Det
			END
		ELSE --for Asset Summary Report
			BEGIN
				DECLARE @Purchase AS INT
				DECLARE @Allocation AS INT
				DECLARE @Return AS INT
				DECLARE @Damage AS INT
				
				CREATE table #ASSET_DETAILS
				(
				 ASSET_ID INT,
				 Asset_Name  varchar(250),
				 Purchase_COUNT INT,
				 Allocation_COUNT INT,				
				 STOCK_COUNT INT,
				 Damage_COUNT INT,
				 Branch_Id INT,
				 Branch_Name VARCHAR(250)
				 )
				 
				IF @Branch_ID > 0				
					BEGIN
						 INSERT INTO #ASSET_DETAILS(ASSET_ID,Asset_Name,Purchase_COUNT,Allocation_COUNT,STOCK_COUNT,Damage_COUNT,Branch_Id,Branch_Name)
						 SELECT DISTINCT AD.Asset_ID,Asset_Name,0,0,0,0,ad.Branch_ID,BM.Branch_Name  FROM T0040_Asset_details AD WITH (NOLOCK)
						 inner join T0040_ASSET_MASTER am WITH (NOLOCK) on am.Asset_ID=ad.Asset_ID 
						 left join T0030_BRANCH_MASTER bm WITH (NOLOCK) on ISNULL(AD.Branch_ID,0) >0 AND bm.Branch_ID=ad.Branch_ID 
						 WHERE AD.Cmp_ID=@Cmp_ID and ad.Branch_ID=ISNULL(@Branch_ID,ad.Branch_ID)  
						 AND (Purchase_date BETWEEN @From_Date AND @TO_DATE OR YEAR(Purchase_date) ='1900')
						 GROUP by Asset_Name,AD.Asset_ID,ad.Branch_ID,bm.Branch_Name
						 
						 --SELECT * FROM #ASSET_DETAILS
						 --SELECT COUNT(AD.Asset_ID)Allocation_COUNT,Asset_ID
							--		FROM T0120_Asset_Approval AA INNER JOIN
							--		T0130_Asset_Approval_Det AD ON AA.Asset_Approval_ID=AD.Asset_Approval_ID										
							--		WHERE AA.Cmp_ID=@Cmp_ID and (AA.Branch_ID=ISNULL(@Branch_ID,AA.Branch_ID) 
							--			 OR AA.Transfer_Branch_For_Dept =ISNULL(@Branch_ID,AA.Transfer_Branch_For_Dept)
							--			 OR AA.Transfer_Branch_Id =ISNULL(@Branch_ID,AA.Transfer_Branch_Id))
							--		AND AD.Allocation_Date BETWEEN @From_Date AND @TO_DATE
							--		GROUP by AD.Asset_ID
							
							--SELECT distinct AD2.Asset_ID,ad2.AssetM_ID--,COUNT(ad2.Asset_ID)
							--		FROM T0120_Asset_Approval AA INNER JOIN
							--		T0130_Asset_Approval_Det AD2 ON AA.Asset_Approval_ID=AD2.Asset_Approval_ID INNER JOIN
							--		T0040_Asset_Details AD1 ON AD1.AssetM_ID=AD2.AssetM_ID AND AD1.allocation=1									
							--		WHERE AA.Cmp_ID=@Cmp_ID and ad2.Asset_ID=7									
							--		AND AD2.Allocation_Date BETWEEN @From_Date AND @TO_DATE
									--GROUP by AD2.Asset_ID
						UPDATE AD
							SET Allocation_COUNT = isnull(a1.Allocation_COUNT,0),
							Purchase_COUNT=isnull(a2.Purchase_COUNT,0),
							Damage_COUNT=ISNULL(A3.Damage_COUNT,0),
							STOCK_COUNT=(ISNULL(A2.Purchase_COUNT,0)-(ISNULL(A1.Allocation_COUNT,0)+ISNULL(A3.Damage_COUNT,0)))					
						FROM #ASSET_DETAILS AD 
						INNER JOIN(SELECT COUNT(AssetM_ID)Purchase_COUNT,Asset_ID
									FROM T0040_Asset_Details WITH (NOLOCK)										
									WHERE Cmp_ID=@Cmp_ID AND (Purchase_date BETWEEN @From_Date AND @TO_DATE OR YEAR(Purchase_date) ='1900')  
									and Branch_ID=ISNULL(@Branch_ID,Branch_ID)
									GROUP by Asset_ID)A2 ON AD.ASSET_ID=A2.Asset_ID
						LEFT JOIN(SELECT distinct COUNT(ad2.AssetM_ID)Allocation_COUNT,AD2.Asset_ID
									FROM T0120_Asset_Approval AA WITH (NOLOCK) INNER JOIN
									T0130_Asset_Approval_Det AD2 WITH (NOLOCK) ON AA.Asset_Approval_ID=AD2.Asset_Approval_ID INNER JOIN
									T0040_Asset_Details AD1 WITH (NOLOCK) ON AD1.AssetM_ID=AD2.AssetM_ID AND AD1.allocation=1 and ad1.Branch_ID=ISNULL(@Branch_ID,ad1.Branch_ID)									
									WHERE AA.Cmp_ID=@Cmp_ID 
										--and (AA.Branch_ID=ISNULL(@Branch_ID,AA.Branch_ID) 
										-- OR AA.Transfer_Branch_For_Dept =ISNULL(@Branch_ID,AA.Transfer_Branch_For_Dept)
										-- OR AA.Transfer_Branch_Id =ISNULL(@Branch_ID,AA.Transfer_Branch_Id))
									AND AD2.Allocation_Date BETWEEN @From_Date AND @TO_DATE
									GROUP by AD2.Asset_ID)A1 ON AD.ASSET_ID=A1.Asset_ID				
						LEFT JOIN(SELECT COUNT(AssetM_ID)Damage_COUNT,Asset_ID
									FROM T0040_Asset_details WITH (NOLOCK)
									WHERE  Cmp_ID=@Cmp_ID AND ISNULL(Asset_Status,'')='D' AND (Purchase_date BETWEEN @From_Date AND @TO_DATE OR YEAR(Purchase_date) ='1900')
									and Branch_ID=ISNULL(@Branch_ID,Branch_ID) GROUP by Asset_ID)A3 ON AD.ASSET_ID=A3.Asset_ID
						
					END
				ELSE
					BEGIN

						 INSERT INTO #ASSET_DETAILS(ASSET_ID,Asset_Name,Purchase_COUNT,Allocation_COUNT,STOCK_COUNT,Damage_COUNT,Branch_Id,Branch_Name)
						 SELECT DISTINCT AD.Asset_ID,Asset_Name,0,0,0,0,ad.Branch_ID,BM.Branch_Name  FROM T0040_Asset_details AD WITH (NOLOCK)
						 inner join T0040_ASSET_MASTER am WITH (NOLOCK) on am.Asset_ID=ad.Asset_ID 	
						 left join T0030_BRANCH_MASTER bm WITH (NOLOCK) on ISNULL(AD.Branch_ID,0) >0 AND bm.Branch_ID=ad.Branch_ID 						
						 WHERE AD.Cmp_ID=@Cmp_ID  
						 AND (Purchase_date BETWEEN @From_Date AND @TO_DATE OR YEAR(Purchase_date) ='1900')

						 GROUP by Asset_Name,AD.Asset_ID,ad.Branch_ID,bm.Branch_Name

						UPDATE AD
							SET Allocation_COUNT = isnull(a1.Allocation_COUNT,0),
							Purchase_COUNT=isnull(a2.Purchase_COUNT,0),
							Damage_COUNT=ISNULL(A3.Damage_COUNT,0),
							STOCK_COUNT=(ISNULL(A2.Purchase_COUNT,0)-(ISNULL(A1.Allocation_COUNT,0)+ISNULL(A3.Damage_COUNT,0)))					
						FROM #ASSET_DETAILS AD 
						INNER JOIN(SELECT COUNT(AssetM_ID)Purchase_COUNT,Asset_ID
									FROM T0040_Asset_Details WITH (NOLOCK)										
									WHERE Cmp_ID=@Cmp_ID AND (Purchase_date BETWEEN @From_Date AND @TO_DATE OR YEAR(Purchase_date) ='1900')  									
									GROUP by Asset_ID)A2 ON AD.ASSET_ID=A2.Asset_ID
						LEFT JOIN(SELECT COUNT(Asset_ID)Allocation_COUNT,Asset_ID
									FROM T0040_Asset_Details WITH (NOLOCK)										
									WHERE Cmp_ID=@Cmp_ID AND allocation=1 AND Purchase_date BETWEEN @From_Date AND @TO_DATE 									
									GROUP by Asset_ID)A1 ON AD.ASSET_ID=A1.Asset_ID				
						LEFT JOIN(SELECT COUNT(AssetM_ID)Damage_COUNT,Asset_ID
									FROM T0040_Asset_details WITH (NOLOCK)
									WHERE  Cmp_ID=@Cmp_ID AND ISNULL(Asset_Status,'')='D' AND (Purchase_date BETWEEN @From_Date AND @TO_DATE OR YEAR(Purchase_date) ='1900')
									GROUP by Asset_ID)A3 ON AD.ASSET_ID=A3.Asset_ID
					END
				--select * from #ASSET_DETAILS
				--SELECT @Return=COUNT(AssetM_ID),AD.Asset_ID FROM T0120_Asset_Approval AA
				--INNER JOIN T0130_Asset_Approval_Det AD ON AA.Asset_Approval_ID=AD.Asset_Approval_ID AND AA.Application_Type=1
				--WHERE AA.Cmp_ID=149 --AND AD.Allocation_Date BETWEEN @From_Date AND @TO_DATE
				--GROUP by Asset_ID
				
				--SELECT @Damage=COUNT(AssetM_ID),Asset_Name FROM V0040_Asset_details 
				--WHERE Cmp_ID=149 AND Asset_Status='Broken/Damage' --AND Purchase_date BETWEEN @From_Date AND @TO_DATE
				--GROUP by Asset_Name
					
				--SELECT @Purchase,@Allocation,@Return,@Damage
				--select * from #ASSET_DETAILS
				--if @Branch_ID > 0					
				--	SELECT AD.*,co.Cmp_Name,co.Cmp_Address,co.cmp_logo,AD.Branch_Id,AD.Branch_Name AS Branch_Name,@FROM_DATE as FROM_DATE,@TO_DATE AS TO_DATE
				--	FROM #ASSET_DETAILS AD
				--	inner join T0010_COMPANY_MASTER co on co.Cmp_Id=@CMP_ID
				--	where ISNULL(AD.Branch_Id,0) >0 and Branch_ID=@Branch_ID and AD.ASSET_ID=ISNULL(@Asset_ID,AD.ASSET_ID)
				--ELSE
				--ronakb
					SELECT DISTINCT AD.*,co.Cmp_Name,co.Cmp_Address,bm.Branch_Name AS Branch_Name,SB.SubBranch_Name,em.subBranch_ID,
					VS.Vertical_Name,em.Vertical_ID,em.SubVertical_ID,SV.SubVertical_Name,Dm.Dept_Name,Dgm.Desig_Name,Etm.Type_Name,
					Gm.Grd_Name,
					@FROM_DATE as FROM_DATE,@TO_DATE AS TO_DATE
					FROM #ASSET_DETAILS AD
					inner join T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=@CMP_ID
					inner join T0120_Asset_Approval AA WITH (NOLOCK) on AA.Asset_Approval_ID=AD.Asset_ID		--ronakb		
				    inner join T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID=AA.Emp_ID
				    inner join T0040_ASSET_MASTER am WITH (NOLOCK) on am.Asset_ID=ad.Asset_ID
					LEFT OUTER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = EM.Grd_ID   
                    LEFT OUTER JOIN  dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON ETM.Type_ID = EM.Type_ID   
                    LEFT OUTER JOIN  dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON DGM.Desig_Id = EM.Desig_Id   
                    LEFT OUTER JOIN  dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id = EM.Dept_Id   
					LEFT outer JOIN T0050_SubBranch SB WITH (NOLOCK)ON SB.SubBranch_ID=EM.subBranch_ID
					LEFT outer JOIN T0040_Vertical_Segment VS WITH (NOLOCK)ON VS.Vertical_ID=EM.Vertical_ID 
					LEFT outer JOIN T0050_SubVertical SV WITH (NOLOCK)ON SV.SubVertical_ID=EM.SubVertical_ID 
					 left join T0030_BRANCH_MASTER bm WITH (NOLOCK) on ISNULL(AD.Branch_ID,0) >0 AND bm.Branch_ID=ad.Branch_ID 
					where AD.ASSET_ID=ISNULL(@Asset_ID,AD.ASSET_ID)
					
				
			END
	



