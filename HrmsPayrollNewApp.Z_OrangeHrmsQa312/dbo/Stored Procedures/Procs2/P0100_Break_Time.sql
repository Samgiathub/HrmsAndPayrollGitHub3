

-- =============================================
-- Author:		Jimit Soni
-- Create date: 19-11-2018
-- Description:	For inserting,and deleting the Break Records
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_Break_Time]
	 @Break_Id		Numeric(5,0) output
	,@Cmp_ID				Numeric(5,0)
	,@Emp_ID				Numeric(5,0) = 0 
	,@Dept_ID				Numeric(5,0) = 0
	,@Branch_ID				Numeric(5,0) = 0
	,@Effective_date		DateTime	
	,@Break_Start_Time		varchar(5)
	,@Break_End_Time		varchar(5)
	,@Break_duration		varchar(5)
	,@Type					tinyint
	,@Tran_Type				varchar(1)	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
				
		if @tran_type ='I' 
			begin
				
				If NOT EXISTS (	
								Select	1 
								From	T0100_Break_Time WITH (NOLOCK)
								where	Emp_ID = CASE WHEN @Emp_ID = 0 then Emp_ID ELSE @Emp_ID END AND
										DEPT_ID = CASE WHEN @DEPT_ID = 0 then DEPT_ID ELSE @DEPT_ID END AND 
										BRANCH_ID = CASE WHEN @BRANCH_ID = 0 then BRANCH_ID ELSE @BRANCH_ID END AND 
										Cmp_ID = @Cmp_ID And Effective_Date =  @Effective_date
								)  
					BEGIN
								select @Break_Id = Isnull(max(Break_Id),0) + 1 From T0100_Break_Time WITH (NOLOCK) 
								
								
																
								INSERT INTO T0100_Break_Time
								(Break_Id
								,Cmp_ID
								,Emp_ID
								,Dept_ID
								,Branch_ID
								,Effective_Date
								,Break_Start_Time
								,Break_End_Time
								,Break_duration
								,[Type]
								
								)
								VALUES   
								(@Break_Id
								,@Cmp_ID
								,@Emp_ID
								,@Dept_ID
								,@Branch_ID
								,@Effective_Date
								,@Break_Start_Time
								,@Break_End_Time
								,@Break_duration								
								,@Type
								)					
						END
				ELSE 
					BEGIN
						 					 
						 
						 UPDATE T0100_Break_Time
						 SET	Effective_Date = @Effective_Date,Break_Start_Time = @Break_Start_Time,
								Break_End_Time = @Break_End_Time,Break_duration = @Break_duration
						 where	Emp_ID = CASE WHEN @Emp_ID = 0 then Emp_ID ELSE @Emp_ID END AND
								DEPT_ID = CASE WHEN @DEPT_ID = 0 then DEPT_ID ELSE @DEPT_ID END AND 
								BRANCH_ID = CASE WHEN @BRANCH_ID = 0 then BRANCH_ID ELSE @BRANCH_ID END AND 
								Cmp_ID = @Cmp_ID And Effective_Date =  @Effective_date AND
								[TYPE] = @TYPE	 
						 
						 			
					END
					
					 
			END	
	else if @tran_type ='D'
			begin
				
				DELETE FROM T0100_Break_Time where Break_Id = @Break_Id					

							
			
			end
			
	RETURN

