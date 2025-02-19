


-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Scheme_Recored]
  @Cmp_ID   numeric
 ,@From_Date  datetime
 ,@To_Date   datetime
 ,@Branch_ID  numeric = 0
 ,@Cat_ID   numeric = 0
 ,@Grd_ID   numeric = 0
 ,@Type_ID   numeric = 0 
 ,@Dept_ID   numeric = 0
 ,@Desig_ID   numeric = 0  
 ,@Salary_Cycle_id numeric = 0	  
 ,@Segment_Id  numeric = 0   
 ,@Vertical_Id numeric = 0   
 ,@SubVertical_Id numeric = 0
 ,@SubBranch_Id numeric = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
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
     dbo.T0095_emp_scheme MS WITH (NOLOCK) on MS.Emp_ID = V.Emp_ID   
     WHERE V.cmp_id=@Cmp_ID     
     AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))            
     AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)        
     AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)        
     AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))        
     AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))        
     AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))  
     And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))  
     And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(Vertical_ID,0))  
     And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_Id,IsNull(SubVertical_ID,0))  
     And ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,IsNull(subBranch_ID,0))
     AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id)   
     AND Increment_Effective_Date <= @To_Date   
     AND ((@From_Date  >= join_Date  AND  @From_Date <= left_date )        
     OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )        
     OR (Left_date IS NULL AND @To_Date >= Join_Date)        
     OR (@To_Date >= left_date  AND  @From_Date <= left_date )  
     OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end))     
	 ORDER BY Emp_ID  
	 
	 
	 
	 Select *
	 ,(select Branch_id from T0095_Increment WITH (NOLOCK) where Increment_ID in 
	 (Select Increment_ID from T0080_Emp_master WITH (NOLOCK) where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID )) as Branch_Id 
	 ,(Select Alpha_Emp_Code from T0080_Emp_master WITH (NOLOCK) where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID ) as Alpha_Emp_Code
	 ,(Select Emp_Full_Name from T0080_Emp_master WITH (NOLOCK) where Emp_Id = temp.Emp_Id and Cmp_Id = @Cmp_ID ) as Emp_Full_Name
	 from (select distinct Emp_ID from @Emp_Cons ) as temp order by Alpha_Emp_Code
   
END

