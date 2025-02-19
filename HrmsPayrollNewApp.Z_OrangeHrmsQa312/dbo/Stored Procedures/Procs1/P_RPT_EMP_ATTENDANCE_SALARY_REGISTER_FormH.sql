

----------------------------------------------

--ADDED JIMIT 19022016------
---SALARY REGISTER FORM-H FOR DELHI---

---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_EMP_ATTENDANCE_SALARY_REGISTER_FormH]      
     @COMPANY_ID		NUMERIC  
	,@FROM_DATE		DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID		NUMERIC	
	,@GRADE_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT	VARCHAR(MAX)
	,@CAT_ID        NUMERIC = 0
	,@IS_COLUMN		TINYINT = 0
	,@SALARY_CYCLE_ID  NUMERIC  = 0
	,@SEGMENT_ID NUMERIC = 0 
	,@VERTICAL NUMERIC = 0 
	,@SUBVERTICAL NUMERIC = 0 
	,@SUBBRANCH NUMERIC = 0 
	,@SUMMARY VARCHAR(MAX)=''
	,@PBRANCH_ID VARCHAR(200) = '0'
	,@ORDER_BY   VARCHAR(30) = 'CODE' 
	,@REPORT_CALL VARCHAR(20) = 'IN-OUT'   
    ,@WEEKOFF_ENTRY VARCHAR(1) = 'Y'
    ,@STATE_ID  NUMERIC(18,0) = 0
    
    
AS      
  	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	
	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)	
	EXEC SP_RPT_FILL_EMP_CONS @COMPANY_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRADE_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
	
	
		CREATE TABLE #CROSSTAB_FORMH      
		(   
			EMP_ID NUMERIC,
			EMP_CODE VARCHAR(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			FULL_NAME_OF_THE_EMPLOYEE   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			DESIGNATION	VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			STATE_NAME	VARCHAR(50)	 COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			DESIG_DIS_NO    NUMERIC(18,0) DEFAULT 0, 
			ENROLL_NO       VARCHAR(50)	 COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS DEFAULT '',
			[MONTH]   VARCHAR(50)	 COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS DEFAULT '',
			[YEAR]    NUMERIC(18,0),
			Cmp_Address	VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS DEFAULT ''
			
		)    
		
		
				DECLARE @STATE_NAME VARCHAR(50)
				SELECT @STATE_NAME = STATE_NAME FROM T0020_STATE_MASTER WITH (NOLOCK) WHERE	CMP_ID= @COMPANY_ID AND STATE_ID = @STATE_ID
				PRINT @STATE_NAME
				INSERT INTO	#CROSSTAB_FORMH(EMP_ID,EMP_CODE,FULL_NAME_OF_THE_EMPLOYEE,DESIGNATION,STATE_NAME,DESIG_DIS_NO,ENROLL_NO,[MONTH],[YEAR],Cmp_Address)   
				SELECT		E.EMP_ID,E.ALPHA_EMP_CODE,(E.ALPHA_EMP_CODE +  ' - ' +E.EMP_FULL_NAME) AS EMP_FULL_NAME,DM.DESIG_NAME
							,@STATE_NAME,DM.Desig_Dis_No,E.Enroll_No,CONVERT(VARCHAR(3),datename(month,@From_date),100),YEAR(@From_Date),C.Cmp_Address
				FROM		T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN
								( SELECT I.EMP_ID,I.BRANCH_ID,I.DESIG_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
									( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @COMPANY_ID
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
								E.EMP_ID = INC_QRY.EMP_ID INNER JOIN 
								#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID LEFT JOIN 
								T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = INC_QRY.DESIG_ID LEFT JOIN
								T0040_SHIFT_MASTER SDM WITH (NOLOCK) ON	SDM.SHIFT_ID = E.SHIFT_ID INNER JOIN
								T0010_COMPANY_MASTER C WITH (NOLOCK) ON   C.CMP_ID = E.CMP_ID INNER JOIN
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID 
		
		
	
		------------------------------------------ATTENDANCE REGISTER------------------------------------------------
		declare @Report_For	varchar(50)
		declare @Export_Type varchar(50)
		declare @Is_Whosoff tinyint 
		declare @Description as varchar(900)        
		Declare @Description_Org as varchar(900)        
		declare @test as Varchar(4000)        
		declare @test1 as varchar(4000)
		set @Export_Type= 'EXCEL'
		set @Is_Whosoff=0
		set @Report_For=''
		
		CREATE table #Att_Muster_Excel 
	  (	
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			Status		varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Leave_Count	numeric(5,2),
			WO_HO		varchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Status_2	varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Row_ID		numeric ,
			WO_HO_Day	numeric(3,2) default 0,
			P_days		numeric(5,2) default 0,
			A_days		numeric(5,2) default 0 ,
			Join_Date	Datetime default null,
			Left_Date	Datetime default null,
			Gate_Pass_Days numeric(18,2) default 0, 
			Late_Deduct_Days numeric(18,2) default 0, 
			Early_Deduct_Days numeric(18,2) default 0, 
			Emp_code    varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Emp_Full_Name  varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Branch_Address varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
			comp_name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Branch_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Dept_Name  varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Grd_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Desig_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			P_From_date  datetime,
			P_To_Date datetime,
			BRANCH_ID numeric(18,0),
			Desig_Dis_No numeric(18,2) default 0,
			SUBBRANCH_NAME VARCHAR(200) DEFAULT '' COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS        
	  )
	  
	  	  
		CREATE NONCLUSTERED INDEX IX_Data ON dbo.#Att_Muster_Excel
					(	Emp_Id,Emp_code,Row_ID ) 
					
					
				  
		exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Company_Id,@From_Date,@To_Date,@Branch_ID,
													  @Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,
													  @Emp_ID,@Constraint,@Report_For,@Export_Type
		Declare @Month_Days as numeric
		Set @Month_Days = DATEDIFF (DD,@From_Date,@To_Date) + 1     

	
	
			If @Month_Days = 31
			Begin 
				DECLARE Att_Muster CURSOR FOR   
				Select Top 38
				Case When cast(Row_ID as varchar(2)) ='32' then 'P' 
				else 
				case When cast(Row_ID as varchar(2)) ='33' then 'A' 
				else
				case When cast(Row_ID as varchar(2)) ='34' then 'L'
				else 
				case When cast(Row_ID as varchar(2)) ='35' then 'W'
				else
				case When cast(Row_ID as varchar(2)) ='36' then 'H'
				else
				case When cast(Row_ID as varchar(2)) ='37' then 'LC'
				else
				case When cast(Row_ID as varchar(2)) ='38' then 'GP'  -- Changed by Gadriwala Muslim 27042015
				
				else
				Cast(DATEPART(day,For_Date) as varchar(2))
				end
				end
				end
				end
				end
				end
				End as Row_ID, For_Date
				from #Att_Muster_Excel  order by Emp_ID,For_Date --asc  
			End
			Else If @Month_Days = 30
					Begin 
						DECLARE Att_Muster CURSOR FOR   
						Select Top 38
						Case When cast(Row_ID as varchar(2)) ='31' then '0' 
						Else
						Case When cast(Row_ID as varchar(2)) ='32' then 'P' 
						else 
						case When cast(Row_ID as varchar(2)) ='33' then 'A' 
						else
						case When cast(Row_ID as varchar(2)) ='34' then 'L'
						else 
						case When cast(Row_ID as varchar(2)) ='35' then 'W'
						else
						case When cast(Row_ID as varchar(2)) ='36' then 'H'
						else
						case When cast(Row_ID as varchar(2)) ='37' then 'LC'
						else
						case When cast(Row_ID as varchar(2)) ='38' then 'GP'  -- Changed by Gadriwala Muslim 27042015
						
						else
						Cast(DATEPART(day,For_Date) as varchar(2))
						end
						end
						end
						end
						end
						end
						end
						End as Row_ID, For_Date
						from #Att_Muster_Excel  order by Emp_ID,For_Date --asc  
					End
			Else If @Month_Days = 28
					Begin 
						DECLARE Att_Muster CURSOR FOR   
						Select Top 38
						Case When cast(Row_ID as varchar(2)) ='29' then 'AA' 
						Else
						Case When cast(Row_ID as varchar(2)) ='30' then 'BB' 
						Else
						Case When cast(Row_ID as varchar(2)) ='31' then 'CC' 
						Else
						Case When cast(Row_ID as varchar(2)) ='32' then 'P' 
						else 
						case When cast(Row_ID as varchar(2)) ='33' then 'A' 
						else
						case When cast(Row_ID as varchar(2)) ='34' then 'L'
						else 
						case When cast(Row_ID as varchar(2)) ='35' then 'W'
						else
						case When cast(Row_ID as varchar(2)) ='36' then 'H'
						else
						case When cast(Row_ID as varchar(2)) ='37' then 'LC'
						else
						case When cast(Row_ID as varchar(2)) ='38' then 'GP'  -- Changed by Gadriwala Muslim 27042015
						else
						Cast(DATEPART(day,For_Date) as varchar(2))
						end
						end
						end
						end
						end
						end
						End
						End
						end
						End as Row_ID, For_Date
						from #Att_Muster_Excel  order by Emp_ID,For_Date --asc  
					End
			Else If @Month_Days = 29
					Begin 
						DECLARE Att_Muster CURSOR FOR   
						Select Top 38
						Case When cast(Row_ID as varchar(2)) ='30' then 'AA' 
						Else
						Case When cast(Row_ID as varchar(2)) ='31' then 'BB' 
						Else
						Case When cast(Row_ID as varchar(2)) ='32' then 'P' 
						else 
						case When cast(Row_ID as varchar(2)) ='33' then 'A' 
						else
						case When cast(Row_ID as varchar(2)) ='34' then 'L'
						else 
						case When cast(Row_ID as varchar(2)) ='35' then 'W'
						else
						case When cast(Row_ID as varchar(2)) ='36' then 'H'
						else
						case When cast(Row_ID as varchar(2)) ='37' then 'LC'
						else
						case When cast(Row_ID as varchar(2)) ='38' then 'GP'  -- Changed by Gadriwala Muslim 27042015
						else
						Cast(DATEPART(day,For_Date) as varchar(2))
						end
						end
						end
						end
						end
						end
						End
						end
						End as Row_ID, For_Date
						from #Att_Muster_Excel  order by Emp_ID,For_Date --asc  
					End
		
		  DECLARE @INSERT_WEEKDAY VARCHAR(MAX);
		  DECLARE @VALUE_WEEKDAY VARCHAR(MAX);
		  DECLARE @WEEKDAY VARCHAR(2);	
		  DECLARE @FOR_DATE DATETIME;
		  
		  SET @INSERT_WEEKDAY = '';
		  SET @VALUE_WEEKDAY = ''

		  OPEN Att_Muster        
		   fetch next from Att_Muster into @Description, @FOR_DATE
		   while @@fetch_status = 0        
			Begin        
		             
		        
				IF ISNUMERIC(@Description) = 1
				BEGIN
					
					IF CAST(@Description AS NUMERIC) > 0
					BEGIN
						
						SET @WEEKDAY = DATENAME(DW, @FOR_DATE);
						SET @INSERT_WEEKDAY = @INSERT_WEEKDAY + '[' + @Description + '],'
						SET @VALUE_WEEKDAY = @VALUE_WEEKDAY + '''' + @WEEKDAY + ''','
						
					END
				END
		        
		        
		        
				set @Description_Org=@Description        
				set @Description=replace(@Description,' ','_')        
				set @Description=replace (@Description,'.','_')        

					If @Description <> 'AA' And @Description <>'BB' and @Description <> 'CC' and @Description <> '0'
					Begin
						Set @test ='alter table  #CROSSTAB_FORMH ADD ['+ @Description +']  varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS default '''''        
						exec(@test)         				
						set @test=''        
						
					End             
			fetch next from Att_Muster into @Description, @FOR_DATE        
			End        
		  close Att_Muster         
		  deallocate Att_Muster 
			
			
						
			declare @Code as varchar(50)        
			Declare @EmpName as varchar(200) 
			Declare @Status as varchar(50)  
			Declare @Status_2 as varchar(50)  
			Declare @Extra_AB_Deduction as numeric(18,2)
			Declare @Present_days as numeric(18,2)
			Declare @A_Days as Numeric(18,2)
			Declare @Unpaid_Leave_Days as Numeric(18,2)
			Declare @Pre_Emp_Code as varchar(50)
			Declare @Absent_Days as numeric(18,2)
			Declare @Leave_Count as Numeric(18,2)
			Declare @Gate_Pass_Days as numeric(18,2)
			Declare @Late_Deduct_Days as numeric(18,2) 
			Declare @Early_Deduct_Days as numeric(18,2)
			Declare @WO_HO_Days as numeric(18,2) 
			Declare @P_Days as numeric(22,2)           
  
			SET @Description = ''        
			Set @Extra_AB_Deduction = 0
			Set @Present_days = 0
			Set @A_Days = 0
			Set @P_Days = 0
			Set @Unpaid_Leave_Days = 0
			Set @Leave_Count = 0
			set @Gate_Pass_Days = 0 
			set @Late_Deduct_Days = 0 
			set @Early_Deduct_Days = 0 
			set @WO_HO_Days = 0 
			
	DECLARE Att_MusterValue CURSOR FOR        
	  select A.Emp_code,A.Emp_Full_Name,Status,isnull(Status_2,'') as  Status_2, P_Days,A_Days,WO_HO_Day,
  			case When cast(Row_ID as varchar(2) ) ='32' then 'P' 
			else 
			case When cast(Row_ID as varchar(2) ) ='33' then 'A' 
			else
			case When cast(Row_ID as varchar(2) ) ='34' then 'L'
			else 
			case When cast(Row_ID as varchar(2)) ='35' then 'W'
			else
			case When cast(Row_ID as varchar(2)) ='36' then 'H'
			else
			case When cast(Row_ID as varchar(2)) ='37' then 'LC'
			else
			case When cast(Row_ID as varchar(2)) ='38' then 'GP'
			else
			Cast(DATEPART(day,For_Date) as varchar(2))
			end
			end
			end
			end
			end
			end
			End as Row_ID,
			Isnull(Extra_AB_Deduction,0), Leave_Count,Early_Deduct_Days
		from #Att_Muster_Excel A Inner Join T0080_EMP_MASTER E WITH (NOLOCK) on A.Emp_Id = E.Emp_ID
		order by A.Emp_Id,For_Date      
   
		  OPEN Att_MusterValue        
		   fetch next from Att_MusterValue into @Code,@EmpName,@Status,@Status_2,@P_Days,@A_Days,@WO_Ho_Days,@Description,@Extra_AB_Deduction,@Leave_Count,@Early_Deduct_Days
		   while @@fetch_status = 0        
			Begin        
				If @Pre_Emp_Code <> @Code
					Set @Unpaid_Leave_Days = 0

			 set @Description_Org=@Description        
			 set @Description=replace(@Description,' ','_')        
			 set @Description=replace (@Description,'.','_')                 
		             
			 Set @test1 ='Update #CROSSTAB_FORMH set [' + cast(@Description as varchar(2)) + '] = ''' +  Cast(@Status as varchar(50))  + '''  Where  EMp_Code = '''+ @Code + ''''        
		     
			 exec(@test1)        
			 set @test=''
		     
		    
			
					Set @Pre_Emp_Code = @Code
		             
			fetch next from Att_MusterValue into @Code,@EmpName,@Status,@Status_2,@P_Days,@A_Days,@WO_Ho_Days,@Description,@Extra_AB_Deduction,@Leave_Count,@Early_Deduct_Days
			End        
		  close Att_MusterValue         
		  deallocate Att_MusterValue                  
			
			
		------------------------------------------ENDED-------------------------------------------------------------------
		
			SET @test = 'ALTER TABLE  #CROSSTAB_FORMH ADD REMARKS VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS default '''''
			EXEC(@test)
		
	DECLARE @COLUMNS NVARCHAR(4000)
	DECLARE @CTC_BASIC NUMERIC(18,2)
	DECLARE @AD_NAME_DYN NVARCHAR(100)
	DECLARE @VAL NVARCHAR(MAX)
	SET @COLUMNS = '#'
	DECLARE @CTC_COLUMNS NVARCHAR(100)
	DECLARE @ALLOW_AMOUNT NUMERIC(18,2)
	DECLARE @CTC_AD_FLAG VARCHAR(1)
	
	DECLARE @SUM_OF_ALLOWNACES_EARNING AS VARCHAR(MAX)
	SET @SUM_OF_ALLOWNACES_EARNING=''
	DECLARE @AD_LEVEL NUMERIC
	SET @AD_LEVEL = 0
		
		
		CREATE TABLE #CTCMAST
				(   CMP_ID			NUMERIC(18,0)
				   ,EMP_ID1			NUMERIC(18,0)  
				   ,FULL_NAME_OF_EMPLOYEE   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
					DESIGNATION_Name VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
					BASIC_SALARY	NUMERIC(18,2)				   
				   ,Dearness_Allowance	NUMERIC(18,2) DEFAULT 0
				   ,HRA				NUMERIC(18,2) DEFAULT 0
				   ,Other_Allowance NUMERIC(18,2) DEFAULT 0
				   ,OT  NUMERIC(18,2) DEFAULT 0
				   ,Consolidated_Wages NUMERIC(18,2) DEFAULT 0 			   
				   ,Advance_Taken	NUMERIC(18,2) DEFAULT 0
				   ,Fine_And_Deduction_On_Damage NUMERIC(18,2) DEFAULT 0
				   ,ESI  NUMERIC(18,2) DEFAULT 0
				   ,PF	NUMERIC(18,2) DEFAULT 0
				   ,PT	NUMERIC(18,2) DEFAULT 0
				   ,Income_Tax NUMERIC(18,2) DEFAULT 0
				   ,Other_Deduction NUMERIC(18,2) DEFAULT 0
				   ,Total_Deduction NUMERIC(18,2) DEFAULT 0
				   ,Net_Amount	NUMERIC(18,2) DEFAULT 0
				   ,Employee_Signature VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				   ,Date_Of_Wages_Payable VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				  )			  
	
				INSERT INTO #CTCMAST(CMP_ID,EMP_ID1,FULL_NAME_OF_EMPLOYEE,DESIGNATION_Name) 
				SELECT E.CMP_ID,E.EMP_ID AS EMP_ID1,(E.ALPHA_EMP_CODE +  ' - ' +E.EMP_FULL_NAME) AS FULL_NAME_OF_EMPLOYEE,DM.Desig_Name
				FROM T0080_EMP_MASTER E	WITH (NOLOCK) INNER JOIN
					( SELECT I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
						( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						AND CMP_ID = @COMPANY_ID
						GROUP BY EMP_ID  ) QRY ON
						I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
					E.EMP_ID = INC_QRY.EMP_ID 
				INNER JOIN #EMP_CONS EC ON E.EMP_ID = EC.EMP_ID  
				LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = INC_QRY.DESIG_ID
-------------------------------START ---------------------------------------------------------			  
				  DECLARE @TOTAL_DAYS_WORKED NUMERIC(18,2)
				  DECLARE @TOTAL_OVERTIME_HOURS_WORKED NUMERIC(18,2)
				  DECLARE @NORMAL_EARNINGS NUMERIC(18,2)
					
				UPDATE  C 
				SET		C.BASIC_SALARY = Q.Basic_Salary					
						,C.Consolidated_Wages = GROSS_SALARY
						,C.Net_Amount = Q.NET_AMOUNT
						,C.OTHER_DEDUCTION = OTHER_DEDU_AMOUNT
						,C.OT = Q.OT_AMOUNT
						,C.PT = Q.PT_Amount							
				FROM 	#CTCMAST C INNER JOIN
				(						
				SELECT  SUM(OT_AMOUNT) aS OT_AMOUNT,MS.Salary_Amount as Basic_Salary
						,Ms.EMP_ID,Ms.CMP_ID,Ms.GROSS_SALARY as GROSS_SALARY ,NET_AMOUNT
						,OTHER_DEDU_AMOUNT,PT_Amount
				FROM T0200_MONTHLY_SALARY	MS WITH (NOLOCK) INNER JOIN
						#EMP_CONS EC On EC.EMP_ID = Ms.Emp_ID 
				WHERE   MS.Cmp_ID= @company_Id and month(Month_End_Date) = month(@To_date) and YEAR(Month_End_Date) = YEAR(@To_date)
				GROUP BY Ms.EMP_ID,SALARY_AMOUNT,Ms.CMP_ID,Ms.GROSS_SALARY,NET_AMOUNT,OT_AMOUNT,OTHER_DEDU_AMOUNT
						,PT_Amount
				)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID	
					
					
					
			-----------------for HRA ----------------------------		
				UPDATE  C 
				SET		C.HRA = Q.M_AD_AMOUNT
				FROM	#CTCMAST C INNER JOIN
						(
						select MAD.M_AD_AMOUNT ,EC.EMP_ID,AM.CMP_ID from T0050_AD_MASTER AM WITH (NOLOCK) INNER join
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.Emp_ID
						where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 17 and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)--and MAD.For_Date > = @From_date and MAD.For_Date < = @To_Date			
						)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID
			-----------------END HRA ----------------------------				
			-----------------FOR DA-------------------			
				UPDATE  C 
				SET		C.Dearness_Allowance = Q.M_AD_AMOUNT
				FROM	#CTCMAST C INNER JOIN
						(
						select MAD.M_AD_AMOUNT,EC.EMP_ID,AM.CMP_ID from T0050_AD_MASTER AM WITH (NOLOCK) INNER join
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.Emp_ID
						where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 11 and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)--and MAD.For_Date > = @From_date and MAD.For_Date < = @To_Date			
						)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID						
			-----------------END DA ----------------------------			
				UPDATE  C 
				SET		C.Other_Allowance = C.Consolidated_Wages -(C.HRA + C.Dearness_Allowance + C.OT + C.BASIC_SALARY)						
				FROM 	#CTCMAST C INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = C.EMP_ID1
		----------------------------Deductions--------------------
				UPDATE  C 
				SET		C.Advance_Taken = Q.ADVANCE
						,C.Total_Deduction = Q.Total_Dedu_Amount					
				FROM	#CTCMAST C INNER JOIN
						(
						select SUM(ISNULl(Ms.Advance_Amount,0)) AS ADVANCE,MS.EMP_ID,CMP_ID,Ms.Total_Dedu_Amount from T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MS.Emp_ID
						where	CMP_ID = @Company_ID AND month(Month_End_Date) = month(@To_date) and YEAR(Month_End_Date) = YEAR(@To_date)--and MS.Month_St_Date > =@From_Date and MS.Month_End_Date<=@To_Date
						GROUP BY MS.Emp_ID,MS.Cmp_ID,MS.Total_Dedu_Amount
						)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID
								
				UPDATE  C 
				SET		C.INCOME_TAX = Q.M_AD_AMOUNT
				FROM	#CTCMAST C INNER JOIN
						(
						select MAD.M_AD_AMOUNT,EC.EMP_ID,AM.CMP_ID from T0050_AD_MASTER AM WITH (NOLOCK) INNER join
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.Emp_ID
						where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 1 and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)--and MAD.For_Date > = @From_date and MAD.For_Date < = @To_Date			
						)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID
		
				UPDATE  C 
				SET		C.PF = Q.M_AD_AMOUNT
				FROM	#CTCMAST C INNER JOIN
						(
						select MAD.M_AD_AMOUNT,EC.EMP_ID,AM.CMP_ID from T0050_AD_MASTER AM WITH (NOLOCK) INNER join
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.Emp_ID
						where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 2 and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)--and MAD.For_Date > = @From_date and MAD.For_Date < = @To_Date			
						)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID
		
				UPDATE  C 
				SET		C.ESI = Q.M_AD_AMOUNT
				FROM	#CTCMAST C INNER JOIN
						(
						select MAD.M_AD_AMOUNT,EC.EMP_ID,AM.CMP_ID from T0050_AD_MASTER AM WITH (NOLOCK) INNER join
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.Emp_ID
						where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 3 and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)--and MAD.For_Date > = @From_date and MAD.For_Date < = @To_Date		
						)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID
									
			
						
				UPDATE  C 
				SET		C.OTHER_DEDUCTION = case WHEN (C.Total_Deduction < (C.Advance_Taken + C.INCOME_TAX + C.PF + C.ESI + C.PT)) THEN	
													((C.Advance_Taken + C.INCOME_TAX + C.PF + C.ESI + C.PT) - C.Total_Deduction)
													ELSE
														(C.Total_Deduction - (C.Advance_Taken + C.INCOME_TAX + C.PF + C.ESI + C.PT))
													ENd		
				FROM 	#CTCMAST C INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = C.EMP_ID1			
				
		
		--------------------------------end-----------------------------------------------	
			UPDATE C
			SET		C.Employee_Signature = Q.Payment_Mode					
			FROM	#CTCMAST C INNER JOIN
					(
						SELECT  I.Emp_ID,I.Payment_Mode,cONVERT(varchar(20),MS.Sal_Generate_Date,103) AS Sal_Generate_Date from T0095_INCREMENT I WITH (NOLOCK) inner JOIN
								 ( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @COMPANY_ID
									GROUP BY EMP_ID) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID INNER JOIN
									#EMP_CONS EC ON QRY.EMP_ID = EC.EMP_ID INNER JOIN
									T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MS.Emp_ID = QRY.Emp_ID and Ms.Increment_ID = QRY.INCREMENT_ID
					)Q ON Q.Emp_ID = C.EMP_ID1
	
	
		
			UPDATE #CROSSTAB_FORMH SET EMP_CODE = '="' + EMP_CODE + '"'
	 
			SELECT ROW_NUMBER() OVER(ORDER BY  @ORDER_BY   ASC) AS SR_NO,C.*,S.*
			INTO #CROSSTABDATA 
			FROM #CROSSTAB_FORMH AS C 
			INNER JOIN #CTCMAST S ON C.EMP_ID=S.EMP_ID1		
			
			
			ALTER TABLE  #CROSSTABDATA DROP COLUMN EMP_ID
			ALTER TABLE  #CROSSTABDATA DROP COLUMN CMP_ID
			ALTER TABLE  #CROSSTABDATA DROP COLUMN EMP_ID1
			
			
			SELECT * FROM #CROSSTABDATA ORDER BY
			CASE WHEN @Order_By ='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(#CROSSTABDATA.Enroll_No AS VARCHAR), 21) 
				--WHEN @Order_By='Name' THEN #CROSSTABDATA.
				When @Order_By = 'Designation' then (CASE WHEN #CROSSTABDATA.Desig_dis_No  = 0 THEN #CROSSTABDATA.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(#CROSSTABDATA.Desig_dis_No AS VARCHAR), 21)   END)   
				---ELSE RIGHT(REPLICATE(N' ', 500) + #CTCMast.Emp_Code, 500) 
				End,Case When IsNumeric(Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"',''), 20)
					 When IsNumeric(Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
					 Else Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"','') End 
			
			
			DROP TABLE #CROSSTAB_FORMH
			
			
			
