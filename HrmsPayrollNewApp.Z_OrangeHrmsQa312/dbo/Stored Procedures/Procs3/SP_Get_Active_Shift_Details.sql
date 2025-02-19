
-- =============================================
-- Author:		Nilesh Patel
-- Create date: 29-05-2019
-- Description:	Get List of Employee Shift is assigned 
---20/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Active_Shift_Details]
	@Cmp_ID Numeric,
	@Shift_ID Numeric,
	@InActive_Date DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If Object_ID('tempdb..#Emp_Cons') is not null
		Drop Table #Emp_Cons
	
	CREATE table #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )
	 
	If Object_ID('tempdb..#Emp_Shift_Details') is not null
		Drop Table #Emp_Shift_Details
	
	CREATE table #Emp_Shift_Details 
	 (      
	   Emp_ID numeric ,  
	   Shift_ID Numeric,
	   Shift_Eff_Date DateTime,
	   Shift_Type Numeric   
	 )
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID=@Cmp_ID,@From_Date=@InActive_Date,@To_Date=@InActive_Date,@Branch_ID = 0,@Cat_ID= 0,@Grd_ID= 0,@Type_ID= 0,@Dept_ID= 0,@Desig_ID= 0,@Emp_ID= 0,@constraint = ''   
		
	-- For Regular Shift Details 	
	Insert into #Emp_Shift_Details(Emp_ID,Shift_ID,Shift_Eff_Date,Shift_Type)
	Select SD.EMP_ID,SD.Shift_ID,SD.For_Date,SD.Shift_Type
	FROM T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) Inner Join #Emp_Cons EC On EC.Emp_ID = SD.Emp_ID
	Where SD.Shift_ID = @Shift_ID AND FOR_DATE > @InActive_Date
	
	--For Regular Shift Assign to Employee
	Insert into #Emp_Shift_Details(Emp_ID,Shift_ID,Shift_Eff_Date,Shift_Type)
	Select SD.EMP_ID,SD.Shift_ID,SD.For_Date,SD.Shift_Type
	FROM T0100_EMP_SHIFT_DETAIL SD  WITH (NOLOCK)
	INNER JOIN (
		SELECT	MAX(FOR_DATE) AS FORDATE,SD1.EMP_ID
			FROM	T0100_EMP_SHIFT_DETAIL SD1 WITH (NOLOCK)
			Inner Join #Emp_Cons EC On EC.Emp_ID = SD1.Emp_ID
		WHERE FOR_DATE <= @InActive_Date AND ISNULL(SHIFT_TYPE,0)=0 and Cmp_ID = @Cmp_ID
		GROUP BY  SD1.EMP_ID
	) AS QRY ON SD.EMP_ID = QRY.EMP_ID AND SD.FOR_DATE = QRY.FORDATE
	Where SD.Shift_ID = @Shift_ID AND ISNULL(SHIFT_TYPE,0)=0
	AND NOT EXISTS(SELECT 1 FROM #Emp_Shift_Details ESD WHERE ESD.EMP_ID = SD.EMP_ID)
	
	-- Commented by Hardik 22/02/2021 for Gartech Client, Redmine Id : 16843, no need to check Temp Shift, before inactive date

	--For Temp Shift Assign to Employee
	--Insert into #Emp_Shift_Details(Emp_ID,Shift_ID,Shift_Eff_Date,Shift_Type)
	--Select SD.EMP_ID,SD.Shift_ID,SD.For_Date,SD.Shift_Type
	--FROM T0100_EMP_SHIFT_DETAIL SD  WITH (NOLOCK)
	--Where SD.Shift_ID = @Shift_ID and FOR_DATE <= @InActive_Date AND ISNULL(SHIFT_TYPE,0)=1 and Cmp_ID = @Cmp_ID
	--AND NOT EXISTS(SELECT 1 FROM #Emp_Shift_Details ESD WHERE ESD.EMP_ID = SD.EMP_ID)
	
	
	if Object_ID('tempdb..#Rotation_Tran_ID') Is not null
		Drop Table #Rotation_Tran_ID
		
	Create Table #Rotation_Tran_ID
	(
		Tran_ID Numeric
	)
	
	Insert into #Rotation_Tran_ID
	SELECT	Distinct Tran_ID
	FROM	(
				SELECT *	
					FROM T0050_SHIFT_ROTATION_MASTER WITH (NOLOCK)
				Where Cmp_ID = @Cmp_ID
			) PVT
			UNPIVOT
			(
				Shift_ID For DayName IN (Day1,Day2,Day3,Day4,Day5,Day6,Day7,Day8,Day9,Day10,Day11,Day12,Day13,Day14,Day15,Day16,Day17,Day18,Day19,Day20,Day21,Day22,Day23,Day24,Day25,Day26,Day27,Day28,Day29,Day30,Day31)
			) T
	WHERE	T.Shift_ID = @Shift_ID and Cmp_ID = @Cmp_ID
	
	if Object_ID('tempdb..#Rotation_Shift') is not null
		Drop Table #Rotation_Shift
	
	Create Table #Rotation_Shift
	(
		Emp_ID Numeric,
		Effe_Date DateTime,
	)
	
	Insert into #Rotation_Shift
	Select	Emp_ID,Effective_Date 
	From	T0050_EMP_MONTHLY_SHIFT_ROTATION SR WITH (NOLOCK)
			Inner Join #Rotation_Tran_ID RT ON SR.Rotation_ID = RT.Tran_ID  					 
	Where Cmp_ID = @Cmp_ID AND EFFECTIVE_DATE > @InActive_Date
	
	Insert into #Rotation_Shift
	Select	Sr.Emp_ID,Sr.Effective_Date 
	From	T0050_EMP_MONTHLY_SHIFT_ROTATION SR WITH (NOLOCK)
			INNER JOIN (SELECT	EMP_ID, MAX(Effective_Date) As Effective_Date
						From	T0050_EMP_MONTHLY_SHIFT_ROTATION SR1 WITH (NOLOCK)
						WHERE	SR1.Effective_Date <= @InActive_Date
						Group By EMP_ID) SR1 ON SR.Emp_ID=Sr1.Emp_ID AND SR.Effective_Date=Sr1.Effective_Date
			Inner Join #Rotation_Tran_ID RT ON SR.Rotation_ID = RT.Tran_ID 				 
	Where Cmp_ID = @Cmp_ID 
	AND NOT Exists(Select 1 From #Rotation_Shift S Where S.Emp_ID = SR.Emp_ID)
	
	Insert into #Emp_Shift_Details(Emp_ID,Shift_ID,Shift_Eff_Date,Shift_Type)
	Select RS.EMP_ID,@Shift_ID,RS.Effe_Date,2
	FROM #Rotation_Shift RS
	
	
	Select Alpha_Emp_Code,Emp_Full_Name,SM.Shift_Name, Shift_Eff_Date as Effective_Date
		From #Emp_Shift_Details SD
	Inner Join T0080_Emp_Master EM WITH (NOLOCK) ON SD.Emp_ID = EM.Emp_ID 
	Inner Join T0040_Shift_MAster SM WITH (NOLOCK) ON SM.Shift_ID = SD.Shift_ID
	
END
