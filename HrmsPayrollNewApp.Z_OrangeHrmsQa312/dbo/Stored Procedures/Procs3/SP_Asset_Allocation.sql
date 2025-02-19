
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Asset_Allocation]
	 @Cmp_ID	 numeric
	,@emp_id   numeric
	,@Type numeric
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
	declare @Asset_ID as numeric(18,0)
	declare @Emp_Full_Name as varchar(250)
	declare @Pending_amount as numeric(18,2)
	declare @Transfer_emp_id as numeric(18,0)
	declare @Return_Asset_Approval_Id numeric(18,0)
	declare @Asset_Description VARCHAR(MAX)
	
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
	 Transfer_Emp_Id numeric(18,0),
	 Asset_Description  VARCHAR(MAX)
	)
		 
	DECLARE ASSET_DETAILS CURSOR FOR
				select apd.Asset_Approval_ID,apd.application_type,apd.assetm_id,ap.Transfer_Emp_Id from T0130_Asset_Approval_Det apd WITH (NOLOCK)
				inner join T0120_Asset_Approval ap WITH (NOLOCK) on apd.Asset_Approval_ID=ap.Asset_Approval_ID and apd.cmp_id=ap.cmp_id
				where ap.cmp_id=@cmp_id 
				and (isnull(ap.emp_id,0) > 0 or isnull(ap.Transfer_emp_id,0) > 0 )
				 and (ap.emp_id=@emp_id or ap.Transfer_emp_id =@emp_id)
				OPEN ASSET_DETAILS
							fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@Transfer_Emp_Id
								while @@fetch_status = 0
									Begin
										if @application_type=1 --fill asset while return
											begin
												SELECT DISTINCT 
													 @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
												     @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
												     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
												     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,
												     @Invoice_amount=dbo.T0040_Asset_Details.Invoice_amount,@Issue_Amount=dbo.T0130_Asset_Approval_Det.Issue_Amount,@AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,
												     @Return_Asset_Approval_Id=Return_Asset_Approval_Id,@Asset_Description=dbo.T0040_Asset_Details.Description
												FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																		  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID left JOIN
																		  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
																		  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																		  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																		  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID 																		 
												WHERE     isnull(Return_asset_approval_id, 0) > 0 and   isnull(Return_Date, '') <> '1900-01-01 00:00:00.000'   and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID
												and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID 
												--and T0120_Asset_Approval.emp_id=@emp_id
																																			   
												   if exists(select * from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3)
													begin
														select @Transfer_Emp_Id=Transfer_Emp_Id from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=3
													
														if isnull(@Transfer_Emp_Id,0)>0 
															begin
																update #ASSET_EMP 
																set Return_Date=@Return_Date
																where Transfer_Emp_Id=@Transfer_Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
															end
													  end
													else
														begin
															select @Emp_Id=Emp_Id from T0120_Asset_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Return_Asset_Approval_Id and application_type=0
															
															set @Pending_amount=0
												
															SELECT  @Pending_amount=ISNULL(ASSET_Closing,0) from dbo.t0140_asset_transaction  LT WITH (NOLOCK) INNER JOIN       
															  (SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_asset_transaction WITH (NOLOCK) 
															   WHERE EMP_iD = @emp_id AND CMP_ID = @Cmp_ID and AssetM_ID=@AssetM_ID AND FOR_DATE <= getdate()      
															   GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = LT.AssetM_ID      
															   AND QRY.FOR_DATE = LT.FOR_DATE       
															   AND QRY.EMP_ID = LT.EMP_ID
												   
															if isnull(@Emp_Id,0)>0 
																begin
																	update #ASSET_EMP 
																	set Return_Date=@Return_Date,Pending_amount=@Pending_amount
																	where Emp_Id=@Emp_Id and AssetM_ID=@AssetM_ID and Asset_Approval_Id=@Return_Asset_Approval_Id
																end
														end
														--update #ASSET_EMP 
														--set Return_Date=@Return_Date,Pending_amount=@Pending_amount
														--where emp_id=@emp_id and AssetM_ID=@AssetM_ID
												
											end
									else if @application_type=3 --fill asset while Transfer
											begin
												SELECT DISTINCT 
													 @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
												     @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
												     @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
												     @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,
												     @Invoice_amount=dbo.T0040_Asset_Details.Invoice_amount,@Issue_Amount=dbo.T0130_Asset_Approval_Det.Issue_Amount,@AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,
												     @Asset_Description=dbo.T0040_Asset_Details.Description
												FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																		  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
																		  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
																		  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																		  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																		  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																		  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Transfer_Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID 																		 
												WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID 
												and T0130_Asset_Approval_Det.application_type=@application_type and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID 
												--and T0120_Asset_Approval.Transfer_Emp_ID=@Transfer_emp_id
																								
												INSERT INTO #ASSET_EMP(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,Issue_Amount,Invoice_amount,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Pending_amount,Transfer_emp_id,Asset_Description)
												VALUES(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@emp_id,@Issue_Amount,@Invoice_amount,@AssetM_Id,@Asset_Id,@Brand_Id,@Asset_Approval_ID,@Pending_amount,@Transfer_emp_id,@Asset_Description)
													
											end
										else if @application_type=0
											begin
													SELECT DISTINCT 
														 @Asset_Name=dbo.T0040_ASSET_MASTER.Asset_Name,@BRAND_Name=dbo.T0040_BRAND_MASTER.BRAND_Name,@Asset_Code= dbo.T0040_Asset_Details.Asset_Code,@SerialNo=dbo.T0040_Asset_Details.SerialNo, 
														 @Allocation_Date=CONVERT(varchar(11),dbo.T0130_Asset_Approval_Det.Allocation_Date,103),@Type_of_Asset=dbo.T0040_Asset_Details.Type_of_Asset, 
														 @Model= dbo.T0040_Asset_Details.Model,@Return_Date= CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103),@Asset_Id=T0040_ASSET_MASTER.Asset_Id,
														 @Brand_Id=T0130_Asset_Approval_Det.Brand_Id,
														 @Invoice_amount=dbo.T0040_Asset_Details.Invoice_amount,@Issue_Amount=dbo.T0130_Asset_Approval_Det.Issue_Amount,@AssetM_Id=T0130_Asset_Approval_Det.AssetM_Id,
														 @Asset_Description=dbo.T0040_Asset_Details.Description
													FROM dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
																			  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
																			  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
																			  dbo.T0040_Asset_Details WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
																			  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
																			  dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
																			  dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID 																		 
													WHERE    Return_asset_approval_id is null  and T0130_Asset_Approval_Det.Asset_Approval_ID=@Asset_Approval_ID 
													 and T0130_Asset_Approval_Det.AssetM_ID=@AssetM_ID 
													--and T0120_Asset_Approval.emp_id=@emp_id  
													--and isnull(@Transfer_emp_id,0)=0
												--	and T0120_Asset_Approval.Emp_ID not in(select emp_id from T0120_Asset_Approval where emp_id=@emp_id and application_type=3)
											
													set @Pending_amount=0
											
													 SELECT  @Pending_amount=ISNULL(ASSET_Closing,0) from dbo.t0140_asset_transaction  LT WITH (NOLOCK) INNER JOIN       
													  (SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_asset_transaction WITH (NOLOCK)  
													   WHERE EMP_iD = @emp_id AND CMP_ID = @Cmp_ID AND FOR_DATE <= getdate() and AssetM_ID=@AssetM_ID 
													   GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = LT.AssetM_ID      
													   AND QRY.FOR_DATE = LT.FOR_DATE       
													   AND QRY.EMP_ID = LT.EMP_ID
													   
																									
													INSERT INTO #ASSET_EMP(Asset_Name,BRAND_Name,Asset_Code,Serial_No,Allocation_Date,Type_of_Asset,Model,Return_Date,Emp_id,Issue_Amount,Invoice_amount,AssetM_Id,Asset_Id,Brand_Id,Asset_Approval_ID,Pending_amount,Transfer_emp_id,Asset_Description)
													VALUES(@Asset_Name,@BRAND_Name,@Asset_Code,@SerialNo,@Allocation_Date,@Type_of_Asset,@Model,'',@Emp_id,@Issue_Amount,@Invoice_amount,@AssetM_Id,@Asset_Id,@Brand_Id,@Asset_Approval_ID,@Pending_amount,@Transfer_emp_id,@Asset_Description)
												end
																	
							
							fetch next from ASSET_DETAILS into @Asset_Approval_ID,@application_type,@AssetM_ID,@Transfer_Emp_Id
									End
					close ASSET_DETAILS	
					deallocate ASSET_DETAILS
					--select * from #ASSET_EMP
					if @Type=0 --to fill only allocated asset for F&F form
						begin		
							select * from #ASSET_EMP where emp_id=@emp_id and isnull(Transfer_Emp_Id,0)=0 and Return_date='' 
							union
							select * from #ASSET_EMP where Transfer_emp_id=@emp_id and Return_date=''     
							--and Pending_amount > 0       
						end
					else
						begin	
							 select v1.* into #tmpasset from
							(select * from #ASSET_EMP where emp_id=@emp_id and isnull(Transfer_Emp_Id,0)=0 
							union
							select * from #ASSET_EMP where Transfer_emp_id=@emp_id)v1  
							
							select * from #tmpasset ta  
							inner join (select max(Allocation_Date)Allocation_Date,AssetM_Id from #ASSET_EMP GROUP by AssetM_Id)asm 
							on asm.AssetM_Id=ta.AssetM_Id and asm.Allocation_Date=ta.Allocation_Date      
						end 
Return




