CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_ApprovalSearchGrid]        
(              
 @Emp_ID int
)              
as                   
 BEGIN    
 	IF NOT EXISTS(Select 1 From KPMS_T0110_TargetAchivement WHERE emp_id=@Emp_ID)
	BEGIN
		Declare @lResult4 varchar(max) =''  
		Select Distinct @lResult4 = @lResult4+ '<tr><td>' + Emp_Full_Name + '</td><td>level1</td>
		<td>  
		<a href="javascript:;" onclick="ShowGrid(' + CONVERT(VARCHAR,ta.emp_id)+','+ CONVERT(VARCHAR,ta.goalAlt_id)+')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>  
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,ta.emp_id) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>  
		</td>
		<tr>'  from KPMS_T0110_TargetAchivement as ta inner join T0080_EMP_MASTER as em on em.Emp_ID = ta.emp_id where R_Emp_ID=@Emp_ID  

		select @lResult4  as Result4  
	END
	ELSE
	BEGIN
		SELECT ISNULL(emp_id,0) AS r_Id
		from KPMS_T0110_TargetAchivement Where (@Emp_ID = 0 Or emp_id=@Emp_ID) 
	END
END              
         