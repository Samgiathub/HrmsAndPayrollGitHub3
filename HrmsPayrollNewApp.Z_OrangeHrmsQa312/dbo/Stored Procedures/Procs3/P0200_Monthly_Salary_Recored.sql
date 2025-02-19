


-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Monthly_Salary_Recored]
  @Cmp_ID   numeric
 ,@From_Date  datetime
 ,@To_Date   datetime
 --,@Branch_ID  numeric = 0
 --,@Cat_ID   numeric = 0
 --,@Grd_ID   numeric = 0
 --,@Type_ID   numeric = 0 
 --,@Dept_ID   numeric = 0
 --,@Desig_ID   numeric = 0
 ,@Branch_ID  varchar(max)
 ,@Cat_ID     varchar(max)
 ,@Grd_ID     varchar(max)
 ,@Type_ID    varchar(max)
 ,@Dept_ID    varchar(max)
 ,@Desig_ID   varchar(max) 
 ,@Emp_ID   numeric = 0	   
 ,@Salary_Cycle_id numeric = 0	  
 --,@Segment_Id  numeric = 0   
 -- ,@Vertical_Id numeric = 0   
 --,@SubVertical_Id numeric = 0
 --,@SubBranch_Id numeric = 0
 ,@Segment_Id  varchar(max)   = 0	 
 ,@Vertical_Id varchar(max)= 0	    
 ,@SubVertical_Id varchar(max)= 0	 
 ,@SubBranch_Id varchar(max) = 0	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  
 CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      
 
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',1,0
  
  /*
  Declare @Emp_Cons Table  
  (  
	  Emp_ID numeric ,       
	  Branch_ID NUMERIC,  
	  Increment_ID NUMERIC
  )  
  
 IF @Branch_ID = 0    
  set @Branch_ID = null  
    
 IF @Cat_ID = 0    
  set @Cat_ID = null  
  
 IF @Grd_ID = 0    
  set @Grd_ID = null  
  
 IF @Type_ID = 0    
  set @Type_ID = null  
  
 IF @Dept_ID = 0    
  set @Dept_ID = null  
  
 IF @Desig_ID = 0    
  set @Desig_ID = null 
  
  --Added By : Nilay Mistry , Date Modified: 20/02/2014
 If @Salary_Cycle_id = 0
   set @Salary_Cycle_id = null
   
  If @Segment_ID = 0
  set @Segment_ID = null
        
  if @Vertical_Id =0
   set @Vertical_Id =NULL
  
  if @SubVertical_Id =0
   set @SubVertical_Id =null
  
  if @SubBranch_Id =0
   set @SubBranch_Id =null
   
  --Added By : Nilay Mistry , Date Modified: 20/02/2014 
  
 DECLARE @Emp_ID as numeric 
 IF @Emp_ID = 0    
  set @Emp_ID = null   
	
	 Insert Into @Emp_Cons  
     SELECT DISTINCT V.emp_id,V.branch_Id,V.Increment_ID FROM V_Emp_Cons V   
     Inner Join  
     dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = V.Emp_ID   
     LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid   
         FROM T0095_Emp_Salary_Cycle ESC  
          INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id   
              FROM T0095_Emp_Salary_Cycle   
              WHERE Effective_date <= @To_Date  
              GROUP BY emp_id  
             ) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id  
        ) AS QrySC ON QrySC.eid = V.Emp_ID  
     WHERE   
        V.cmp_id=@Cmp_ID     
     AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))            
     AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)        
     AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)        
     AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))        
     AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))        
     AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))  
     AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))       
     And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))  
     And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(Vertical_ID,0))  
     And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_Id,IsNull(SubVertical_ID,0))  
     And ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,IsNull(subBranch_ID,0))
     and ms.Month_End_Date  >= @from_Date and ms.Month_End_Date  >= @from_Date
     and ms.Month_End_Date  <= @To_Date and ms.Month_End_Date  <= @To_Date
     and ms.Is_FNF = 0  
     AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id)   
     AND Increment_Effective_Date <= @To_Date   
     AND ((@From_Date  >= join_Date  AND  @From_Date <= left_date )        
     OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )        
     OR (Left_date IS NULL AND @To_Date >= Join_Date)        
     OR (@To_Date >= left_date  AND  @From_Date <= left_date )  
     OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end))     
	 ORDER BY Emp_ID  */ 
	 
	 
	 
	 --Select *
	 --,(select Branch_id from T0095_Increment where Increment_ID in 
	 --(Select Increment_ID from T0080_Emp_master where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID )) as Branch_Id 
	 --,(Select Alpha_Emp_Code from T0080_Emp_master where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID ) as Alpha_Emp_Code
	 --,(Select Emp_Full_Name from T0080_Emp_master where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID ) as Emp_Full_Name
	 --from (select distinct Emp_ID from #Emp_Cons ) as temp 
	 --order by Alpha_Emp_Code
	 
   
   
	Select INC_Qry.Branch_ID,Alpha_Emp_Code,
		CASE WHEN Isnull(S.Setting_Value,1)  = 1 then   --Added By Hardik 04/02/2016
		isnull(E.Initial,'')+' '+E.Emp_First_Name +' '+ isnull(E.Emp_Second_Name,'') +  ' '+ isnull(E.Emp_Last_Name,'') 
		ELSE
			E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'')+' ' + isnull(E.Emp_Last_Name,'')
		End AS Emp_Full_Name
	--	Emp_Full_Name
	,EC.Emp_ID from #Emp_Cons EC 
		Inner Join T0080_EMP_MASTER E WITH (NOLOCK) on Ec.Emp_ID = E.Emp_ID Inner Join
		(Select I.Emp_ID,I.Branch_id  From T0095_INCREMENT I WITH (NOLOCK) Inner Join 
			(Select MAX(Increment_Id) as Increment_Id, Emp_Id 
				From T0095_INCREMENT WITH (NOLOCK)
				Where Increment_Effective_Date <= @To_Date 
				Group by Emp_Id) Qry on I.Increment_ID = Qry.Increment_Id and I.Emp_Id = Qry.Emp_ID) INC_Qry on INC_Qry.Emp_ID = Ec.Emp_ID
		Left OUTER JOIN T0040_SETTING S WITH (NOLOCK) on E.Cmp_ID = S.Cmp_ID And S.Setting_Name='Add initial in employee full name' --Added Condition by Hardik 29/02/2016
	Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
			When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
				Else Alpha_Emp_Code
			End
   
   
END

