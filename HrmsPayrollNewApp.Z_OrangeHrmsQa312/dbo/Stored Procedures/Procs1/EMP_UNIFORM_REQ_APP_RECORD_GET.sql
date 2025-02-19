CREATE PROCEDURE [dbo].[EMP_UNIFORM_REQ_APP_RECORD_GET]  
	  @Cmp_ID  NUMERIC  
	 ,@From_Date  DATETIME  
	 ,@To_Date  DATETIME   
	 ,@Branch_ID  NUMERIC   = 0  
	 ,@Cat_ID  VARCHAR(MAX) = ''   
	 ,@Grd_ID  VARCHAR(MAX) = ''   
	 ,@Type_ID  NUMERIC  = 0  
	 ,@Dept_ID  VARCHAR(MAX) = ''   
	 ,@Desig_ID  VARCHAR(MAX) = ''   
	 ,@Emp_ID  NUMERIC  = 0  
	 ,@Constraint VARCHAR(MAX) = ''  
	 ,@Salary_Status VARCHAR(10)='All'  
	 ,@Salary_Cycle_id  NUMERIC  = 0  
	 ,@Branch_Constraint VARCHAR(MAX) = ''   
	 ,@Segment_ID VARCHAR(MAX) = ''   
	 ,@Vertical VARCHAR(MAX) = ''   
	 ,@SubVertical VARCHAR(MAX) = ''   
	 ,@subBranch VARCHAR(MAX) = ''   
	 ,@Uniform_id numeric(18,0) = 0  
AS  
	 SET NOCOUNT ON   
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
	 SET ARITHABORT ON  
   
	IF @Dept_ID='0'   
		SET @Dept_ID=null                
   
	IF @Vertical='0'   
		SET @Vertical=null   
  
	IF @SubVertical='0'   
		SET @SubVertical=null   
   
	IF @Branch_Constraint='0'   
		SET @Branch_Constraint=null   
    
	 CREATE TABLE #Emp_Cons   
	 (        
		  Emp_ID NUMERIC ,       
		  Branch_ID NUMERIC,  
		  Increment_ID NUMERIC      
	 )    
   
	IF @Constraint <> ''  
		BEGIN    
			INSERT INTO #Emp_Cons  
			SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T    
		END  
	ELSE  
		BEGIN  
			EXEC SP_EMP_SALARY_Constraint @Cmp_ID, @From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID ,@Desig_ID,@Emp_ID,@Salary_Cycle_id ,@Branch_Constraint,@Segment_ID,@Vertical,@SubVertical,@subBranch,@Constraint -- Changed By Gadriwala 11092013  
		END  
   
	 DECLARE @Uni_Rate Numeric(18,2)  
	 DECLARE @Uni_Deduct_Installment Numeric(18,0)  
	 DECLARE @Uni_Refund_Installment Numeric(18,0)  
   
	 SET @Uni_Rate = 0  
	 SET @Uni_Deduct_Installment = 0  
	 SET @Uni_Refund_Installment = 0  
   
	 SELECT @Uni_Rate = Uni_Rate
			,@Uni_Refund_Installment = UMD.Uni_Refund_Installment
			,@Uni_Deduct_Installment=UMD.Uni_Deduct_Installment    
	 FROM	V0050_Uniform_Master_Detail UMD   
	 WHERE	UMD.Uni_ID = @Uniform_id and UMD.Cmp_Id = @Cmp_ID  
    
   
	SELECT	EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,EM.Mobile_No,  
			CONVERT(Varchar(30), EM.Date_Of_Join, 103)as Date_Of_Join ,
			--Dispatch_Date as Last_Dispatch_Date,
			@Uni_Rate as Fabric_Price,  
			@Uni_Deduct_Installment as Uni_Ded_Install,@Uni_Refund_Installment as Uni_Ref_Install  ,
			--,UDD.Dispatch_Date  
			ISNULL(CASE WHEN CONVERT(DATE, Dispatch_Date) = '1900-01-01' THEN '-' ELSE CONVERT(CHAR(12), Dispatch_Date, 103) END, '-') AS Last_Dispatch_Date

	FROM	#Emp_Cons EC 
			INNER JOIN T0080_Emp_Master EM WITH(NOLOCK) ON EM.Emp_ID = EC.Emp_ID   
			LEFT OUTER JOIN T0110_Uniform_Dispatch_Detail UDD WITH(NOLOCK) ON EC.Emp_ID = UDD.Emp_ID
			LEFT OUTER JOIN (
								SELECT	MAX(Dispatch_Date) as For_Date,Emp_ID
								FROM	T0110_Uniform_Dispatch_Detail WITH(NOLOCK)
								WHERE	Dispatch_Date <= @To_Date
								Group By Emp_ID
							) Q ON Q.Emp_ID = EC.Emp_ID and Q.For_Date = Dispatch_Date
 RETURN  