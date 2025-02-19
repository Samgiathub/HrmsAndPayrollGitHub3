
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_BalanceScoreCard_Setting]
	   @BSC_SettingId	numeric(18,0) out
      ,@Cmp_Id			numeric(18,0)
      ,@Emp_Id			numeric(18,0)
      ,@BSC_Status		numeric(18,0)
      ,@FinYear			int
      ,@Tran_Type		varchar(1)
      ,@User_Id			numeric(18,0)
      ,@IP_Address		varchar(30)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN

declare @OldValue as varchar(max)
declare @OldBSC_Status as varchar(18)
declare @OldFinYear as varchar(4)
--declare @OldEmp_Comment as varchar(300)
--declare @OldManager_Comment as varchar(300)
declare @oldDate as varchar(50)

set @OldValue =''
set @OldBSC_Status = ''
set @OldFinYear = ''
--set @OldEmp_Comment =''
--set @OldManager_Comment =''
set @oldDate =''

	
	If @Tran_Type = 'I'
		BEGIN
			if EXISTS(select 1 from T0090_BalanceScoreCard_Setting WITH (NOLOCK) where Emp_Id=@Emp_Id and FinYear=@FinYear)
				BEGIN 
					SET @BSC_SettingId = 0 
					Select @BSC_SettingId
					RETURN
				END
			select @BSC_SettingId = isnull(max(BSC_SettingId),0)+1 from T0090_BalanceScoreCard_Setting WITH (NOLOCK)
			INSERT INTO T0090_BalanceScoreCard_Setting
			(
			   BSC_SettingId
			  ,Cmp_Id
			  ,Emp_Id
			  ,BSC_Status
			  ,FinYear
			  ,Createddate
			  ,CreatedBy
			)VALUES
			(
			   @BSC_SettingId
			  ,@Cmp_Id
			  ,@Emp_Id
			  ,@BSC_Status
			  ,@FinYear
			  ,Getdate()
			  ,@User_Id	
			)
			
			set @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @BSC_Status = 0 then 'Draft' when @BSC_Status=1 then 'Send For Employee Review' when @BSC_Status=3 then 'Approved By Employee' when @BSC_Status =4 then 'Approved By Manager' end + '#' + 'Date :' +  cast(GETDATE() as varchar)
		END
	ELSE IF  @Tran_Type = 'U'
		BEGIN
			select @OldBSC_Status = cast(BSC_Status as varchar) ,@OldFinYear =cast(FinYear as varchar),@oldDate= isnull(ModifiedDate,CreatedDate) From dbo.T0090_BalanceScoreCard_Setting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and BSC_SettingId = @BSC_SettingId
		
			UPDATE T0090_BalanceScoreCard_Setting
			SET BSC_Status	= @BSC_Status
				,FinYear	= @FinYear
				,ModifiedDate = GETDATE()
				,ModifiedBy	= @User_Id
			Where BSC_SettingId = @BSC_SettingId
			
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + @OldFinYear + '#' + 'Status :' + case when @OldBSC_Status = 0 then 'Draft' when @OldBSC_Status=1 then 'Send For Employee Review' when @OldBSC_Status=3 then 'Approved By Employee' when @OldBSC_Status =4 then 'Approved By Manager' end + '#' + 'Date :' +  @oldDate +
							'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @BSC_Status = 0 then 'Draft' when @BSC_Status=1 then 'Send For Employee Review' when @BSC_Status=3 then 'Approved By Employee' when @BSC_Status =4 then 'Approved By Manager' end + '#' + 'Date :' + cast(GETDATE() as varchar)
		END
	ELSE IF  @Tran_Type = 'D'
		BEGIN	
			select @OldBSC_Status = BSC_Status ,@OldFinYear =FinYear,@oldDate= isnull(ModifiedDate,CreatedDate) From dbo.T0090_BalanceScoreCard_Setting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and BSC_SettingId = @BSC_SettingId
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + @OldFinYear + '#' + 'Status :' + case when @OldBSC_Status = 0 then 'Draft' when @OldBSC_Status=1 then 'Send For Employee Review' when @OldBSC_Status=3 then 'Approved By Employee' when @OldBSC_Status =4 then 'Approved By Manager' end + '#' + 'Date :' +  @oldDate
		
			DELETE FROM T0115_BSC_ScoringKey_Level WHERE BSC_Setting_Detail_Id IN 
				(SELECT  cast(data AS numeric(18, 0)) 
				 FROM    dbo.Split(ISNULL(BSC_Setting_Detail_Id,'0'), '#')
				 left join T0095_BalanceScoreCard_Setting_Details WITH (NOLOCK) on 
					T0115_BSC_ScoringKey_Level.BSC_Setting_Detail_Id=T0095_BalanceScoreCard_Setting_Details.BSC_Setting_Detail_Id
				 WHERE   data <> '' and  BSC_SettingId = @BSC_SettingId  FOR XML path(''))
			
			DELETE FROM T0115_BalanceScoreCard_Setting_Details_Level WHERE BSC_Level_Id IN 
			(select BSC_Level_Id from  T0110_BalanceScoreCard_Setting_Approval WITH (NOLOCK)  where BSC_SettingId= @BSC_SettingId)
			DELETE FROM T0110_BalanceScoreCard_Setting_Approval WHERE BSC_SettingId = @BSC_SettingId
		
			DELETE FROM T0100_BSC_ScoringKey WHERE BSC_Setting_Detail_Id IN 
				(SELECT  cast(data AS numeric(18, 0)) 
				 FROM    dbo.Split(ISNULL(BSC_Setting_Detail_Id,'0'), '#')
				 left join T0095_BalanceScoreCard_Setting_Details WITH (NOLOCK) on 
					T0100_BSC_ScoringKey.BSC_Setting_Detail_Id=T0095_BalanceScoreCard_Setting_Details.BSC_Setting_Detail_Id
				 WHERE   data <> '' and  BSC_SettingId = @BSC_SettingId  FOR XML path(''))
			
			DELETE FROM T0095_BalanceScoreCard_Setting_Details WHERE BSC_SettingId = @BSC_SettingId
			DELETE FROM T0090_BalanceScoreCard_Setting WHERE BSC_SettingId = @BSC_SettingId
		END
 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Balance Score Setting',@OldValue,@BSC_SettingId,@User_Id,@IP_Address

END

