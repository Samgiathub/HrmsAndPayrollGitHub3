---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[GET_OT_UNAPPROVED_RECORDS]  
  @Cmp_ID    numeric        
 ,@From_Date   datetime        
 ,@To_Date    datetime         
 ,@Branch_ID   Varchar(Max) = ''      
 ,@Cat_ID    numeric         
 ,@Grd_ID    Varchar(Max) = ''      
 ,@Type_ID    numeric   
 ,@Vertical  Varchar(Max) = ''      
 ,@subVertical  Varchar(Max) = ''      
 ,@segment   Varchar(Max) = ''      
 ,@Dept_ID     Varchar(Max) = ''    
 ,@Desig_ID    numeric        
 ,@Emp_ID    numeric        
 ,@constraint   varchar(5000)        
 ,@Return_Record_set numeric = 1 
 ,@StrWeekoff_Date varchar(1000)  =''
AS
 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


CREATE table #Emp_Cons 
 (			
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )
	
 
exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Vertical,@Desig_ID,@Emp_ID,@constraint,0,0,@segment,@Vertical,@subVertical,0,0,0,3,'0',0,@Type_ID   

DECLARE @result varchar(MAX)

SELECT @RESULT = ISNULL(@result, '') +  CAST(Emp_ID AS varchar(10))+ '#' FROM #Emp_Cons 
SELECT @RESULT = substring(@result, 1, len(@result) - 1) 

set @constraint = @RESULT

	if @Return_Record_set = 3
		begin
		
			--select @Emp_ID
			--exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,@Return_Record_set 
				exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,0,@Cat_ID,0,@Type_ID,0,@Desig_ID,@Emp_ID,@constraint,@Return_Record_set 

				-----24082022 by yogesh



				select * from T0160_OT_APPROVAL WITH (NOLOCK) where  MONTH(For_Date) = MONTH(@To_Date) And year(For_Date) = year(@To_Date) and Cmp_ID = @Cmp_ID And Isnull(Is_Month_Wise,0) = 1
			IF(@Emp_ID = 0)
				BEGIN
					Select Extra_Work_Date ,Emp_ID from T0120_CompOff_Approval WITH (NOLOCK) where Approve_Status = 'A' and Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Cmp_ID = @Cmp_ID 
				END
			ELSE
				BEGIN
					Select Extra_Work_Date ,Emp_ID from T0120_CompOff_Approval WITH (NOLOCK) where Approve_Status = 'A' and Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 
				END
		end
	else
		begin	
		print '2323'
			--exec  SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,@Return_Record_set
			--select @Cmp_ID,@From_Date,@To_Date,0,@Cat_ID,0,@Type_ID,0,@Desig_ID,@Emp_ID,@constraint,@Return_Record_set
	
				 exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,0,@Cat_ID,0,@Type_ID,0,@Desig_ID,@Emp_ID,@constraint,@Return_Record_set


				 print '000'
				
			select * from T0160_OT_APPROVAL WITH (NOLOCK) where For_Date >= @From_Date and For_Date <= @To_Date  and Cmp_ID = @Cmp_ID And Isnull(Is_Month_Wise,0) = 1
			
			IF(@Emp_ID = 0)
				BEGIN
				print '123'
					Select Extra_Work_Date ,Emp_ID from T0120_CompOff_Approval WITH (NOLOCK) where Approve_Status = 'A' and Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Cmp_ID = @Cmp_ID 
				END
			ELSE
				BEGIN
					Select Extra_Work_Date ,Emp_ID from T0120_CompOff_Approval WITH (NOLOCK) where Approve_Status = 'A' and Extra_Work_Date >= @From_Date and Extra_Work_Date <= @To_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 
				END
		end
  
 Return
 



