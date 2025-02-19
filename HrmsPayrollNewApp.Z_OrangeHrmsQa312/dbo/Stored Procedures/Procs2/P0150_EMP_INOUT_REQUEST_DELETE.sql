-- =============================================
-- Author     :	Alpesh
-- ALTER date: 12-Jun-2012
-- Description:	Regularization Request Delete
-- =============================================
CREATE PROCEDURE [dbo].[P0150_EMP_INOUT_REQUEST_DELETE]
	 @Cmp_Id   numeric(18) 
	,@Emp_ID   numeric(18)    
    ,@For_Date datetime	
    ,@Is_Ess   tinyint = 0 --Added by Jaina 16-11-2017     
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	

	Declare @In_Time datetime
	Declare @Out_Time Datetime
	Declare @Duration varchar
	Declare @Manual_flag varchar(5) --Mukti(07092016)
	Declare @Out_Date_Time varchar(50)  --Added by Jaina 08-03-2017
	Declare @In_Date_Time  varchar(50)
	Declare @Chk_By_Superior tinyint  --Added by Rajput 12072017
	
	Set @In_Time=''
	set @Out_Time = ''
	Set @Duration = '0'
	Set @Out_Date_Time = null
	Set @In_Date_Time = null
	
	--Added By Jaina 26-09-2016
	IF @Is_Ess = 1
	begin
		if exists (SELECT 1 FROM T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_Id AND For_Date = @For_Date)
		BEGIN
			
			Raiserror('Reference Exists',16,2)
			RETURN -1
		END
	END

	 If ((SELECT count(1) FROM T0150_EMP_INOUT_RECORD E 
	 inner join T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID 
	 WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @Emp_ID and @For_Date between From_Date and To_Date and Chk_By_Superior = 1) > 0)
	 BEGIN
	 	Raiserror('Attendance Lock for this Period.',16,2)
	 	return -1								
	 END
		
	
	

	select @In_Time = isnull(In_Time,''),@Out_Time = isnull(Out_Time,'')
		,@Duration = isnull(Duration,'0'),
		   @Manual_flag=ManualEntryFlag,
		   @In_Date_Time =   isnull(In_Date_Time,''),
		   @Out_Date_Time = isnull(Out_Date_Time,''), --Added by Jaina 08-03-2017
		   @Chk_By_Superior=isnull(Chk_By_Superior,0)  --Added by Rajput 12072017
	 from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where 
	 --Cmp_Id=@Cmp_Id and 
	 Emp_ID=@Emp_ID and For_Date=@For_Date  

	 --print @In_Time
	 --print @Out_Time
	if @In_Time = '1900-01-01 00:00:00.000' and @Out_Time = '1900-01-01 00:00:00.000' and @Manual_flag='Abs'
	begin
		delete From	T0150_EMP_INOUT_RECORD	Where Emp_ID=@Emp_ID and For_Date=@For_Date 
		delete FROM T0115_AttendanceRegu_Level_Approval WHERE Emp_ID = @Emp_ID AND For_Date = @For_Date
	end
	
	if ((isnull(@In_Time,'') = '' and @In_Time = '1900-01-01 00:00:00.000' and ISNULL(@Out_Time,'') = '' 
		and @Out_Time = '1900-01-01 00:00:00.000' and isnull(@In_Date_Time,'') = '' and isnull(@In_Date_Time,'') = '1900-01-01 00:00:00.000' 
		and ISNULL(@Out_Date_Time,'') = '' and ISNULL(@Out_Date_Time,'') = '1900-01-01 00:00:00.000'  and ISNULL(@Duration,'0')='0')
		--or(@Manual_flag='Abs')
		) 
		begin 		
			delete From	T0150_EMP_INOUT_RECORD	Where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date 
			delete FROM T0115_AttendanceRegu_Level_Approval WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_Id AND For_Date = @For_Date  --Added by Jaina 16-11-2017
		End
	Else
		BEGIN
		select @Out_Date_Time
				IF @Out_Date_Time ='1900-01-01 00:00:00.000' AND @Chk_By_Superior=1    --Added by Jaina 08-03-2017
					BEGIN
					
						Update T0150_EMP_INOUT_RECORD Set
						 Reason=''
						,Chk_By_Superior = 0
						,Sup_Comment = ''
						,Half_Full_day = ''
						,Is_Cancel_Late_In = 0
						,Is_Cancel_Early_Out = 0			 
						,Is_Default_In = 0
						,Is_Default_Out = 0
						,App_date = Null	
						--,Out_Time = NULL
						--,Out_Date_Time = NULL commented by Deepal 11102021
						,Duration = 0
						,Apr_Date=Null
						,In_Date_Time= @In_Time 
						,Out_Date_Time = @Out_Time
						,Other_Reason = null -- Added by ronakk 25012023
						Where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date  
					End
				else
					BEGIN
				
						Update T0150_EMP_INOUT_RECORD Set
							 Reason=''
							,Chk_By_Superior = 0
							,Sup_Comment = ''
							,Half_Full_day = ''
							,Is_Cancel_Late_In = 0
							,Is_Cancel_Early_Out = 0			 
							,Is_Default_In = 0
							,Is_Default_Out = 0
							,App_date = Null
							,Apr_Date=Null
							,In_Date_Time= case when In_Admin_Time = 'A' then @In_Date_Time Else NULL end
							,Out_Date_Time = case when Out_Admin_Time = 'A' then @Out_Date_Time Else NULL end 
							,In_Time = Case when Is_Default_In = 1 then Null else In_Time End
							,Out_Time = Case when Is_Default_Out = 1 then Null else Out_Time End
							,Duration = Case When Is_Default_In =1 OR Is_Default_Out = 1 then Null Else Duration End
							,Other_Reason = null -- Added by ronakk 25012023
						Where Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date  
				

				--if ((Select In_Admin_Time from T0150_EMP_INOUT_RECORD  where  Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date ) = 'A')
				--Begin 

				--	update T0150_EMP_INOUT_RECORD
				--	set 
				--	OUT_Admin_Time = NULL
				--	Where  Cmp_Id=@Cmp_Id and Emp_ID=@Emp_ID and For_Date=@For_Date
				--	Return
				--END

				END
			IF exists(select 1 FROM T0115_AttendanceRegu_Level_Approval WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_Id AND For_Date = @For_Date)
			BEGIN
				DELETE FROM T0115_AttendanceRegu_Level_Approval WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_Id AND For_Date = @For_Date  --Added by Deepal to solved the Unipath issue 04062022
			END
		End	 
END
