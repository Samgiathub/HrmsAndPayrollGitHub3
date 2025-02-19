

---------------------------------------------

--ADDED JIMIT 05022015------
---SALARY REGISTER FORM-II FOR MAHARASTRA---
---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)--- 
---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_EMP_ATTENDANCE_SALARY_REGISTER_FormII]      
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
	
	
		CREATE TABLE #CROSSTAB_FORMR      
		(   
			EMP_ID NUMERIC,
			EMP_CODE VARCHAR(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			FULL_NAME_OF_THE_EMPLOYEE   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			AGE VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			SEX VARCHAR(20),
			DATE_OF_ENTRY_INTO_SERVICE VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Nature_Of_Work_DESIGNATION	VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			WORKING_HOURS_FROM VARCHAR(5) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS ,
			WORKING_HOURS_TO VARCHAR(5) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS ,
			INTERVAL_FOR_REST_FROM	VARCHAR(5) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS ,
			INTERVAL_FOR_REST_TO	VARCHAR(5) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS ,
			CMP_ADDRESS VARCHAR(500) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			STATE_NAME	VARCHAR(50)	 COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			DESIG_DIS_NO    NUMERIC(18,0) DEFAULT 0, 
			ENROLL_NO       VARCHAR(50)	 COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS DEFAULT '',
			Name_Of_The_Employer	varchar(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS 	
		)    
		
		
				DECLARE @STATE_NAME VARCHAR(50)
				SELECT @STATE_NAME = STATE_NAME FROM T0020_STATE_MASTER WITH (NOLOCK) WHERE	CMP_ID= @COMPANY_ID AND STATE_ID = @STATE_ID
				
				INSERT INTO	#CROSSTAB_FORMR(EMP_ID,EMP_CODE,FULL_NAME_OF_THE_EMPLOYEE,AGE,SEX,DATE_OF_ENTRY_INTO_SERVICE,Nature_Of_Work_DESIGNATION,WORKING_HOURS_FROM,WORKING_HOURS_TO,INTERVAL_FOR_REST_FROM,
											INTERVAL_FOR_REST_TO,CMP_ADDRESS,STATE_NAME,DESIG_DIS_NO,ENROLL_NO,Name_Of_The_Employer)   
				SELECT		E.EMP_ID,E.ALPHA_EMP_CODE,(E.ALPHA_EMP_CODE +  ' - ' +E.EMP_FULL_NAME) AS EMP_FULL_NAME,dbo.Age(Date_Of_Birth,getdate(),'Y') AS AGE,
							CASE WHEN E.GENDER='M' THEN 'MALE' ELSE 'FEMALE' END SEX,CONVERT(VARCHAR(20),E.DATE_OF_JOIN,103) AS DATE_OF_JOIN,DM.DESIG_NAME,SDM.SHIFT_ST_TIME,SDM.SHIFT_END_TIME,SDM.S_ST_TIME,SDM.S_END_TIME 
							,(CASE WHEN BM.BRANCH_ADDRESS = '' THEN C.CMP_ADDRESS ELSE BM.BRANCH_ADDRESS END) AS CMP_ADDRESS
							,@STATE_NAME,DM.Desig_Dis_No,E.Enroll_No
							,(Select top 1 Director_Name FROM T0010_COMPANY_DIRECTOR_DETAIL WITH (NOLOCK) where Cmp_ID = @company_Id)
				FROM		T0080_EMP_MASTER E WITH (NOLOCK)	INNER JOIN
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
		
		
	
---------------------------------------------------------ATTENDANCE REgister --------------------------------------------------------
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
			Desig_Dis_No numeric(18,2) default 0 ,
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
						Set @test ='alter table  #CROSSTAB_FORMR ADD ['+ @Description +']  varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS default '''''        
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
		             
			 Set @test1 ='Update #CROSSTAB_FORMR set [' + cast(@Description as varchar(2)) + '] = ''' +  Cast(@Status as varchar(50))  + '''  Where  EMp_Code = '''+ @Code + ''''        
		     
			 exec(@test1)        
			 set @test=''			
										
					Set @Pre_Emp_Code = @Code
		             
			fetch next from Att_MusterValue into @Code,@EmpName,@Status,@Status_2,@P_Days,@A_Days,@WO_Ho_Days,@Description,@Extra_AB_Deduction,@Leave_Count,@Early_Deduct_Days
			End        
		  close Att_MusterValue         
		  deallocate Att_MusterValue                  
					
----------------------------------------------------------------ended-------------------------------------------------------------------------			
			
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
				   ,####			VARCHAR(2)
				   ,S_NO		Numeric(18,0)
				   ,TOTAL_DAYS_WORKED NUMERIC(18,2)  --SAL_CAL_DAY				   
				   ,EMployee_Full_Name   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
					MINIMUM_RATE_OF_WAGES_PAYABLE NUMERIC(18,2)
				   ,ACTUAL_RATE_OF_WAGES_PAYABLE NUMERIC(18,2)
				   ,TOTAL_PRODUCTION_IN_CASE_OF_PIECE_RATE NUMERIC(18,0)
				   ,TOTAL_OVERTIME_HOURS_WORKED NUMERIC(18,2)
				   ,NORMAL_EARNINGS NUMERIC(18,2)
				   ,Housing_Rent_Allowance	NUMERIC(18,2)
				   ,OT_Earnings NUMERIC(18,2)
				   ,Other_Allowance NUMERIC(18,2)
				  )
				  
	
		INSERT INTO #CTCMAST 
				SELECT E.CMP_ID,E.EMP_ID AS EMP_ID1,'',0,0,E.ALPHA_EMP_CODE +  ' - ' + E.Emp_Full_Name,0,0,0,0,0,0,0,0
				FROM T0080_EMP_MASTER E	WITH (NOLOCK) INNER JOIN
					( SELECT I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
						( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						AND CMP_ID = @COMPANY_ID
						GROUP BY EMP_ID  ) QRY ON
						I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
					E.EMP_ID = INC_QRY.EMP_ID 
				INNER JOIN #EMP_CONS EC ON E.EMP_ID = EC.EMP_ID  
				
	---------------------FOR ALLOWANCE AND DEDUCTION-------------------------------------

		
			
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD GROSS_WAGES_PAYABLE NUMERIC(18,2)'
			EXEC(@VAL)
			

	
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD ADVANCE NUMERIC(18,2)'
			EXEC(@VAL)
			
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD PF NUMERIC(18,2)'
			EXEC(@VAL)
			
			
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD PROFESSIONAL_TAX NUMERIC(18,2)'
			EXEC(@VAL)
			
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD INCOME_TAX NUMERIC(18,2)'
			EXEC(@VAL)
			
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD ESIC NUMERIC(18,2)'
			EXEC(@VAL)
			
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD OTHER_DEDUCTION NUMERIC(18,2)'
			EXEC(@VAL)
			
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD TOTAL_DEDUCTION NUMERIC(18,2)'
			EXEC(@VAL)
			
			
			SET @VAL = 'ALTER TABLE  #CTCMAST ADD NET_WAGES_PAID NUMERIC(18,2)'
			EXEC(@VAL)

-----------------------------ENDED ALLOWANCE/DEDUCTION------------------------------------------------------------

--------------------------START ---------------------------------------------------------
				
				
				
				  DECLARE @TOTAL_DAYS_WORKED NUMERIC(18,2)
				  DECLARE @TOTAL_OVERTIME_HOURS_WORKED NUMERIC(18,2)
				  DECLARE @NORMAL_EARNINGS NUMERIC(18,2)
							
			-----------------for HRA ----------------------------		
				UPDATE  C 
				SET		C.Housing_Rent_Allowance = Q.M_AD_AMOUNT
				FROM	#CTCMAST C INNER JOIN
						(
						select MAD.M_AD_AMOUNT,EC.EMP_ID,AM.CMP_ID from T0050_AD_MASTER AM WITH (NOLOCK) INNER join
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.Emp_ID
						where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 17 and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)--and	MAD.For_Date > = @From_date and MAD.For_Date < = @To_Date			
						)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID
			-----------------END HRA ----------------------------				
										
				UPDATE  C 
				SET		C.TOTAL_DAYS_WORKED = Q.Present_Days, C.TOTAL_OVERTIME_HOURS_WORKED = Q.TOTAL_OVERTIME_HOURS_WORKED
						,C.NORMAL_EARNINGS = Q.BASIC_SALARY	
						,C.GROSS_WAGES_PAYABLE = GROSS_SALARY
						,C.NET_WAGES_PAID = Q.NET_AMOUNT
						,C.OTHER_DEDUCTION = OTHER_DEDU_AMOUNT
						,C.OT_Earnings = Q.OT_AMOUNT
						,C.PROFESSIONAL_TAX = Q.PT_Amount	
						,C.ACTUAL_RATE_OF_WAGES_PAYABLE = Q.ACTUAL_RATE_OF_WAGES_PAYABLE							
				FROM 	#CTCMAST C INNER JOIN
				(						
				SELECT Present_Days,SUM(ISNULL(OT_HOURS,0)) AS TOTAL_OVERTIME_HOURS_WORKED,SUM(OT_AMOUNT) aS OT_AMOUNT
						,SALARY_AMOUNT AS BASIC_SALARY,Ms.EMP_ID,Ms.CMP_ID,Ms.GROSS_SALARY as GROSS_SALARY ,NET_AMOUNT
						,OTHER_ALLOW_AMOUNT,OTHER_DEDU_AMOUNT,PT_Amount,INC_QRY.Gross_Salary AS ACTUAL_RATE_OF_WAGES_PAYABLE
				FROM T0200_MONTHLY_SALARY	MS WITH (NOLOCK) INNER JOIN
					( SELECT I.EMP_ID,I.BASIC_SALARY,I.Gross_Salary,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
									( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @COMPANY_ID
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
								MS.EMP_ID = INC_QRY.EMP_ID									
				 WHERE month(Month_End_Date) = month(@To_date) and YEAR(Month_End_Date) = YEAR(@To_date)--MONTH_ST_DATE BETWEEN @FROM_DATE AND @TO_DATE
				GROUP BY Ms.EMP_ID,Present_Days,SALARY_AMOUNT,Ms.CMP_ID,Ms.GROSS_SALARY,NET_AMOUNT,OT_AMOUNT,OTHER_ALLOW_AMOUNT,OTHER_DEDU_AMOUNT
						,PT_Amount,INC_QRY.Gross_Salary
				)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID				
								
				
				UPDATE  C 
				SET		C.Other_Allowance = ISNULL(C.GROSS_WAGES_PAYABLE,0) -(ISNULL(C.NORMAL_EARNINGS,0) + ISNULL(C.OT_Earnings,0) + ISNULL(C.Housing_Rent_Allowance,0))						
				FROM 	#CTCMAST C INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = C.EMP_ID1
		----------------------------Deductions------------------------------------
		
				UPDATE  C 
				SET		C.ADVANCE = Q.ADVANCE
				FROM	#CTCMAST C INNER JOIN
						(
						select SUM(ISNULl(Ms.Advance_Amount,0)) AS ADVANCE,MS.EMP_ID,CMP_ID from T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MS.Emp_ID
						where	CMP_ID = @Company_ID and month(Month_End_Date) = month(@To_date) and YEAR(Month_End_Date) = YEAR(@To_date)--MS.Month_St_Date > =@From_Date and MS.Month_End_Date<=@To_Date
						GROUP BY MS.Emp_ID,MS.Cmp_ID
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
				SET		C.ESIC = Q.M_AD_AMOUNT
				FROM	#CTCMAST C INNER JOIN
						(
						select MAD.M_AD_AMOUNT,EC.EMP_ID,AM.CMP_ID from T0050_AD_MASTER AM WITH (NOLOCK) INNER join
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.Emp_ID
						where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 3 and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)--and MAD.For_Date > = @From_date and MAD.For_Date < = @To_Date		
						)Q ON Q.EMP_ID = C.EMP_ID1 AND Q.CMP_ID = C.CMP_ID
						
				
				
				UPDATE  C 
				SET		C.TOTAL_DEDUCTION = (ISNULL(C.ADVANCE,0) + ISNULL(C.INCOME_TAX,0) + ISNULL(C.PF,0) + ISNULL(C.ESIC,0) + ISNULL(C.OTHER_DEDUCTION,0) + ISNULL(C.PROFESSIONAL_TAX,0))					
				FROM 	#CTCMAST C INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = C.EMP_ID1			
				
		
		--------------------------------end-----------------------------------------------		
		
				
				
-----------------------END---------------------------------------	

------------------------------LEAVE WAGES REGISTER------------------------------------------------------------------------
	
			DECLARE @LEAVE_ID AS NUMERIC
			DECLARE @COUNT NUMERIC
			DECLARE  @TEMP_DATE DATETIME
			DECLARE @EMP_ID_CUR AS NUMERIC
			
			CREATE TABLE #EMP_LEAVE
					(
						ROW_ID				NUMERIC		IDENTITY (1,1) NOT NULL,
						LEAVE_ID			NUMERIC,
						EMP_ID				NUMERIC,
						CMP_ID				NUMERIC,
						LEAVE_PREVIOUS_BALANCE	NUMERIC(18,2),
						LEAVE_EARNED_DURING_MONTH		NUMERIC(18,2), --LEAVE_CREDITED
						LEAVE_USE			NUMERIC(18,2),
						LEAVE_CLOSE		NUMERIC(18,2),
						MONTH_DATE			DATETIME			
					)
	
		
				
				Insert Into #EMP_LEAVE
				SELECT 0,EMP_ID1,CMP_ID,0,0,0,0,'' from 
				#CTCMAST 
				
				UPDATE 	CQ
				SET CQ.LEAVE_USE = Q.LEAVE_AVAILED_CL,
					Cq.LEAVE_ID = Q.Leave_ID
				FROM #EMP_LEAVE CQ INNER JOIN 
				(
				SELECT  SUM(IsNull(LEAVE_USED,0))AS LEAVE_AVAILED_CL,EC.EMP_ID,LM.Leave_ID
				FROM    T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN
						T0040_LEAVE_MASTER LM WITH (NOLOCK) On Lm.Leave_ID = Lt.Leave_ID and Lm.Cmp_ID = Lt.Cmp_ID INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = LT.EMP_ID														
				WHERE   Lt.CMP_ID = @COMPANY_ID AND FOR_DATE > = @FROM_DATE AND FOR_DATE <= @TO_DATE  and 
						LM.Leave_Type = 'Encashable'
					--AND LEAVE_ID = @LEAVE_ID 
				GROUP BY  EC.EMP_ID,LM.Leave_ID
				)Q ON Q.EMP_ID = CQ.EMP_ID
				
										
				UPDATE 	CQ
				SET CQ.LEAVE_EARNED_DURING_MONTH = Q.Leave_Credit,
					Cq.LEAVE_ID = Q.Leave_ID
				FROM #EMP_LEAVE CQ INNER JOIN 
				(
					SELECT  SUM(LT.Leave_Credit)AS Leave_Credit,EC.EMP_ID,LM.Leave_ID
					FROM    T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN
						T0040_LEAVE_MASTER LM WITH (NOLOCK) On Lm.Leave_ID = Lt.Leave_ID and Lm.Cmp_ID = Lt.Cmp_ID INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = LT.EMP_ID														
					WHERE   Lt.CMP_ID = @COMPANY_ID AND FOR_DATE > = @FROM_DATE AND FOR_DATE <= @TO_DATE  AND 
					LM.Leave_Type = 'Encashable'
					--LEAVE_ID = @LEAVE_ID 							
					GROUP BY  EC.EMP_ID,LM.Leave_ID
				)Q ON Q.EMP_ID = CQ.EMP_ID
				
				UPDATE 	CQ
				SET CQ.LEAVE_CLOSE = Q2.LEAVE_CLOSING,
					Cq.LEAVE_ID = Q2.Leave_ID
				FROM #EMP_LEAVE CQ INNER JOIN 
				(
					SELECT LEAVE_CLOSING,L1.EMP_ID,L1.LEAVE_ID
							FROM T0140_LEAVE_TRANSACTION L1 WITH (NOLOCK) INNER JOIN
								 ( SELECT MAX(FOR_DATE)AS FOR_DATE,LT.EMP_ID,LT.LEAVE_ID
								   FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN
						T0040_LEAVE_MASTER LM WITH (NOLOCK) On Lm.Leave_ID = Lt.Leave_ID and Lm.Cmp_ID = Lt.Cmp_ID INNER JOIN
										#EMP_CONS EC ON EC.EMP_ID = LT.EMP_ID
								   WHERE	Lt.CMP_ID = @COMPANY_ID AND FOR_DATE < = @TO_DATE AND  LM.Leave_Type = 'Encashable'--LEAVE_ID = @LEAVE_ID 
								   GROUP BY	LT.EMP_ID,LT.LEAVE_ID
								  )Q ON Q.EMP_ID = L1.EMP_ID AND Q.LEAVE_ID = L1.LEAVE_ID	AND L1.FOR_DATE = Q.FOR_DATE		
				)Q2 ON Q2.EMP_ID = CQ.EMP_ID 
							
				UPDATE 	CQ
				SET CQ.LEAVE_PREVIOUS_BALANCE = Q2.Leave_Opening,
					Cq.LEAVE_ID = Q2.Leave_ID
				FROM #EMP_LEAVE CQ INNER JOIN 
				(
					SELECT L1.Leave_Opening,L1.EMP_ID,L1.LEAVE_ID
							FROM T0140_LEAVE_TRANSACTION L1 WITH (NOLOCK) INNER JOIN
								 ( SELECT MAX(FOR_DATE)AS FOR_DATE,LT.EMP_ID,LT.LEAVE_ID
								   FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN
						T0040_LEAVE_MASTER LM WITH (NOLOCK) On Lm.Leave_ID = Lt.Leave_ID and Lm.Cmp_ID = Lt.Cmp_ID INNER JOIN
										#EMP_CONS EC ON EC.EMP_ID = LT.EMP_ID
								   WHERE	Lt.CMP_ID = @COMPANY_ID AND FOR_DATE < = @TO_DATE AND LM.Leave_Type = 'Encashable'--LEAVE_ID = @LEAVE_ID 
								   GROUP BY	LT.EMP_ID,LT.LEAVE_ID
								  )Q ON Q.EMP_ID = L1.EMP_ID AND Q.LEAVE_ID = L1.LEAVE_ID	AND L1.FOR_DATE = Q.FOR_DATE		
				)Q2 ON Q2.EMP_ID = CQ.EMP_ID 
					
					
						
			CREATE table #Emp_Signature 
			(
				Emp_Id NUMERIC(18,0),
				Cmp_Id NUMERIC(18,0),
				DATE_PAYMENT_OF_WAGES VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				SIGNATURE_OF_EMPLOYEE VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
			
			)
			
				
							
				INSERT INTO #Emp_Signature(Emp_Id,Cmp_Id,SIGNATURE_OF_EMPLOYEE)									
				SELECT  I.Emp_ID,I.cmp_Id,I.Payment_Mode from T0095_INCREMENT I WITH (NOLOCK) inner JOIN
								 ( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)  
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @COMPANY_ID
									GROUP BY EMP_ID) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID INNER JOIN
									#EMP_CONS EC ON QRY.EMP_ID = EC.EMP_ID 		
				
			
			
-----------------------------ENDED----------------------------------------------------------------------------------
	
	
		
	UPDATE #CROSSTAB_FORMR SET EMP_CODE = '="' + EMP_CODE + '"'
	
	
	  
	  SELECT ROW_NUMBER() OVER(ORDER BY   @ORDER_BY   ASC) AS SR_NO,C.*,S.*,L.LEAVE_PREVIOUS_BALANCE,
				L.LEAVE_EARNED_DURING_MONTH,L.LEAVE_USE,L.LEAVE_CLOSE,EL.DATE_PAYMENT_OF_WAGES,EL.SIGNATURE_OF_EMPLOYEE
				,DATENAME(MONTH,@To_Date) as Month_Name,Year(@To_Date) as [Year]
			INTO #CROSSTABDATA 
			FROM #CROSSTAB_FORMR AS C 
			INNER JOIN #CTCMAST S ON C.EMP_ID=S.EMP_ID1
			LEFT JOIN  #EMP_LEAVE L ON L.EMP_ID = C.EMP_ID
			INNER JOIN  #Emp_Signature EL ON EL.Emp_Id = C.EMP_ID
			
			
			UPDATE #CROSSTABDATA SET S_No = SR_NO
			--where  
			
			ALTER TABLE  #CROSSTABDATA DROP COLUMN EMP_ID1
			ALTER TABLE  #CROSSTABDATA DROP COLUMN CMP_ID
			ALTER TABLE  #CROSSTABDATA DROP COLUMN EMP_ID
			
			
			SELECT * FROM #CROSSTABDATA ORDER BY
			CASE WHEN @Order_By ='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(#CROSSTABDATA.Enroll_No AS VARCHAR), 21) 
				--WHEN @Order_By='Name' THEN #CROSSTABDATA.
				When @Order_By = 'Designation' then (CASE WHEN #CROSSTABDATA.Desig_dis_No  = 0 THEN #CROSSTABDATA.Nature_Of_Work_DESIGNATION ELSE RIGHT(REPLICATE('0',21) + CAST(#CROSSTABDATA.Desig_dis_No AS VARCHAR), 21)   END)   
				---ELSE RIGHT(REPLICATE(N' ', 500) + #CTCMast.Emp_Code, 500) 
				End,Case When IsNumeric(Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"',''), 20)
					 When IsNumeric(Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
					 Else Replace(Replace(#CROSSTABDATA.Emp_Code,'="',''),'"','') End 
			
			
			DROP TABLE #CROSSTAB_FORMR
			DROP TABLE #EMP_LEAVE
			DROP TABLE #Emp_Signature
			
			
	
