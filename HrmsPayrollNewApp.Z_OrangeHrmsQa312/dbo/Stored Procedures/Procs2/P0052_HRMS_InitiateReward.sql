

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0052_HRMS_InitiateReward]
	@InitReward_Id			numeric(18,0) output
   ,@Cmp_Id					numeric(18,0)
   ,@From_Date				datetime
   ,@To_Date				datetime
   ,@Dept_Id				varchar(800)
   ,@Cat_Id					varchar(800)
   ,@tran_type				varchar(1) 
   ,@User_Id				numeric(18,0) = 0
   ,@IP_Address			    varchar(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) <>'D' and @From_Date > @To_Date
	Begin
		SET @InitReward_Id=0
		RAISERROR('@@To Date Must Be Greater Than From Date.@@', 16,1);
	END
	If Exists(select InitReward_Id From dbo.T0052_HRMS_InitiateReward WITH (NOLOCK) WHERE From_Date= @From_Date)  
      begin     
       SET @InitReward_Id=0
		RAISERROR('@@From date already exists@@', 16,1);
       return          
	END
	If Exists(select InitReward_Id From dbo.T0052_HRMS_InitiateReward WITH (NOLOCK) WHERE To_Date= @To_Date)  
      begin     
       SET @InitReward_Id=0
		RAISERROR('@@To date already exists@@', 16,1);
       return          
	END

	If Upper(@tran_type) ='I'
		Begin
		
			select @InitReward_Id = isnull(max(InitReward_Id),0) + 1 from T0052_HRMS_InitiateReward WITH (NOLOCK)
			insert into T0052_HRMS_InitiateReward
			(
				   InitReward_Id
				  ,Cmp_Id
				  ,From_Date
				  ,To_Date
				  ,Dept_Id
				  ,Cat_Id
			)
			Values
			(
				   @InitReward_Id
				  ,@Cmp_Id
				  ,@From_Date
				  ,@To_Date
				  ,@Dept_Id
				  ,@Cat_Id
			)
		END
	Else If Upper(@tran_type) ='U'
		Begin
			Update T0052_HRMS_InitiateReward
			set  InitReward_Id	=	@InitReward_Id
				,From_Date		=	@From_Date
				,To_Date		=	@To_Date
				,Dept_Id		=	@Dept_Id
				,Cat_Id			=	@Cat_Id
				where InitReward_Id = @InitReward_Id
		End
	Else If Upper(@tran_type) ='D'
		Begin
			Delete from T0052_HRMS_InitiateReward where InitReward_Id = @InitReward_Id
		End
END


