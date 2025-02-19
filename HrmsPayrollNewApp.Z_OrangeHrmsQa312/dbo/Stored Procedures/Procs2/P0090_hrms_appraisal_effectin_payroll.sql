



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_hrms_appraisal_effectin_payroll]   
 @Appr_int_ID numeric(18,0)  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
Declare @Data table  
(  
Appr_int_ID numeric(18,0),  
Emp_ID numeric(18,0),  
increment_effective_date datetime,  
basic_salary numeric(22,2),  
Gross_salary numeric(22,2),  
emp_code varchar(50),  
Emp_Full_Name varchar(200),  
Other_Email  Varchar(50),
Increment_id numeric(18,0),  
Status tinyint,  
Increment_Amount numeric(22,2),  
Increment_Amount_Gross numeric(22,2),  
Pre_Gross numeric(22,2),  
Total_Score numeric(18,2),
Eval_score numeric(18,2),
App_End_date DateTime
)  
  
Declare @App_End_Date DateTime
Declare @Count_Emp Numeric
Declare @Count_Sup Numeric

Declare @Temp Table
(	
	Count_Emp Numeric,
	Count_Sup Numeric,
	Flag Int
)
 --insert into @Data  
 --select hrms.Appr_int_ID,hrms.Emp_ID,i.increment_effective_date,i.basic_salary,i.Gross_salary  
 --,em.emp_code,em.Emp_Full_Name,hrms.Increment_id,0 ,I.Increment_Amount,0,i.pre_Gross_salary  
 --from t0090_hrms_appraisal_initiation_detail hrms   
 --inner join t0095_increment I on hrms.emp_id=i.emp_id  
 --inner join t0080_emp_master EM on hrms.Emp_id=em.emp_id  
 --where hrms.Appr_Int_ID=@Appr_int_ID  
 --And i.Increment_ID  in  
 --(select Max(Increment_ID) from t0095_increment Group by emp_id)  
 

 
 insert into @Data  --Nikunj 21-May-2010
 select hrms.Appr_int_ID,hrms.Emp_ID,i.increment_effective_date,i.basic_salary,i.Gross_salary,
		em.Alpha_Emp_Code  as Emp_Code,em.Emp_Full_Name,em.other_email,hrms.Increment_id,hrms.Is_Accept,--Added by hrms.Is_Accept Ripal 23July2014
		I.Increment_Amount,0,i.pre_Gross_salary,sum(FS.Total_Score)as Total_Score,
		sum(FS.Eval_Score)As Eval_Score,getdate()  
 from t0090_hrms_appraisal_initiation_detail hrms WITH (NOLOCK)  
 inner join t0095_increment I WITH (NOLOCK) on hrms.emp_id=i.emp_id  
 inner join t0080_emp_master EM WITH (NOLOCK) on hrms.Emp_id=em.emp_id  
 left outer join T0090_hrms_Final_score FS WITH (NOLOCK) on FS.Appr_int_ID = hrms.Appr_int_ID
where hrms.Appr_Int_ID = @Appr_int_ID
	  And i.Increment_ID  in (select Max(Increment_ID) from t0095_increment WITH (NOLOCK) group by emp_ID) 
Group by hrms.Appr_int_ID,hrms.Emp_ID,i.increment_effective_date,i.basic_salary,i.Gross_salary,
		 em.Alpha_Emp_Code,em.Emp_Full_Name,hrms.Increment_id,I.Increment_Amount,i.pre_Gross_salary,
		 em.Other_Email,hrms.Is_Accept

   
 update @Data  set Status = 1 where Increment_id is not null  
 Update @Data  set Increment_Amount_Gross = (Gross_salary-Pre_Gross) where Pre_Gross <> 0  
 update @Data  set Increment_Amount =null where Increment_Amount=0   
 update @Data  set Increment_Amount_Gross =null where Increment_Amount_Gross=0
 Update @Data  set basic_salary =(basic_salary-isnull(Increment_Amount,0)),Gross_salary=(Gross_salary-isnull(Increment_Amount_Gross,0))
 Select  @App_End_Date = End_Date From T0090_hrms_appraisal_Initiation_detail WITH (NOLOCK) where Appr_int_Id=@Appr_int_Id
 update @Data  set App_End_date = @App_End_Date


If Exists(Select Appr_Int_Id From T0090_hrms_Final_Score WITH (NOLOCK) Where Appr_Int_Id=@Appr_Int_Id) 
	Begin
		select @Count_Emp = Count(Appr_Int_Id)from T0090_hrms_final_score WITH (NOLOCK) where Appr_int_Id=@Appr_Int_Id and Emp_Status=0 and Inspection_Status=0
		select @Count_Sup = Count(Appr_Int_Id)from T0090_hrms_final_score WITH (NOLOCK) where Appr_int_Id=@Appr_Int_Id and Emp_Status=1 and Inspection_Status=0
		insert into @temp(Count_Emp,Count_Sup,Flag)values(@Count_Emp,@Count_Sup,1)
	End
Else 
	Begin
       insert into @temp(Count_Emp,Count_Sup,Flag)values(0,0,0)     
    End

 select * from @Data    
 select * from @temp
RETURN  




