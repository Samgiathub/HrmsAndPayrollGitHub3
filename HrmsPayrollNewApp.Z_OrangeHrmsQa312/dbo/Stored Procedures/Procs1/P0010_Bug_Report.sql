



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0010_Bug_Report]
	     @Bug_ID numeric output
		,@Bug_Code varchar(20)
		,@Bug_Type  numeric
		,@Bug_Description  varchar(6000)
		,@Bug_Shanp_short datetime
		,@Bug_Serverity varchar(20) output
		,@Bug_Priority Varchar(20)
		,@Bug_Report_BY varchar(250)
		,@Bug_Report_On datetime
		,@Bug_Assign_On datetime
	        ,@Bug_Exp_Fix_Date datetime
	        ,@Bug_Fix_BY varchar(30)
		,@Bug_Fix_On datetime
		,@Bug_Status varchar(20)
		,@Bug_Fix_Comments varchar(30)
		,@tran_type varchar(1)
	
AS	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if @tran_type ='I' 
			
			declare @Emp_Code as numeric
		declare @str_Emp_Code as varchar(20)
		
									
				
				select @Bug_ID = isnull(max(Bug_ID),0) +1 from T0100_Bug_APPLICATION WITH (NOLOCK)
			
			
			
				SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code) 
			
				select @Bug_Code =   cast(isnull(max(substring(Bug_Code,8,len(Bug_Code))),0) + 1 as varchar)  
						from T0100_Bug_APPLICATION  WITH (NOLOCK) where Bug_ID = @Bug_ID
				
				If charindex(':',@Bug_Code) > 0 
					Select @Bug_Code = right(@Bug_Code,len(@Bug_Code) - charindex(':',@Bug_Code))
				
				if @Bug_Code is not null
					begin
						while len(@Bug_Code) <> 4
							begin
								set @Bug_Code = '0' + @Bug_Code
							end
						set @Bug_Code = 'BV'+ @str_Emp_Code +':'+ @Bug_Code
					end
				else
					SET @Bug_Code = 'BV' + @str_Emp_Code + ':' + '0001'
		begin
							
	INSERT INTO T0100_Bug_APPLICATION
        (Bug_ID 
	    ,Bug_Code 
		,Bug_Type  
		,Bug_Description  
		,Bug_Shanp_short
		,Bug_Serverity 
		,Bug_Priority
		,Bug_Report_BY 
		,Bug_Report_On 
		,Bug_Assign_On 
	    ,Bug_Exp_Fix_Date
	    ,Bug_Fix_BY 
		,Bug_Fix_On 
		,Bug_Status 
		,Bug_Fix_Comments
		,tran_type)
		 VALUES     
		(@Bug_ID 
		,@Bug_Code 
		,@Bug_Type  
		,@Bug_Description  
		,@Bug_Shanp_short 
		,@Bug_Serverity 
		,@Bug_Priority 
		,@Bug_Report_BY 
		,@Bug_Report_On
		,@Bug_Assign_On 
	    ,@Bug_Exp_Fix_Date 
	    ,@Bug_Fix_BY 
		,@Bug_Fix_On 
		,@Bug_Status 
		,@Bug_Fix_Comments 
		,@tran_type )
		end
		
	
	RETURN




