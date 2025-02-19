



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEAVE_CLOSING_AS_ON_DATE_lEAVE1]
	@CMP_ID		NUMERIC ,
	@EMP_ID		NUMERIC ,
	@FOR_DATE	DATETIME = null,
	@Leave_ID  NUMERIC
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
		if Isnull(@For_Date,'') = '' 
			begin
				select @For_Date = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID = @Emp_ID
			end
	
	   Declare @Leave_Negative as numeric
	   Declare @Leave_clos as numeric(18,2)
	  
	
		CREATE table #Data 
		 ( 
			Leave_Opening numeric(18,2),
			Leave_Used    Numeric(18,2),
			Leave_Closing numeric(18,2),
			Leave_Code    varchar(100),
			Leave_Name    varchar(100),
			Leave_ID      numeric,
			Leave_Negative numeric
		 )
		
		declare @GRD_ID		NUMERIC
		select @GRD_ID = grd_id from t0080_emp_master WITH (NOLOCK) where emp_id = @EMP_ID and cmp_id = @CMP_ID 
		
		insert into #Data(Leave_Opening,Leave_Used,Leave_Closing,Leave_Code,Leave_Name,Leave_ID,Leave_Negative)

		SELECT Leave_Opening,Leave_Used,LEAVE_CLOSING,LEAVE_CODE,LEAVE_NAME,LT.LEAVE_ID,LM.Leave_Negative_Allow FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN  
		(SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
		WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE AND LEAVE_ID in (Select Leave_ID from V0040_LEAVE_DETAILS Where Grd_ID=@GRD_ID)
		GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
		LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID
		where LT.LEAVE_ID=@Leave_ID
	
		--SELECT Leave_Opening,Leave_Used,LEAVE_CLOSING,LEAVE_CODE,LEAVE_NAME,LT.LEAVE_ID,LM.Leave_Negative_Allow FROM T0140_LEAVE_TRANSACTION LT INNER JOIN  
		--( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION 
		--	WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE
		--GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
		--LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID = LM.LEAVE_ID
		-- where LT.LEAVE_ID=@Leave_ID
		 
		 Select @Leave_Negative=Leave_Negative,@Leave_clos=Leave_closing from #Data
		 
		  if @Leave_Negative =0 
		     Begin 
		         if  @Leave_clos < 0
		           Begin 
		             	Raiserror('@@Leave Balance Negative, Negative Not Allowed@@',16,2)
					    return 
		           end
		     
		     end
	RETURN




