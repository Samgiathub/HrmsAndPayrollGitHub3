

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Payment_Process_WORKING_21042022]
	@Bank_Flag			Numeric = 0,
	@Branch_ID			Numeric = 0,
	@Emp_ID				Numeric = 0,
	@cmp_id				Numeric = 0,
	@Month_ID			Numeric = 0,
	@Year_ID			Numeric = 0,
	@process_type		Varchar(500) = NULL,
	@process_type_id	numeric(18,0) = 0,
	@Dept_ID			numeric = 0,
	@Desig_Id			numeric = 0,
	@Grd_ID				numeric = 0,
	@Constraint			varchar(max) = '', --Added by Jaina 22-12-2017
	@Travel_Approval_Id varchar(max) = '',  --Added by Jaina 22-12-2017
	@From_Date			Datetime	=	'1900-01-01',	--Added By Ramiz on 02/10/2018
	@To_Date			Datetime	=	'1900-01-01' ,	--Added By Ramiz on 02/10/2018
	@Bond_ID			Integer = 0,						--Added By Ramiz on 02/10/2018
	@Claim_ID			Integer = 0, --Added By Mehul on 16/12/2021
	@Month				Numeric = 0,
	@Year				Numeric = 0

AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @Branch_ID = 0 
		Set @Branch_ID = NULL
	
	IF @Emp_ID = 0
		Set @Emp_ID = NULL
		
	IF @Dept_ID = 0
		SET @Dept_ID = NULL
		
	IF 	@Desig_Id = 0
		SET @Desig_Id = NULL
		
	IF	@Grd_ID = 0
		SET @Grd_ID = NULL	
			
	
	IF OBJECT_ID('tempdb..#Payment_Process') IS NOT NULL
		begin
			drop table #Payment_Process
		end
	
	--SELECT  TOP 0 Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
	--		Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
	--		cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
	--		Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
	--		IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id 
	--INTO #PAYMENT_PROCESS		
	--   From V0200_PAYMENT_PROCESS
	
	--COMMENTED ABOVE CODE AND TABLE ADDED BY RAMIZ ON 25/12/2018--
	
	CREATE TABLE #PAYMENT_PROCESS
	(
		Cmp_ID				INT,
		Emp_ID				NUMERIC,
		Alpha_Emp_Code		VARCHAR(50),
		Emp_Full_Name		VARCHAR(250),
		Month_St_Date		DATETIME,
		Month_End_Date		DATETIME,
		Bank_Name			VARCHAR(100),
		Inc_Bank_AC_No		VARCHAR(20),
		Payment_Mode		VARCHAR(20),
		Bank_ID_Two			NUMERIC,
		Payment_Mode_Two	VARCHAR(20),
		Inc_Bank_AC_No_Two	VARCHAR(20),
		cmp_bank_ac_no		VARCHAR(20),
		Cmp_bank_name		VARCHAR(100),
		Cmp_bank_id			INT,
		Net_Amount			NUMERIC(18,2),
		Branch_ID			INT,
		Dept_ID				INT,
		Cat_ID				INT,
		Type_ID				INT,
		Desig_Id			INT,
		Emp_Left			CHAR(1),
		Bank_ID				INT,
		IT_M_ED_Cess_Amount	NUMERIC(18,2),
		Salary_Status		VARCHAR(10),
		process_Type		VARCHAR(100),
		Ad_Id				INT,
		BOND_APR_ID			NUMERIC,
		Claim_APR_ID		NUMERIC,
		Claim_ID			NUMERIC,
		Claim_Name			VARCHAR(100)
	)
	

	if @process_type_id > 9000
			BEGIN
				if @process_type = 'Salary'
					Begin 
						Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
						Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
						cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
						Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
						IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id)
						SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.Month_St_Date, MS.Month_End_Date, BM.Bank_Name, 
								  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,
									  (SELECT     Bank_Ac_No
										FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,
									  (SELECT     Bank_Name
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,
									  (SELECT     Bank_ID
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, MS.Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID, 
								  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID, 
								  MS.IT_M_ED_Cess_Amount, MS.Salary_Status
								   ,'Salary' as process_Type
								  ,0 as Ad_Id 
								  --,INC.Vertical_ID,INC.SubVertical_ID   --Added By Jaina 30-09-2015
						FROM         dbo.T0200_MONTHLY_SALARY AS MS WITH (NOLOCK) INNER JOIN
								  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID  and isnull(ms.Is_FNF,0) = 0 INNER JOIN
								  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN
									  --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID
									  --  FROM          dbo.T0095_INCREMENT
									  --  WHERE      (Increment_Effective_Date <= GETDATE())
									  --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date 
									  (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK) 
									Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
									Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id
										LEFT OUTER JOIN
								  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID 
							ORDER BY EM.Emp_code

					End
				if @process_type = 'Full and Final'
					Begin 
						Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
						Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
						cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
						Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
						IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
						SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.Month_St_Date, MS.Month_End_Date, BM.Bank_Name, 
								  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,
									  (SELECT     Bank_Ac_No
										FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,
									  (SELECT     Bank_Name
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,
									  (SELECT     Bank_ID
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, MS.Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID, 
								  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID, 
								  MS.IT_M_ED_Cess_Amount, MS.Salary_Status
								   ,'Full and Final' as process_Type
								  ,0 as Ad_Id 
           				FROM         dbo.T0200_MONTHLY_SALARY AS MS WITH (NOLOCK) INNER JOIN
								  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID and isnull(ms.Is_FNF,0) = 1 INNER JOIN
								  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN
									  (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
									Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id
										LEFT OUTER JOIN
								  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID 
							ORDER BY EM.Emp_code

					End		
				if @process_type = 'Bonus'
					Begin 
						Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
						Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
						cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
						Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
						IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
						SELECT  TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, 
								dbo.GET_MONTH_END_DATE(ms.Bonus_effect_month,ms.bonus_effect_year) as Month_St_Date, 
								dbo.GET_MONTH_END_DATE(ms.Bonus_effect_month,ms.bonus_effect_year) as Month_End_Date, BM.Bank_Name, 
								INC.Inc_Bank_AC_No, INC.Payment_Mode, INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,
								(
									SELECT     Bank_Ac_No 
									FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)
								) AS cmp_bank_ac_no,
								(	
									SELECT     Bank_Name
									FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)
								) AS Cmp_bank_name,
								(
									SELECT     Bank_ID
									FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)
								) AS Cmp_bank_id, MS.Net_Payable_Bonus as net_amount, 
								INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID, 
								ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, 
								ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID, 
								0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status,
								'Bonus' as process_Type,0 as Ad_id 
						FROM  dbo.T0180_BONUS AS MS WITH (NOLOCK) INNER JOIN
							  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN
							  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN
								  (
									select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
									from t0095_increment TI WITH (NOLOCK) inner join
									 (
										SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE,EMP_ID 
										FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE INCREMENT_EFFECTIVE_DATE <= GETDATE() GROUP BY EMP_ID
									  ) new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
									Where TI.Increment_effective_Date <= GETDATE() 
									group by ti.emp_id
								   ) Qry on INC.Increment_Id = Qry.Increment_Id LEFT OUTER JOIN
							  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID
						 WHERE isnull(ms.Bonus_Effect_on_Sal,0) <> 1
						 Union ALL
						 SELECT  TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, 
								dbo.GET_MONTH_END_DATE(ms.Bonus_effect_month,ms.bonus_effect_year) as Month_St_Date, 
								dbo.GET_MONTH_END_DATE(ms.Bonus_effect_month,ms.bonus_effect_year) as Month_End_Date, BM.Bank_Name, 
								INC.Inc_Bank_AC_No, INC.Payment_Mode, INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,
								(
									SELECT     Bank_Ac_No
									FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)
								) AS cmp_bank_ac_no,
								(	
									SELECT     Bank_Name
									FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)
								) AS Cmp_bank_name,
								(
									SELECT     Bank_ID
									FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)
								) AS Cmp_bank_id, MS.Total_Bonus_Amount as net_amount, 
								INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID, 
								ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, 
								ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID, 
								0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status,
								'Bonus' as process_Type,0 as Ad_id 
						FROM  dbo.T0100_Bonus_Slabwise AS MS WITH (NOLOCK)  INNER JOIN
							  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN
							  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN
								  (
									select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
									from t0095_increment TI WITH (NOLOCK) inner join
									 (
										SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE,EMP_ID 
										FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE INCREMENT_EFFECTIVE_DATE <= GETDATE() GROUP BY EMP_ID
									  ) new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
									Where TI.Increment_effective_Date <= GETDATE() 
									group by ti.emp_id
								   ) Qry on INC.Increment_Id = Qry.Increment_Id LEFT OUTER JOIN
							  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID
						 WHERE isnull(ms.Bonus_Effect_on_Sal,0) <> 1
						 --ORDER BY EM.Emp_code
						 
						 
					End 
				if @process_type = 'Leave Encashment'
					Begin
						Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
						Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
						cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
						Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
						IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
						SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.Lv_Encash_Apr_Date as  Month_St_Date, MS.Lv_Encash_Apr_Date  as Month_End_Date, BM.Bank_Name,   
								  INC.Inc_Bank_AC_No, INC.Payment_Mode, INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									  (SELECT     Bank_Ac_No  
										FROM          dbo.T0040_BANK_MASTER   WITH (NOLOCK) 
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
									  (SELECT     Bank_Name  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
									  (SELECT     Bank_ID  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, MS.Leave_Encash_Amount as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
								  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
								  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
								  ,'Leave Encashment' as process_Type  
								  ,0 as Ad_Id  
								FROM         dbo.T0120_LEAVE_ENCASH_APPROVAL AS MS WITH (NOLOCK) INNER JOIN  
								  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
								  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
									  --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
									  --  FROM          dbo.T0095_INCREMENT  
									  --  WHERE      (Increment_Effective_Date <= GETDATE())  
									  --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
													  (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
								  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment   WITH (NOLOCK)
								  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
								  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
								  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
							                              
								 LEFT OUTER JOIN  
												  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID  
								where isnull(Ms.Eff_In_Salary,0) =0				  
							ORDER BY EM.Emp_code  
					End
				If @process_type = 'Advance'
					BEGIN
						Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
						Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
						cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
						Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
						IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
						SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_Date as  Month_St_Date, MS.For_Date as  Month_End_Date, BM.Bank_Name,   
							  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
								  (SELECT     Bank_Ac_No  
									FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
								  (SELECT     Bank_Name  
									FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
								  (SELECT     Bank_ID  
									FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, MS.Adv_Amount as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
							  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
							  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
							  ,'Advance' as process_Type  
							  ,0 as Ad_Id  
								FROM         dbo.T0100_ADVANCE_PAYMENT AS MS WITH (NOLOCK) INNER JOIN  
													  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
													  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
														  --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
														  --  FROM          dbo.T0095_INCREMENT  
														  --  WHERE      (Increment_Effective_Date <= GETDATE())  
														  --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
															(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
									  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK) 
									  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
									  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
									  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
								        
															LEFT OUTER JOIN  
													  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID  
								ORDER BY EM.Emp_code  
					End
				if @process_type = 'Travel Amount'	-- Added by rohit on 13012016 for travel Amount
					Begin 
						Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
						Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
						cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
						Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
						IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
						SELECT     TOP (100) PERCENT Em.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, dbo.GET_MONTH_END_DATE(ms.month_id,ms.year_id) as Month_St_Date, dbo.GET_MONTH_END_DATE(ms.month_id,ms.year_id) as Month_End_Date , BM.Bank_Name, 
								  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,
									  (SELECT     Bank_Ac_No
										FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS cmp_bank_ac_no,
									  (SELECT     Bank_Name
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS Cmp_bank_name,
									  (SELECT     Bank_ID
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS Cmp_bank_id, (ms.Adjust_Amount) as Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID, 
								  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID, 
								  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status
								   ,'Travel Amount' as process_Type
								  ,0 as Ad_Id 
								FROM 
								(
									select emp_id ,sum(adjust_amount) as adjust_amount  ,MONTH(Approval_date) as month_id, YEAR(Approval_date) as year_id 
									from  dbo.T0150_Travel_Settlement_Approval ts WITH (NOLOCK)
									where Travel_Amt_In_Salary = 0 and adjust_amount > 0
									and is_apr=1
									AND EXISTS (select Data from dbo.Split(@Travel_Approval_Id, ',') T Where cast(T.data as numeric)=Isnull(Ts.Travel_Set_Application_id,0))  --Added by Jaina 22-12-2017
									AND EXISTS (select Data from dbo.Split(@Constraint, ',') T Where cast(T.data as numeric)=Isnull(TS.EMP_ID,0)) --Added by Jaina 22-12-2017
									group by emp_id,MONTH(Approval_date) ,YEAR(Approval_date)
									
								)
									AS MS INNER JOIN
									dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN
									dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN
									(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
									Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id
										LEFT OUTER JOIN
								  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID 
			                      
							ORDER BY EM.Emp_code
							
							
						End		
				if @process_type = 'Travel Advance Amount'		---Added by Sumit on 27072016--Travel Advance Amount ---------------------------------
						Begin					 
							Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
								Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
								cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
								Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
								IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
								
								SELECT     TOP (100) PERCENT Em.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, dbo.GET_MONTH_END_DATE(ms.month_id,ms.year_id) as Month_St_Date, dbo.GET_MONTH_END_DATE(ms.month_id,ms.year_id) as Month_End_Date , BM.Bank_Name, 
										  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,
											  (SELECT     Bank_Ac_No 
												FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
												WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS cmp_bank_ac_no,
											  (SELECT     Bank_Name
												FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
												WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS Cmp_bank_name,
											  (SELECT     Bank_ID
												FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
												WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS Cmp_bank_id, (ms.Advance_amount) as Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID, 
										  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID, 
										  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status
										   ,'Travel Advance Amount' as process_Type
										  ,0 as Ad_Id 
										FROM 
										(
											select emp_id ,sum(Amount) as Advance_amount  ,MONTH(Approval_date) as month_id, YEAR(Approval_date) as year_id 
											from  dbo.T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) inner join T0130_TRAVEL_APPROVAL_ADVDETAIL TAD WITH (NOLOCK)
												on TA.Travel_Approval_ID=TAD.Travel_Approval_ID and TA.Cmp_ID=TAD.Cmp_ID
											 where TAD.Amount > 0 and LTRIM(RTRIM(isnull(TA.Approved_Account_Advance_desk,'P')))='A'
											 AND EXISTS (select Data from dbo.Split(@Travel_Approval_Id, ',') T Where cast(T.data as numeric)=Isnull(TAD.Travel_Approval_ID,0))  --Added by Jaina 22-12-2017
											 AND EXISTS (select Data from dbo.Split(@Constraint, ',') T Where cast(T.data as numeric)=Isnull(TA.EMP_ID,0)) --Added by Jaina 22-12-2017
											 group by TA.Emp_ID--,TA.Travel_Approval_ID
											 ,MONTH(TA.Approval_Date) ,YEAR(TA.Approval_Date)
										 )
										 AS MS INNER JOIN
										  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN
										  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN
											  (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
											(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
											Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc
											on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
											Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id
												LEFT OUTER JOIN
										  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID 
					                      
									ORDER BY EM.Emp_code
									
									
						END
				if @process_type = 'Salary Settlement'
						Begin
							Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
								Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
								cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
								Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
								IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
								SELECT     TOP (100) PERCENT Em.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, dbo.GET_MONTH_END_DATE(ms.month_id,ms.year_id) as Month_St_Date, dbo.GET_MONTH_END_DATE(ms.month_id,ms.year_id) as Month_End_Date , BM.Bank_Name, 
										  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,
											  (SELECT     Bank_Ac_No
												FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
												WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS cmp_bank_ac_no,
											  (SELECT     Bank_Name
												FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
												WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS Cmp_bank_name,
											  (SELECT     Bank_ID 
												FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
												WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS Cmp_bank_id, (ms.Net_Amount) as Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID, 
										  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID, 
										  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status
										   ,'Salary Settlement' as process_Type
										  ,0 as Ad_Id 
										FROM 
										(
											 Select Emp_ID,Sum(S_Net_Amount) as Net_Amount,MONTH(S_Eff_Date) as month_id, YEAR(S_Eff_Date) as year_id
											 From T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
											 Where isnull(Effect_On_Salary,0) = 0
											 Group By Emp_ID,MONTH(S_Eff_Date),YEAR(S_Eff_Date)
										 )
										 AS MS INNER JOIN
										  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN
										  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN
											  (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
											(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
											Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc
											on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
											Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id
												LEFT OUTER JOIN
										  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID 
					                      
									ORDER BY EM.Emp_code
						END
				if @process_type = 'Incentive'		---- Added by Rajput 26072017 For Incentive
						BEGIN	
								INSERT INTO #PAYMENT_PROCESS(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
								Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
								cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
								Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
								IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id)
								
								SELECT     TOP (100) PERCENT Em.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, 
								dbo.GET_MONTH_END_DATE(ms.month_id,ms.year_id) as Month_St_Date, dbo.GET_MONTH_END_DATE(ms.month_id,ms.year_id) as Month_End_Date , BM.Bank_Name, 
								INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,
								(	SELECT     Bank_Ac_No FROM  dbo.T0040_BANK_MASTER WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS cmp_bank_ac_no,
								
								(	SELECT     Bank_Name FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS Cmp_bank_name,
									
								(	SELECT     Bank_ID		FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = Em.Cmp_ID)) AS Cmp_bank_id, 
									
								(ms.INCENTIVE_AMOUNT) as Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID, 
								 ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id,
								 EM.Emp_Left, INC.Bank_ID, 0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status,'Incentive' as process_Type
								 ,0 as Ad_Id 
										FROM 
										(
											 
											SELECT  INCP.EMP_ID,SUM(INCP.INCENTIVE_AMT + INCP.ADDITIONAL_AMT) AS INCENTIVE_AMOUNT,
											MONTH(INCP.FOR_DATE) AS MONTH_ID,YEAR(FOR_DATE) AS YEAR_ID
											FROM DBO.T0220_INCENTIVE_PROCESS INCP WITH (NOLOCK) WHERE INCP.INCENTIVE_AMT > 0 AND INCP.STATUS='P'
											GROUP BY INCP.EMP_ID,MONTH(INCP.FOR_DATE),YEAR(FOR_DATE)
											 
										 )
										  AS MS 
										  INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID
										  INNER JOIN dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID 
										  INNER JOIN (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK)
										  INNER JOIN (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
										  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc
										  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
										  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id
										  LEFT OUTER JOIN
										  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID 
					                      
								ORDER BY EM.Emp_code
						END
			if @process_type = 'Bond'			--Added By Ramiz on 01/12/2018--
						BEGIN
							INSERT INTO #PAYMENT_PROCESS
								(	Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
									cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
									IT_M_ED_Cess_Amount,Salary_Status,process_Type , Ad_Id , BOND_APR_ID
								)
							SELECT	BA.Cmp_ID, BA.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, @From_Date as  Month_St_Date, @To_Date as  Month_End_Date, BM.Bank_Name,   
									INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									(SELECT     Bank_Ac_No FROM dbo.T0040_BANK_MASTER WITH (NOLOCK)  WHERE (Is_Default = 'Y') AND (Cmp_Id = BA.Cmp_ID)) AS cmp_bank_ac_no,  
									(SELECT     Bank_Name  FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  WHERE      (Is_Default = 'Y') AND (Cmp_Id = BA.Cmp_ID)) AS Cmp_bank_name,  
									(SELECT     Bank_ID	 FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1	WITH (NOLOCK) WHERE      (Is_Default = 'Y') AND (Cmp_Id = BA.Cmp_ID)) AS Cmp_bank_id, 
									BA.Bond_Apr_Amount as Net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id,
									EM.Emp_Left, INC.Bank_ID, 0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  ,@process_type as process_Type , 0 , Bond_Apr_Id
							FROM    dbo.T0120_BOND_APPROVAL AS BA  WITH (NOLOCK)
									INNER JOIN  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON BA.Emp_ID = EM.Emp_ID
									INNER JOIN  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON BA.Emp_ID = INC.Emp_ID
									INNER JOIN  (SELECT MAX(TI.Increment_ID) Increment_Id,TI.Emp_ID 
												 FROM T0095_INCREMENT TI  WITH (NOLOCK)
												 INNER JOIN  
													  (	SELECT MAX(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
														FROM T0095_Increment  WITH (NOLOCK)
														WHERE Increment_effective_Date <= GETDATE() 
														GROUP BY emp_ID
													  ) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date = new_inc.Increment_Effective_Date  
													  WHERE TI.Increment_effective_Date <= GETDATE() 
													  GROUP BY ti.emp_id
												 ) Qry on INC.Increment_Id = Qry.Increment_Id  
									LEFT OUTER JOIN  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID
							WHERE Bond_Return_Mode = 'P' AND Bond_Apr_Pending_Amount = 0 and Bond_Id = @Bond_ID	--and Bond_Return_Status <> 'Yes' --BOND AMOUNT TO BE RETURNED TO EMPLOYEE IF THE POENDING AMOUNT IN THAT DURATION IS 0
								--AND (Bond_Return_Month BETWEEN MONTH(@FROM_DATE) AND MONTH(@TO_DATE))
								--AND (Bond_Return_Year BETWEEN YEAR(@FROM_DATE) AND YEAR(@TO_DATE))
								And Bond_Return_Month = @Month
								And Bond_Return_Year = @Year
							ORDER BY EM.Emp_code 
								
						END

				
			if @process_type = 'Claim'			--Added By Mehul on 16/12/2021--
			begin
			
				if isnull(@Emp_ID,0) = 0 and isnull(@Claim_ID,0) = 0
				BEGIN
				SELECT 1
				INSERT INTO #PAYMENT_PROCESS
								(	Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
									cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
									IT_M_ED_Cess_Amount,Salary_Status,process_Type , Claim_APR_ID,Claim_ID,Claim_Name
								)
							SELECT	CAD.Cmp_ID, CAD.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, @From_Date as  Month_St_Date, @To_Date as  Month_End_Date, BM.Bank_Name,   
									INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									(SELECT     Bank_Ac_No FROM dbo.T0040_BANK_MASTER WITH (NOLOCK)  WHERE (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS cmp_bank_ac_no,  
									(SELECT     Bank_Name  FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  WHERE      (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS Cmp_bank_name,  
									(SELECT     Bank_ID	 FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1	WITH (NOLOCK) WHERE      (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS Cmp_bank_id, 
									cad.Claim_Apr_Amount as Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id,
									EM.Emp_Left, INC.Bank_ID, 0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  ,@process_type as process_Type , cad.Claim_Apr_ID as Claim_APR_ID ,Cm.Claim_ID as Claim_ID, cm.Claim_Name as Claim_Name
							FROM    dbo.T0130_CLAIM_APPROVAL_DETAIL AS CAD  WITH (NOLOCK)
									INNER JOIN  dbo.T0040_CLAIM_MASTER AS CM WITH (NOLOCK) ON CAD.Claim_ID = CM.Claim_ID
									INNER JOIN  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON CAD.Emp_ID = EM.Emp_ID
									INNER JOIN  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON CAD.Emp_ID = INC.Emp_ID
									INNER JOIN  (SELECT MAX(TI.Increment_ID) Increment_Id,TI.Emp_ID 
												 FROM T0095_INCREMENT TI  WITH (NOLOCK)
												 INNER JOIN  
													  (	SELECT MAX(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
														FROM T0095_Increment  WITH (NOLOCK)
														WHERE Increment_effective_Date <= GETDATE() 
														GROUP BY emp_ID
													  ) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date = new_inc.Increment_Effective_Date  
													  WHERE TI.Increment_effective_Date <= GETDATE() 
													  GROUP BY ti.emp_id
												 ) Qry on INC.Increment_Id = Qry.Increment_Id  
									LEFT OUTER JOIN  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID
							WHERE  cad.Cmp_ID = @cmp_id and cad.Claim_Status = 'A' and cm.Claim_Apr_Deduct_From_Sal = 0 and cad.Payment_Process_ID is null 
							and cad.Claim_Apr_Date between @From_Date and @To_Date
							ORDER BY EM.Emp_code 
				END

				
				else if isnull(@Claim_ID,0) = 0 and isnull(@Emp_ID,0) > 0
				BEGIN
				INSERT INTO #PAYMENT_PROCESS
								(	Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
									cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
									IT_M_ED_Cess_Amount,Salary_Status,process_Type , Claim_APR_ID,Claim_ID,Claim_Name
								)
							SELECT	CAD.Cmp_ID, CAD.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, @From_Date as  Month_St_Date, @To_Date as  Month_End_Date, BM.Bank_Name,   
									INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									(SELECT     Bank_Ac_No FROM dbo.T0040_BANK_MASTER WITH (NOLOCK)  WHERE (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS cmp_bank_ac_no,  
									(SELECT     Bank_Name  FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  WHERE      (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS Cmp_bank_name,  
									(SELECT     Bank_ID	 FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1	WITH (NOLOCK) WHERE      (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS Cmp_bank_id, 
									cad.Claim_Apr_Amount as Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id,
									EM.Emp_Left, INC.Bank_ID, 0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  ,@process_type as process_Type , cad.Claim_Apr_ID as Claim_APR_ID ,Cm.Claim_ID as Claim_ID, cm.Claim_Name as Claim_Name
							FROM    dbo.T0130_CLAIM_APPROVAL_DETAIL AS CAD  WITH (NOLOCK)
									INNER JOIN  dbo.T0040_CLAIM_MASTER AS CM WITH (NOLOCK) ON CAD.Claim_ID = CM.Claim_ID
									INNER JOIN  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON CAD.Emp_ID = EM.Emp_ID
									INNER JOIN  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON CAD.Emp_ID = INC.Emp_ID
									INNER JOIN  (SELECT MAX(TI.Increment_ID) Increment_Id,TI.Emp_ID 
												 FROM T0095_INCREMENT TI  WITH (NOLOCK)
												 INNER JOIN  
													  (	SELECT MAX(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
														FROM T0095_Increment  WITH (NOLOCK)
														WHERE Increment_effective_Date <= GETDATE() 
														GROUP BY emp_ID
													  ) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date = new_inc.Increment_Effective_Date  
													  WHERE TI.Increment_effective_Date <= GETDATE() 
													  GROUP BY ti.emp_id
												 ) Qry on INC.Increment_Id = Qry.Increment_Id  
									LEFT OUTER JOIN  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID
							WHERE cad.emp_id=@emp_id and cad.Cmp_ID = @cmp_id and cad.Claim_Status = 'A' and cm.Claim_Apr_Deduct_From_Sal = 0 
							and cad.Payment_Process_ID is null 
							and cad.Claim_Apr_Date between @From_Date and @To_Date
							ORDER BY EM.Emp_code 
				END
			


				else if isnull(@Emp_ID,0) > 0 and isnull(@Claim_ID,0) > 0 
				begin
				INSERT INTO #PAYMENT_PROCESS
								(	Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
									cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
									IT_M_ED_Cess_Amount,Salary_Status,process_Type , Claim_APR_ID,Cm.Claim_ID,Claim_Name
								)
							SELECT	CAD.Cmp_ID, CAD.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, @From_Date as  Month_St_Date, @To_Date as  Month_End_Date, BM.Bank_Name,   
									INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									(SELECT     Bank_Ac_No FROM dbo.T0040_BANK_MASTER WITH (NOLOCK)  WHERE (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS cmp_bank_ac_no,  
									(SELECT     Bank_Name  FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  WHERE      (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS Cmp_bank_name,  
									(SELECT     Bank_ID	 FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1	WITH (NOLOCK) WHERE      (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS Cmp_bank_id, 
									cad.Claim_Apr_Amount as Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id,
									EM.Emp_Left, INC.Bank_ID, 0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  ,@process_type as process_Type , cad.Claim_Apr_ID as Claim_APR_ID,Cm.Claim_ID as Claim_ID , cm.Claim_Name as Claim_Name
							FROM    dbo.T0130_CLAIM_APPROVAL_DETAIL AS CAD  WITH (NOLOCK)
									INNER JOIN  dbo.T0040_CLAIM_MASTER AS CM WITH (NOLOCK) ON CAD.Claim_ID = CM.Claim_ID
									INNER JOIN  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON CAD.Emp_ID = EM.Emp_ID
									INNER JOIN  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON CAD.Emp_ID = INC.Emp_ID
									INNER JOIN  (SELECT MAX(TI.Increment_ID) Increment_Id,TI.Emp_ID 
												 FROM T0095_INCREMENT TI  WITH (NOLOCK)
												 INNER JOIN  
													  (	SELECT MAX(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
														FROM T0095_Increment  WITH (NOLOCK)
														WHERE Increment_effective_Date <= GETDATE() 
														GROUP BY emp_ID
													  ) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date = new_inc.Increment_Effective_Date  
													  WHERE TI.Increment_effective_Date <= GETDATE() 
													  GROUP BY ti.emp_id
												 ) Qry on INC.Increment_Id = Qry.Increment_Id  
									LEFT OUTER JOIN  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID
							WHERE cad.Claim_ID = @Claim_ID and cad.Emp_ID = @Emp_ID and cad.Cmp_ID = @cmp_id and cad.Claim_Status = 'A' 
							and cm.Claim_Apr_Deduct_From_Sal = 0 and cad.Payment_Process_ID is null 
							and cad.Claim_Apr_Date between @From_Date and @To_Date
							ORDER BY EM.Emp_code 
				end

			
				
				else if isnull(@Emp_ID,0) = 0  and isnull(@Claim_ID,0) > 0 
				Begin
				INSERT INTO #PAYMENT_PROCESS
								(	Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
									cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
									IT_M_ED_Cess_Amount,Salary_Status,process_Type, Claim_APR_ID,Cm.Claim_ID,Claim_Name
								)
							SELECT	CAD.Cmp_ID, CAD.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, @From_Date as  Month_St_Date, @To_Date as  Month_End_Date, BM.Bank_Name,   
									INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									(SELECT     Bank_Ac_No FROM dbo.T0040_BANK_MASTER WITH (NOLOCK)  WHERE (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS cmp_bank_ac_no,  
									(SELECT     Bank_Name  FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  WHERE      (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS Cmp_bank_name,  
									(SELECT     Bank_ID	 FROM dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1	WITH (NOLOCK) WHERE      (Is_Default = 'Y') AND (Cmp_Id = CAD.Cmp_ID)) AS Cmp_bank_id, 
									cad.Claim_Apr_Amount as Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id,
									EM.Emp_Left, INC.Bank_ID, 0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  ,@process_type as process_Type , cad.Claim_Apr_ID as Claim_APR_ID,Cm.Claim_ID as Claim_ID , cm.Claim_Name as Claim_Name
							FROM    dbo.T0130_CLAIM_APPROVAL_DETAIL AS CAD  WITH (NOLOCK)
									INNER JOIN  dbo.T0040_CLAIM_MASTER AS CM WITH (NOLOCK) ON CAD.Claim_ID = CM.Claim_ID
									INNER JOIN  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON CAD.Emp_ID = EM.Emp_ID
									INNER JOIN  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON CAD.Emp_ID = INC.Emp_ID
									INNER JOIN  (SELECT MAX(TI.Increment_ID) Increment_Id,TI.Emp_ID 
												 FROM T0095_INCREMENT TI  WITH (NOLOCK)
												 INNER JOIN  
													  (	SELECT MAX(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
														FROM T0095_Increment  WITH (NOLOCK)
														WHERE Increment_effective_Date <= GETDATE() 
														GROUP BY emp_ID
													  ) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date = new_inc.Increment_Effective_Date  
													  WHERE TI.Increment_effective_Date <= GETDATE() 
													  GROUP BY ti.emp_id
												 ) Qry on INC.Increment_Id = Qry.Increment_Id  
									LEFT OUTER JOIN  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID
							WHERE cad.Claim_ID = @Claim_ID and cad.Cmp_ID = @cmp_id and cad.Claim_Status = 'A' and cm.Claim_Apr_Deduct_From_Sal = 0 
							and cad.Payment_Process_ID is null 
							and cad.Claim_Apr_Date between @From_Date and @To_Date
							ORDER BY EM.Emp_code 
				End
			
			 end

			If (@process_type not in ('Advance','Salary','Bonus','Leave Encashment','Travel Amount','Travel Advance Amount','Salary Settlement' , 'Bond','Claim')) --<> 'Advance' and @process_type <> 'Salary' and @process_type <> 'Bonus' and @process_type <> 'Leave Encashment' and @process_type <> 'Travel Amount' and @process_type <> 'Travel Advance Amount'
			Begin
							Declare @AD_ID Numeric
							Set @AD_ID = 0
							
							Select @AD_ID = AD_ID From T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = @cmp_id and AD_NAME = @process_type
							if @AD_ID > 0
								Begin
								  Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
									Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
									cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
									Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
									IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
								  SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_date as Month_St_Date, MS.To_date as Month_End_Date,   
									BM.Bank_Name,   
								  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									  (SELECT     Bank_Ac_No  
										FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
									  (SELECT     Bank_Name  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
									  (SELECT     Bank_ID  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.M_AD_Amount,0) + isnull(ms.M_AREAR_AMOUNT,0) + isnull(MS.M_AREAR_AMOUNT_Cutoff,0)) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
								  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
								  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
								  ,AM.ad_name as process_Type  
								  ,Am.AD_ID  
									FROM         dbo.T0210_MONTHLY_AD_DETAIL AS MS WITH (NOLOCK) INNER JOIN  
														  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
														  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
															  --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
															  --  FROM          dbo.T0095_INCREMENT  
															  --  WHERE      (Increment_Effective_Date <= GETDATE())  
															  --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
																(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
										  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment  WITH (NOLOCK)
										  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
										  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
										  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
									        
																LEFT OUTER JOIN  
														  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID  
														  inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and isnull(Ad_Effect_on_Esic,0) <> 1 and isnull(Auto_Ded_TDS,0) <> 1   and ISNULL(Allowance_Type ,'A') ='A' and isnull(AM.Hide_In_Reports,0) <> 1
									Where MS.AD_ID = @AD_ID
									
									--ORDER BY EM.Emp_code
									
									union all

									SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_date as Month_St_Date, MS.For_Date  as Month_End_Date, BM.Bank_Name,   
														  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
															  (SELECT     Bank_Ac_No  
																FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK)
																WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
															  (SELECT     Bank_Name  
																FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
																WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
															  (SELECT     Bank_ID  
																FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
																WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.Net_Amount ,0)) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
														  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
														  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
														  ,AM.ad_name as process_Type  
														  ,Am.AD_ID  
									FROM         T0210_ESIC_On_Not_Effect_on_Salary AS MS WITH (NOLOCK) INNER JOIN  
														  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
														  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
															  --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
															  --  FROM          dbo.T0095_INCREMENT  
															  --  WHERE      (Increment_Effective_Date <= GETDATE())  
															  --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
									                              
															(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
										  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK) 
										  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
										  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
										  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
									        
										  LEFT OUTER JOIN  
														  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID  
														  inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and (isnull(Ad_Effect_on_Esic,0) = 1  or isnull(Auto_Ded_TDS,0) = 1 OR ISNULL(AM.Hide_In_Reports,0)=1 ) and ISNULL(Allowance_Type ,'A') ='A'
									Where MS.AD_ID = @AD_ID
									                       
									--ORDER BY EM.Emp_code  
									
									--union all  -- commented by rohit for record showing twice while auto deduct tds and hide in report on 23012017

									--SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_date as Month_St_Date, MS.For_Date  as Month_End_Date, BM.Bank_Name,   
									--					  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									--						  (SELECT     Bank_Ac_No  
									--							FROM          dbo.T0040_BANK_MASTER  
									--							WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
									--						  (SELECT     Bank_Name  
									--							FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  
									--							WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
									--						  (SELECT     Bank_ID  
									--							FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  
									--							WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.Net_Amount ,0)) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
									--					  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
									--					  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
									--					  ,AM.ad_name as process_Type  
									--					  ,Am.AD_ID  
									--FROM         T0210_ESIC_On_Not_Effect_on_Salary AS MS INNER JOIN  
									--					  dbo.T0080_EMP_MASTER AS EM ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
									--					  dbo.T0095_INCREMENT AS INC ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
									--						  --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
									--						  --  FROM          dbo.T0095_INCREMENT  
									--						  --  WHERE      (Increment_Effective_Date <= GETDATE())  
									--						  --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
									                              
									--						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI inner join  
									--	  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment  
									--	  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
									--	  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
									--	  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
									        
									--	  LEFT OUTER JOIN  
									--					  dbo.T0040_BANK_MASTER AS BM ON INC.Bank_ID = BM.Bank_ID  
									--					  inner join T0050_AD_MASTER AM on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and ISNULL(AM.Hide_In_Reports,0)=1  and ISNULL(Allowance_Type ,'A') ='A'
									--Where MS.AD_ID = @AD_ID
									
									union ALL
									
									SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_date as Month_St_Date, MS.For_Date  as Month_End_Date, BM.Bank_Name,   
									INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									  (SELECT     Bank_Ac_No  
										FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
									  (SELECT     Bank_Name  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
									  (SELECT     Bank_ID  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.Net_Amount ,0)) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
								  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
								  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
								  ,AM.ad_name as process_Type  
								  ,Am.AD_ID  
									FROM         dbo.T0210_Emp_Seniority_Detail AS MS WITH (NOLOCK) INNER JOIN  
														  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
														  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
															  --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
															  --  FROM          dbo.T0095_INCREMENT  
															  --  WHERE      (Increment_Effective_Date <= GETDATE())  
															  --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
																(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
										  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK) 
										  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
										  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
										  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
									                              
																LEFT OUTER JOIN  
														  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID  
														  inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and ISNULL(Allowance_Type ,'A') ='A' and ISNULL(AM.Hide_In_Reports,0) = 0
										 Where MS.Ad_id = @AD_ID
										 
									union all
									
									 SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_date as Month_St_Date, MS.For_Date as Month_End_Date,   
									BM.Bank_Name,   
								  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									  (SELECT     Bank_Ac_No  
										FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
									  (SELECT     Bank_Name  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
									  (SELECT     Bank_ID  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.Amount,0) ) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
								  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
								  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
								  ,AM.ad_name as process_Type  
								  ,Am.AD_ID  
									FROM         dbo.T0190_MONTHLY_AD_DETAIL_IMPORT AS MS WITH (NOLOCK) INNER JOIN  
														  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
														  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
															  --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
															  --  FROM          dbo.T0095_INCREMENT  
															  --  WHERE      (Increment_Effective_Date <= GETDATE())  
															  --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
																(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
										  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK) 
										  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
										  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
										  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
									        
																LEFT OUTER JOIN  
														  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID  
														  inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and isnull(Ad_Effect_on_Esic,0) <> 1 and isnull(Auto_Ded_TDS,0) <> 1  and isnull(Is_Calculated_On_Imported_Value,0) = 1 and ISNULL(Allowance_Type ,'A') ='A'
									Where MS.AD_ID = @AD_ID	
									
									union all
									
										 SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.payment_date as Month_St_Date, MS.Payment_date  as Month_End_Date, BM.Bank_Name,   
										INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
									  (SELECT     Bank_Ac_No  
										FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
									  (SELECT     Bank_Name  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
									  (SELECT     Bank_ID  
										FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK)
										WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.Apr_Amount,0) + isnull(ms.Taxable_Exemption_Amount,0)) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
								  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
								  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
								  ,AM.ad_name as process_Type  
								  ,Am.AD_ID  
									FROM         dbo.T0120_RC_Approval AS MS WITH (NOLOCK) INNER JOIN  
														  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
														  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
														 (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
										  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment   WITH (NOLOCK)
										  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
										  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
										  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
											LEFT OUTER JOIN  
														  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID  
														  inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.RC_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and ISNULL(Allowance_Type ,'A') ='R'
										 Where MS.Rc_id = @AD_ID and ms.RC_Apr_Effect_In_Salary =0 and ms.APR_Status =1
								End 
						End 	 
			END

		ELSE
			BEGIN
					Declare @ad_id_Process numeric
					Declare @ad_id_Multi varchar(max)
					Declare @Loan_Id_Multi varchar(max) -- Added by rohit for Loan and Leave on 06012016
					Declare @Leave_id_Multi varchar(max)
					
					set @Loan_Id_Multi = ''  -- Added by rohit for Loan and Leave on 06012016
					set @Leave_id_Multi= ''
					Set @ad_id_Process = 0
					set @ad_id_Multi=''
					
					select @ad_id_Multi=Ad_Id_Multi,@Loan_Id_Multi=Loan_id_multi,@Leave_id_Multi=leave_id_multi  from T0301_Process_Type_Master WITH (NOLOCK) where Process_Type_Id = @process_type_id and cmp_id= @cmp_id  -- Added by rohit for Loan and Leave on 06012016
					
					
					delete from t0302_process_detail where cmp_id= @cmp_id and emp_id=isnull(@emp_id,emp_id) and month(for_date) = @month_id and YEAR(for_date) = @Year_ID and process_type_id = @process_type_id and payment_process_id = 0
					
						if @ad_id_Multi <> ''
						begin	
							Declare CusrCompanyMST cursor for	                  
							SELECT cast(data  as numeric) as Ad_id FROM dbo.Split(@ad_id_Multi,'#') 
							Open CusrCompanyMST
							Fetch next from CusrCompanyMST into @ad_id_Process
							While @@fetch_status = 0                    
								Begin     
									if @ad_id_Process > 0
										Begin
										
										 Insert into t0302_process_detail(cmp_id,emp_id,For_Date,process_type_id,payment_process_id,Ad_id,Amount,Esic,Comp_Esic,Net_Amount,modify_date,TDS)
										 
										  SELECT MS.Cmp_ID, MS.Emp_ID,MS.To_date as Month_End_Date,@process_type_id,0,@ad_id_Process,( isnull(ms.M_AD_Amount,0) + isnull(ms.M_AREAR_AMOUNT,0) + isnull(MS.M_AREAR_AMOUNT_Cutoff,0)) as net_Salary ,0,0,( isnull(ms.M_AD_Amount,0) + isnull(ms.M_AREAR_AMOUNT,0) + isnull(MS.M_AREAR_AMOUNT_Cutoff,0)) as net_Salary,getdate(),0
										 FROM         dbo.T0210_MONTHLY_AD_DETAIL AS MS WITH (NOLOCK)
										 inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 
										 and am.AD_NOT_EFFECT_SALARY = 1 and isnull(Ad_Effect_on_Esic,0) <> 1 and isnull(Auto_Ded_TDS ,0) <> 1  and ISNULL(Allowance_Type,'A') ='A'  and isnull(Is_Calculated_On_Imported_Value,0) <> 1 
										 Where MS.AD_ID = @ad_id_Process
										 and MS.cmp_id= @cmp_id and emp_id=isnull(@emp_id,Emp_ID) and month(MS.to_date) = @month_id and YEAR(MS.to_date) = @year_id 
										
										 union all
					  
										 SELECT MS.Cmp_ID,MS.Emp_ID,MS.For_Date  as Month_End_Date,@process_type_id,0,@ad_id_Process,ms.amount,ms.esic,ms.Comp_esic,(isnull(ms.Net_Amount ,0)) as net_Salary,getdate(),MS.tds 
										
											FROM T0210_ESIC_On_Not_Effect_on_Salary AS MS WITH (NOLOCK)
										  inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and 
										  am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and ( isnull(Ad_Effect_on_Esic,0) = 1  or isnull(Auto_Ded_TDS ,0) = 1 ) and ISNULL(Allowance_Type,'A') ='A'
											Where MS.AD_ID = @ad_id_Process
											and MS.cmp_id= @cmp_id and emp_id = isnull(@emp_id,emp_id) and month(MS.For_Date) = @month_id and YEAR(MS.For_Date ) = @year_id 
											                       
											union ALL
											
											SELECT MS.Cmp_ID, MS.Emp_ID, MS.For_Date  as Month_End_Date,@process_type_id,0,@ad_id_Process,( isnull(ms.Net_Amount ,0)) as net_Salary,0,0,( isnull(ms.Net_Amount ,0)) as net_Salary,getdate(),0
						  					FROM         dbo.T0210_Emp_Seniority_Detail AS MS WITH (NOLOCK) inner join 
						  					T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and ISNULL(Allowance_Type,'A') ='A'
										   Where MS.Ad_id = @ad_id_Process
									   		and MS.cmp_id= @cmp_id and emp_id = isnull(@emp_id,emp_id) and month(MS.For_Date) = @month_id and YEAR(MS.For_Date ) = @year_id 
										
										union ALL
										
											SELECT MS.Cmp_ID, MS.Emp_ID, MS.For_Date  as Month_End_Date,@process_type_id,0,@ad_id_Process,( isnull(ms.Amount ,0)) as net_Salary,0,0,( isnull(ms.Amount ,0)) as net_Salary,getdate(),0
						  					FROM         dbo.T0190_MONTHLY_AD_DETAIL_IMPORT AS MS WITH (NOLOCK) inner join 
						  					T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and ISNULL(Allowance_Type,'A') ='A'
											 Where MS.Ad_id = @ad_id_Process
									   		and MS.cmp_id= @cmp_id and emp_id = isnull(@emp_id,emp_id) and month(MS.For_Date) = @month_id and YEAR(MS.For_Date ) = @year_id 
											and isnull(Ad_Effect_on_Esic,0) <> 1 and isnull(Auto_Ded_TDS,0) <> 1  and isnull(Is_Calculated_On_Imported_Value,0) = 1 
										
										
										  union ALL
											
											SELECT MS.Cmp_ID, MS.Emp_ID, MS.Payment_date  as Month_End_Date,@process_type_id,0,@ad_id_Process,( isnull(ms.Apr_Amount,0) + isnull(ms.Taxable_Exemption_Amount,0)) as net_Salary,0,0,( isnull(ms.Apr_Amount,0) + isnull(ms.Taxable_Exemption_Amount,0)) as net_Salary,getdate(),0
						  					FROM         dbo.T0120_RC_Approval AS MS WITH (NOLOCK) inner join 
						  					T0050_AD_MASTER AM WITH (NOLOCK) on Ms.Rc_id = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and ISNULL(Allowance_Type,'A') ='R'
										   Where MS.rc_id = @ad_id_Process
									   		and MS.cmp_id= @cmp_id and emp_id = isnull(@emp_id,emp_id) and month(MS.Payment_date) = @month_id and YEAR(MS.Payment_date ) = @year_id 
										   and ms.RC_Apr_Effect_In_Salary =0 and ms.APR_Status =1
											
												 
										End 
								fetch next from CusrCompanyMST into @ad_id_Process	
								end
							close CusrCompanyMST                    
							deallocate CusrCompanyMST	
						 End
						
						-- Added by rohit for Loan and Leave on 06012016
						if @Loan_Id_Multi<>''
						begin
							
							Insert into t0302_process_detail(cmp_id,emp_id,For_Date,process_type_id,payment_process_id,Ad_id,Amount,Esic,Comp_Esic,Net_Amount,modify_date,TDS,Loan_id,leave_id)
										 
										  SELECT MS.Cmp_ID, MS.Emp_ID,MS.loan_Apr_payment_date as Month_End_Date,@process_type_id,0,0,isnull(ms.Loan_Apr_Amount,0) as net_Salary ,0,0,isnull(ms.Loan_Apr_Amount,0)  as net_Salary,getdate(),0,ms.loan_id,0
										 FROM         dbo.T0120_LOAN_APPROVAL AS MS WITH (NOLOCK)
										 inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on Ms.Loan_ID = LM.loan_id
										 Where MS.cmp_id= @cmp_id and emp_id=isnull(@emp_id,Emp_ID) and month(MS.loan_Apr_payment_date) = @month_id and 
										 YEAR(MS.loan_Apr_payment_date) = @year_id 
										 and ms.Loan_id in (SELECT cast(data  as numeric) as leave_id FROM dbo.Split(@Loan_Id_Multi,'#'))
										
						end
						
						if @Leave_id_Multi<>''
						begin
							
							Insert into t0302_process_detail(cmp_id,emp_id,For_Date,process_type_id,payment_process_id,Ad_id,Amount,Esic,Comp_Esic,Net_Amount,modify_date,TDS,Loan_id,leave_id)
										 
										  SELECT MS.Cmp_ID, MS.Emp_ID,MS.Lv_Encash_Apr_Date as Month_End_Date,@process_type_id,0,0,isnull(ms.leave_encash_amount,0) as net_Salary ,0,0,isnull(ms.leave_encash_amount,0)  as net_Salary,getdate(),0,0,ms.Leave_ID
										 FROM         dbo.T0120_LEAVE_ENCASH_APPROVAL AS MS WITH (NOLOCK)
										 inner join t0040_leave_master LM WITH (NOLOCK) on Ms.leave_id = LM.leave_id
										 Where MS.cmp_id= @cmp_id and emp_id=isnull(@emp_id,Emp_ID) and month(MS.Lv_Encash_Apr_Date) = @month_id and 
										 YEAR(MS.Lv_Encash_Apr_Date) = @year_id 
										 and ms.Leave_ID in (SELECT cast(data  as numeric) as leave_id FROM dbo.Split(@Leave_id_Multi,'#'))
										
						end
						-- Ended by rohit on 06012015	
							
							 CREATE TABLE #Net_Amount         
								(         
									Emp_Id   numeric ,         
									Net_Amount Numeric(18,0) default(0)
								)      

							
							insert into #Net_Amount
							select  emp_id,isnull(Sum(net_amount),0) from t0302_process_detail WITH (NOLOCK)
							where cmp_id= @cmp_id and emp_id=isnull(@emp_id,emp_id) and month(for_date) = @month_id and YEAR(for_date) = @Year_ID 
							and process_type_id = @process_type_id and payment_process_id = 0
							group by emp_id
								
							
							  Insert into #Payment_Process(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,Bank_Name, 
								Inc_Bank_AC_No,Payment_Mode,Bank_ID_Two,Payment_Mode_Two,Inc_Bank_AC_No_Two,
								cmp_bank_ac_no,Cmp_bank_name,Cmp_bank_id,Net_Amount,Branch_ID, Dept_ID, 
								Cat_ID, Type_ID, Desig_Id, Emp_Left, Bank_ID, 
								IT_M_ED_Cess_Amount,Salary_Status,process_Type,Ad_Id )
								
							 -- SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.Month_St_Date as Month_St_Date, MS.month_end_date as Month_End_Date,   
								--BM.Bank_Name,   
							 -- INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
								--  (SELECT     Bank_Ac_No  
								--	FROM          dbo.T0040_BANK_MASTER  
								--	WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
								--  (SELECT     Bank_Name  
								--	FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  
								--	WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
								--  (SELECT     Bank_ID  
								--	FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  
								--	WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, (NA.Net_Amount) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
							 -- ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
							 -- 0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
							 -- , @process_type as process_Type  
							 -- ,0
								--FROM  T0200_MONTHLY_SALARY AS MS INNER JOIN  
								--					  dbo.T0080_EMP_MASTER AS EM ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
								--					  dbo.T0095_INCREMENT AS INC ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
								--						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI inner join  
								--	  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment  
								--	  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
								--	  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
								--	  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
								--  LEFT OUTER JOIN  
								--dbo.T0040_BANK_MASTER AS BM ON EM.Bank_ID = BM.Bank_ID  
								--left Join #Net_Amount NA on ms.Emp_ID = Na.Emp_Id	
								--where isnull(NA.Net_Amount,0) > 0
								
								  SELECT     TOP (100) PERCENT Em.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, dbo.GET_MONTH_ST_DATE(@Month_ID,@Year_ID) as Month_St_Date, dbo.GET_MONTH_END_DATE(@Month_ID,@Year_ID) as Month_End_Date,   
								BM.Bank_Name,   
							  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
								  (SELECT     Bank_Ac_No  
									FROM          dbo.T0040_BANK_MASTER   WITH (NOLOCK)
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = EM.Cmp_ID)) AS cmp_bank_ac_no,  
								  (SELECT     Bank_Name  
									FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = EM.Cmp_ID)) AS Cmp_bank_name,  
								  (SELECT     Bank_ID  
									FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
									WHERE      (Is_Default = 'Y') AND (Cmp_Id = EM.Cmp_ID)) AS Cmp_bank_id, (MS.Net_Amount) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
							  ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
							  0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
							  , @process_type as process_Type  
							  ,0
								FROM #Net_Amount AS MS INNER JOIN  
								dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
								dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
									  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc   
									  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
									  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
								  LEFT OUTER JOIN  
								dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON INC.Bank_ID = BM.Bank_ID  
								--left Join #Net_Amount NA on ms.Emp_ID = Na.Emp_Id	
								where isnull(MS.Net_Amount,0) > 0
							
							
							
		 end
	 
	--Added By Jaina 30-09-2015 Start
	declare @effectiveDate datetime = Cast(@Year_ID as varchar) + '-' + Cast(@Month_ID As varchar) + '-01'
	SET @effectiveDate = dateadd(d, -1,DATEADD(m, 1, @effectiveDate))
	--Added By Jaina 30-09-2015 End
	--Added by Jaina 27-12-2017 Start
	if @process_type = 'Travel Advance Amount' or @process_type = 'Travel Amount'		
		Begin
				
				Select DISTINCT P.Cmp_ID,P.Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,
					(Case when @Bank_Flag = 1 then Bank_Name ELSE (SELECT Bk.Bank_Name FROM T0040_BANK_MASTER Bk WITH (NOLOCK) Where Bk.Bank_ID = Bank_ID_Two AND Bk.Cmp_Id = Cmp_ID) END) As Bank_Name,
					(Case when @Bank_Flag = 1 then Inc_Bank_AC_No ELSE Inc_Bank_AC_No_Two END) As Inc_Bank_AC_No,
					(Case when @Bank_Flag = 1 then P.Payment_Mode ELSE Payment_Mode_Two END) As Payment_Mode,
					P.cmp_bank_ac_no,Cmp_bank_name,P.Cmp_bank_id,P.Net_Amount,B.Branch_ID, B.Dept_ID, 
					Cat_ID, Type_ID, B.Desig_Id,P.Emp_Left,(Case when @Bank_Flag = 1 then Bank_ID ELSE Bank_ID_Two End) as Bank_ID, 
					IT_M_ED_Cess_Amount,Salary_Status,P.process_Type,P.Ad_Id
					,B.Vertical_ID,B.SubVertical_ID  --Added By Jaina 30-09-2015
					,B.Grd_ID , 0 as BOND_APR_ID --Added By Dhruv 08-02-2017
			From #Payment_Process As P 
				 INNER JOIN(                  --Added By Jaina 30-09-2015 Start
					SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID,I.Grd_ID,I.Desig_Id
					FROM	T0095_INCREMENT I WITH (NOLOCK)
					WHERE	I.INCREMENT_ID = (
												SELECT	TOP 1 INCREMENT_ID
												FROM	T0095_INCREMENT I1 WITH (NOLOCK)
												WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID and INCREMENT_EFFECTIVE_DATE <= @effectiveDate
												ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
											)
				 ) AS B ON B.EMP_ID = P.EMP_ID AND B.CMP_ID=P.CMP_ID  				 
				 left join MONTHLY_EMP_BANK_PAYMENT ME  WITH (NOLOCK) on P.Emp_ID=ME.Emp_ID and month(P.Month_End_Date) = MONTH(me.For_Date) and YEAR(P.Month_End_Date)=YEAR(Me.For_Date) and p.process_Type = Me.Process_Type --and p.Ad_Id = ME.Ad_Id
				 --left JOIN T0302_Payment_Process_Travel_Details PT ON PT.Emp_Id = P.Emp_Id
				 left JOIN dbo.T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) ON TA.Emp_ID = ME.Emp_ID
				 
				 --left JOIN MONTHLY_EMP_BANK_PAYMENT Me ON Me.payment_process_id = PT.Payment_Process_Id
					--	and MONTH(Me.For_Date) = MONTH(P.Month_End_Date) and YEAR(P.Month_End_Date)=YEAR(Me.For_Date) and p.process_Type = Me.Process_Type
					--	and Me.Emp_ID = pt.Emp_Id
				 --Added By Jaina 30-09-2015 End
			where isnull(B.branch_id,0) = isnull(@Branch_ID ,Isnull(B.branch_id,0))    
					and isnull(P.Emp_ID,0) = isnull(@Emp_ID,Isnull(P.Emp_ID,0))
					and B.cmp_id = @cmp_id 
					and month(month_end_date) = @Month_ID
					and year(month_end_date) = @Year_ID
					and isnull(P.process_Type,0) = isnull(@process_type,ISNULL(p.process_Type,0))
					--and isnull(ME.payment_process_id,0) = 0 
					and ISNULL(B.Dept_ID,0) = ISNULL(@Dept_ID,ISNULL(B.Dept_ID,0))  --added By Dhruv(start) 08022017
					and ISNULL(B.Grd_ID,0) = ISNULL(@Grd_ID,ISNULL(B.Grd_ID,0))
					and ISNULL(B.Desig_Id,0) = ISNULL(@Desig_Id,ISNULL(B.Desig_Id,0) ) --added By Dhruv(End) 08022017 
					and P.Net_Amount <> 0 ---Added by Jaina 24-11-2017
					And NOT EXISTS(Select 1 From T0302_Payment_Process_Travel_Details PT WITH (NOLOCK)
							   WHERE TA.Travel_Approval_Id = PT.Travel_Approval_Id 	AND TA.Emp_ID = PT.Emp_Id)	
			order by alpha_emp_code		
					
		END --Added by Jaina 27-12-2017 EN
	ELSE if @process_type = 'Bond'	--Added By Ramiz on 01/11/2018
		BEGIN
			SELECT	P.Cmp_ID,P.Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,
					(CASE WHEN @Bank_Flag = 1 THEN Bank_Name ELSE (SELECT Bk.Bank_Name FROM T0040_BANK_MASTER Bk WITH (NOLOCK) WHERE Bk.Bank_ID = Bank_ID_Two AND Bk.Cmp_Id = Cmp_ID) END) As Bank_Name,
					(CASE WHEN @Bank_Flag = 1 THEN Inc_Bank_AC_No ELSE Inc_Bank_AC_No_Two END) As Inc_Bank_AC_No,
					(CASE WHEN @Bank_Flag = 1 THEN P.Payment_Mode ELSE Payment_Mode_Two END) As Payment_Mode,
					P.cmp_bank_ac_no,Cmp_bank_name,P.Cmp_bank_id,P.Net_Amount,B.Branch_ID, B.Dept_ID, Cat_ID, Type_ID, B.Desig_Id,P.Emp_Left,
					(Case when @Bank_Flag = 1 then Bank_ID ELSE Bank_ID_Two End) as Bank_ID, IT_M_ED_Cess_Amount,Salary_Status,P.process_Type,
					P.Ad_Id,B.Vertical_ID,B.SubVertical_ID,B.Grd_ID , me.payment_process_id,P.BOND_APR_ID ,BA.Bond_Id, '' as Claim_Name,0 as Claim_APR_ID
			FROM #PAYMENT_PROCESS AS P
				 INNER JOIN(
							SELECT	EMP_ID, Branch_ID, CMP_ID ,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID,I.Grd_ID,I.Desig_Id
							FROM	T0095_INCREMENT I WITH (NOLOCK)
							WHERE	I.INCREMENT_ID = (
														SELECT	TOP 1 INCREMENT_ID
														FROM	T0095_INCREMENT I1 WITH (NOLOCK)
														WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID and INCREMENT_EFFECTIVE_DATE <= @EffectiveDate
														ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
													)
							) AS B ON B.EMP_ID = P.EMP_ID AND B.CMP_ID = P.CMP_ID
				 INNER JOIN T0120_BOND_APPROVAL BA WITH (NOLOCK) ON BA.Bond_Apr_Id = P.BOND_APR_ID
				 LEFT JOIN MONTHLY_EMP_BANK_PAYMENT ME WITH (NOLOCK) ON P.Emp_ID = ME.Emp_ID and MONTH(P.Month_End_Date) = MONTH(ME.For_Date) and YEAR(P.Month_End_Date)=YEAR(Me.For_Date) and P.process_Type = Me.Process_Type AND BA.Payment_Process_ID = ME.payment_process_id
				 
			WHERE	ISNULL(B.Branch_id,0) = ISNULL(@Branch_ID ,ISNULL(B.branch_id,0))    
					AND ISNULL(P.Emp_ID,0) = ISNULL(@Emp_ID,ISNULL(P.Emp_ID,0))
					and B.cmp_id = @cmp_id 
					AND ISNULL(P.process_Type,0) = ISNULL(@process_type,ISNULL(p.process_Type,0))
					and isnull(ME.payment_process_id,0) = 0 
					and ISNULL(B.Dept_ID,0) = ISNULL(@Dept_ID,ISNULL(B.Dept_ID,0))
					and ISNULL(B.Grd_ID,0) = ISNULL(@Grd_ID,ISNULL(B.Grd_ID,0))
					and ISNULL(B.Desig_Id,0) = ISNULL(@Desig_Id,ISNULL(B.Desig_Id,0) )
					and P.Net_Amount <> 0
			ORDER BY alpha_emp_code
		END	
	ELSE if @process_type = 'Claim'
		 Begin
		 Select Distinct P.Cmp_ID,P.Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,
					(Case when @Bank_Flag = 1 then Bank_Name ELSE (SELECT Bk.Bank_Name FROM T0040_BANK_MASTER Bk WITH (NOLOCK) Where Bk.Bank_ID = Bank_ID_Two AND Bk.Cmp_Id = Cmp_ID) END) As Bank_Name,
					(Case when @Bank_Flag = 1 then Inc_Bank_AC_No ELSE Inc_Bank_AC_No_Two END) As Inc_Bank_AC_No,
					(Case when @Bank_Flag = 1 then P.Payment_Mode ELSE Payment_Mode_Two END) As Payment_Mode,
					P.cmp_bank_ac_no,Cmp_bank_name,P.Cmp_bank_id,P.Net_Amount,B.Branch_ID, B.Dept_ID, 
					Cat_ID, Type_ID, B.Desig_Id,P.Emp_Left,(Case when @Bank_Flag = 1 then Bank_ID ELSE Bank_ID_Two End) as Bank_ID, 
					IT_M_ED_Cess_Amount,Salary_Status,P.process_Type,P.Ad_Id
					,B.Vertical_ID,B.SubVertical_ID  --Added By Jaina 30-09-2015
					,B.Grd_ID , 0 as BOND_APR_ID --Added By Dhruv 08-02-2017
					,P.Claim_APR_ID,CAD.Claim_ID,cm.Claim_Name
			From #Payment_Process As P 
				 INNER JOIN(                  --Added By Jaina 30-09-2015 Start
					SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID,I.Grd_ID,I.Desig_Id
					FROM	T0095_INCREMENT I WITH (NOLOCK)
					WHERE	I.INCREMENT_ID = (
												SELECT	TOP 1 INCREMENT_ID
												FROM	T0095_INCREMENT I1 WITH (NOLOCK)
												WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID and INCREMENT_EFFECTIVE_DATE <= @effectiveDate
												ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
											)
				 ) AS B ON B.EMP_ID = P.EMP_ID AND B.CMP_ID=P.CMP_ID  
				 INNER JOIN T0130_CLAIM_APPROVAL_DETAIL CAD WITH (NOLOCK) ON CAD.Claim_Apr_ID = P.Claim_APR_ID
				 INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.Claim_ID = P.Claim_ID
				 left join MONTHLY_EMP_BANK_PAYMENT ME  on P.Emp_ID=ME.Emp_ID and month(P.Month_End_Date) = MONTH(me.For_Date) and YEAR(P.Month_End_Date)=YEAR(Me.For_Date) and p.process_Type = Me.Process_Type and p.Ad_Id = ME.Ad_Id
				 --Added By Jaina 30-09-2015 End
			where isnull(B.branch_id,0) = isnull(@Branch_ID ,Isnull(B.branch_id,0))    
					and isnull(P.Emp_ID,0) = isnull(@Emp_ID,Isnull(P.Emp_ID,0))
					and B.cmp_id = @cmp_id 
					--and month(month_end_date) = @Month_ID
					and year(month_end_date) = @Year_ID
					and isnull(P.process_Type,'') = isnull(@process_type,ISNULL(p.process_Type,''))
					and isnull(ME.payment_process_id,0) = 0 
					and ISNULL(B.Dept_ID,0) = ISNULL(@Dept_ID,ISNULL(B.Dept_ID,0))  --added By Dhruv(start) 08022017
					and ISNULL(B.Grd_ID,0) = ISNULL(@Grd_ID,ISNULL(B.Grd_ID,0))
					and ISNULL(B.Desig_Id,0) = ISNULL(@Desig_Id,ISNULL(B.Desig_Id,0) ) --added By Dhruv(End) 08022017 
					and P.Net_Amount <> 0 ---Added by Jaina 24-11-2017
			order by alpha_emp_code	

			End

	ELSE
		BEGIN
		
			Select P.Cmp_ID,P.Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Month_St_Date,Month_End_Date,
					(Case when @Bank_Flag = 1 then Bank_Name ELSE (SELECT Bk.Bank_Name FROM T0040_BANK_MASTER Bk WITH (NOLOCK) Where Bk.Bank_ID = Bank_ID_Two AND Bk.Cmp_Id = Cmp_ID) END) As Bank_Name,
					(Case when @Bank_Flag = 1 then Inc_Bank_AC_No ELSE Inc_Bank_AC_No_Two END) As Inc_Bank_AC_No,
					(Case when @Bank_Flag = 1 then P.Payment_Mode ELSE Payment_Mode_Two END) As Payment_Mode,
					P.cmp_bank_ac_no,Cmp_bank_name,P.Cmp_bank_id,P.Net_Amount,B.Branch_ID, B.Dept_ID, 
					Cat_ID, Type_ID, B.Desig_Id,P.Emp_Left,(Case when @Bank_Flag = 1 then Bank_ID ELSE Bank_ID_Two End) as Bank_ID, 
					IT_M_ED_Cess_Amount,Salary_Status,P.process_Type,P.Ad_Id
					,B.Vertical_ID,B.SubVertical_ID  --Added By Jaina 30-09-2015
					,B.Grd_ID , 0 as BOND_APR_ID --Added By Dhruv 08-02-2017
			From #Payment_Process As P 
				 INNER JOIN(                  --Added By Jaina 30-09-2015 Start
					SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID,I.Grd_ID,I.Desig_Id
					FROM	T0095_INCREMENT I WITH (NOLOCK)
					WHERE	I.INCREMENT_ID = (
												SELECT	TOP 1 INCREMENT_ID
												FROM	T0095_INCREMENT I1 WITH (NOLOCK)
												WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID and INCREMENT_EFFECTIVE_DATE <= @effectiveDate
												ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
											)
				 ) AS B ON B.EMP_ID = P.EMP_ID AND B.CMP_ID=P.CMP_ID  
				 left join MONTHLY_EMP_BANK_PAYMENT ME  on P.Emp_ID=ME.Emp_ID and month(P.Month_End_Date) = MONTH(me.For_Date) and YEAR(P.Month_End_Date)=YEAR(Me.For_Date) and p.process_Type = Me.Process_Type and p.Ad_Id = ME.Ad_Id
				 --Added By Jaina 30-09-2015 End
			where isnull(B.branch_id,0) = isnull(@Branch_ID ,Isnull(B.branch_id,0))    
					and isnull(P.Emp_ID,0) = isnull(@Emp_ID,Isnull(P.Emp_ID,0))
					and B.cmp_id = @cmp_id 
					and month(month_end_date) = @Month_ID
					and year(month_end_date) = @Year_ID
					and isnull(P.process_Type,'') = isnull(@process_type,ISNULL(p.process_Type,''))
					and isnull(ME.payment_process_id,0) = 0 
					and ISNULL(B.Dept_ID,0) = ISNULL(@Dept_ID,ISNULL(B.Dept_ID,0))  --added By Dhruv(start) 08022017
					and ISNULL(B.Grd_ID,0) = ISNULL(@Grd_ID,ISNULL(B.Grd_ID,0))
					and ISNULL(B.Desig_Id,0) = ISNULL(@Desig_Id,ISNULL(B.Desig_Id,0) ) --added By Dhruv(End) 08022017 
					and P.Net_Amount <> 0 ---Added by Jaina 24-11-2017
			order by alpha_emp_code		
		END		
	
	drop table #Payment_Process
	
	
END


