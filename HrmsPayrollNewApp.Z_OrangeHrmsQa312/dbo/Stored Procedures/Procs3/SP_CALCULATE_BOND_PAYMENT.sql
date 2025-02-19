


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_BOND_PAYMENT]
	@CMP_ID			NUMERIC ,
	@EMP_ID			NUMERIC,
	@From_Date		Datetime,
	@To_Date		DATETIME,
	@SALARY_TRAN_ID	NUMERIC ,
	--@MANUAL_BOND	NUMERIC,
	@IS_BONDDEDU	NUMERIC ,
	@Is_FNF			int = 0
	
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	
	DECLARE @BOND_ID			AS NUMERIC
	DECLARE @PENDING_BOND		AS NUMERIC(27,5)
	DECLARE @BOND_INST			AS NUMERIC(27,5)
	DECLARE @BOND_INST_AMOUNT	AS NUMERIC(27,5)
	DECLARE @BOND_PAYMENT_ID	AS NUMERIC
	DECLARE @TOTALINST_AMOUNT	AS NUMERIC(27,5)
	
	DECLARE @TOTBOND_CLOSING	AS NUMERIC(27,5)
	
	DECLARE @BOND_APR_ID		AS NUMERIC
	DECLARE @BOND_APR_DEDUCT_FROM_SAL NUMERIC
	
	DECLARE @RETURN_AMOUNT		AS NUMERIC(27,5)
	DECLARE @BOND_APR_AMOUNT	AS NUMERIC(27,5)
	DECLARE @DEDUCTION_TYPE		AS VARCHAR(20)
	
	DECLARE @DESIG_ID NUMERIC(18,0)			
	DECLARE @PAID_AMOUNT AS NUMERIC(18,2)
	DECLARE @INSTALLMENT_START_DATE DATETIME;


	DECLARE @BOND_INTEREST_AMOUNT	 NUMERIC(27,2)
	DECLARE @INTEREST_TYPE			 VARCHAR(20)
	DECLARE @BOND_APR_DATE			 DATETIME 	


	DECLARE @MONTHDAYS AS NUMERIC
	DECLARE @BONDDAYS AS NUMERIC
	DECLARE @BRANCH_ID_TEMP AS NUMERIC
	
	DECLARE @SAL_ST_DATE   DATETIME    
	DECLARE @SAL_END_DATE   DATETIME   
	DECLARE @MONTH_ST_DATE  DATETIME
	DECLARE @MONTH_END_DATE  DATETIME
	
	
	
	SET @MONTHDAYS = 0
	SET @BONDDAYS = 0
	SET @BRANCH_ID_TEMP = 0
	

	
	SET @PENDING_BOND			= 0.0
	SET @TOTBOND_CLOSING		= 0.0
	SET @TOTALINST_AMOUNT		= 0.0
	SET @BOND_APR_AMOUNT		= 0.0
	SET @BOND_PAYMENT_ID		= 0

	SET @RETURN_AMOUNT			= 0.0
	SET @BOND_APR_AMOUNT		=0.0
	SET @BOND_INST				= 0
	SET @DEDUCTION_TYPE			=''
	

	SET @DESIG_ID = 0
	DECLARE @DELPAYMENT_ID AS NUMERIC
	SET @DELPAYMENT_ID = 0
	SET @PAID_AMOUNT = 0
	
	
	
	IF @IS_BONDDEDU = 1 
		BEGIN		
			SET @BOND_PAYMENT_ID = 0
			DECLARE CURBOND CURSOR FOR
			
				SELECT  LA.BOND_ID,LA.BOND_APR_ID,
						(
							CASE	WHEN LA.BOND_PAID_AMOUNT <> 0 
									THEN ISNULL(BOND_APR_AMOUNT,0) + ISNULL(LA.BOND_PAID_AMOUNT,0) 
									ELSE BOND_APR_AMOUNT END
						) AS BOND_APR_AMOUNT,
							CASE	WHEN ISNULL(QRY.INSTALLMENT_AMOUNT,0) = 0
									THEN LA.BOND_APR_INSTALLMENT_AMOUNT 
									ELSE QRY.INSTALLMENT_AMOUNT 
									END
								
						,BOND_APR_DEDUCT_FROM_SAL
						,BOND_APR_NO_OF_INSTALLMENT ,BOND_APR_DATE,LA.DEDUCTION_TYPE,
						 LA.BOND_PAID_AMOUNT
						,INSTALLMENT_START_DATE
						
				FROM	T0120_BOND_APPROVAL LA WITH (NOLOCK) INNER JOIN T0040_BOND_MASTER LM WITH (NOLOCK) ON LA.CMP_ID=LM.CMP_ID AND LA.BOND_ID = LM.BOND_ID
						LEFT OUTER JOIN
							(
									SELECT	INSTALLMENT_AMT AS INSTALLMENT_AMOUNT,BOND_APR_ID FROM DBO.T0130_BOND_INSTALLMENT_DETAIL WITH (NOLOCK)
											WHERE EFFECTIVE_DATE = 
												(
													SELECT MAX(EFFECTIVE_DATE) FROM  DBO.T0130_BOND_INSTALLMENT_DETAIL WITH (NOLOCK)
													WHERE EFFECTIVE_DATE <= @TO_DATE AND EMP_ID = @EMP_ID
												)
												AND EMP_ID = @EMP_ID		   
							)QRY ON QRY.BOND_APR_ID = LA.BOND_APR_ID 					
							
						
						  
				WHERE	EMP_ID = @EMP_ID AND LA.CMP_ID = @CMP_ID
				 		AND BOND_APR_PENDING_AMOUNT > 0 	
						AND INSTALLMENT_START_DATE <= @TO_DATE
						AND BOND_RETURN_MODE IN ('S','P')
						AND (BOND_APR_DEDUCT_FROM_SAL = 1)
					
						--AND BOND_APR_DATE <= @TO_DATE COMMMENTED BY RAJPUT ON 12112018
			OPEN CURBOND		
			FETCH NEXT FROM CURBOND INTO @BOND_ID,@BOND_APR_ID,@BOND_APR_AMOUNT,@BOND_INST_AMOUNT,@BOND_APR_DEDUCT_FROM_SAL ,
			@BOND_INST,@BOND_APR_DATE,@DEDUCTION_TYPE,@PAID_AMOUNT,@INSTALLMENT_START_DATE
			
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
				
					SELECT	@TOTBOND_CLOSING = ISNULL(SUM(BOND_PAY_AMOUNT),0) FROM T0210_MONTHLY_BOND_PAYMENT WITH (NOLOCK) WHERE 
							CMP_ID = @CMP_ID AND BOND_APR_ID =@BOND_APR_ID AND BOND_PAYMENT_DATE <=  @TO_DATE
				
					DECLARE @TEMP_MONTH_ST_DATE AS DATETIME
					DECLARE @TEMP_MONTH_END_DATE AS DATETIME
					DECLARE @TEMP_TOTBOND_CLOSING AS NUMERIC(22,0)
					DECLARE @TEMP_BOND_CLOSING AS NUMERIC(22,0)
					DECLARE @PRE_BOND_INTEREST_AMOUNT AS NUMERIC(22,2)
					SET @PRE_BOND_INTEREST_AMOUNT = 0

					IF NOT EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE MONTH(MONTH_END_DATE) = MONTH(@MONTH_ST_DATE) AND YEAR(MONTH_END_DATE) = YEAR(@MONTH_ST_DATE))
						BEGIN
			
							DECLARE CURBONDTEST CURSOR FOR
							SELECT	MONTH_ST_DATE,MONTH_END_DATE 
							FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
							WHERE	MONTH_END_DATE  BETWEEN (SELECT ISNULL( MAX(MONTH_END_DATE),@FROM_DATE) 
																FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
																WHERE  EMP_ID = @EMP_ID AND Bond_Amount = 0 AND MONTH_END_DATE > @TO_DATE) 
									AND @TO_DATE AND EMP_ID = @EMP_ID AND Bond_Amount = 0	
						
					
						END	
					
					
					
					SET @MONTH_ST_DATE = @FROM_DATE
					SET @MONTH_END_DATE = @TO_DATE

					DECLARE @BOND_CLOSING AS NUMERIC(18,0)
					SET @BOND_CLOSING = @BOND_APR_AMOUNT - @TOTBOND_CLOSING
				  
					Select @Branch_ID_Temp = Branch_ID,@desig_ID = Desig_Id From T0095_Increment I WITH (NOLOCK) inner join     
					   (select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
					   where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
					   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID 
	  
					Select @Sal_St_Date = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    

					
					if isnull(@Sal_St_Date,'') = ''    
						  begin    
							   set @Month_St_Date  = @Month_St_Date     
							   set @Month_End_Date = @Month_End_Date    
						  end     
					 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
						  begin    
							   set @Month_St_Date  = @Month_St_Date     
							   set @Month_End_Date = @Month_End_Date    
						  end     
					 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
						  begin    
							   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@From_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
							   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

							   Set @Month_St_Date = @Sal_St_Date
							   Set @Month_End_Date = @Sal_End_Date    
						  end

					Set @MonthDays = DATEDIFF(d,@Month_St_Date,@Month_End_Date)+1
					
					Set @BondDays = DATEDIFF(d,@Bond_Apr_Date,@Month_End_Date) --+ 1
					
					
				
					DECLARE @Request_status Varchar(10);	
					Declare @Bond_Inst_Amount_New Numeric(18,4)
					
					Set @Request_status = ''
					Set @Bond_Inst_Amount_New = 0
					
				
					if @paid_Amount <> 0 and @Interest_Type = 'FIX'
						BEGIN
							Select  @Return_Amount = Isnull(sum(Bond_Pay_Amount),0) From T0210_MONTHLY_Bond_PAYMENT WITH (NOLOCK) WHERE Bond_Apr_ID = @Bond_Apr_ID
							Set @Pending_Bond  = @Bond_Apr_Amount - (@Return_Amount + @paid_Amount)
						End 
					Else
						Begin
							Select  @Return_Amount = Isnull(sum(Bond_Pay_Amount),0) From T0210_MONTHLY_Bond_PAYMENT WITH (NOLOCK) WHERE Bond_Apr_ID = @Bond_Apr_ID
							Set @Pending_Bond  = @Bond_Apr_Amount - @Return_Amount 
						End 
					
				  
				
					IF @BOND_CLOSING > 0 
						BEGIN
										
							IF @BOND_INST_AMOUNT > @PENDING_BOND AND @PENDING_BOND >0 
								SET @BOND_INST_AMOUNT = @PENDING_BOND
							ELSE IF @PENDING_BOND =0 
								SET @BOND_INST_AMOUNT = 0
									
										 IF (@BOND_INST_AMOUNT) > 0 AND @BOND_APR_DEDUCT_FROM_SAL = 1 -- @BOND_INTEREST_AMOUNT
											BEGIN	
												
													
													EXEC P0210_MONTHLY_BOND_PAYMENT_INSERT 0,@BOND_APR_ID,@CMP_ID,@SALARY_TRAN_ID,
													@BOND_INST_AMOUNT,'',@TO_DATE
														
														
											END																  
										
						END
						
					FETCH NEXT FROM CURBOND INTO @BOND_ID,@BOND_APR_ID,@BOND_APR_AMOUNT,@BOND_INST_AMOUNT,
					@BOND_APR_DEDUCT_FROM_SAL ,@BOND_INST,@BOND_APR_DATE,@DEDUCTION_TYPE,
					@PAID_AMOUNT,@INSTALLMENT_START_DATE
				END 			
			CLOSE CURBOND
			DEALLOCATE CURBOND					
		END	
	RETURN




