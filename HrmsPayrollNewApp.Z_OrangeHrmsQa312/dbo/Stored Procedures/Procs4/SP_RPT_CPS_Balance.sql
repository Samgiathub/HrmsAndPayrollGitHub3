

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_CPS_Balance]
  @Cmp_ID     Numeric          
 ,@From_Date  Datetime          
 ,@To_Date    Datetime          
 ,@Branch_ID  Numeric          
 ,@Cat_ID     Numeric           
 ,@Grd_ID     Numeric          
 ,@Type_ID    Numeric          
 ,@Dept_ID    Numeric          
 ,@Desig_ID   Numeric          
 ,@Emp_ID     Numeric          
 ,@constraint Varchar(MAX)          
 ,@Sal_Type   Numeric = 0
 ,@Bank_id	   numeric = 0
 ,@Payment_mode varchar(100) = ''
 ,@Salary_Cycle_id numeric = 0	
 ,@Segment_Id  numeric = 0		
 ,@Vertical_Id numeric = 0		
 ,@SubVertical_Id numeric = 0	
 ,@SubBranch_Id numeric = 0
       
AS          
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	                      
	 IF @Branch_ID = 0            
	   Set @Branch_ID = null          
	            
	 IF @Cat_ID = 0            
		Set @Cat_ID =  null          
	          
	 IF @Grd_ID = 0            
		Set @Grd_ID = null          
	          
	 IF @Type_ID = 0            
		Set @Type_ID = null          
	          
	 IF @Dept_ID = 0            
		Set @Dept_ID = null          
	          
	 IF @Desig_ID = 0            
		Set @Desig_ID = null          
	          
	 IF @Emp_ID = 0            
		Set @Emp_ID = null      
		
	if @Salary_Cycle_id = 0	
		set @Salary_Cycle_id = NULL
			
			
	If @Segment_Id = 0		
		set @Segment_Id = null
	If @Vertical_Id = 0		
		set @Vertical_Id = null
	If @SubVertical_Id = 0	
		set @SubVertical_Id = null	
	If @SubBranch_Id = 0	
		set @SubBranch_Id = null	

	Declare @Next_Month_End_Date as Datetime

	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
	declare @manual_salary_period as numeric(18,0)
  
	SET @manual_salary_period = 0
	  
	DECLARE @is_salary_cycle_emp_wise AS TINYINT 
	SET @is_salary_cycle_emp_wise = 0

	SELECT	@is_salary_cycle_emp_wise = ISNULL(Setting_Value,0) 
	FROM	T0040_SETTING WITH (NOLOCK)
	WHERE	Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'


	IF @is_salary_cycle_emp_wise = 1 AND ISNULL(@Salary_Cycle_id,0) > 0 BEGIN
		SELECT	@Sal_St_Date = SALARY_ST_DATE 
		FROM	T0040_SALARY_CYCLE_MASTER WITH (NOLOCK)
		WHERE	tran_id = @Salary_Cycle_id
	END ELSE BEGIN
		IF @Branch_ID IS NULL BEGIN 
			SELECT	TOP 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0)
			FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE cmp_ID = @cmp_ID    
				  AND For_Date=( 
								SELECT	MAX(For_Date) 
								FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
								WHERE	For_Date <=@From_Date AND Cmp_ID = @Cmp_ID
								)    
		END ELSE BEGIN
			SELECT	@Sal_St_Date=Sal_st_Date,@manual_salary_period=ISNULL(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013
			FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE	cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID
					AND For_Date = (
									SELECT	MAX(For_Date)
									FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
									WHERE	For_Date <=@From_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID
									)    
		END
	END

	   
	IF isnull(@Sal_St_Date,'') = '' BEGIN    
		SET	@From_Date  = @From_Date     
		SET	@To_Date = @To_Date    
	END ELSE IF day(@Sal_St_Date) = 1 BEGIN 	    
		SET	@From_Date  = @From_Date     
		SET	@To_Date = @To_Date    
	END ELSE IF @Sal_St_Date <> '' AND day(@Sal_St_Date) > 1 BEGIN    
		IF @manual_salary_period = 0 BEGIN
			SET	@Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			SET	@Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			SET	@From_Date = @Sal_St_Date
			SET	@To_Date = @Sal_End_Date
		END ELSE BEGIN
			SELECT	@Sal_St_Date=from_date,@Sal_End_Date=end_date
			FROM	salary_period 
			WHERE	MONTH=MONTH(@From_Date) AND YEAR=YEAR(@From_Date)

			SET	@From_Date = @Sal_St_Date
			SET	@To_Date = @Sal_End_Date 
		End    
	End

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id           
             
  Declare @Emp_CPS_Balance Table          
  (
   Tran_ID Numeric,
   Cmp_ID    numeric,          
   Emp_ID    numeric,
   Sal_Tran_ID numeric,
   Sal_End_Date Datetime,  
   Opening_Amount numeric(18,2),
   EMP_CPS numeric(18,2),
   Company_CPS numeric(18,2),
   DA_Arrears numeric(18,2)
  )
  
  Declare @Cur_Emp_Id Numeric
  Declare @Cur_Cmp_Id Numeric
  Declare @Cur_Sal_End_Date Datetime
  Declare @Cur_Sal_Tran_ID Numeric
  Declare @Cur_Opening_Amount Numeric
  Declare @Cur_Opening_Amount_1 Numeric
  Declare @Tran_ID Numeric
  Declare @Opening_Amount Numeric(18,2)
  Declare @CPP_Amount Numeric(18,2)
  Declare @EPP_Amount Numeric(18,2)
  Declare @DA_Arrear_Amount Numeric(18,2)
  Declare @Chck_EMP_ID Numeric
  
  Set @Opening_Amount = 0
  Set @Tran_ID = 0 
  set @Chck_EMP_ID = 0;
 
  Declare Cur_Cps Cursor for 
  SELECT EC.Emp_ID,MS.Cmp_ID,MS.Month_End_Date,MS.Sal_Tran_ID FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) Inner join #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
  ORDER BY EC.Emp_ID
  
  open Cur_Cps 
  fetch next from Cur_Cps into @Cur_Emp_Id,@Cur_Cmp_Id,@Cur_Sal_End_Date,@Cur_Sal_Tran_ID
  while @@fetch_status = 0 
	Begin
		  Set @CPP_Amount =0 
		  Set @EPP_Amount = 0
		  Set @DA_Arrear_Amount = 0
		 
		 if @Chck_EMP_ID <> @Cur_Emp_Id 
			Begin
				
				Set @Chck_EMP_ID = @Cur_Emp_Id 
				
				Set @Opening_Amount = 0
				SET @Cur_Opening_Amount = 0
			End 	
			
		 IF not exists(Select 1 FROM @Emp_CPS_Balance Where Emp_ID = @Cur_Emp_Id AND Cmp_ID = @Cur_Cmp_Id)
			begin
				
				SELECT @Tran_ID = MAX(isnull(Tran_ID,0)) + 1 From  @Emp_CPS_Balance
				
				Insert INTO @Emp_CPS_Balance(Tran_ID,Cmp_ID,Emp_ID,Sal_Tran_ID,Sal_End_Date,Opening_Amount,EMP_CPS,Company_CPS,DA_Arrears) 
				(Select isnull(@Tran_ID,0),@Cur_Cmp_Id,@Cur_Emp_Id,0,CP.For_Date,CP.CPS_Opening,0,0,0 
				     From T0095_CPS_OPENING CP WITH (NOLOCK) INNER JOIN(SELECT MAX(For_Date)as For_Date,Emp_ID FROM T0095_CPS_OPENING WITH (NOLOCK) where Emp_ID = @Cur_Emp_Id GROUP BY Emp_ID) Qry
				     on Qry.For_Date = CP.For_Date
				     Where CP.Emp_ID = @Cur_Emp_Id AND CP.Cmp_ID = @Cur_Cmp_Id)
				
				Select 	@Cur_Opening_Amount = CPS_Opening From T0095_CPS_OPENING WITH (NOLOCK) Where Emp_ID = @Cur_Emp_Id AND Cmp_ID = @Cur_Cmp_Id
				
				Set @Opening_Amount = @Opening_Amount + @Cur_Opening_Amount
			End
		
		SELECT @Tran_ID = MAX(isnull(Tran_ID,0)) + 1 From  @Emp_CPS_Balance
		Insert INTO @Emp_CPS_Balance VALUES(@Tran_ID,@Cur_Cmp_Id,@Cur_Emp_Id,@Cur_Sal_Tran_ID,@Cur_Sal_End_Date,0,0,0,0)
		
		Select @CPP_Amount = isnull(MD.M_AD_Amount,0)   From @Emp_CPS_Balance CB inner JOIN T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK)
		on MD.Sal_Tran_ID = CB.Sal_Tran_ID Inner Join T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID = MD.AD_ID
		Where MD.M_AD_Flag = 'I' and AD.AD_DEF_ID = 15 and CB.Emp_ID = @Cur_Emp_Id AND MD.M_AD_Amount <> 0 and Isnull(MD.S_Sal_Tran_ID,0) = 0
		
		Select @EPP_Amount = isnull(MD.M_AD_Amount,0)  From @Emp_CPS_Balance CB inner JOIN T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK)
		on MD.Sal_Tran_ID = CB.Sal_Tran_ID Inner Join T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID = MD.AD_ID
		Where MD.M_AD_Flag = 'D' and AD.AD_DEF_ID = 16 and CB.Emp_ID = @Cur_Emp_Id AND MD.M_AD_Amount <> 0 and Isnull(MD.S_Sal_Tran_ID,0) = 0
		
		
		Select  @DA_Arrear_Amount = Isnull(Qry.M_AD_Amount,0) From @Emp_CPS_Balance CB inner JOIN 
		(Select Sum(isnull(MD.M_AD_Amount,0)) as M_AD_Amount ,MD.Sal_Tran_ID as Sal_Tran_ID  From T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) Inner Join T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID = MD.AD_ID
		Where AD.AD_DEF_ID IN(15,16) and MD.Emp_ID = @Cur_Emp_Id AND MD.M_AD_Amount <> 0 and MD.S_Sal_Tran_ID <> 0
		group by MD.Sal_Tran_ID) Qry ON Qry.Sal_Tran_ID = CB.Sal_Tran_ID
		Where CB.Emp_ID = @Cur_Emp_Id and CB.Sal_End_Date = @Cur_Sal_End_Date 
		
		Update CB Set CB.Company_CPS = MD.M_AD_Amount   From @Emp_CPS_Balance CB inner JOIN T0210_MONTHLY_AD_DETAIL MD
		on MD.Sal_Tran_ID = CB.Sal_Tran_ID Inner Join T0050_AD_MASTER AD on AD.AD_ID = MD.AD_ID
		Where MD.M_AD_Flag = 'I' and AD.AD_DEF_ID = 15 and CB.Emp_ID = @Cur_Emp_Id AND MD.M_AD_Amount <> 0 and Isnull(MD.S_Sal_Tran_ID,0) = 0
		
		Update CB Set CB.EMP_CPS = MD.M_AD_Amount  From @Emp_CPS_Balance CB inner JOIN T0210_MONTHLY_AD_DETAIL MD
		on MD.Sal_Tran_ID = CB.Sal_Tran_ID Inner Join T0050_AD_MASTER AD on AD.AD_ID = MD.AD_ID
		Where MD.M_AD_Flag = 'D' and AD.AD_DEF_ID = 16 and CB.Emp_ID = @Cur_Emp_Id AND MD.M_AD_Amount <> 0 and Isnull(MD.S_Sal_Tran_ID,0) = 0
		
		Update CB Set CB.DA_Arrears = Qry.M_AD_Amount From @Emp_CPS_Balance CB inner JOIN 
		(Select Sum(MD.M_AD_Amount) as M_AD_Amount ,MD.Sal_Tran_ID as Sal_Tran_ID  From T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) Inner Join T0050_AD_MASTER AD WITH (NOLOCK)on AD.AD_ID = MD.AD_ID
		Where AD.AD_DEF_ID IN(15,16) and MD.Emp_ID = @Cur_Emp_Id AND MD.M_AD_Amount <> 0 and MD.S_Sal_Tran_ID <> 0
		group by MD.Sal_Tran_ID) Qry ON Qry.Sal_Tran_ID = CB.Sal_Tran_ID
		Where CB.Emp_ID = @Cur_Emp_Id and CB.Sal_End_Date = @Cur_Sal_End_Date 
		
		set @Opening_Amount = @Opening_Amount + (@CPP_Amount + @EPP_Amount + @DA_Arrear_Amount)
		
		Update @Emp_CPS_Balance SET Opening_Amount = @Opening_Amount where Sal_Tran_ID = @Cur_Sal_Tran_ID and Emp_ID = @Cur_Emp_Id
		
		--select @Opening_Amount,@CPP_Amount,@EPP_Amount,@Cur_Sal_End_Date,@Cur_Sal_Tran_ID
		 	
		fetch next from Cur_Cps  into @Cur_Emp_Id,@Cur_Cmp_Id,@Cur_Sal_End_Date,@Cur_Sal_Tran_ID
	End
  close Cur_Cps
  deallocate Cur_Cps

  Select CB.*,EM.Alpha_Emp_Code,EM.Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,EM.SSN_No As PF_No 
  From  @Emp_CPS_Balance CB Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
  on CB.Emp_ID = EM.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID  
  where Sal_End_Date >= @From_Date and Sal_End_Date <= @To_Date
  
 RETURN           



