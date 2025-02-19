

CREATE PROCEDURE [dbo].[SP_CURR_T0100_EMP_SHIFT_GET]

 @emp_Id as numeric
,@Cmp_ID as numeric
,@For_Date as datetime
,@Shift_St_Time as varchar(10) = null output
,@Shift_End_Time as varchar(10) = null output
,@Shift_Dur as varchar(10) = null output
,@First_Break_Duration as varchar(10) = null output
,@Second_Break_Duration as varchar(10)= null output
,@Third_Break_Duration as varchar(10) = null output
,@Shift_Min_Hours as varchar(10) = null output
,@Shift_ID as numeric = null output
,@Is_Half_Day	tinyint	= 0  output
,@Week_Day	varchar(10)	= '' output
,@Half_St_Time	varchar(10)	= '' output
,@Half_End_Time	varchar(10)	= '' output
,@Half_Dur	varchar(10)	= '' output

AS

	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON  
 
    --Modified by Nimesh 21 May 2015
	--To Fetch Record from Employee Shift Rotation Master Table if exist.
	
	IF not exists(SELECT 1 FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) WHERE Emp_ID = @emp_Id and For_Date <= @For_Date)
		BEGIN
			SELECT @For_Date = isnull(Min(For_Date),@For_Date) FROM T0100_EMP_SHIFT_DETAIL  WITH (NOLOCK) where Emp_ID = @Emp_ID
		END
	
	SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @emp_Id, @For_Date);	
	
	SELECT @Shift_St_Time = SM.Shift_St_Time,@Shift_End_Time = SM.Shift_End_Time ,
			@Shift_Dur = Shift_Dur 
			,@Is_Half_Day=Is_Half_Day,@Week_Day=Week_Day,@Half_St_Time=Half_St_Time,@Half_End_Time=Half_End_Time,@Half_Dur=Half_Dur, @Second_Break_Duration = S_Duration,@Third_Break_Duration=T_Duration
			
	FROM dbo.T0040_SHIFT_MASTER  SM  WITH (NOLOCK) 
	WHERE SM.Cmp_ID = @Cmp_ID AND SM.Shift_ID= @Shift_ID
	
	
RETURN
