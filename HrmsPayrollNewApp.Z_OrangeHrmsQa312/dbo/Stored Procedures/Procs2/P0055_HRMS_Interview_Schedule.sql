
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_HRMS_Interview_Schedule]
	@Interview_Schedule_Id			numeric(18,0) output
	,@Interview_Process_Detail_Id	numeric(18,0)
	,@Rec_Post_Id					numeric(18,0)
	,@Cmp_Id						numeric(18,0)
	,@S_Emp_Id						numeric(18,0)
	,@S_Emp_Id2                     numeric(18,0)
	,@S_Emp_Id3                     numeric(18,0)
	,@S_Emp_ID4                     numeric(18,0)
	,@From_Date                     datetime
	,@To_Date                       datetime
	,@From_Time                     varchar(15)
	,@To_Time                       varchar(15) 
	,@Resume_Id						numeric(18,0)
	,@Rating						numeric(18,2)
	,@Rating2                       numeric(18,2)
	,@Rating3                       numeric(18,2)
	,@Rating4						numeric(18,2)
	,@Schedule_Time					varchar(50)
	,@Schedule_Date					Datetime
	,@Process_Dis_No				numeric(18,0)
	,@status						numeric(18,0)
	,@tran_type						char(1)
	,@Comments						varchar(1000)
	,@HR_Doc_ID						numeric(18,0) = 0  --Mukti 09052015
	,@Paid_Travel_Amount			numeric(18,2)=0 --Mukti(12012019) 

AS
-------------------------------------------------------------------------
----------------- Created By : Falak on 21-apr-2010 ---------------------
-------------------------------------------------------------------------
----------------  Changed BY : Falak on 17-Jun-2010 ---------------------
---------------- Added New column for table 'Comments' ------------------
-------------------------------------------------------------------------
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	 if @Rating = 0
		set @Rating = null
	if @Rating2 = 0
		set @Rating = null
	if @Rating3 = 0
		set @Rating = null
	if @Rating4 = 0
		set @Rating = null
	if @Comments = ''
		set @Comments = null
	if @Schedule_Time = ''
		set @Schedule_Time = null
	if @Schedule_Date =null
		set @Schedule_Date =null
	if @S_Emp_Id2 = 0
		set @S_Emp_Id2 = null	
	if @S_Emp_Id3 = 0
		set @S_Emp_Id3 = null
	if @S_Emp_Id4 = 0
		set @S_Emp_Id4 = null
	if @Interview_Process_Detail_Id = 0
		set @Interview_Process_Detail_Id = null
	if @S_Emp_Id = 0
		set @S_Emp_Id = null	
	if @HR_Doc_ID =0
		set @HR_Doc_ID=NULL
			
		DECLARE @Interview_Schedule_History_Id  NUMERIC(18,0)
	 
	if @tran_type = 'I'
	begin
		if exists (Select Interview_Schedule_Id  from T0055_HRMS_Interview_Schedule WITH (NOLOCK) Where cmp_id= @CMP_ID AND Interview_Process_Detail_Id = @Interview_Process_Detail_Id and Resume_Id = @Resume_Id)
		begin
			--if(@Rating <> 0 or @Rating<>null)
			--	begin
					Update T0055_HRMS_Interview_Schedule 
					Set 
						 Rating = @Rating
						,S_Emp_Id	= @S_Emp_Id
						,S_Emp_Id2 =@S_Emp_Id2
						,S_Emp_Id3 = @S_Emp_Id3
						,S_Emp_Id4 = @S_Emp_Id4
						,From_Date =@From_Date
						,To_Date=@To_Date
						,From_Time=@From_Time                       
						,To_Time =@To_Time 
						,status = @status		
						,System_Date=getdate()
						,Comments = @Comments	
						,HR_Doc_ID=@HR_Doc_ID
						,Paid_Travel_Amount=@Paid_Travel_Amount
						where Interview_Schedule_Id = @Interview_Schedule_Id
											
					--End
				--else
				--	begin
				--		Update T0055_HRMS_Interview_Schedule 
				--	Set 						
				--		S_Emp_Id	= @S_Emp_Id
				--		,S_Emp_Id2 =@S_Emp_Id2
				--		,S_Emp_Id3 = @S_Emp_Id3
				--		,S_Emp_Id4 = @S_Emp_Id4
				--		,From_Date =@From_Date
				--		,To_Date=@To_Date
				--		,From_Time=@From_Time                       
				--		,To_Time =@To_Time 
				--		where Interview_Process_Detail_Id = @Interview_Process_Detail_Id and Resume_Id = @Resume_Id
				--	end
					
			RETURN 
		end
		
					
		select @Interview_Schedule_Id = isnull(max(Interview_Schedule_Id),0) +1 from T0055_HRMS_Interview_Schedule WITH (NOLOCK) 
     
     						
		insert into T0055_HRMS_Interview_Schedule(
											Interview_Schedule_Id
											,Interview_Process_Detail_Id
											,cmp_id
											,Rec_Post_ID																				
											,S_Emp_ID
											,S_Emp_Id2
											,S_Emp_Id3
											,S_Emp_ID4
											,From_Date 
											,To_Date
											,From_Time                
											,To_Time 
											,Resume_Id
											,Rating
											,Rating2
											,Rating3 
											,Rating4
											,Schedule_Time
											,Schedule_Date
											,Process_Dis_No
											,status
											,System_Date
											,Comments
											,HR_Doc_ID
											,Paid_Travel_Amount
					) 
											
								values(      @Interview_Schedule_Id
											,@Interview_Process_Detail_Id
											,@cmp_id
											,@Rec_Post_ID											
											,@S_Emp_ID
											,@S_Emp_Id2
											,@S_Emp_Id3
											,@S_Emp_ID4
											,@From_Date 
											,@To_Date
											,@From_Time                
											,@To_Time 
											,@Resume_Id
											,@Rating
											,@Rating2
											,@Rating3 
											,@Rating4
											,@Schedule_Time
											,@Schedule_Date
											,@Process_Dis_No
											,@status
											,getdate()
											,@Comments
											,@HR_Doc_ID
											,@Paid_Travel_Amount
					)					
		update t0055_resume_master set resume_status=1,Rec_Post_ID=@Rec_Post_ID , resume_code =('R' + cast(@cmp_id as varchar(20)) + ':' + cast(1000 + isnull(@Resume_id,0) as varchar(20)) ) where cmp_id=@cmp_id and resume_id =@resume_id
		--
		
		---added on 25/10/2017 - for maintaining interview history		
		SELECT @Interview_Schedule_History_Id = isnull(max(Interview_Schedule_History_Id),0) +1 from T0055_HRMS_Interview_Schedule_History WITH (NOLOCK)
		INSERT INTO T0055_HRMS_Interview_Schedule_History
		(
			 Interview_Schedule_History_Id
			,Interview_Process_Detail_Id
			,Cmp_Id
			,Rec_Post_Id
			,Resume_Id
			,S_Emp_Id
			,S_Emp_Id2
			,S_Emp_Id3
			,S_Emp_Id4
			,From_Date
			,To_Date
			,From_Time
			,To_Time
			,System_Date
		)VALUES
		(
			@Interview_Schedule_History_Id
			,@Interview_Process_Detail_Id
			,@Cmp_Id
			,@Rec_Post_Id
			,@Resume_Id
			,@S_Emp_Id
			,@S_Emp_Id2
			,@S_Emp_Id3
			,@S_Emp_Id4
			,@From_Date
			,@To_Date
			,@From_Time
			,@To_Time
			,GETDATE()
		)
		  --end
		end 
	ELSE IF upper(@tran_type) ='U' 
	BEGIN
			
		IF 	(@Rating IS NULL  and @S_Emp_ID IS NOT NULL)
			BEGIN 
				UPDATE T0055_HRMS_Interview_Schedule 
				SET  S_Emp_ID	= @S_Emp_ID
					,S_Emp_Id2	= @S_Emp_Id2
					,S_Emp_Id3	= @S_Emp_Id3
					,S_Emp_ID4	= @S_Emp_ID4
					,From_Date	= @From_Date
					,To_Date	= @To_Date
					,From_Time	= @From_Time               
					,To_Time	= @To_Time
					,Paid_Travel_Amount=@Paid_Travel_Amount
				WHERE Interview_Process_Detail_Id = @Interview_Process_Detail_Id
					 AND Resume_Id = @Resume_Id AND Rec_Post_Id = @Rec_Post_ID
					 
					 
				---added on 25/10/2017 - for maintaining interview history		
				--IF NOT EXISTS(SELECT 1 FROM T0055_HRMS_Interview_Schedule_History
				--			  WHERE Interview_Process_Detail_Id = @Interview_Process_Detail_Id
				--					AND Resume_Id = @Resume_Id AND Rec_Post_Id = @Rec_Post_ID
				--					AND ISNULL(S_Emp_Id,0) = ISNULL(@S_Emp_ID,0) AND ISNULL(S_Emp_Id2,0) = ISNULL(@S_Emp_Id2,0)
				--					AND ISNULL(S_Emp_Id3,0) = ISNULL(@S_Emp_ID3,0) AND ISNULL(S_Emp_Id4,0) = ISNULL(@S_Emp_Id4,0)
				--					AND From_Date = @From_Date AND To_Date = @To_Date
				--					AND From_Time = @From_Time AND To_Time = @To_Time)
				--	BEGIN
						SELECT @Interview_Schedule_History_Id = isnull(max(Interview_Schedule_History_Id),0) +1 from T0055_HRMS_Interview_Schedule_History WITH (NOLOCK)
						INSERT INTO T0055_HRMS_Interview_Schedule_History
				(
					 Interview_Schedule_History_Id
					,Interview_Process_Detail_Id
					,Cmp_Id
					,Rec_Post_Id
					,Resume_Id
					,S_Emp_Id
					,S_Emp_Id2
					,S_Emp_Id3
					,S_Emp_Id4
					,From_Date
					,To_Date
					,From_Time
					,To_Time
					,System_Date
				)VALUES
				(
					@Interview_Schedule_History_Id
					,@Interview_Process_Detail_Id
					,@Cmp_Id
					,@Rec_Post_Id
					,@Resume_Id
					,@S_Emp_Id
					,@S_Emp_Id2
					,@S_Emp_Id3
					,@S_Emp_Id4
					,@From_Date
					,@To_Date
					,@From_Time
					,@To_Time
					,GETDATE()
				)
					--END
			--end
			END
		ELSE 
			BEGIN
				UPDATE T0055_HRMS_Interview_Schedule 
				SET 
					Rating = @Rating
					,S_Emp_Id	= @S_Emp_Id
					,S_Emp_Id2 =@S_Emp_Id2
					,S_Emp_Id3 = @S_Emp_Id3
					,S_Emp_Id4 = @S_Emp_Id4
					,Schedule_Time = @Schedule_Time
					,Schedule_Date = @Schedule_Date
					,status = @status		
					,System_Date=getdate()
					,Comments = @Comments	
					,HR_Doc_ID=@HR_Doc_ID
					,Paid_Travel_Amount=@Paid_Travel_Amount
				WHERE Interview_Schedule_Id = @Interview_Schedule_Id  
			END
	END	
	else if upper(@tran_type) ='D'
	Begin
		--delete  from T0055_HRMS_Interview_Schedule where Interview_Schedule_Id=@Interview_Schedule_Id 
		declare @inter_process1 as numeric(18,0)
		declare @s_empid1 as numeric(18,0)
		declare @ResumeFinal_ID as numeric(18,0)
	declare @col as numeric(18,0)
		
		if exists (Select *  from T0055_HRMS_Interview_Schedule hs WITH (NOLOCK) inner join T0060_RESUME_FINAL rf WITH (NOLOCK) on hs.Resume_Id=rf.Resume_ID and hs.Cmp_Id=rf.Cmp_ID and rf.Confirm_Emp_id<>0 Where hs.Cmp_Id= @CMP_ID AND hs.Resume_Id = @Resume_Id)
			begin
				set @Interview_Schedule_Id = 0
				RAISERROR ('This details cannot be deleted because it exists in employee master', 16, 2)
				return  
			end
		else
			begin	
				select @inter_process1=Interview_Process_Detail_Id,@s_empid1=S_Emp_Id from T0055_HRMS_Interview_Schedule WITH (NOLOCK) where Resume_Id=@Resume_Id	
				select @ResumeFinal_ID=Tran_ID from T0060_RESUME_FINAL WITH (NOLOCK) where Resume_Id=@Resume_Id and Confirm_Emp_id =0
				
				delete from t0090_HRMS_RESUME_DOCUMENT where Resume_Id=@Resume_Id  --Mukti 05052015
				delete from T0095_HRMS_CANDIDATE_SCHEME where Resume_Id=@Resume_Id  --Mukti 14042015
				delete from T0100_HRMS_CANDIDATE_SCHEME_LEVEL where Resume_Id=@Resume_Id  --Mukti 14042015
				delete from T0100_HRMS_RESUME_EARN_DEDUCTION_LEVEL where Resume_Id=@Resume_Id  --Mukti 15042015
				delete from T0052_ResumeFinal_Approval where ResumeFinal_ID=@ResumeFinal_ID  --Added By Mukti 29012015 candidate approval table of scheme								
				delete from T0090_HRMS_RESUME_EARN_DEDUCTION where Resume_id=@Resume_Id  
				delete from T0052_ResumeFinal_Approval where Resume_Id=@Resume_Id --added on 1 apr 2015
				delete from T0060_RESUME_FINAL where Resume_Id=@Resume_Id and Confirm_Emp_id =0 
						
				declare cur cursor
				for 
				select Interview_Schedule_Id from 	T0055_HRMS_Interview_Schedule WITH (NOLOCK) where Resume_Id=@Resume_Id	
				open cur
				fetch next from cur into @col
				while @@FETCH_STATUS = 0
					Begin
						delete from T0060_Hrms_Interview_Feedback_detail where Interview_Schedule_Id=@col
					
						fetch next from cur into @col
					end 
				close cur
				deallocate cur	
				--delete from T0060_Hrms_Interview_Feedback_detail where Emp_id=@s_empid1
				
				delete  from T0055_HRMS_Interview_Schedule where resume_Id=@resume_Id and Rec_Post_Id = @Rec_Post_Id
				delete  from T0055_HRMS_Interview_Schedule_History where resume_Id=@resume_Id and Rec_Post_Id = @Rec_Post_Id --25/10/2017
				update T0055_Resume_Master set Resume_Status=0 where Resume_Id=@Resume_Id	and Rec_Post_Id = @Rec_Post_Id
			End		
	end
	 
RETURN




