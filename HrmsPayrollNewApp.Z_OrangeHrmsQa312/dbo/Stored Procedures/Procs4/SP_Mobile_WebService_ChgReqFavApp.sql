-- =============================================
-- Author:		<Author,,Nilesh Patel>
-- Create date: <Create Date,12-Dec-2014 ,>
-- Description:	<Description, For Change Application Details,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_WebService_ChgReqFavApp] 
	 @Row_id					Numeric(18,0),
	 @Cmp_id					Numeric(18,0),
	 @Emp_ID					Numeric(18,0),
	 @Request_Type_id			Numeric(18,0),
	 @Change_Reason				Varchar(500),
	 @Request_Date				datetime,
	 @EmpFavSportID				Varchar(250) = NULL,
	 @EmpFavSportName			Varchar(250) = NULL,
	 @EmpHobbyID				Varchar(250) = NULL,
	 @EmpHobbyName				Varchar(250) = NULL,
	 @EmpFavFood				Varchar(250) = NULL,
	 @EmpFavRestro				Varchar(250) = NULL,
	 @EmpFavTrvDestination		Varchar(250) = NULL,
	 @EmpFavFestival			Varchar(250) = NULL,
	 @EmpFavSportPerson			Varchar(250) = NULL,
	 @EmpFavSinger				Varchar(250) = NULL,
	 @CurrEmpFavSportID			Varchar(250) = NULL,
	 @CurrEmpFavSportName		Varchar(250) = NULL,
	 @CurrEmpHobbyID			Varchar(250) = NULL,
	 @CurrEmpHobbyName			Varchar(250) = NULL,
	 @CurrEmpFavFood			Varchar(250) = NULL,
	 @CurrEmpFavRestro			Varchar(250) = NULL,
	 @CurrEmpFavTrvDestination	Varchar(250) = NULL,
	 @CurrEmpFavFestival		Varchar(250) = NULL,
	 @CurrEmpFavSportPerson		Varchar(250) = NULL,
	 @CurrEmpFavSinger			Varchar(250) = NULL,
	 @Image_path				VarChar(250) = '',
	 @tran_type					char(1),
	 @OtherSport				nvarchar(200)  = '',
	 @OtherHobby				nvarchar(200)  = '',
	 @Request_id				Numeric(18,0) output,
	 @Result					Varchar(250) output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  
	DECLARE @MONTH NUMERIC(18,0)
	DECLARE @YEAR NUMERIC(18,0)
	DECLARE @YEAR_ST_DATE DATETIME
	DECLARE @YEAR_END_DATE DATETIME		
	Declare @App_Count numeric(18,0) = 0
	DECLARE @Appr_Count numeric(18,0) = 0
	Declare @Count numeric(18,0) = 0 
	Declare @Max_Limit numeric(18,0) 
	declare @Message varchar(2000)
		
    if @tran_type = 'I'
		Begin	
					
			If Exists(Select Request_id From T0090_Change_Request_Application WITH (NOLOCK) Where Emp_id = @Emp_ID and Request_Type_id = @Request_Type_id and Request_status = 'P')
				begin					
					Select @Request_id = Request_id From T0090_Change_Request_Application WITH (NOLOCK) Where Emp_id = @Emp_ID and Request_Type_id = @Request_Type_id and Request_status = 'P'
					Set @Request_id = 0
					SET @Result = 'Already Exist#False#'
					Return
				end
			Else
			Begin										
					SELECT @Request_id = Isnull(max(Request_id),0) + 1 
					FROM dbo.T0090_Change_Request_Application WITH (NOLOCK)
					INSERT INTO T0090_Change_Request_Application  
					(
					  Request_id,
					  Cmp_id,
					  Emp_ID,
					  Request_Type_id,
					  Change_Reason,
					  Request_Date,
					  OtherSports,
					  OtherHobby,
					  Emp_Fav_Sport_id
					 ,Emp_Fav_Sport_Name
					 ,Emp_Hobby_id
					 ,Emp_Hobby_Name
					 ,Emp_Fav_Food
					 ,Emp_Fav_Restro
					 ,Emp_Fav_Trv_Destination
					 ,Emp_Fav_Festival
					 ,Emp_Fav_SportPerson
					 ,Emp_Fav_Singer
					 ,Curr_Emp_Fav_Sport_id
					 ,Curr_Emp_Fav_Sport_Name
					 ,Curr_Emp_Hobby_id
					 ,Curr_Emp_Hobby_Name
					 ,Curr_Emp_Fav_Food
					 ,Curr_Emp_Fav_Restro
					 ,Curr_Emp_Fav_Trv_Destination
					 ,Curr_Emp_Fav_Festival
					 ,Curr_Emp_Fav_SportPerson
					 ,Curr_Emp_Fav_Singer
					 ,Image_path
					 ,Request_Status
					 ) 
					 VALUES
					 (@Request_id,
					  @Cmp_id,
					  @Emp_ID,
					  @Request_Type_id,
					  @Change_Reason,
					  @Request_Date,
					  @OtherSport,
					  @OtherHobby
					  ,@EmpFavSportID				
					  ,@EmpFavSportName			
					  ,@EmpHobbyID				
					  ,@EmpHobbyName				
					  ,@EmpFavFood				
					  ,@EmpFavRestro				
					  ,@EmpFavTrvDestination		
					  ,@EmpFavFestival			
					  ,@EmpFavSportPerson			
					  ,@EmpFavSinger				
					  ,@CurrEmpFavSportID			
					  ,@CurrEmpFavSportName		
					  ,@CurrEmpHobbyID			
					  ,@CurrEmpHobbyName			
					  ,@CurrEmpFavFood			
					  ,@CurrEmpFavRestro			
					  ,@CurrEmpFavTrvDestination	
					  ,@CurrEmpFavFestival		
					  ,@CurrEmpFavSportPerson		
					  ,@CurrEmpFavSinger	
					  ,@Image_Path
					  ,'P'
					 )

					IF @Request_id > 0
					BEGIN 
						SET @Result = 'Inserted Successfully#True#'+cast(@Request_id as varchar)
					END
					RETURN 
			 End
		End
	ELSE IF @Tran_Type = 'U'
	BEGIN

		
				Update T0090_Change_Request_Application
				set  Change_Reason = @Change_Reason,
					 Request_Type_id = @Request_Type_id
				    ,Emp_Fav_Sport_id = @EmpFavSportID
				    ,Emp_Fav_Sport_Name = @EmpFavSportName
				    ,Emp_Hobby_id = @EmpHobbyID
				    ,Emp_Hobby_Name = @EmpHobbyName
				    ,Emp_Fav_Food = @EmpFavFood
				    ,Emp_Fav_Restro = @EmpFavRestro
				    ,Emp_Fav_Trv_Destination = @EmpFavTrvDestination
				    ,Emp_Fav_Festival = @EmpFavFestival
				    ,Emp_Fav_SportPerson = @EmpFavSportPerson
				    ,Emp_Fav_Singer = @EmpFavSinger 
					,Curr_Emp_Fav_Sport_id = @CurrEmpFavSportID			
					,Curr_Emp_Fav_Sport_Name = @CurrEmpFavSportName		
					,Curr_Emp_Hobby_id = @CurrEmpHobbyID			
					,Curr_Emp_Hobby_Name = @CurrEmpHobbyName			
					,Curr_Emp_Fav_Food = @CurrEmpFavFood			
					,Curr_Emp_Fav_Restro = @CurrEmpFavRestro			
					,Curr_Emp_Fav_Trv_Destination= @CurrEmpFavTrvDestination	
					,Curr_Emp_Fav_Festival = @CurrEmpFavFestival		
					,Curr_Emp_Fav_SportPerson = @CurrEmpFavSportPerson		
					,Curr_Emp_Fav_Singer = @CurrEmpFavSinger	
					,OtherHobby = @OtherHobby
					,OtherSports = @OtherSport
					,Image_path = @Image_path
					where Request_id= @Row_id and Cmp_id = @Cmp_id and Emp_ID = @Emp_ID
				
					IF @Row_id > 0
					BEGIN 
						SET @Result = 'Updated Successfully#True#'
					END
					RETURN 
	END
	Else if @Tran_Type = 'D'
	BEGIN
		Delete From T0090_Change_Request_Application Where Request_id= @Row_id and Cmp_id = @Cmp_id  and Emp_ID = @Emp_ID
		IF @Row_id > 0
		BEGIN 
			SET @Result = 'Deleted Successfully#True#'
		END
		RETURN 
	END
END

