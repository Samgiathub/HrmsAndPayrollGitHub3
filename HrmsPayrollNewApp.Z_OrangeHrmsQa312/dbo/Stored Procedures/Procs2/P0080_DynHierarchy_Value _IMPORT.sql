CREATE PROCEDURE [dbo].[P0080_DynHierarchy_Value _IMPORT]	
	  @Row_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Alpha_Emp_Code varchar(100)	
     ,@DynamicTypeName varchar(100)
	 ,@DynamicRM varchar(100)    
	 ,@tran_type varchar(1)	 
	 ,@Row_No	numeric
	 ,@Log_Status numeric output
	 ,@GUID varchar(2000) = '' 
	 
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 
 --Created By ronakk 25052022

DECLARE @Emp_id numeric
select @Emp_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id

DECLARE @EmpRM_id numeric
select @EmpRM_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @DynamicRM  and Cmp_ID = @cmp_id

Declare @DynHyTypeID int
SELECT @DynHyTypeID = Dyn_Hierarchy_Id FROM T0040_Dyn_Hierarchy_Type WITH (NOLOCK) where Cmp_Id = @cmp_id and Dyn_Hierarchy_Type = RTRIM(LTRIM(@DynamicTypeName))

declare @EmpIncID int
select @EmpIncID = max(Increment_ID) from T0095_INCREMENT where Emp_ID=@Emp_id and Cmp_ID=@Cmp_ID


Set @Log_Status = 0

if isnull(@Emp_id,0) = 0 
	Begin
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Does not Exists',0,'Employee Does not Exists.',GetDate(),'Dynamic Hierarchy',@GUID)
		set @Log_Status = 1
		return @Log_Status
	End
  
if not exists(SELECT 1 FROM T0040_Dyn_Hierarchy_Type WITH (NOLOCK) where Cmp_Id = @cmp_id and Dyn_Hierarchy_Type = RTRIM(LTRIM(@DynamicTypeName)))
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Dynamic Type Name Details Does not Exists',0,'Enter Valid Details of Dynamic Type.',GetDate(),'Dynamic Hierarchy',@GUID)
		set @Log_Status = 1
		return @Log_Status
	End
	

if isnull(@EmpRM_id,0) = 0 
Begin
	Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Dynamic Hierarchy Employee Does not Exists',0,'Employee Does not Exists.',GetDate(),'Dynamic Hierarchy',@GUID)
	set @Log_Status = 1
	return @Log_Status
End


if @EmpRM_id = @Emp_id
Begin
	Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Dynamic Hierarchy Employee and Employee Can Not Be Same.',0,'Dynamic Hierarchy Employee and Employee Can Not Be Same.',GetDate(),'Dynamic Hierarchy',@GUID)
	set @Log_Status = 1
	return @Log_Status
End



IF @tran_type ='I'


			If exists(select DynHierarchyId from T0080_DynHierarchy_Value WITH (NOLOCK) where Emp_ID = @Emp_ID And Cmp_ID=@Cmp_ID and DynHierColName=@DynamicTypeName )
				BEGIN 

				    Update T0080_DynHierarchy_Value set 
					DynHierColName=@DynamicTypeName,
					DynHierColValue=@EmpRM_id,
					DynHierColId = @DynHyTypeID,
					IncrementId = @EmpIncID
					where Emp_ID = @Emp_ID And Cmp_ID=@Cmp_ID

					--Set @Row_ID = 0
					--return

				END

				select @Row_ID = Isnull(max(DynHierarchyId),0) + 1 	From T0080_DynHierarchy_Value WITH (NOLOCK)

				insert into T0080_DynHierarchy_Value (Emp_ID,Cmp_ID,DynHierColName,DynHierColValue,DynHierColId,IncrementId )
										      values (@Emp_ID,@Cmp_ID,@DynamicTypeName,@EmpRM_id,@DynHyTypeID,@EmpIncID)
			
RETURN




