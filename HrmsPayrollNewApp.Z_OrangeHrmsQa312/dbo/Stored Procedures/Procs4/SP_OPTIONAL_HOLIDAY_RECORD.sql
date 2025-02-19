



---==================================================
--CREATED BY: NILAY
--DESCRIPTION: OPTIONAL HOLIDAY EMPLOYEE RECORDS
--DATE CREATED: 06/04/2013
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---==================================================
CREATE PROCEDURE [dbo].[SP_OPTIONAL_HOLIDAY_RECORD]       
    @CMP_ID		NUMERIC  
   ,@HOLIDAY_ID NUMERIC      
   ,@BRANCH_ID NUMERIC   
   ,@GRD_ID	   NUMERIC 
   ,@DEPT_ID   NUMERIC 
   ,@DESIG_ID  NUMERIC 
   ,@STATUS    CHAR(1) 
   ,@Emp_ID		numeric
   ,@Constraint	VARCHAR(5000) = ''
   		
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON     

	IF @BRANCH_ID = 0
		SET @BRANCH_ID = NULL	
	IF @DEPT_ID = 0
		SET @DEPT_ID = NULL
	IF @GRD_ID = 0
		SET @GRD_ID = NULL	
	If @DESIG_ID = 0
		SET @DESIG_ID = NULL
				
	DECLARE @Emp_Cons TABLE
	(
		Emp_ID	NUMERIC
	)
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO @Emp_Cons
			SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN
						
			INSERT INTO @Emp_Cons

			SELECT I.Emp_Id FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
					(SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK)
					WHERE Increment_Effective_date <= GETDATE()
					AND Cmp_ID = @Cmp_ID
					GROUP BY emp_ID  ) Qry ON
					I.Emp_ID = Qry.Emp_ID	AND I.Increment_effective_Date = Qry.For_Date
			WHERE Cmp_ID = @Cmp_ID 
		
			AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)
			AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)
			AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))		
			AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))		
			AND I.Emp_ID in 
				(SELECT Emp_Id FROM
				(SELECT emp_id, cmp_ID, join_Date, ISNULL(left_Date, GETDATE()) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				WHERE cmp_ID = @Cmp_ID   AND  
				(( GETDATE()  >= join_Date  AND  GETDATE() <= left_date ) 
				OR ( GETDATE()  >= join_Date  AND GETDATE() <= left_date )
				OR Left_date IS NULL  AND GETDATE() >= Join_Date)
				OR GETDATE() >= left_date  AND  GETDATE() <= left_date ) 			
		END
				
	  SELECT 
		  T0080_EMP_MASTER.Emp_ID,  CAST(Emp_code AS varchar(255)) + ' - ' +  Emp_Full_Name AS  Emp_Full_Name, 
		  Emp_code,
		  Hday_Name, 
		  H_From_Date, 
		  H_To_Date,
		  Op_Holiday_Status,
		  Emp_Superior,
		  Op_Holiday_App_ID		  
	  FROM T0100_OP_Holiday_Application WITH (NOLOCK) 
	  INNER JOIN T0080_EMP_MASTER WITH (NOLOCK) ON T0100_OP_Holiday_Application.Emp_ID = T0080_EMP_MASTER.Emp_ID  
	  INNER JOIN T0040_HOLIDAY_MASTER WITH (NOLOCK) ON T0100_OP_Holiday_Application.HDay_ID = T0040_HOLIDAY_MASTER.Hday_ID	  
	  WHERE T0040_HOLIDAY_MASTER.Hday_ID =@HOLIDAY_ID  AND Op_Holiday_Status=@STATUS
	  AND T0080_EMP_MASTER.emp_ID in (SELECT T0080_EMP_MASTER.Emp_ID from @Emp_Cons) order by Emp_code
  
  
RETURN



