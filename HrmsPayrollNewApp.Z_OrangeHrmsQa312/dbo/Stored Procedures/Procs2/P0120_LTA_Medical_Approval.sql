



--zalak for lta medical application's approval
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_LTA_Medical_Approval]
	 @LM_Apr_ID	numeric(18, 0) output
	,@Cmp_ID	numeric(18, 0)
	,@LM_App_ID	numeric(18, 0)
	,@Emp_ID	numeric(18, 0)
	,@Apr_Date	datetime
	,@Apr_Code	varchar(20)
	,@Apr_Amount	numeric(18, 2)
	,@APr_Comments	varchar(500)
	,@APR_Status	int
	,@type_id	int
	,@tran_type char(1)
	
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--'Alpesh 21-Oct-2011
	Declare @Branch_ID numeric
	Declare @Effective_Month varchar(100)
	Declare @Start_Date datetime
	Declare @Claim_Month int
	Declare @Claim_Date datetime
	
	Select @Branch_ID=branch_id from t0095_increment I WITH (NOLOCK) inner join     
     ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)    --Changed by Hardik 10/09/2014 for Same Date Increment 
     where Increment_Effective_date <= @Apr_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
    Where I.Emp_ID = @Emp_ID  
    
    select  @Effective_Month=effective_month, @Start_Date=start_date  from T0040_LM_SETTING WITH (NOLOCK) where branch_id=@branch_id and start_date<=@Apr_Date and end_date>=@Apr_Date and type_id=@type_id		
		
	set @Claim_Month  = (Select top 1 data from dbo.Split(@effective_month,'#') where data <> '')
	
	set @Claim_Date =  cast(cast(day(@Start_Date)as varchar) + '-' + cast(datename(mm,dateadd(m,@Claim_Month,@Start_Date)) as varchar(10)) + '-' +  cast(year(@Start_Date)as varchar(10)) as smalldatetime)    
	
	select @Claim_Date,@Claim_Month,@Effective_Month,@Start_Date
	
	-- End --
	
	declare @System_Date as varchar(11)
	set @System_Date=cast(getdate() as varchar(11))
	
	
		If @tran_type  = 'I' 
			Begin
				
				Declare @str varchar(100)
				if @Apr_Date < @Claim_Date
				Begin
					set @str = '@@Claim cannot be done before' + @Claim_Date + '@@'			
					RAISERROR (@str, 16, 2) 
					Return
				End
			
				If Exists(select LM_Apr_ID From T0120_LTA_Medical_Approval WITH (NOLOCK) Where cmp_ID = @Cmp_ID and
									Emp_ID = @Emp_ID  and Apr_Date=@Apr_Date)
					Begin
						set @LM_Apr_ID = 0
						Return 
					end
	
				select @LM_Apr_ID = Isnull(max(LM_Apr_ID),0) + 1 ,@Apr_Code=Isnull(max(LM_Apr_ID),0) + 1	From T0120_LTA_Medical_Approval WITH (NOLOCK)
				
				INSERT INTO T0120_LTA_Medical_Approval
				                      (
										        LM_Apr_ID
												,Cmp_ID
												,LM_App_ID
												,Emp_ID
												,Apr_Date
												,Apr_Code
												,Apr_Amount
												,APr_Comments
												,System_Date
												,APR_Status
												,type_id
									 )
								VALUES     
								(
									            @LM_Apr_ID
												,@Cmp_ID
												,@LM_App_ID
												,@Emp_ID
												,@Apr_Date
												,@Apr_Code
												,@Apr_Amount
												,@APr_Comments
												,@System_Date
												,@APR_Status
												,@type_id
								)
				End
	Else if @Tran_Type = 'U' 
		begin
				Update T0120_LTA_Medical_Approval
				set 
							Apr_Date=@Apr_Date
							,Apr_Code=@Apr_Code
							,Apr_Amount=@Apr_Amount
							,APr_Comments=@APr_Comments
							,APR_Status=@APR_Status

				where LM_Apr_ID  = @LM_Apr_ID
		end
	Else if @Tran_Type = 'D' 
		begin
				update  T0130_LTA_For_Dependant set  LM_Apr_ID= null where LM_Apr_ID  = @LM_Apr_ID
				update  T0130_LTA_Jurney_Detail  set  LM_Apr_ID= null where LM_Apr_ID  = @LM_Apr_ID
				Delete From T0120_LTA_Medical_Approval where LM_Apr_ID  = @LM_Apr_ID
		end
	RETURN



