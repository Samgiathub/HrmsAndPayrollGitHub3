


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_Hrms_Emp_Check]
@Cmp_Id Numeric(18,0),
@Emp_Id Numeric(18,0)

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

create Table #Temp  
 (
     Emp_Id Numeric(18,0)
 )

     If Exists(Select Emp_Id From dbo.V0090_hrms_appraisal_status_Report where Emp_id= @Emp_Id and is_accept=2 and invoke_emp=2 and ISNULL(Inspection_Status,0)=0)
		Begin
               Insert Into #Temp Select Emp_Id From dbo.V0090_hrms_appraisal_status_Report where Emp_id= @Emp_Id and is_accept=2 and invoke_emp=2 and ISNULL(Inspection_Status,0)=0				
        End
	Else
        Begin			
              If not Exists(Select Emp_ID From dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_id=@Emp_Id And Emp_status = 0 And ISNULL(Inspection_Status,0)=1 And Cmp_Id=@Cmp_Id)
                  Begin		
					     Insert Into #Temp (Emp_Id) 
					       (Select emp_id from T0090_Hrms_Appraisal_Initiation_Detail aid WITH (NOLOCK) left join  T0090_Hrms_Appraisal_Initiation ai WITH (NOLOCK) on ai.Appr_Int_Id = aid.Appr_Int_Id
                          where aid.Emp_Id=@Emp_Id and Is_Accept=0 and AI.Invoke_Emp=2)  
                  End    	
                else
					begin  
						Insert Into #Temp(Emp_Id)  (Select Emp_Id From dbo.T0090_hrms_appraisal_initiation_detail AID WITH (NOLOCK) INNER JOIN dbo.T0090_hrms_appraisal_initiation AI WITH (NOLOCK) On AI.Appr_Int_Id = AID.Appr_int_Id  
                           Where AID.Emp_id= @Emp_Id and AID.Is_Accept=2 and AI.Invoke_Emp=2 And AI.Cmp_Id= @Cmp_Id )  
					end		
        End			
			Select * from #Temp
			
			delete from #Temp
END




