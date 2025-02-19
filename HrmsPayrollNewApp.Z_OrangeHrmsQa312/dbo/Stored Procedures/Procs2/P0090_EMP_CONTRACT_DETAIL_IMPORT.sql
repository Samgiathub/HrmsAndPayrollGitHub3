
CREATE PROCEDURE [dbo].[P0090_EMP_CONTRACT_DETAIL_IMPORT]	
	  @Row_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Alpha_Emp_Code varchar(100)	
     ,@Project varchar(100)
	 ,@StartDate datetime
	 ,@EndDate datetime
	 ,@Comments varchar(1000) =''
	 ,@Is_Renew  numeric(1,0)=0
	 ,@Is_Reminder numeric(1,0)=0
	 ,@tran_type varchar(1)	 
	 ,@Row_No	numeric
	 ,@Log_Status numeric output
	 ,@GUID varchar(2000) = '' 
	 
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


--Created By ronakk 27052022
 
DECLARE @Emp_id numeric
select @Emp_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id




Set @Log_Status = 0

if isnull(@Emp_id,0) = 0 
	Begin
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Does not Exists',0,'Employee Does not Exists.',GetDate(),'Contract Details',@GUID)
		set @Log_Status = 1
		return @Log_Status
	End
  
if not exists(SELECT 1 FROM T0040_PROJECT_MASTER WITH (NOLOCK) where Cmp_Id = @cmp_id and Prj_name = RTRIM(LTRIM(@Project)))
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Project Details Does not Exists',0,'Enter Valid Details of Project.',GetDate(),'Contract Details',@GUID)
		set @Log_Status = 1
		return @Log_Status
	End



If @StartDate is null
Begin

	    Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Start date can not be blank.',0,'Start date can not be blank.',GetDate(),'Contract Details',@GUID)
		set @Log_Status = 1
		return @Log_Status

End


If @EndDate is null
Begin

	    Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'End date can not be blank.',0,'End date can not be blank.',GetDate(),'Contract Details',@GUID)
		set @Log_Status = 1
		return @Log_Status

End


If @EndDate < @StartDate
Begin

	    Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'End date can not be less than start date.',0,'End date can not be less than start date.',GetDate(),'Contract Details',@GUID)
		set @Log_Status = 1
		return @Log_Status

End


IF @tran_type ='I'
Begin




		     Declare @ProjID int
		     if @Project <>''
		     Begin
		         SELECT @ProjID = Prj_ID FROM T0040_PROJECT_MASTER WITH (NOLOCK) where Cmp_Id = @cmp_id and Prj_name = RTRIM(LTRIM(@Project))
		     End



			   If exists(select Tran_ID from T0090_EMP_CONTRACT_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And Prj_ID=@ProjID And Start_Date=@StartDate And End_Date = @EndDate  and Cmp_ID = @Cmp_ID)
				BEGIN 
					Set @Row_ID = 0
					return
				END


				select @Row_ID = Isnull(max(Tran_ID),0) + 1 From T0090_EMP_CONTRACT_DETAIL WITH (NOLOCK)
			
				INSERT INTO T0090_EMP_CONTRACT_DETAIL(Tran_ID,Cmp_ID,Emp_ID,Prj_ID,Start_Date,End_Date,Is_Renew,Is_Reminder,Comments)
				VALUES (@Row_ID,@Cmp_ID,@Emp_id,@ProjID,@StartDate,@EndDate,@Is_Renew,@Is_Reminder,@Comments)

End
RETURN




