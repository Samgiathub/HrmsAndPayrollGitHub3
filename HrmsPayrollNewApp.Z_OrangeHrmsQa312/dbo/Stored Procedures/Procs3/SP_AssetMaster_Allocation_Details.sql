CREATE PROCEDURE [dbo].[SP_AssetMaster_Allocation_Details]
	 @Cmp_ID	 numeric,
	 @Asset_ID numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Asset_Approval_ID as numeric(18,0)
	declare @application_type as numeric(18,0)
	declare @AssetM_ID as numeric(18,0)
	declare @Asset_Name as varchar(250)
	declare @BRAND_Name as varchar(250)
	declare @Asset_Code as varchar(250)
	declare @SerialNo as varchar(250)
	declare @Allocation_Date as  varchar(250)
	declare @Vendor as varchar(250)
	declare @Type_of_Asset as varchar(250)
	declare @Model as varchar(250)
	declare @Return_Date  as  varchar(250)
	declare @Alpha_Emp_Code as varchar(250)
	declare @Brand_Id as numeric(18,0) 
	declare @Issue_Amount as numeric(18,2)
	declare @Invoice_amount as numeric(18,2)
	declare @Asset_Status as varchar(250)
	declare @Emp_Full_Name as varchar(250)
	declare @Pending_amount as numeric(18,2)
	declare @emp_id as numeric(18,2)
	declare @Branch_Name varchar(250)
	declare @Dept_Name varchar(250)
	declare @Transfer_Emp_Id numeric(18,0)
	declare @Branch_Id numeric(18,0)
	declare @Transfer_Branch_Id numeric(18,0)
	declare @Dept_Id numeric(18,0)
	declare @Transfer_Dept_Id numeric(18,0)
	declare @Return_Asset_Approval_Id numeric(18,0)
	declare @Emp_Branch varchar(250)
	declare @Emp_Dept varchar(250)

	CREATE table #ASSET_EMP
	(
	 Asset_Name  varchar(250),
	 BRAND_Name  varchar(250),
	 Asset_Code  varchar(250),
	 Serial_No  varchar(250),
	 Allocation_Date  varchar(250),
	 Return_Date  varchar(250),
	 Type_of_Asset  varchar(250),
	 Model  varchar(250),
	 AssetM_Id numeric(18,0) ,
	 Asset_Id numeric(18,0) ,
	 Brand_Id numeric(18,0) ,
	 Asset_Approval_ID numeric(18,0) ,
	 Emp_Id  numeric(18,0) ,
	 Issue_Amount  numeric(18,2),
	 Invoice_amount  numeric(18,2),
	 Pending_amount  numeric(18,2),
	 Alpha_Emp_Code varchar(250),
	 Emp_Full_Name varchar(250),
	 Branch_Name  varchar(250),
	 Asset_Status  varchar(25),
	 Dept_Name varchar(250),
	 Application_Type numeric(18,0),
	 Transfer_Emp_Id numeric(18,0),
	 Branch_Id numeric(18,0),
	 Transfer_Branch_Id numeric(18,0),
	 Dept_Id numeric(18,0),
	 Transfer_Dept_Id numeric(18,0),
	 Return_Asset_Appr_ID numeric(18,0),
	 Emp_Branch varchar(250),
	 Emp_Dept varchar(250)
	)
	
	 
	DECLARE ASSET_DETAILS CURSOR FOR
				select apd.Asset_Approval_ID,apd.application_type,apd.assetm_id,ap.emp_id,ap.Transfer_Emp_Id,ap.Branch_Id,ap.Transfer_Branch_Id,ap.Dept_Id,ap.Transfer_Dept_Id				
				from T0130_Asset_Approval_Det apd WITH (NOLOCK)
				inner join T0120_Asset_Approval ap WITH (NOLOCK) on apd.Asset_Approval_ID=ap.Asset_Approval_ID and apd.cmp_id=ap.cmp_id
				where ap.cmp_id=@cmp_id  and apd.Asset_ID=@Asset_ID and apd.Approval_status='A'
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
												     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Emp_Full_Name,
												     @Invoice_amount=dbo.T0040_Asset_Details.Invoice_amount,@Issue_Amount=dbo.T0130_Asset_Approval_Det.Issue_Amount,@AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Branch_Name=B.Branch_Name,
												     @Dept_Name=D.dept_name,@Return_Asset_Approval_Id=Return_Asset_Approval_Id,
												     @Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END													
												FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																		  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
																		  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
																		  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																		  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																		  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID																	 
												WHERE     isnull(Return_asset_approval_id, 0) > 0 and   isnull(Return_Date, '') <> '1900-01-01 00:00:00.000'   and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID 
												and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID and T0130_Asset_Approval_Det.Approval_status='A'
																								   
											if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3)
												begin
													select @Transfer_Branch_Id=Transfer_Branch_Id,@Transfer_Emp_Id=Transfer_Emp_Id,@Transfer_Dept_Id=Transfer_Dept_Id from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3
													
													if isnull(@Transfer_Emp_Id,0)>0 
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date,Return_Asset_Appr_ID=@Asset_Approval_ID
															where Transfer_Emp_Id=@Transfer_Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
													
													 if isnull(@Transfer_Branch_Id,0) >0 
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date,Return_Asset_Appr_ID=@Asset_Approval_ID
															where Transfer_Branch_Id=@Transfer_Branch_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
													 if isnull(@Transfer_Dept_Id,0) >0  
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date,Return_Asset_Appr_ID=@Asset_Approval_ID
															where Transfer_Dept_Id=@Transfer_Dept_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
												end
											else
												begin
													select @Branch_Id=Branch_Id,@Emp_Id=Emp_Id,@Dept_Id=Dept_Id from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=0
													
													if isnull(@Emp_Id,0)>0 
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date,Return_Asset_Appr_ID=@Asset_Approval_ID
															where Emp_Id=@Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
													
													 if isnull(@Branch_Id,0) >0 
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date,Return_Asset_Appr_ID=@Asset_Approval_ID
															where Branch_Id=@Branch_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
														end
													 if isnull(@Dept_Id,0) >0  
														begin
															update #ASSET_EMP 
															set Return_Date=@Return_Date,Return_Asset_Appr_ID=@Asset_Approval_ID
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
												     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Emp_Full_Name,
												     @Invoice_amount=dbo.T0040_Asset_Details.Invoice_amount,@Issue_Amount=dbo.T0130_Asset_Approval_Det.Issue_Amount,
												     @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name= E.Emp_Full_Name,@Branch_Name=B.Branch_Name,
												     @Dept_Name=D.dept_name +'-' + BDM.BRANCH_NAME ,@Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,
													 @Emp_Branch=bm.Branch_Name,@Emp_Dept=dm.Dept_Name
											FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																		  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
																		  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
																		  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																		  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																		  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS BDM WITH (NOLOCK) ON dbo.T0120_Asset_Approval.BRANCH_FOR_DEPT = BDM.Branch_ID LEFT OUTER JOIN
																		  DBO.T0095_INCREMENT IC WITH (NOLOCK) ON IC.INCREMENT_ID=E.INCREMENT_ID and IC.EMP_ID=E.EMP_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID  LEFT OUTER JOIN
																		  dbo.t0040_department_master AS DM WITH (NOLOCK) ON IC.Dept_ID = DM.Dept_ID 																		 
												WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID
												and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID and T0130_Asset_Approval_Det.Approval_status='A'
											
												INSERT INTO #ASSET_EMP(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,Issue_Amount,Invoice_amount,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Pending_amount,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Asset_Status,Dept_Name,application_type,Transfer_Emp_Id,Branch_Id,Transfer_Branch_Id,Dept_Id,Transfer_Dept_Id,Emp_Branch,Emp_Dept)
										    	VALUES(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@Issue_Amount,@Invoice_amount,@AssetM_Id,@Asset_Id,@Brand_Id,@Asset_Approval_ID,@Pending_amount,@Alpha_Emp_Code,@Emp_Full_Name,@Branch_Name,@Asset_Status,@Dept_Name,@application_type,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id,@Emp_Branch,@Emp_Dept)
											
											end
										else
											begin
												SELECT DISTINCT 
													 @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
												     @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
												     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
												     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name=E.Emp_Full_Name,
												     @Invoice_amount=dbo.T0040_Asset_Details.Invoice_amount,@Issue_Amount=dbo.T0130_Asset_Approval_Det.Issue_Amount,
												     @AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,@Alpha_Emp_Code=E.Alpha_Emp_Code,@Emp_Full_Name= E.Emp_Full_Name,@Branch_Name=B.Branch_Name,
												      @Dept_Name=D.dept_name +'-' + BDM.BRANCH_NAME,
   												     @Asset_Status=CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' ELSE 'Working' END,
													 @Emp_Branch=bm.Branch_Name,@Emp_Dept=dm.Dept_Name
											FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																		  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
																		  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
																		  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																		  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																		  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
																		  dbo.t0040_department_master AS D WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Dept_ID = D.Dept_ID AND D.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID	LEFT OUTER JOIN																	 
																		  dbo.T0030_BRANCH_MASTER AS BDM WITH (NOLOCK) ON dbo.T0120_Asset_Approval.BRANCH_FOR_DEPT = BDM.Branch_ID LEFT OUTER JOIN
																		 dbo.T0095_INCREMENT IC WITH (NOLOCK) ON IC.INCREMENT_ID=E.INCREMENT_ID and IC.EMP_ID=E.EMP_ID LEFT OUTER JOIN
																		  dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON IC.Branch_ID = BM.Branch_ID  LEFT OUTER JOIN
																		  dbo.t0040_department_master AS DM WITH (NOLOCK) ON IC.Dept_ID = DM.Dept_ID 					
												WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID 
												and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID and T0130_Asset_Approval_Det.Approval_status='A'
												--and T0120_Asset_Approval.emp_id=@emp_id 
										
												 --SELECT  @Pending_amount=ISNULL(ASSET_Closing,0) from dbo.t0140_asset_transaction  LT INNER JOIN       
												 -- (SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_asset_transaction  
												 --  WHERE EMP_iD = @emp_id AND CMP_ID = @Cmp_ID AND FOR_DATE <= getdate() and AssetM_ID=@AssetM_ID 
												 --  GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = LT.AssetM_ID      
												 --  AND QRY.FOR_DATE = LT.FOR_DATE       
												 --  AND QRY.EMP_ID = LT.EMP_ID
												
	
												INSERT INTO #ASSET_EMP(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,Issue_Amount,Invoice_amount,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Pending_amount,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Asset_Status,Dept_Name,application_type,Transfer_Emp_Id,Branch_Id,Transfer_Branch_Id,Dept_Id,Transfer_Dept_Id,Emp_Branch,Emp_Dept)
												VALUES(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@Issue_Amount,@Invoice_amount,@AssetM_Id,@Asset_Id,@Brand_Id,@Asset_Approval_ID,@Pending_amount,@Alpha_Emp_Code,@Emp_Full_Name,@Branch_Name,@Asset_Status,@Dept_Name,@application_type,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id,@Emp_Branch,@Emp_Dept)
								--select * from #ASSET_EMP			
											end										
							
							fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@emp_id,@Transfer_Emp_Id,@Branch_Id,@Transfer_Branch_Id,@Dept_Id,@Transfer_Dept_Id
															End
					close ASSET_DETAILS	
					deallocate ASSET_DETAILS
	select * from #ASSET_EMP					
Return




