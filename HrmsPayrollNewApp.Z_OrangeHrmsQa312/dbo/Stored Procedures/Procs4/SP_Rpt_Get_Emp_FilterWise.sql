

---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Rpt_Get_Emp_FilterWise]
	@Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max) --  Added by nilesh patel on 06092014
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) --  Added by nilesh patel on 06092014
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) --  Added by nilesh patel on 06092014
	,@Desig_ID		varchar(Max) --  Added by nilesh patel on 06092014
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@Report_Type varchar(50) = ''		 -- Added By Jignesh Patel 13-Dec-2013	
	,@PrintEmpName varchar(500) = ''   --Added By Jaina 16-10-2015
	,@reportPath    varchar(max) =''   --Added by rohit 19022016
	,@Payment_Mode varchar(20) = ''  --added jimit 02062016	
	,@For_Attendance tinyint = 0   --Added By Jaina 07-09-2016
	,@Is_Active tinyint = 0
	,@Salary_status	varchar(20) = ''
	,@Bank_ID	VARCHAR(MAX) = '0'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   
       DECLARE @SAL_STATUS VARCHAR(32)
   SET @SAL_STATUS = @Salary_status
   
 IF @Salary_status NOT IN ('Done', 'Hold')
	set @Salary_status = NULL
    
 IF @Bank_ID =0  
	SET @Bank_ID = null  
  

 IF @Payment_mode = ''		--Ankit 30122015
	SET @Payment_mode = 'Bank Transfer'
  
 
CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )  
 
-- Added by nilesh patel on 06092014


if @Left_Emp = 1 OR @New_Join_emp > 0
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0,@Bank_ID    
else
	EXEC SP_EMP_SALARY_Constraint @Cmp_ID, @From_Date,@To_Date,0,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID	,@Desig_ID,@Emp_ID,@Salary_Cycle_id ,@Branch_ID,@Segment_ID,@Vertical_Id,@SubVertical_Id,@subBranch_Id,@Constraint	-- Changed By Gadriwala 11092013
 
		select  I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name, E.Present_Street As Street_1,E.City,E.State,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,
						CASE WHEN S.Setting_Value = 1 then   --Added By Hardik 04/02/2016
							isnull(E.Initial,'')+' '+E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'') + ' '+ isnull(E.Emp_Last_Name,'') 
						ELSE
							E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'') + ' ' + isnull(E.Emp_Last_Name,'')
						End AS Emp_Full_Name,
						
						Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
						,Dm.Dept_Name,Dgm.Desig_Name,Etm.Type_Name,Gm.Grd_Name,BM.Branch_Name,E.Date_of_Join,E.Date_Of_Birth,E.Emp_Mark_Of_Identification,E.Gender,@From_Date as From_Date ,@To_Date as To_Date
						,Cm.Cmp_Name,Cmp_Address,E.Present_Street,E.Present_State,E.Present_City,E.Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(E.Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
						Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no
						--,I_Q.Bank_ID,I_Q.Inc_Bank_AC_No
						,E.Enroll_No    --Added By Nimesh 17-07-2015 (To sort by enroll no)
						,CASE WHEN Is_Terminate = 1 THEN 'Terminated' WHEN Is_Death = 1 THEN 'Death' WHEN isnull(Is_Retire,0) = 1 THEN 'Retirement' ELSE 'Resignation'  End as Reason_Type		--Added By Ramiz on 18/08/2015
						,DGM.Desig_Dis_No        --added jimit 21082015
						,I_Q.Vertical_ID,I_Q.SubVertical_ID   --Added By Jaina 5-10-2015
						,E.Emp_First_Name   --added jimit 09022016
						,E.Initial --added by chetan 280817
						--,Reason_Name --Added By Jimit 25122018
						,salary_status
				from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Bank_ID,Inc_Bank_AC_No
							,I.Payment_Mode,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary from dbo.T0095_Increment I WITH (NOLOCK) inner join 
							(select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
						#Emp_Cons EC on E.Emp_ID = EC.Emp_ID Inner JOIN
						T0040_SETTING S WITH (NOLOCK) on E.Cmp_ID = S.Cmp_ID And S.Setting_Name='Add initial in employee full name' Inner Join  --Added Condition by Hardik 04/02/2016												
						T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id  inner join
						--T0040_Reason_Master Rm ON rm.Res_Id = l.Res_Id inner join
						T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID = EC.Emp_ID
			WHERE E.Cmp_ID = @Cmp_Id --and Emp_Left='N'
				 and not exists( select Emp_Id from T9999_Bank_Transfer_Export WITH (NOLOCK) where Emp_ID = Ec.Emp_ID and Regerate_Flag='I' and [Month] = DATENAME(MONTH, ms.Month_End_Date) and [Year]=Year(ms.Month_End_Date) )
			   	 and I_Q.Payment_Mode = (case when (@Payment_Mode = '--Select--' or @Payment_Mode = '')then I_Q.Payment_Mode
																  else @Payment_Mode END)			
				 and isnull(I_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(I_Q.Bank_ID,0))
				 --and MS.salary_status = isnull(@salary_status,ms.salary_status)
				 and Month(ms.Month_End_Date) = Month(@To_Date) and Year(ms.Month_End_Date) =Year(@To_Date) 
				AND 1 = CASE 	WHEN @SAL_STATUS IN ('Done', 'Hold', 'All') AND Net_Amount > 0
							AND ms.salary_status = isnull(@salary_status,ms.salary_status)
						THEN 1
					WHEN @SAL_STATUS = 'Negative' and Net_Amount < 0
						THEN 1
					WHEN  @SAL_STATUS = 'Zero'  and Net_Amount = 0
						THEN 1
					ELSE 0 END
				Order by 
							Case	When IsNumeric(e.Alpha_Emp_Code) = 1 then
										Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
									ELSE
										Left(e.Alpha_Emp_Code + Replicate('',21), 20)
									END										


END
