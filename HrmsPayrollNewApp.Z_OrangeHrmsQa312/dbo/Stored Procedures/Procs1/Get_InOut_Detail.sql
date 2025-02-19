



-- =============================================
-- Author     :	Alpesh
-- ALTER date: 16-Jul-2012
-- Description:	
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_InOut_Detail]

 @Emp_ID    numeric(18)    
,@Cmp_Id    numeric(18)
,@Today		numeric(18) 

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	 
	Declare @For_Date datetime
	Declare @In_Time datetime
	Declare @Out_Time datetime
	Declare @Min_In_Time datetime
	Declare @Max_Out_Time datetime
	
	If @Today = 1
		Begin
			Set @For_Date = CONVERT(varchar(10),getdate(),120)
	
			--Select Min(In_Time) In_Time,Max(Out_Time) Out_Time from T0150_EMP_INOUT_RECORD where Cmp_ID=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date	
			
			Select @Min_In_Time = Max(In_Time), @Max_Out_Time = Max(Out_Time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date	

			If @Min_In_Time is not null
				Begin
					Select @Out_Time = Min(Out_Time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date and Out_Time > @Min_In_Time	
					
					If @In_Time is null
						Set @In_Time = @Min_In_Time
				End
			Else
				Begin
					Set @In_Time = null
				End
			
						
			If @Max_Out_Time is not null
				Begin
					Select @In_Time = Min(In_Time) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date and In_Time > @Max_Out_Time	
					
					--If @Out_Time is null
					--	Set @Out_Time = @Max_Out_Time
				End
			Else
				Begin
					Set @Out_Time = null
				End
				
			--Added by Hardik 29/10/2012 for IN and OUT Button open for All Date on the Form level..
			Set @In_Time = Null							
			Set @Out_Time = Null							
			----------------------
			
			Select @In_Time as In_Time, @Out_Time as Out_Time
			
		End
	
    
    
END



