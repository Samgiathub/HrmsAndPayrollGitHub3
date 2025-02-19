

-- =============================================
-- Author:		<Author,,Jimit>
-- Create date: <Create Date,,20112018>
-- Description:	<Description,,For Getting Form 16 Publish Records>
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_EMP_Form16_View_Publish]
	 @Cmp_ID			numeric
	,@From_Date			datetime
	,@To_Date			datetime 
	,@Branch_ID			numeric = 0
	,@Cat_ID			numeric	= 0	
	,@Dept_ID			numeric = 0		
	,@Constraint		varchar(max) = ''	
	,@Form16_View_Type	numeric = 0
	,@Form16_Upload		varchar(15) = 'Uploaded'
		
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	
	if @Dept_ID = 0
		set @Dept_ID = null
	
			  
	
		CREATE table #Emp_Cons 
		 (      
			Emp_ID			numeric ,     
			Branch_ID		numeric,
			Increment_ID	numeric    
		 )      
 
 
	
	EXEC SP_RPT_FILL_EMP_CONS	@Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,0,0,@Dept_ID,0,0,
								@constraint,0 ,0 ,0,0,0,0,0,0,0,'0',0	

	Create Clustered index IX_Emp_Cons_Emp_ID_Branch_ID_Increment_ID on #Emp_Cons (Emp_ID,Branch_ID,Increment_ID) 
		
		
		
	IF @Form16_Upload = 'Uploaded'
		BEGIN
				delete EC FROM #Emp_Cons EC
				WHERE  NOT EXISTS (SELECT	1 
									FROM	T0050_Form_16_Import FI WITH (NOLOCK)
									WHERE	FI.Emp_ID = EC.EMP_ID AND Left(FI.Financial_Year,4) = Year(@From_Date) and 
																	Right(FI.Financial_Year,4) = Year(@To_Date))
		END

		

	   if @Form16_View_Type = 0 
		   begin		
			   select Distinct	E.Emp_ID,E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name,DM.Dept_Name as Department,E.Branch_ID,E.Vertical_ID,e.SubVertical_ID,e.subBranch_ID,e.Dept_ID,
								case when IsNull(SPE.Is_Publish,0) = 1 then 'Publish' else 'Unpublish' end  as Is_Publish,Comments
				from			dbo.T0080_EMP_MASTER E WITH (NOLOCK) inner join
								( 
									select  I.Emp_Id,Branch_ID,Dept_ID 
									from	dbo.T0095_Increment I WITH (NOLOCK) inner join 
											( 
												select	max(Increment_ID) as Increment_ID , Emp_ID 
												from	dbo.T0095_Increment WITH (NOLOCK)
												where	Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
												group by emp_ID 
											 ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
									) I_Q on E.Emp_ID = I_Q.Emp_ID  Left OUTER JOIN							  
								dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I_Q.Dept_ID = DM.Dept_Id LEFT OUTER JOIN							
								dbo.T0250_Form16_Publish_ESS SPE WITH (NOLOCK) on E.Emp_ID = SPE.Emp_ID and
																	Left(SPE.Financial_Year,4) = Year(@From_Date) and 
																	Right(SPE.Financial_Year,4) = Year(@To_Date) Inner join
								#Emp_Cons EC on E.Emp_ID = EC.Emp_ID 
				WHERE			E.Cmp_ID = @Cmp_Id  and E.Emp_Left='N' ---added by aswini 09/1/2024
				ORDER BY		E.ALPHA_EMP_CODE,E.Emp_Full_Name
		   end
	   else if @Form16_View_Type = 1 
	     begin
			   select Distinct	E.Emp_ID,E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name,DM.Dept_Name as Department,E.Branch_ID,E.Vertical_ID,e.SubVertical_ID,e.subBranch_ID,e.Dept_ID,
								case when IsNull(SPE.Is_Publish,0) = 1 then 'Publish' else 'Unpublish' end  as Is_Publish,Comments
			   from				dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
								(
									select  I.Emp_Id,Branch_ID,I.Emp_Full_PF,I.Emp_Auto_Vpf,Dept_ID  
									from	dbo.T0095_Increment I WITH (NOLOCK) inner join 
									( 
										select	max(Increment_ID) as Increment_ID , Emp_ID 
										from	dbo.T0095_Increment WITH (NOLOCK)
										where	Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
										group by emp_ID  
									) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
								) I_Q on E.Emp_ID = I_Q.Emp_ID  inner join							
								dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Left outer join 
								dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I_Q.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
								dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID  Inner Join
								dbo.T0250_Form16_Publish_ESS SPE WITH (NOLOCK) on E.Emp_ID = SPE.Emp_ID and 
																	Left(SPE.Financial_Year,4) = Year(@From_Date) and 
																	Right(SPE.Financial_Year,4) = Year(@To_Date) Inner join 
								#Emp_Cons EC on E.Emp_ID = EC.Emp_ID 
				WHERE			E.Cmp_ID = @Cmp_Id 
				ORDER BY		E.ALPHA_EMP_CODE,E.Emp_Full_Name	
	   end
	   else if @Form16_View_Type = 2
		   begin
			   select Distinct	E.Emp_ID,E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name,DM.Dept_Name as Department, E.Branch_ID,E.Vertical_ID,e.SubVertical_ID,e.subBranch_ID,e.Dept_ID,---for filter  added by aswini 09/1/2024
								case when IsNull(SPE.Is_Publish,0) = 1 then 'Publish' else 'Unpublish' end  as Is_Publish,Comments  
				from			dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
								(
									select  I.Emp_Id,Branch_ID,I.Emp_Full_PF,I.Emp_Auto_Vpf,Dept_ID 
									from	dbo.T0095_Increment I WITH (NOLOCK) inner join 
									(
										select	max(Increment_ID) as Increment_ID , Emp_ID 
										from	dbo.T0095_Increment WITH (NOLOCK)
										where	Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
										group by emp_ID  
									) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
								) I_Q on E.Emp_ID = I_Q.Emp_ID  inner join							
							dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Left outer join 
							dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I_Q.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
							dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID  left outer join  
							dbo.T0250_Form16_Publish_ESS SPE WITH (NOLOCK) on E.Emp_ID = SPE.Emp_ID and 
																Left(SPE.Financial_Year,4) = Year(@From_Date) and 
																Right(SPE.Financial_Year,4) = Year(@To_Date) Inner join 
							#Emp_Cons EC on E.Emp_ID = EC.Emp_ID 
				WHERE		E.Cmp_ID = @Cmp_Id and IsNull(SPE.Is_Publish,0) = 0 
				ORDER BY	E.ALPHA_EMP_CODE,E.Emp_Full_Name		
		end
RETURN
	
	
	

