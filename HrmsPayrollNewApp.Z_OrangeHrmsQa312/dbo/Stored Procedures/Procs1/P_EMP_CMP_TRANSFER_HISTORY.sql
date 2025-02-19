
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_EMP_CMP_TRANSFER_HISTORY]
	--@Cmp_ID		numeric
	@Emp_ID		numeric  = 0
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

;with cte as
	(  
		select 	Convert(Varchar,Em.DAte_Of_join,103) as Effective_Date ,cm.Cmp_Name AS Old_Comapny_Name
				,Cm1.Cmp_Name as New_Company_Name,Convert(Varchar,T.Effective_Date,103) As New_Effective_Date,EM.Emp_ID,Cm.Cmp_Id,
				EM.Date_Of_Join,em1.Emp_ID as new_emp_id,cm1.Cmp_Id as new_cmp_id
		
		from	T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK) inner join  
				T0080_EMP_MASTER EM WITH (NOLOCK) on Em.Emp_ID = T.Old_Emp_Id and Em.Cmp_ID = T.Old_Cmp_Id inner JOIN 						
				T0010_COMPANY_MASTER Cm WITH (NOLOCK) on  Cm.Cmp_Id = T.Old_Cmp_Id INNER JOIN
				T0080_EMP_MASTER EM1 WITH (NOLOCK) on Em1.Emp_ID = T.New_Emp_Id and Em1.Cmp_ID = T.New_Cmp_Id inner JOIN 						
				T0010_COMPANY_MASTER Cm1 WITH (NOLOCK) on  Cm1.Cmp_Id = T.New_Cmp_Id
		
		where T.Old_Emp_Id = @Emp_Id
		
		union all
		
		select 	Convert(Varchar,Em.DAte_Of_join,103) as Effective_Date ,cm.Cmp_Name AS Old_Comapny_Name
				,Cm1.Cmp_Name as New_Company_Name,Convert(Varchar,T.Effective_Date,103) As New_Effective_Date,EM.Emp_ID,Cm.Cmp_Id,
				EM.Date_Of_Join,em1.Emp_ID as new_emp_id,cm1.Cmp_Id as new_cmp_id
		
		from	T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK) inner join  
				T0080_EMP_MASTER EM WITH (NOLOCK) on Em.Emp_ID = T.Old_Emp_Id and Em.Cmp_ID = T.Old_Cmp_Id inner JOIN 						
				T0010_COMPANY_MASTER Cm WITH (NOLOCK) on  Cm.Cmp_Id = T.Old_Cmp_Id INNER JOIN
				T0080_EMP_MASTER EM1 WITH (NOLOCK) on Em1.Emp_ID = T.New_Emp_Id and Em1.Cmp_ID = T.New_Cmp_Id inner JOIN 						
				T0010_COMPANY_MASTER Cm1 WITH (NOLOCK) on  Cm1.Cmp_Id = T.New_Cmp_Id inner join 
				cte as C on T.Old_Emp_Id = C.New_Emp_Id
		)
	select * INTO
	#Temp
	from cte

	;with cte1 as
	(  
		select 	Convert(Varchar,Em.DAte_Of_join,103) as Effective_Date ,cm.Cmp_Name AS Old_Comapny_Name
				,Cm1.Cmp_Name as New_Company_Name,Convert(Varchar,T.Effective_Date,103) As New_Effective_Date,EM.Emp_ID,Cm.Cmp_Id,
				EM.Date_Of_Join,em1.Emp_ID as new_emp_id,cm1.Cmp_Id as new_cmp_id
		
		from	T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK) inner join  
				T0080_EMP_MASTER EM WITH (NOLOCK) on Em.Emp_ID = T.Old_Emp_Id and Em.Cmp_ID = T.Old_Cmp_Id inner JOIN 						
				T0010_COMPANY_MASTER Cm WITH (NOLOCK) on  Cm.Cmp_Id = T.Old_Cmp_Id INNER JOIN
				T0080_EMP_MASTER EM1 WITH (NOLOCK) on Em1.Emp_ID = T.New_Emp_Id and Em1.Cmp_ID = T.New_Cmp_Id inner JOIN 						
				T0010_COMPANY_MASTER Cm1 WITH (NOLOCK) on  Cm1.Cmp_Id = T.New_Cmp_Id
		
		where T.New_Emp_Id = @Emp_Id
		
		union all
		
		select 	Convert(Varchar,Em.DAte_Of_join,103) as Effective_Date ,cm.Cmp_Name AS Old_Comapny_Name
				,Cm1.Cmp_Name as New_Company_Name,Convert(Varchar,T.Effective_Date,103) As New_Effective_Date,EM.Emp_ID,Cm.Cmp_Id,
				EM.Date_Of_Join,em1.Emp_ID as new_emp_id,cm1.Cmp_Id as new_cmp_id
		
		from	T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK) inner join  
				T0080_EMP_MASTER EM WITH (NOLOCK) on Em.Emp_ID = T.Old_Emp_Id and Em.Cmp_ID = T.Old_Cmp_Id inner JOIN 						
				T0010_COMPANY_MASTER Cm WITH (NOLOCK) on  Cm.Cmp_Id = T.Old_Cmp_Id INNER JOIN
				T0080_EMP_MASTER EM1 WITH (NOLOCK)on Em1.Emp_ID = T.New_Emp_Id and Em1.Cmp_ID = T.New_Cmp_Id inner JOIN 						
				T0010_COMPANY_MASTER Cm1 WITH (NOLOCK) on  Cm1.Cmp_Id = T.New_Cmp_Id inner join 
				cte1 as C on T.New_Emp_Id = C.Emp_Id
		)
	select * INTO
	#temp1
	from cte1
	
	select	* from #temp
	Union	All SELECT * from #temp1
	order by emp_id
	
RETURN
