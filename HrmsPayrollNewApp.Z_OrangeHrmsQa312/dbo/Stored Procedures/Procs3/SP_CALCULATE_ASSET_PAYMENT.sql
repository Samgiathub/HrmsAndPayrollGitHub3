

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_ASSET_PAYMENT]
	@CMP_ID			NUMERIC ,
	@EMP_ID			NUMERIC ,
	@FOR_DATE		DATETIME ,
	@SALARY_TRAN_ID	NUMERIC 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 declare @Asset_Approval_ID as numeric(18,0)
	 declare @Asset_Tran_ID as numeric(18,0)
	 declare @AssetM_ID as numeric(18,0)
	 declare @Issue_Amount as numeric(18,2)
	 declare @Asset_Closing as numeric(18,2)
	 declare @Asset_Closing1 as numeric(18,2)
	 declare @Installment_Amount as numeric(18,2)
	 declare @Asset_Installment as numeric(18,2)
	 declare @TotASSET_Closing as numeric(18,2)
	 declare @Deduction_Type as varchar(20)
	 declare @Installment_Date as datetime
BEGIN
	
		DECLARE ASSET_INSTALLMENT CURSOR FOR
						select APD.AssetM_ID,APD.Issue_Amount,AP.Asset_Approval_ID,APD.Installment_Amount,APD.Deduction_Type,apd.Installment_Date from T0120_Asset_Approval AP WITH (NOLOCK)
						inner join T0130_Asset_Approval_Det APD WITH (NOLOCK) on ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.cmp_id=apd.cmp_id
						--inner join t0140_asset_transaction AT on ap.emp_id=AT.emp_id and APD.Asset_Approval_ID=AT.Asset_Approval_ID
						where AP.Emp_ID=@Emp_ID and AP.Cmp_ID=@cmp_id 
		OPEN ASSET_INSTALLMENT
							fetch next from ASSET_INSTALLMENT into @AssetM_ID,@Issue_Amount,@Asset_Approval_ID,@Installment_Amount,@Deduction_Type,@Installment_Date
								while @@fetch_status = 0
									Begin
										if @Deduction_Type = 'Quaterly' Or @Deduction_Type = 'Half Yearly' or @Deduction_Type = 'Yearly'
											begin
												Declare @Is_Deduct varchar(max)
												set @Is_Deduct = DBO.F_GET_LOAN_DED_M(@Installment_Date,@Installment_Date,@Deduction_Type)
												print @Is_Deduct
											
												if charindex(cast(DateName(m,@FOR_DATE) as varchar(3)),@Is_Deduct) <> 0
													Begin
													
														SELECT @Asset_Closing = ISNULL(SUM(Asset_Closing),0) from dbo.t0140_Asset_transaction  AT WITH (NOLOCK) INNER JOIN       
														(SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_Asset_transaction  WITH (NOLOCK) WHERE  CMP_ID = @CMP_ID      
														AND FOR_DATE <= @FOR_DATE and AssetM_Id = @AssetM_Id and Emp_Id=@Emp_Id
														GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = AT.AssetM_ID      
														AND QRY.FOR_DATE = AT.FOR_DATE       
														AND QRY.EMP_ID = AT.EMP_ID and AT.Emp_ID=@Emp_ID and AT.assetM_Id=@AssetM_ID and AT.ASSET_CLOSING > 0
													
														set @Asset_Closing1=0
												
														IF @Installment_Amount > @Asset_Closing 
															BEGIN
																set @Installment_Amount=@Asset_Closing
															END
														
														set @Asset_Closing1=@Asset_Closing-@Installment_Amount
													
														 if @Issue_Amount >0 and @Asset_Closing > 0 
															begin
																if not exists(select 1 from T0140_ASSET_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_ID and AssetM_ID=@AssetM_ID and FOR_DATE=@FOR_DATE and Asset_Approval_ID=@Asset_Approval_ID)
																	begin
																			select @Asset_Tran_ID = isnull(max(Asset_Tran_ID),0) + 1  from T0140_Asset_Transaction WITH (NOLOCK)
																			insert into T0140_Asset_Transaction(Asset_Tran_ID,Asset_Approval_ID,Cmp_ID,Emp_Id,AssetM_ID,Asset_Opening,Issue_Amount,Receive_Amount,Asset_Closing,For_Date,sal_tran_id)
																			values(@Asset_Tran_ID,@Asset_Approval_ID,@Cmp_ID,@Emp_ID,@AssetM_ID,@Asset_Closing,@Issue_Amount,@Installment_Amount,@Asset_Closing1,@FOR_DATE,@SALARY_TRAN_ID)
																	end
																else
																	begin
																		update T0140_Asset_Transaction
																		set Receive_Amount=@Installment_Amount,
																		Asset_closing=@Asset_Closing1,
																		sal_tran_id=@SALARY_TRAN_ID
																		where cmp_id=@cmp_id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_ID=@AssetM_ID and FOR_DATE=@FOR_DATE 
																	end
															end
													end
											end
										else if @Deduction_Type ='Monthly'
											begin
												SELECT @Asset_Closing = ISNULL(SUM(Asset_Closing),0) from dbo.t0140_Asset_transaction   AT WITH (NOLOCK) INNER JOIN       
												(SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_Asset_transaction  WITH (NOLOCK) WHERE  CMP_ID = @CMP_ID      
												AND FOR_DATE <= @FOR_DATE and AssetM_Id = @AssetM_Id and Emp_Id=@Emp_Id
												GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = AT.AssetM_ID      
												AND QRY.FOR_DATE = AT.FOR_DATE       
												AND QRY.EMP_ID = AT.EMP_ID and AT.Emp_ID=@Emp_ID and AT.assetM_Id=@AssetM_ID and AT.ASSET_CLOSING > 0
													
												set @Asset_Closing1=0
										
												IF @Installment_Amount > @Asset_Closing 
													BEGIN
														set @Installment_Amount=@Asset_Closing
													END
												
												set @Asset_Closing1=@Asset_Closing-@Installment_Amount
											
												 if @Issue_Amount >0 and @Asset_Closing > 0 
													begin
														if not exists(select 1 from T0140_ASSET_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_ID and AssetM_ID=@AssetM_ID and FOR_DATE=@FOR_DATE and Asset_Approval_ID=@Asset_Approval_ID)
															begin
																	select @Asset_Tran_ID = isnull(max(Asset_Tran_ID),0) + 1  from T0140_Asset_Transaction WITH (NOLOCK)
																	insert into T0140_Asset_Transaction(Asset_Tran_ID,Asset_Approval_ID,Cmp_ID,Emp_Id,AssetM_ID,Asset_Opening,Issue_Amount,Receive_Amount,Asset_Closing,For_Date,sal_tran_id)
																	values(@Asset_Tran_ID,@Asset_Approval_ID,@Cmp_ID,@Emp_ID,@AssetM_ID,@Asset_Closing,@Issue_Amount,@Installment_Amount,@Asset_Closing1,@FOR_DATE,@SALARY_TRAN_ID)
															end
														else
															begin
																update T0140_Asset_Transaction
																set Receive_Amount=@Installment_Amount,
																Asset_closing=@Asset_Closing1,
																sal_tran_id=@SALARY_TRAN_ID
																where cmp_id=@cmp_id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_ID=@AssetM_ID and FOR_DATE=@FOR_DATE 
															end
													end
										end
									
							fetch next from ASSET_INSTALLMENT into @AssetM_ID,@Issue_Amount,@Asset_Approval_ID,@Installment_Amount,@Deduction_Type,@Installment_Date
									End
					close ASSET_INSTALLMENT	
					deallocate ASSET_INSTALLMENT
					
		
end

