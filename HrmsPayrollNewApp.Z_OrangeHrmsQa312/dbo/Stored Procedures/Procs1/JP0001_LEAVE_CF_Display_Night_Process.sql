

CREATE PROCEDURE [dbo].[JP0001_LEAVE_CF_Display_Night_Process]  
	@leave_Cf_ID NUMERIC(18,0) output,  
	@Cmp_ID  NUMERIC ,  
	@From_Date Datetime ,  
	@To_Date Datetime ,  
	@For_Date Datetime ,  
	@Branch_ID NUMERIC,  
	@Cat_ID  NUMERIC,  
	@Grd_ID  NUMERIC,  
	@Type_ID NUMERIC,  
	@Dept_ID NUMERIC,  
	@Desig_ID NUMERIC,  
	@Emp_Id  NUMERIC ,  
	@Constraint varchar(max)='',  
	@P_LeavE_ID NUMERIC, 
	@Is_FNF int = 0,   --Added by Falak on 02-FEB-2011 
	@Inc_HOWO int=0,
	@Segment_ID		NUMERIC = 0,
	@subBranch_ID		NUMERIC = 0,
	@Vertical_ID		NUMERIC = 0,
	@SubVertical_ID	NUMERIC = 0,
	@CallFor	Varchar(24) = ''
AS

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	SET ANSI_WARNINGS OFF; 


BEGIN 

	DECLARE @Qry as Nvarchar(MAX) = ''
	set @Qry =  'WHERE CMP_ID = '+ Cast( @CMP_ID as nvarchar(3)) +''
	
	if isnull(@Emp_Id,0) <> 0
	BEGIN
		Set @Constraint = ''
		set @Qry = @Qry + ' AND Emp_Id In ('+ Cast(@Emp_Id as nvarchar(10)) +')'
	END
		
	if isnull( @Constraint,'') <> ''	
			 set @Qry = @Qry + ' AND Emp_Id In ('+ Cast(Substring(@Constraint,2,LEN(@Constraint))  as nvarchar(MAX)) +')'
	
	if isnull(@P_LeavE_ID,0) > 0	
		 set @Qry = @Qry + ' and LeavE_ID = '+ Cast(@P_LeavE_ID as nvarchar(10)) +''

	
	set @Qry = @Qry + ' and Month = '+ Cast(MONTH(@From_Date) as nvarchar(10)) +' and Year =  '+ Cast(YEAR(@From_Date) as nvarchar(10)) +''
	

	DECLARE @Str as Nvarchar(MAX) = ''
	if @Constraint = ''
	BEGIN
		if isnull( @Branch_ID ,0) > 0	
			 set @Qry = @Qry + ' AND branch_id = '+ Cast( @Branch_ID  as nvarchar(10)) +''
		if isnull(@Grd_ID,0) > 0	
			 set @Qry =  @Qry + ' and Grd_ID = '+ Cast(@Grd_ID as nvarchar(10)) +''
		if isnull(@Desig_ID,0) > 0	
			 set @Qry = @Qry + ' and Desig_ID = '+ Cast(@Desig_ID as nvarchar(10)) +''
		if isnull(@Dept_Id,0) > 0	
			 set @Qry = @Qry + ' and Dept_Id = '+ Cast(@Dept_Id as nvarchar(10)) +''
		if isnull(@Cat_ID,0) > 0	
			 set @Qry = @Qry + ' and Cat_ID = '+ Cast(@Cat_ID as nvarchar(10)) +''
		if isnull(@Type_ID,0) > 0	
			 set @Qry = @Qry + ' and Type_ID = '+ Cast(@Type_ID as nvarchar(10)) +''
		if isnull(@Segment_ID,0) > 0	
			 set @Qry = @Qry + ' and Segment_ID = '+ Cast(@Segment_ID as nvarchar(10)) +''
		if isnull(@Vertical_ID,0) > 0	
			 set @Qry = @Qry + ' and Vertical_ID = '+ Cast(@Vertical_ID as nvarchar(10)) +''
		if isnull(@SubVertical_ID,0) > 0	
			 set @Qry = @Qry + ' and SubVertical_ID = '+ Cast(@SubVertical_ID as nvarchar(10)) +''
		if isnull(@subBranch_ID,0) > 0	
			 set @Qry = @Qry + ' and subBranch_ID = '+ Cast(@subBranch_ID as nvarchar(10)) +''
		
   
	    SET @Str = 'SELECT LEAVE_CF_ID,Branch_ID,Grd_ID,Dept_ID,Desig_ID,Cat_ID,Type_ID,Segment_ID,subBranch_ID,Vertical_ID,SubVertical_ID,Cmp_ID
		,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates
		,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance
		,Is_Advance_Leave_Balance from T0001_LEAVECF_NightProcess '+ @Qry + ''
		
		exec sp_executesql @Str
   END
   ELSe
   BEGIN
		SET @Str = 'SELECT LEAVE_CF_ID,Branch_ID,Grd_ID,Dept_ID,Desig_ID,Cat_ID,Type_ID,Segment_ID,subBranch_ID,Vertical_ID,SubVertical_ID,Cmp_ID
		,Emp_ID,Leave_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Exceed_CF_Days,Leave_CompOff_Dates
		,Is_Fnf,Alpha_Emp_Code,Emp_Full_Name,Leave_Name,new_join_flag,date_of_join,diff,Advance_Leave_Balance,Advance_Leave_Recover_balance
		,Is_Advance_Leave_Balance from T0001_LEAVECF_NightProcess '+ @Qry + ''
		exec sp_executesql @Str
		
   END
END