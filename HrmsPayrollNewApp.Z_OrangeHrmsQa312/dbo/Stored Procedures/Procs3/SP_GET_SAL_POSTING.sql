



-- exec  [dbo].[SP_EMP_SALARY_RECORD_GET1] 121,'10/1/2022','10/31/2022',0,'','',0,'','',26749,'','All',0,'','','','','',0
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_SAL_POSTING]
	 @Cmp_ID		NUMERIC
	,@strwhere	NVARCHAR(1000)
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

CREATE TABLE #Temp_Emp (
    Sal_Tran_ID INT, 
    Sal_Receipt_No VARCHAR(50), 
    Emp_ID INT, 
    Cmp_ID INT, 
    Increment_ID INT, 
    Month_St_Date DATE, 
    Month_End_Date DATE, 
    Sal_Generate_Date DATE, 
    Emp_Full_Name VARCHAR(255),
    IS_FNF BIT, 
    IS_Emp_FNF BIT, 
    Emp_First_Name VARCHAR(255), 
    Emp_code VARCHAR(50), 
    Alpha_Emp_Code VARCHAR(50), 
    Salary_Status VARCHAR(50), 
    Max_Increment_ID INT, 
    Emp_Left Varchar(10), 
    Emp_Left_Date DATE, 
    exit_id INT,
    Dept_ID INT, 
    Grd_ID INT, 
    Branch_ID INT, 
    Branch_Name VARCHAR(255), 
    SalDate_id INT, 
    Segment_ID INT, 
    Vertical_ID INT, 
    SubVertical_ID INT, 
    subBranch_ID INT, 
    Desig_Id INT, 
    Cat_ID INT
);
				
declare @Qry varchar(MAX)

set @Qry = '
INSERt INTO #Temp_Emp (Sal_Tran_ID
,Sal_Receipt_No
,Emp_ID
,Cmp_ID
,Increment_ID
,Month_St_Date
,Month_End_Date
,Sal_Generate_Date
,Emp_Full_Name
,IS_FNF
,IS_Emp_FNF
,Emp_First_Name
,Emp_code
,Alpha_Emp_Code
,Salary_Status
,Max_Increment_ID
,Emp_Left
,Emp_Left_Date
,exit_id
,Dept_ID
,Grd_ID
,Branch_ID
,Branch_Name
,SalDate_id
,Segment_ID
,Vertical_ID
,SubVertical_ID
,subBranch_ID
,Desig_Id
,Cat_ID)

select *  from  (
select tbl1.*,Qry1.Dept_ID,Qry1.Grd_ID,Qry1.Branch_ID,Qry1.Branch_Name,Qry1.SalDate_id,Qry1.Segment_ID,Qry1.Vertical_ID,Qry1.SubVertical_ID,Qry1.subBranch_ID,Qry1.Desig_Id,Qry1.Cat_ID
 from 
 
(
SELECT MS.Sal_Tran_ID, MS.Sal_Receipt_No, MS.Emp_ID, MS.Cmp_ID, MS.Increment_ID, MS.Month_St_Date, MS.Month_End_Date, MS.Sal_Generate_Date, 
						 e.Emp_Full_Name,
                      /*i.Dept_ID, i.Grd_ID, i.Branch_ID, BM.Branch_Name,i.SalDate_id, i.Segment_ID, i.Vertical_ID, i.SubVertical_ID, i.subBranch_ID,i.Desig_Id, ISNULL(i.Cat_ID, 0) AS Cat_ID*/
                      ISNULL(MS.Is_FNF, 0) AS IS_FNF, e.IS_Emp_FNF, e.Emp_First_Name, e.Emp_code, e.Alpha_Emp_Code, 
                      MS.Salary_Status, 
                      (
						SELECT Increment_ID from
						(
						   select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)    
						   where Increment_Effective_date <= MS.Month_End_Date and Emp_ID = ms.Emp_id
						   GROUP BY Emp_ID
						) as tbl
                      ) as Max_Increment_ID
                      ,e.Emp_Left,e.Emp_Left_Date,EX.exit_id 
					
FROM         dbo.T0200_MONTHLY_SALARY AS MS WITH (NOLOCK)  INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON MS.Emp_ID = e.Emp_ID LEFT JOIN 
                      T0200_Emp_ExitApplication EX WITH (NOLOCK)  ON EX.emp_id=MS.Emp_ID
                      
) as tbl1 Inner join

(select I.Emp_Id as Emp_id1, Increment_Effective_Date,i.Dept_ID, i.Grd_ID, i.Branch_ID, BM.Branch_Name,i.SalDate_id, i.Segment_ID, i.Vertical_ID, i.SubVertical_ID, i.subBranch_ID,i.Desig_Id, ISNULL(i.Cat_ID, 0) AS Cat_ID,I.Increment_ID As Max_Increment_ID_1 
	from T0095_INCREMENT as I WITH (NOLOCK)  INNER JOIN
		dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON i.Branch_ID = BM.Branch_ID
	) as Qry1
	on Qry1.Emp_id1 = tbl1.Emp_ID and Qry1.Max_Increment_ID_1 = tbl1.Max_Increment_ID
	)T
	where '+ @strwhere +'
	'
	--select @Qry
EXEC(@Qry)

select SPM.* INTO #Final_data from (
select MSP.POst_req_ID,COUNT(Account)GL_Account,COUNT(Center_Code)Center_Code from #Temp_Emp EM
INNER JOIN T0210_MONTHLY_Sal_POS_DETAIL MSP ON MSP.EMP_ID= EM.Emp_ID AND MSP.Post__Date = EM.Month_St_Date
group by POst_req_ID)T
INNER JOIN T0200_Salary_Posting_Master SPM ON SPM.Post_Req_ID = T.POst_req_ID

select Sal_Pos_MID,Process_type,Doc_Date,Pos_Date,Doc_No,Doc_Type,Com_Code,Emp_Cnt,GL_Ac_Cnt,Cost_Center_CNt,ISNULL(R_Post_Req_ID,'')R_Post_Req_ID from #Final_data

select count(1)Total_Records from #Final_data

	RETURN

