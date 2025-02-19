
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--DFM:-25368,COO:-0,CEO:-0,DMP:-0,PM:-25395,SPM:-0,Nodal HR:-0,Block HR:-0,Admin:-0,Account:-0,Corporate HR:-0,Project Director (COO Johar project):-0,BPM:-0,DPO:-0,Corporate Admin:-0,District Admin:-0,Corporate Account:-0,
CREATE PROCEDURE [dbo].[P0100_DynHierarchy]
  	 @CMP_ID		Numeric	= 0
	,@EMP_ID		Numeric = 0
	,@Dyn_Hierarchy	Varchar(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
BEGIN
	 
	 --insert into T0080_DynHierarchy_Value  (Emp_id,Cmp_Id,DynHierColName,DynHierColValue)
	 --select @EMP_ID,@CMP_ID,val1,val2 FROM dbo.Split(replace(@Dyn_Hierarchy,':',''),',') CROSS APPLY dbo.fnc_BifurcateString(isNULL(data,''),'-') WHERE val2 > '0'   
	 Declare @IncrementId as numeric(18,0) 

	 SET @Dyn_Hierarchy = replace(@Dyn_Hierarchy , 'null', 0)

	 SELECT @IncrementId = Q_I.Increment_ID
	 FROM t0080_emp_master E 
		   INNER JOIN (SELECT I.emp_id,i.Increment_ID
					   FROM   t0095_increment I 
							  INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
										  FROM   t0095_increment 
										  WHERE  increment_effective_date <= Getdate() AND cmp_id = 149 
										  GROUP  BY emp_id) Qry 
										  ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
										  )Q_I 
					ON E.emp_id = Q_I.emp_id 


	 IF ((Select Count(1) from T0080_DynHierarchy_Value where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID) > 0)
	 Begin 
		DELETE from T0080_DynHierarchy_Value where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID and (IncrementId = @IncrementId or isnull(IncrementId,0) = 0)
	 END
	 INSERT INTO T0080_DynHierarchy_Value  (Emp_id,Cmp_Id,DynHierColName,DynHierColValue,DynHierColId,IncrementId)
	 SELECT @emp_id,@cmp_id,val1,val2,Dyn_Hierarchy_Id ,@IncrementId
	 FROM 
	 (
		SELECT val1,val2 
		FROM dbo.Split(replace(@Dyn_Hierarchy,':',''),',') 
		CROSS APPLY dbo.fnc_BifurcateString(isNULL(data,''),'-') WHERE val2 > '0'   
	 ) as A
	 INNER JOIN T0040_Dyn_Hierarchy_Type T on a.val1 = t.Dyn_Hierarchy_Type


END
		
				
	

