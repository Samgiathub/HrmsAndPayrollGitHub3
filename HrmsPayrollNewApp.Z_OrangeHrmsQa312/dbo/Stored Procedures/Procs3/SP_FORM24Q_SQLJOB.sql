

-- =============================================
-- AUTHOR:		SHAIKH RAMIZ
-- CREATE DATE: 21/01/2019
-- DESCRIPTION:	THIS JOB CAN BE KEPT IN JOB , SO THAT IT WILL RUN AT NIGHT 
--				AND WILL INSERT THE DATA SO THAT IF REQUESTED FOR 
--              REPORT WITHIN 24 HOURS ,IT WILL SHOW THE DATA FROM 
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_FORM24Q_SQLJOB]
@FROM_DATE  DATETIME = '1900-01-01',
@TO_DATE    DATETIME = '1900-01-01'
AS
BEGIN
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	SET ANSI_WARNINGS OFF;
    
    IF @FROM_DATE = '1900-01-01' OR @TO_DATE = '1900-01-01'
       SET @FROM_DATE = GETDATE()
    
    DECLARE @CMP_ID AS INT;
    DECLARE @FROMDATEVARCHAR AS VARCHAR(20)
    DECLARE @TODATEVARCHAR AS VARCHAR(20)
    
    IF MONTH(@FROM_DATE) < 4
      BEGIN
         SET @FROMDATEVARCHAR = CAST(YEAR(dateadd(m,-1,@FROM_DATE))as varchar(10)) + '-04-01'
         SET @TODATEVARCHAR = CAST(YEAR(@FROM_DATE)as varchar(10)) + '-03-31'
      END
    ELSE
       BEGIN
         SET @FROMDATEVARCHAR = CAST(YEAR(@FROM_DATE) as varchar(10)) + '-04-01'
         SET @TODATEVARCHAR = CAST(YEAR(dateadd(m,1,@FROM_DATE))as varchar(10)) + '-03-31'
      END

    DECLARE Cur_24Q CURSOR FOR
     SELECT CMP_ID FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE IS_Active = 1
    OPEN Cur_24Q
      FETCH NEXT FROM Cur_24Q INTO @CMP_ID
       WHILE @@FETCH_STATUS = 0
         BEGIN
           EXEC P0220_24Q_REPORT @Cmp_ID = @CMP_ID,@From_Date = @FROM_DATE,@To_Date = @TO_DATE
        
        FETCH NEXT FROM Cur_24Q INTO @CMP_ID
       END
    CLOSE Cur_24Q
    DEALLOCATE Cur_24Q
    
    
    /****SOME IMPORTANT SCRIPTS****
	
	CREATE TABLE Tax_Report_Output_Cache
	  ( 
		Row_ID				numeric(18),
		FIELD_NAME			varchar(500),
		Amount_Col_Final	numeric(18,2),
		Amount_Col_1		numeric(18,2),
		Amount_Col_2		numeric(18,2),
		Amount_Col_3		numeric(18,2),
		Amount_Col_4		numeric(18,2),
		Default_def_ID		numeric(18,0),
		AD_ID				numeric(18,0),
		IT_ID				numeric(18,0),
		Emp_ID				numeric(18,0),
		Emp_Code			numeric(18),
		Alpha_Emp_Code		varchar(50),
		Emp_Full_Name		varchar(100),
		Desig_Name			varchar(50),
		Date_Of_Join		datetime,
		Pan_No				varchar(50),
		P_From_Date			datetime,
		P_To_Date			datetime,
		Is_Show				tinyint,
		Concate_Space		numeric(18,0),
		Exempted_Amount		numeric(18,2),
		Branch_ID			numeric(18,0),
		H_From_date			datetime ,
		H_To_test			datetime,
		field_type			tinyint,
		Show_In_SalarySlip	tinyint, -- Added By Ali 05042014
		Display_Name_For_SalarySlip varchar(300), -- Added By Ali 05042014
		Column_24Q			tinyint default 0 --added by Hardik 19/08/2014
		,Amount_Col_Actual	NUMERIC DEFAULT 0,  -- Added By rohit For Actual Value on 04052015
		Amount_Col_Assumed	NUMERIC DEFAULT 0, -- Added by rohit For Assumed Value on 04052015
		Dept_Name			varchar(Max),
		branch_Name			Varchar(max),
		INSERTED_DATE		DATETIME,
		CMP_ID				INT
	  )
	  
	  
	  --New Code Added by Ramiz for Samarth DiamonD Form 24Q Faster Loading
         IF NOT EXISTS (select 1 from Tax_Report_Output_Cache where CMP_ID = @Cmp_Id AND DATEDIFF(HH ,INSERTED_DATE, GETDATE()) < 24)
           BEGIN
             DELETE FROM Tax_Report_Output_Cache WHERE CMP_ID = @Cmp_Id
		     
		     INSERT INTO #Tax_Report_output 
		     EXEC SP_IT_TAX_PREPARATION @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='',@Product_ID=0,@Taxable_Amount_Cond=0,@Format_Name ='Format1',@Form_ID=@form_id,@Sp_Call_For = 'Form24Q',@Month_En_Date = NULL ,@Month_St_Date = NULL ,@Salary_Cycle_id = 0, @Segment_ID = '' ,@Vertical = '' ,@SubVertical = '' ,@subBranch = ''
		     
		     INSERT INTO Tax_Report_Output_Cache
             SELECT * , GETDATE(),@Cmp_Id from #Tax_Report_Output
           END
         ELSE
           BEGIN
             INSERT INTO #Tax_Report_output
             SELECT Row_ID, FIELD_NAME, Amount_Col_Final, Amount_Col_1, Amount_Col_2, Amount_Col_3, Amount_Col_4, Default_def_ID, AD_ID, IT_ID, Emp_ID, Emp_Code, Alpha_Emp_Code, Emp_Full_Name, Desig_Name, Date_Of_Join, Pan_No, P_From_Date, P_To_Date, Is_Show, Concate_Space, Exempted_Amount, Branch_ID, H_From_date, H_To_test, field_type, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q, Amount_Col_Actual, Amount_Col_Assumed, Dept_Name, branch_Name 
             FROM Tax_Report_Output_Cache
             
           END
		--CODE ENDS
	*/
   
END

