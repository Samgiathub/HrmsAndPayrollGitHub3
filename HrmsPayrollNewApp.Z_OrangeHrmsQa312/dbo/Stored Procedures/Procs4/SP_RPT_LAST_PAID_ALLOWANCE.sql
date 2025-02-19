
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LAST_PAID_ALLOWANCE]  
  @Cmp_ID			numeric  
 ,@From_Date		datetime  
 ,@To_Date			datetime  
 ,@Branch_ID		numeric  
 ,@Cat_ID			numeric   
 ,@Grd_ID			numeric  
 ,@Type_ID			numeric  
 ,@Dept_ID			numeric  
 ,@Desig_ID			numeric  
 ,@Emp_ID			numeric  
 ,@constraint		varchar(max)  
 ,@AD_ID			numeric
 ,@Is_Column        tinyint
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  if Object_ID('tempdb..#EmpData') is not null
	Begin
		Drop Table #EmpData
	End   
   
  CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  

   EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0 

   if Object_ID('tempdb..#Emp_Paid_Detail') is not null
		Begin
			Drop Table #Emp_Paid_Detail
		End 

	Create Table #Emp_Paid_Detail
	(
		Emp_ID Numeric,
		Alpha_Emp_Code Varchar(50),
		Emp_Full_Name Varchar(200),
		Desig_Name Varchar(100),
		Date_of_Join Varchar(11),
		Cost_Center Varchar(100),
		Last_Paid_Date Varchar(11),
		Last_Paid_Amt Numeric(18,2),
		Completed_Year Numeric(3,0)
	)

   if @Is_Column = 1
	Begin
		Select Alpha_Emp_Code as Employee_Code,Emp_Full_Name as Employee_Name,Desig_Name as Designation ,Date_of_Join as Date_of_Joining,Cost_Center as Cost_Center
		,Completed_Year as Completed_Year_of_Service,Last_Paid_Amt as Last_Paid_Amount,Last_Paid_Date From #Emp_Paid_Detail
		return
	End

   Insert into #Emp_Paid_Detail(Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Desig_Name,Date_of_Join,Cost_Center,Last_Paid_Date,Last_Paid_Amt,Completed_Year)
   Select EM.Emp_ID,Alpha_Emp_Code,Emp_Full_Name,DM.Desig_Name,IsNull(CONVERT(VARCHAR(12),EM.Date_Of_Join, 103),''),CC.Center_Name,IsNull(CONVERT(VARCHAR(12),Qry_1.For_Date, 103),''),Qry_1.M_AD_Amount,(DATEDIFF(MM,Date_Of_Join,Getdate())/12)
		From T0080_EMP_MASTER EM WITH (NOLOCK)
	 Inner Join #Emp_Cons EC ON EC.Emp_ID = EM.Emp_ID
	 Inner Join T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID
	 LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id
	 LEFT OUTER JOIN T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON CC.Center_ID = I.Center_ID
	 Left Outer JOIN(
					Select MAD.Emp_ID,MAD.For_Date,MAD.M_AD_Amount
					From T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
					Inner Join (
									Select Max(For_Date) as ForDate,Emp_ID,AD_ID 
										From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
									WHERE AD_ID = @AD_ID and For_Date <= @To_Date and Isnull(M_AD_Amount,0) <> 0 and Cmp_ID = @Cmp_ID
									Group BY Emp_ID,AD_ID
								) as Qry 
					ON MAD.For_Date = Qry.ForDate and MAD.Emp_ID = Qry.Emp_ID and MAD.AD_ID = Qry.AD_ID
				) as Qry_1
	ON EM.EMp_ID = Qry_1.Emp_ID

	
	Update EPD
		Set 
			Last_Paid_Amt = Isnull(Qry_1.Net_Amount,0),
			Last_Paid_Date = Case when Qry_1.For_Date Is Null Then '' Else CONVERT(VARCHAR(12),Qry_1.For_Date, 103) End
		From #Emp_Paid_Detail EPD
	Inner Join (
				 Select EB.For_Date,EB.Emp_ID,EB.Net_Amount,EB.Ad_Id 
					From MONTHLY_EMP_BANK_PAYMENT EB WITH (NOLOCK)
				 Inner Join(
								Select Max(For_Date) as ForDate,BP.Emp_ID,Ad_Id
									From MONTHLY_EMP_BANK_PAYMENT BP WITH (NOLOCK)
								Inner Join #Emp_Paid_Detail PD ON BP.Emp_ID = PD.Emp_ID
								Where For_Date <= @To_Date and Cmp_ID = @Cmp_ID and Ad_Id =@AD_ID and Net_Amount <> 0
								Group By BP.Emp_ID,Ad_Id
						   ) as Qry
				 ON EB.For_Date = Qry.ForDate and EB.Emp_ID = Qry.Emp_ID and EB.Ad_Id = Qry.Ad_Id
				) as Qry_1
	ON EPD.Emp_ID = Qry_1.Emp_ID 
	Where Qry_1.For_Date > EPD.Last_Paid_Date and Qry_1.Ad_Id = @AD_ID

	Select 
		Alpha_Emp_Code as Employee_Code,
		Emp_Full_Name as Employee_Name,
		Desig_Name as Designation,
		Date_of_Join as Date_of_Joining,
		Cost_Center as Cost_Center,
		Completed_Year as Completed_Year_of_Service,
		Last_Paid_Amt as Last_Paid_Amount,
		Last_Paid_Date 
	From #Emp_Paid_Detail 
	Where Isnull(Last_Paid_Amt,0) <> 0
 RETURN   
  
  
  

