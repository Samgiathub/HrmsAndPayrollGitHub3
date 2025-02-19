



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0220_PF_CHALLAN_SETT]
		 @Pf_Challan_ID						numeric(18, 0) output
		,@Branch_ID							numeric(18, 0)
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
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Branch_ID = 0 
		set	@Branch_ID = NULL
	
	if @tran_type = 'I'
			begin
					If Exists(select Pf_Challan_ID From T0220_PF_CHALLAN_SETT WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and Month = @Month AND Year=@Year and branch_id = @Branch_ID )
						begin
							set @Pf_Challan_ID = 0
							return 
					end
					select @Pf_Challan_ID = Isnull(max(Pf_Challan_ID),0) + 1 	From T0220_PF_CHALLAN_SETT WITH (NOLOCK)
				
				INSERT INTO T0220_PF_CHALLAN_SETT
				                      (Pf_Challan_ID, Cmp_ID, Branch_ID, Bank_ID, Month, Year, Payment_Date, E_Code, Acc_Gr_No, Payment_Mode, Cheque_No, Total_SubScriber, 
				                      Total_Wages_Due, Total_Challan_Amount, Total_Family_Pension_Subscriber, Total_Family_Pension_Wages_Amount, Total_EDLI_Subscriber, Total_EDLI_Wages_Amount)
				VALUES     (@Pf_Challan_ID,@Cmp_ID,@Branch_ID,@Bank_ID,@Month,@Year,@Payment_Date,@E_Code,@Acc_Gr_No,@Payment_Mode,@Cheque_No,@Total_SubScriber,@Total_Wages_Due,@Total_Challan_Amount
							,@Total_Family_Pension_Subscriber, @Total_Family_Pension_Wages_Amount, @Total_EDLI_Subscriber, @Total_EDLI_Wages_Amount)	
						
			END
			
	else if @tran_type ='U' 
				begin
								
						UPDATE    T0220_PF_CHALLAN_SETT
						SET              Bank_ID = @Bank_ID, Payment_Date = @Payment_Date, E_Code = @E_Code, Acc_Gr_No = @Acc_Gr_No, Payment_Mode = @Payment_Mode, 
						                      Cheque_No = @Cheque_No, Total_SubScriber = @Total_SubScriber, Total_Wages_Due = @Total_Wages_Due, 
						                      Total_Challan_Amount = @Total_Challan_Amount, 
						                      Total_Family_Pension_Subscriber =@Total_Family_Pension_Subscriber, Total_Family_Pension_Wages_Amount =@Total_Family_Pension_Wages_Amount , 
						                      Total_EDLI_Subscriber =@Total_EDLI_Subscriber, Total_EDLI_Wages_Amount =@Total_EDLI_Wages_Amount 
						WHERE     (Pf_Challan_ID = @Pf_Challan_ID) 	
				                      
				                      
				end
	else if @tran_type ='D'
		Begin
				
				DELETE FROM T0230_PF_CHALLAN_DETAIL_SETT where Pf_Challan_ID = @Pf_Challan_ID 
				
				if not exists(select Pf_Challan_ID  from T0230_PF_CHALLAN_DETAIL_SETT WITH (NOLOCK) Where Pf_Challan_ID = @Pf_Challan_ID )
				 begin
				 
						DELETE FROM T0220_PF_CHALLAN_SETT where Pf_Challan_ID = @Pf_Challan_ID
				 End 
				 
		End
		
	
	RETURN




