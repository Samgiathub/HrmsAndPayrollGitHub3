


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0220_PF_CHALLAN]
		 @Pf_Challan_ID						numeric(18, 0) output
		--,@Branch_ID							numeric(18, 0)
		,@Branch_ID							varchar(Max) --  Ankit 20082015
		,@Cmp_ID							numeric(18, 0)
		,@Bank_ID							numeric(18, 0)
		,@Month								numeric(18, 0)
		,@Year								numeric(18, 0)
		,@Payment_Date						datetime
		,@E_Code							varchar(20)
		,@Acc_Gr_No							varchar(5)
		,@Payment_Mode						varchar(20)
		,@Cheque_No							varchar(10)
		,@Total_SubScriber					numeric(18, 0)
		,@Total_Wages_Due					numeric(18, 0)
		,@Total_Challan_Amount				numeric(18, 0)
		,@tran_type							char
		,@Total_Family_Pension_Subscriber	numeric(18, 0)=0
		,@Total_Family_Pension_Wages_Amount	numeric(18, 0)=0
		,@Total_EDLI_Subscriber				numeric(18, 0)=0
		,@Total_EDLI_Wages_Amount			numeric(18, 0)=0
		,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 19102013
		,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 19102013
		
AS	

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

										-- Added for audit trail By Ali 19102013 -- Start
											Declare @OldValue as varchar(max)
											Declare @Old_Branch_ID as numeric(18, 0)
											Declare @Old_Branch_Name as varchar(150)
											Declare @New_Branch_Name as varchar(150)
											Declare @Old_Bank_ID as numeric(18, 0)
											Declare @Old_Bank_Name as varchar(150)
											Declare @New_Bank_Name as varchar(150)
											Declare @Old_Month as numeric(18, 0)
											Declare @Old_Year as numeric(18, 0)
											Declare @Old_Payment_Date as datetime
											Declare @Old_E_Code as varchar(20)
											Declare @Old_Acc_Gr_No as varchar(5)
											Declare @Old_Payment_Mode as varchar(20)
											Declare @Old_Cheque_No as varchar(10)
											Declare @Old_Total_SubScriber as numeric(18, 0)
											Declare @Old_Total_Wages_Due as numeric(18, 0)
											Declare @Old_Total_Challan_Amount as numeric(18, 0)		
											Declare @Old_Total_Family_Pension_Subscriber as numeric(18, 0)
											Declare @Old_Total_Family_Pension_Wages_Amount as numeric(18, 0)
											Declare @Old_Total_EDLI_Subscriber as numeric(18, 0)
											Declare @Old_Total_EDLI_Wages_Amount as numeric(18, 0)
											DECLARE @Old_Branch_ID_Multi as varchar(MAX)
											
											Set @OldValue = ''
											Set @Old_Branch_ID = 0
											Set @Old_Branch_Name = ''
											Set @New_Branch_Name = ''
											Set @Old_Bank_ID = 0
											Set @Old_Bank_Name = ''
											Set @New_Bank_Name = ''
											Set @Old_Month = 0
											Set @Old_Year = 0
											Set @Old_Payment_Date = null
											Set @Old_E_Code  = ''
											Set @Old_Acc_Gr_No  = ''
											Set @Old_Payment_Mode = '' 
											Set @Old_Cheque_No = ''
											Set @Old_Total_SubScriber = 0
											Set @Old_Total_Wages_Due = 0
											Set @Old_Total_Challan_Amount = 0
											Set @Old_Total_Family_Pension_Subscriber = 0
											Set @Old_Total_Family_Pension_Wages_Amount = 0
											Set @Old_Total_EDLI_Subscriber = 0
											Set @Old_Total_EDLI_Wages_Amount = 0
											set @Old_Branch_ID_Multi = ''
										-- Added for audit trail By Ali 19102013 -- End
										
	Set NoCount On;
	
	if @Branch_ID = ''--0 
		set	@Branch_ID = NULL
	
	if @tran_type = 'I'
			begin
					--If Exists(select Pf_Challan_ID From dbo.T0220_PF_CHALLAN Where Cmp_ID = @Cmp_ID  and Month = @Month AND Year=@Year and branch_id = @Branch_ID )
					--	begin
					--		set @Pf_Challan_ID = 0
					--		return 
					--end
					
					If Exists(select Pf_Challan_ID From dbo.T0220_PF_CHALLAN WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and Month = @Month AND Year=@Year 
								and Branch_ID IN ( SELECT CAST(data as NUMERIC) as data FROM dbo.Split(@Branch_ID,'#' ) )) 
						begin
							set @Pf_Challan_ID = 0
							return 
					end
					
					select @Pf_Challan_ID = Isnull(max(Pf_Challan_ID),0) + 1 	From dbo.T0220_PF_CHALLAN WITH (NOLOCK)
				
				INSERT INTO dbo.T0220_PF_CHALLAN
				                      (Pf_Challan_ID, Cmp_ID, Branch_ID, Bank_ID, Month, Year, Payment_Date, E_Code, Acc_Gr_No, Payment_Mode, Cheque_No, Total_SubScriber, 
				                      Total_Wages_Due, Total_Challan_Amount, Total_Family_Pension_Subscriber, Total_Family_Pension_Wages_Amount, Total_EDLI_Subscriber, Total_EDLI_Wages_Amount,Branch_ID_Multi)
				VALUES     (@Pf_Challan_ID,@Cmp_ID,NULL,@Bank_ID,@Month,@Year,@Payment_Date,@E_Code,@Acc_Gr_No,@Payment_Mode,@Cheque_No,@Total_SubScriber,@Total_Wages_Due,@Total_Challan_Amount
							,@Total_Family_Pension_Subscriber, @Total_Family_Pension_Wages_Amount, @Total_EDLI_Subscriber, @Total_EDLI_Wages_Amount,@Branch_Id)	
							
										-- Added for audit trail By Ali 19102013 -- Start
											--Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID)
											Select @Old_Branch_Name = COALESCE(@Old_Branch_Name + ',', '') +  (convert(nvarchar,Branch_Name)) from T0030_BRANCH_MASTER WITH (NOLOCK)
																			where Cmp_ID = @Cmp_ID and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@branch_Id,ISNULL(Branch_ID,0)),'#') )
											Set @Old_Bank_Name = (Select Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID And Bank_ID = @Bank_ID)
											
											set @OldValue = 'New Value' 
												+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Month,0))
												+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Year,0))
												+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')
												+ '#' + 'Establishment Code No : ' + ISNULL(@E_Code,'')
												+ '#' + 'Acc. Group No : ' + ISNULL(@Acc_Gr_No,'')
												+ '#' + 'Name of the Bank : ' + ISNULL(@Old_Bank_Name,'')
												+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Payment_Date,'') as nvarchar(11))
												+ '#' + 'Paid By : ' + ISNULL(@Payment_Mode,'')
												+ '#' + 'Cheque No : ' + ISNULL(@Cheque_No,'')
												+ '#' + 'Total No. Of Subscriber : ' + CONVERT(nvarchar(100),ISNULL(@Total_SubScriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Total_Wages_Due,0))
												+ '#' + 'Total No. Of Subscriber(F.P.) : ' + CONVERT(nvarchar(100),ISNULL(@Total_Family_Pension_Subscriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Total_Family_Pension_Wages_Amount,0))
												+ '#' + 'Total No. Of Subscriber (EDIL) 	 : ' + CONVERT(nvarchar(100),ISNULL(@Total_EDLI_Subscriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Total_EDLI_Wages_Amount,0))
												+ '#' + 'Total Challan Amount : ' + CONVERT(nvarchar(100),ISNULL(@Total_Challan_Amount,0))
																																												
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'PF Challan',@Oldvalue,@Pf_Challan_ID,@User_Id,@IP_Address
										-- Added for audit trail By Ali 19102013 -- End
						
			END
			
	else if @tran_type ='U' 
				begin
										-- Added for audit trail By Ali 19102013 -- Start
										
										print 1
										print 2		
											Select 
											@Old_Branch_ID = branch_id_multi--Branch_ID
											,@Old_Bank_ID = Bank_ID
											,@Old_Month = [Month]
											,@Old_Year = [Year]
											,@Old_E_Code = E_Code
											,@Old_Acc_Gr_No = Acc_Gr_No
											,@Old_Payment_Date = Payment_Date
											,@Old_Payment_Mode = Payment_Mode
											,@Old_Cheque_No = Cheque_No
											,@Old_Total_SubScriber= Total_SubScriber
											,@Old_Total_Wages_Due = Total_Wages_Due
											,@Old_Total_Family_Pension_Subscriber = Total_Family_Pension_Subscriber
											,@Old_Total_Family_Pension_Wages_Amount = Total_Family_Pension_Wages_Amount
											,@Old_Total_EDLI_Subscriber = Total_EDLI_Subscriber
											,@Old_Total_EDLI_Wages_Amount = Total_EDLI_Wages_Amount
											,@Old_Total_Challan_Amount = Total_Challan_Amount				
											FROM dbo.T0220_PF_CHALLAN WITH (NOLOCK)
											where Pf_Challan_ID = @Pf_Challan_ID
																			
											--Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_ID and Branch_ID = @Old_Branch_ID)
											Select @Old_Branch_Name = COALESCE(@Old_Branch_Name + ',', '') +  (convert(nvarchar,Branch_Name)) from T0030_BRANCH_MASTER WITH (NOLOCK)
																			where Cmp_ID = @Cmp_ID and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Old_Branch_ID,ISNULL(Branch_ID,0)),'#') )
											Set @Old_Bank_Name = (Select Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID And Bank_ID = @Old_Bank_ID)
											
											--Set @New_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID)
											Select @New_Branch_Name = COALESCE(@New_Branch_Name + ',', '') +  (convert(nvarchar,Branch_Name)) from T0030_BRANCH_MASTER WITH (NOLOCK)
																			where Cmp_ID = @Cmp_ID and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') )
											Set @New_Bank_Name = (Select Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID And Bank_ID = @Bank_ID)
											
											
											set @OldValue = 'old Value' 
												+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Old_Month,0))
												+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Year,0))
												+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')
												+ '#' + 'Establishment Code No : ' + ISNULL(@Old_E_Code,'')
												+ '#' + 'Acc. Group No : ' + ISNULL(@Old_Acc_Gr_No,'')
												+ '#' + 'Name of the Bank : ' + ISNULL(@Old_Bank_Name,'')
												+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Old_Payment_Date,'') as nvarchar(11))
												+ '#' + 'Paid By : ' + ISNULL(@Old_Payment_Mode,'')
												+ '#' + 'Cheque No : ' + ISNULL(@Old_Cheque_No,'')
												+ '#' + 'Total No. Of Subscriber : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_SubScriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Wages_Due,0))
												+ '#' + 'Total No. Of Subscriber(F.P.) : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Family_Pension_Subscriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Family_Pension_Wages_Amount,0))
												+ '#' + 'Total No. Of Subscriber (EDIL) 	 : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_EDLI_Subscriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_EDLI_Wages_Amount,0))
												+ '#' + 'Total Challan Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Challan_Amount,0))
												+ '#' +
												+ 'New Value' +
												+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Month,0))
												+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Year,0))
												+ '#' + 'Branch abc : ' + ISNULL(@New_Branch_Name,'')
												+ '#' + 'Establishment Code No : ' + ISNULL(@E_Code,'')
												+ '#' + 'Acc. Group No : ' + ISNULL(@Acc_Gr_No,'')
												+ '#' + 'Name of the Bank : ' + ISNULL(@New_Bank_Name,'')
												+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Payment_Date,'') as nvarchar(11))
												+ '#' + 'Paid By : ' + ISNULL(@Payment_Mode,'')
												+ '#' + 'Cheque No : ' + ISNULL(@Cheque_No,'')
												+ '#' + 'Total No. Of Subscriber : ' + CONVERT(nvarchar(100),ISNULL(@Total_SubScriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Total_Wages_Due,0))
												+ '#' + 'Total No. Of Subscriber(F.P.) : ' + CONVERT(nvarchar(100),ISNULL(@Total_Family_Pension_Subscriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Total_Family_Pension_Wages_Amount,0))
												+ '#' + 'Total No. Of Subscriber (EDIL) 	 : ' + CONVERT(nvarchar(100),ISNULL(@Total_EDLI_Subscriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Total_EDLI_Wages_Amount,0))
												+ '#' + 'Total Challan Amount : ' + CONVERT(nvarchar(100),ISNULL(@Total_Challan_Amount,0))
																
																																										
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'PF Challan',@Oldvalue,@Pf_Challan_ID,@User_Id,@IP_Address
										-- Added for audit trail By Ali 19102013 -- End
									
									
										
						UPDATE    dbo.T0220_PF_CHALLAN
						SET       Bank_ID = @Bank_ID, Payment_Date = @Payment_Date, E_Code = @E_Code, Acc_Gr_No = @Acc_Gr_No, Payment_Mode = @Payment_Mode, 
			                      Cheque_No = @Cheque_No, Total_SubScriber = @Total_SubScriber, Total_Wages_Due = @Total_Wages_Due, 
			                      Total_Challan_Amount = @Total_Challan_Amount, 
			                      Total_Family_Pension_Subscriber =@Total_Family_Pension_Subscriber, Total_Family_Pension_Wages_Amount =@Total_Family_Pension_Wages_Amount , 
			                      Total_EDLI_Subscriber =@Total_EDLI_Subscriber, Total_EDLI_Wages_Amount =@Total_EDLI_Wages_Amount ,Branch_ID_Multi = @Branch_Id
						WHERE     (Pf_Challan_ID = @Pf_Challan_ID) 	
				                      
				                      
				end
	else if @tran_type ='D'
		Begin
				DELETE FROM dbo.T0230_PF_CHALLAN_DETAIL where Pf_Challan_ID = @Pf_Challan_ID 
				
				if not exists(select Pf_Challan_ID  from dbo.T0230_PF_CHALLAN_DETAIL WITH (NOLOCK)  Where Pf_Challan_ID = @Pf_Challan_ID )
				 begin
				 
										-- Added for audit trail By Ali 19102013 -- Start
											Select 
											@Old_Branch_ID = Branch_ID
											,@Old_Bank_ID = Bank_ID
											,@Old_Month = [Month]
											,@Old_Year = [Year]
											,@Old_E_Code = E_Code
											,@Old_Acc_Gr_No = Acc_Gr_No
											,@Old_Payment_Date = Payment_Date
											,@Old_Payment_Mode = Payment_Mode
											,@Old_Cheque_No = Cheque_No
											,@Old_Total_SubScriber= Total_SubScriber
											,@Old_Total_Wages_Due = Total_Wages_Due
											,@Old_Total_Family_Pension_Subscriber = Total_Family_Pension_Subscriber
											,@Old_Total_Family_Pension_Wages_Amount = Total_Family_Pension_Wages_Amount
											,@Old_Total_EDLI_Subscriber = Total_EDLI_Subscriber
											,@Old_Total_EDLI_Wages_Amount = Total_EDLI_Wages_Amount
											,@Old_Total_Challan_Amount = Total_Challan_Amount	
											,@Old_Branch_ID_Multi = Branch_ID_Multi			
											FROM dbo.T0220_PF_CHALLAN WITH (NOLOCK)
											where Pf_Challan_ID = @Pf_Challan_ID
																					
											--Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_ID and Branch_ID = @Old_Branch_ID)
											Select @Old_Branch_Name = COALESCE(@Old_Branch_Name + ',', '') +  (convert(nvarchar,Branch_Name)) from T0030_BRANCH_MASTER WITH (NOLOCK)
																			where Cmp_ID = @Cmp_ID and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Old_Branch_ID_Multi,ISNULL(Branch_ID,0)),'#') )
											Set @Old_Bank_Name = (Select Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID And Bank_ID = @Old_Bank_ID)
											
											set @OldValue = 'old Value' 
												+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Old_Month,0))
												+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Year,0))
												+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')
												+ '#' + 'Establishment Code No : ' + ISNULL(@Old_E_Code,'')
												+ '#' + 'Acc. Group No : ' + ISNULL(@Old_Acc_Gr_No,'')
												+ '#' + 'Name of the Bank : ' + ISNULL(@Old_Bank_Name,'')
												+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Old_Payment_Date,'') as nvarchar(11))
												+ '#' + 'Paid By : ' + ISNULL(@Old_Payment_Mode,'')
												+ '#' + 'Cheque No : ' + ISNULL(@Old_Cheque_No,'')
												+ '#' + 'Total No. Of Subscriber : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_SubScriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Wages_Due,0))
												+ '#' + 'Total No. Of Subscriber(F.P.) : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Family_Pension_Subscriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Family_Pension_Wages_Amount,0))
												+ '#' + 'Total No. Of Subscriber (EDIL) 	 : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_EDLI_Subscriber,0))
												+ '#' + 'Total Wages Due : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_EDLI_Wages_Amount,0))
												+ '#' + 'Total Challan Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Challan_Amount,0))
																																												
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'PF Challan',@Oldvalue,@Pf_Challan_ID,@User_Id,@IP_Address
										-- Added for audit trail By Ali 19102013 -- End
										
						DELETE FROM dbo.T0220_PF_CHALLAN where Pf_Challan_ID = @Pf_Challan_ID
				 End 
		End
		
	
	RETURN




