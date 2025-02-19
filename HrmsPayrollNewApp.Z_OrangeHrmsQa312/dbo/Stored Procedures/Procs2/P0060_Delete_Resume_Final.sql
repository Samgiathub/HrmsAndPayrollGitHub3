

CREATE PROCEDURE [dbo].[P0060_Delete_Resume_Final]
  @resumeid as numeric(18,0),
  @cmpid as numeric(18,0),
  @Admin as numeric(18,0)=0
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
declare @Level2_Approval int
	if(@resumeid<>0)
		begin
			select @Level2_Approval=Level2_Approval from T0060_RESUME_FINAL WITH (NOLOCK) where Resume_ID=@resumeid and Cmp_ID = @cmpid
			if(@Level2_Approval=1)
				begin
					if (@Admin = 1)	-- Added by rohit For Only Admin can Delete Offer letter generate candidate on 20082015
					begin
						update T0060_RESUME_FINAL set Level2_Approval = 5  where Resume_ID=@resumeid and Cmp_ID = @cmpid
					end
					else
					begin
						raiserror('@@You cannot delete this data@@',16,2)
					end	
				End
			else
				begin
					Delete from T0060_RESUME_FINAL
					where Resume_ID= @resumeid and Cmp_ID= @cmpid			
					
					if exists(select 1 from T0055_HRMS_Interview_Schedule WITH (NOLOCK) where Resume_Id=@resumeid )
					begin
						declare @scheduleid as numeric(18,0)
						select @scheduleid=Interview_Schedule_Id from T0055_HRMS_Interview_Schedule WITH (NOLOCK) where Resume_Id = @resumeid and Cmp_Id=@cmpid
						delete from T0060_Hrms_Interview_Feedback_detail
						where  Interview_Schedule_Id = @scheduleid and Cmp_ID= @cmpid
					END		
					
					Delete from T0055_HRMS_Interview_Schedule
					where Resume_Id= @resumeid and Cmp_ID= @cmpid
					
				
								
					update T0055_Resume_Master set
					Resume_Status = 0
					where Cmp_id = @cmpid and Resume_Id = @resumeid
				end
		END
END


