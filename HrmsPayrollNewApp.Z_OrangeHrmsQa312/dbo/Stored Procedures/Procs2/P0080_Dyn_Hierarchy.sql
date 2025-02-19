--exec P0080_Dyn_Hierarchy 119,2,1,0,0,0,0,0,0,0,0,0,0
CREATE PROCEDURE [dbo].[P0080_Dyn_Hierarchy]  
	@Cmp_ID			numeric(18,0)  
   ,@Branch_ID		numeric(18,0)  
   ,@Dept_ID		numeric(18,0)  
   ,@Desig_Id		numeric(18,0)  
   ,@Grd_ID			numeric(18,0)  
   ,@Cat_ID			numeric(18,0)  
   ,@Band_ID		numeric(18,0) 
   ,@Type_ID		numeric(18,0)  
   ,@Segment_ID		numeric = 0  
   ,@Vertical_ID	numeric = 0  
   ,@SubVertical_ID numeric = 0 
   ,@SubBranch_ID	numeric = 0 
   ,@Cost_Center_ID	numeric = 0 

AS   
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
BEGIN

		SELECT Dyn_Hierarchy_Id,Dyn_Hierarchy_Type,Em.Emp_ID,EM.Emp_Full_Name
		FROM T0040_Dyn_Hierarchy_Type DT 
		INNER JOIN  T0080_Dyn_Hierarchy_Comb DC ON DT.Dyn_Hierarchy_Id = DC.Dyn_Hierarchy_Type_Id
		INNER JOIN T0080_EMP_MASTER EM on EM.Emp_ID = Dc.Dyn_Manager_Id 
		Where Dyn_Branch_Id = @Branch_ID and Dyn_Dept = @Dept_ID  

END
