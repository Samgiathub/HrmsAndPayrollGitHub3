


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Sp_Skill_Evalution_Reminder]
	@Cmp_Id As Numeric(18,0),
	@Branch_Id As Numeric(18,0),
	@Dash_Board As Int	
AS
--Nikunj 2-June-2010
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
 if @Branch_Id=0 
 Set @Branch_Id=NULL
 
 Declare @Skill_Eval_Duration As Int
 Declare @For_Date As DateTime
 Declare @Branch_Name As Varchar(50)
 Declare @Date As DateTime
 Declare @Month_Diff As Numeric
 Declare @Div as Numeric
 Declare @New_Month As Numeric
 Declare @New_Date As Datetime
 Declare @Skill_D_Id As Numeric
 
 Declare @temp Table
 (
	Skill_d_Id Numeric,
	Branch_Name Varchar(50)	
 ) 
 
 Declare Cur_Skill Cursor For 
		Select Skill_D_Id,Branch_Name,Skill_Eval_Duration,Fore_Date From dbo.V0050_HRMS_Skill_Rate_Setting where Cmp_Id=@cmp_Id And isnull(Branch_ID,0) = isnull(@Branch_Id ,isnull(Branch_ID,0))
Open Cur_Skill
	  Fetch Next From Cur_Skill Into @Skill_D_Id,@Branch_Name,@Skill_Eval_Duration,@For_Date
	  While @@Fetch_Status = 0
	  Begin	  				
	         --If @Skill_Eval_Duration <= datediff(month,@For_Date,getdate())
		    If datediff(month,@For_Date,getdate())<= @Skill_Eval_Duration
					Begin                         
							SELECT @Date=(DATEADD(M,@Skill_Eval_Duration,@For_Date))	   	      
								if CONVERT(VARCHAR(9),Getdate(),112)<= CONVERT(VARCHAR(9),@Date,112) And CONVERT(VARCHAR(9),Getdate(),112) > = CONVERT(VARCHAR(9),dateadd(d,-10,@Date),112)				    
									Begin																								
										insert into @temp values(@Skill_D_Id,@Branch_Name)
									End	
								Else
									Begin																									
										insert into @temp values(NULL,NULL)
									End		 
	          		End
	          	 Else
	          		Begin	          	  
							Select @Month_Diff=DateDiff(Month,@For_Date,GetDate())
						
							Set @div=(@Month_Diff)/(@Skill_Eval_Duration)
						
							Set @New_Month=(@div)*(@Skill_Eval_Duration)
						
							Select @New_Date = (DATEADD(M,@New_Month,@For_Date))				
						
						--SELECT @Date=(DATEADD(M,@Skill_Eval_Duration,@For_Date))	   	      								            
							if CONVERT(VARCHAR(9),Getdate(),112)<= CONVERT(VARCHAR(9),@New_Date,112) And CONVERT(VARCHAR(9),Getdate(),112) > = CONVERT(VARCHAR(9),dateadd(d,-10,@New_Date),112)				
									Begin															
										insert into @temp values(@Skill_D_Id,@Branch_Name)
									End	
							Else
									Begin																
										insert into @temp values(NULL,NULL)
									End		 
					End
       Fetch Next From Cur_Skill Into @Skill_D_Id,@Branch_Name,@Skill_Eval_Duration,@For_Date
	  End                      
	  Close Cur_Skill
Deallocate Cur_Skill 

if @Dash_Board=1
Begin
Select Count(Skill_D_ID) As Count from @temp where Skill_d_Id is not null
End
Else
Begin
select Skill_d_ID,Branch_Name from @temp where Skill_d_ID is not null
End		
RETURN




