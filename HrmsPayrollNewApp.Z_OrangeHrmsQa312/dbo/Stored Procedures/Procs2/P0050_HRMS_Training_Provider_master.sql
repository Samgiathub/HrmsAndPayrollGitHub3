


 ---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0050_HRMS_Training_Provider_master] 
	 @Training_Pro_ID		Numeric(18,0) output
	,@Provider_Name			varchar(50)=null
	,@Provider_contact_Name	varchar(250)	
	,@Provider_Number 		numeric(18,0)
	,@Provider_Detail		varchar(500)
	,@Provider_Email		varchar(50)
	,@Provider_Website		varchar(50)
	,@Training_id			numeric(18,0)
	,@cmp_id				numeric(18,0)
	,@Trans_Type            char(1)
	--,@Provider_Emp_Id		numeric(18,0) =null --28 July 2015
	,@Provider_Emp_Id		varchar(max) ='' --17072017
	,@Provider_TypeId		numeric(18,0) =null--28 July 2015
	--,@Provider_FacultyId	varchar(max)=null	--28/04/2017
	,@Provider_InstituteId	numeric(18,0)   --28/04/2017
	,@Training_Institute_LocId	numeric(18,0)  --18/05/2017
	,@User_Id numeric(18,0) = 0 -- added By Mukti 14082015
    ,@IP_Address varchar(30)= '' -- added By Mukti 14082015
    
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--Added By Mukti 14082015(start)
	declare @OldValue as varchar(max)
	declare @OldProvider_Name as varchar(50)
	declare @OldProvider_contact_Name as varchar(250)	
	declare @OldProvider_Number as varchar(50)
	declare @OldProvider_Detail as	varchar(500)
	declare @OldProvider_Email	as varchar(50)
	declare @OldProvider_Website as varchar(50)
	declare @OldTraining_id as	varchar(50)
	declare @OldProvider_Emp_Id as varchar(50)
	declare @OldProvider_TypeId as varchar(50)
--Added By Mukti 14082015(end)	

	if @Training_id=0
	set @Training_id=null
	if @Provider_Number =0 
	set @Provider_Number = null
	if @cmp_id=0
	set @cmp_id=null
	if @Provider_Emp_Id = ''--28 July 2015
	set @Provider_Emp_Id = null--28 July 2015
	
	if @Provider_InstituteId = 0
	set @Provider_InstituteId = null
	
	declare @Provider_FacultyId	varchar(max)
	set @Provider_FacultyId = NULL
	
	if @Training_Institute_LocId = 0
	set @Training_Institute_LocId = null
	
	set @Provider_Detail = dbo.fnc_ReverseHTMLTags(@Provider_Detail)  --added by Ronak 221021
	If @Trans_Type  = 'I' 
		Begin 
		
			--Added By Ashwin 13102016  (START)
			if @Provider_TypeId = 0
				begin
					IF @Training_Institute_LocId is NULL	
						BEGIN
							If Exists(select 1 From T0050_HRMS_Training_Provider_master  WITH (NOLOCK) Where (Provider_Name = @Provider_Name ) and Cmp_Id = @Cmp_Id AND Training_id = @Training_id and Provider_InstituteId = @Provider_InstituteId and Training_Institute_LocId is NULL) -----training_ID Added By Ashwin 13102016
								BEGIN 
									set @Training_Pro_ID = 0
									return 
								end
						END
					ELSE
						BEGIN
							If Exists(select 1 From T0050_HRMS_Training_Provider_master  WITH (NOLOCK) Where (Provider_Name = @Provider_Name ) and Cmp_Id = @Cmp_Id AND Training_id = @Training_id and Provider_InstituteId = @Provider_InstituteId and Training_Institute_LocId = @Training_Institute_LocId) -----training_ID Added By Ashwin 13102016
								BEGIN 
									set @Training_Pro_ID = 0
									return 
								end
						END
						
					--added on 19/05/2017-------(start)
			
						IF @Training_Institute_LocId IS NULL
							BEGIN
								SELECT @Provider_FacultyId  = STUFF
									   ((SELECT     '#' + cast(b.Training_FacultyId as VARCHAR)
										   FROM         T0055_Training_Faculty b WITH (NOLOCK)
										   WHERE		b.Training_InstituteId = a.Training_InstituteId and 
														b.Training_Id  = a.Training_Id and
														b.Training_Institute_LocId is null 
														FOR XML PATH('')), 1, 1, '')
								FROM T0055_Training_Faculty  a WITH (NOLOCK)
								WHERE Cmp_Id = @cmp_id and Training_InstituteId = @Provider_InstituteId and Training_Id = @Training_Id and Training_Institute_LocId is NULL
							END
						ELSE
							BEGIN
								SELECT @Provider_FacultyId  = STUFF
									   ((SELECT     '#' + cast(b.Training_FacultyId as VARCHAR)
										   FROM         T0055_Training_Faculty b WITH (NOLOCK)
										   WHERE		b.Training_InstituteId = a.Training_InstituteId and 
														b.Training_Id  = a.Training_Id and 
														b.Training_Institute_LocId = a.Training_Institute_LocId 
											FOR XML PATH('')), 1, 1, '')
								FROM T0055_Training_Faculty  a WITH (NOLOCK)
								WHERE Cmp_Id = @cmp_id and Training_InstituteId = @Provider_InstituteId and Training_Id = @Training_Id and Training_Institute_LocId = @Training_Institute_LocId
							END
						
						
					--added on 19/05/2017-------(end)
				end
			Else if  @Provider_TypeId = 1
				begin
					If Exists(select 1 From T0050_HRMS_Training_Provider_master WITH (NOLOCK) Where (Provider_Emp_Id = @Provider_Emp_Id ) and Cmp_Id = @Cmp_Id AND Training_id = @Training_id) -----training_ID Added By Ashwin 13102016
						begin 
							set @Training_Pro_ID = 0
							return 
						end
				end
			
			--Added By Ashwin 13102016 (END)
		
			--commented by Mukti 19082015(start)
			--if @Provider_TypeId = 0
			--	begin
			--		If Exists(select Training_Pro_ID From T0050_HRMS_Training_Provider_master  Where (Provider_Name = @Provider_Name ) and Cmp_Id = @Cmp_Id)
			--			begin 
			--				set @Training_Pro_ID = 0
			--				return 
			--			end
			--	end
			--Else if  @Provider_TypeId = 1
			--	begin
			--		If Exists(select Training_Pro_ID From T0050_HRMS_Training_Provider_master  Where (Provider_Emp_Id = @Provider_Emp_Id ) and Cmp_Id = @Cmp_Id)
			--			begin 
			--				set @Training_Pro_ID = 0
			--				return 
			--			end
			--	end
			--commented by Mukti 19082015(end)
			
			
			
			select @Training_Pro_ID = Isnull(max(Training_Pro_ID),0) + 1 	From T0050_HRMS_Training_Provider_master WITH (NOLOCK)

			INSERT INTO T0050_HRMS_Training_Provider_master
			        (
						    Training_Pro_ID
							,Provider_Name
							,Provider_contact_Name
							,Provider_Number
							,Provider_Detail
							,Provider_Email
							,Provider_Website
							,Training_id
							,cmp_id
							,Provider_Emp_Id
							,Provider_TypeId
							,Provider_FacultyId		--28/04/2017
							,Provider_InstituteId	--28/04/2017
							,Training_Institute_LocId	--18/05/2017
			        )
				VALUES     
					(		@Training_Pro_ID
							,@Provider_Name
							,@Provider_contact_Name
							,@Provider_Number
							,@Provider_Detail
							,@Provider_Email
							,@Provider_Website
							,@Training_id
							,@cmp_id 
							,@Provider_Emp_Id --28 July 2015
							,@Provider_TypeId --28 July 2015
							,@Provider_FacultyId		--28/04/2017
							,@Provider_InstituteId		--28/04/2017
							,@Training_Institute_LocId	--18/05/2017
					)
					
			--Added By Mukti 14082015(start)
				    set @OldValue = 'New Value' + '#'+ 'Provider Name :' + cast(Isnull(@Provider_Name,'') as varchar(50)) + '#' + 
						'Provider contact Name :' + cast(Isnull(@Provider_contact_Name,'') as varchar(50)) + '#' + 
						'Provider Number :' + cast(Isnull(@Provider_Number,0) as varchar(50)) + '#' + 
						'Provider Detail :' + cast(Isnull(@Provider_Detail,'') as varchar(500)) + '#' + 
						'Email ID :' + cast(Isnull(@Provider_Email,'') as varchar(50)) + '#' + 
						'Website :' + cast(Isnull(@Provider_Website,'') as varchar(50)) + '#' + 
						'Training id :' + cast(Isnull(@Training_id,0) as varchar(5)) + '#' + 
						'Company Id  :' + Cast(ISNULL(@Cmp_Id,0) as varchar(5)) + '#' +
						'Provider Emp Id :' + cast(Isnull(@Provider_Emp_Id,'') as varchar(max)) + '#' +
						'Provider Type Id :' + cast(Isnull(@Provider_TypeId,0) as varchar(5)) 
			--Added By Mukti 14082015(end)	
		End
	Else if @Trans_Type = 'U'
 		begin
 		
 			--Added By Ashwin 13102016(Start)	
 			if @Provider_TypeId = 0
					begin
						IF @Training_Institute_LocId is NULL	
							BEGIN
								If Exists(select 1 From T0050_HRMS_Training_Provider_master WITH (NOLOCK)  Where (Provider_Name = @Provider_Name ) and Cmp_Id = @Cmp_Id AND Training_id = @Training_id and Provider_InstituteId = @Provider_InstituteId and Training_Institute_LocId is NULL AND Training_Pro_ID <> @Training_Pro_ID) -----training_ID Added By Ashwin 13102016
									BEGIN 
										set @Training_Pro_ID = 0
										return 
									end
							END
						ELSE
							BEGIN
								If Exists(select 1 From T0050_HRMS_Training_Provider_master WITH (NOLOCK)  Where (Provider_Name = @Provider_Name ) and Cmp_Id = @Cmp_Id AND Training_id = @Training_id and Provider_InstituteId = @Provider_InstituteId and Training_Institute_LocId = @Training_Institute_LocId AND Training_Pro_ID <> @Training_Pro_ID) -----training_ID Added By Ashwin 13102016
									BEGIN 
										set @Training_Pro_ID = 0
										return 
									end
							END
						
							--added on 19/05/2017-------(start)
			
						IF @Training_Institute_LocId IS NULL
							BEGIN
								SELECT @Provider_FacultyId  = STUFF
									   ((SELECT     '#' + cast(b.Training_FacultyId as VARCHAR)
										   FROM         T0055_Training_Faculty b WITH (NOLOCK)
										   WHERE		b.Training_InstituteId = a.Training_InstituteId and 
														b.Training_Id  = a.Training_Id and
														b.Training_Institute_LocId is null 
														FOR XML PATH('')), 1, 1, '')
								FROM T0055_Training_Faculty  a WITH (NOLOCK)
								WHERE Cmp_Id = @cmp_id and Training_InstituteId = @Provider_InstituteId and Training_Id = @Training_Id and Training_Institute_LocId is NULL
							END
						ELSE
							BEGIN
								SELECT @Provider_FacultyId  = STUFF
									   ((SELECT     '#' + cast(b.Training_FacultyId as VARCHAR)
										   FROM         T0055_Training_Faculty b WITH (NOLOCK)
										   WHERE		b.Training_InstituteId = a.Training_InstituteId and 
														b.Training_Id  = a.Training_Id and 
														b.Training_Institute_LocId = a.Training_Institute_LocId 
											FOR XML PATH('')), 1, 1, '')
								FROM T0055_Training_Faculty  a WITH (NOLOCK)
								WHERE Cmp_Id = @cmp_id and Training_InstituteId = @Provider_InstituteId and Training_Id = @Training_Id and Training_Institute_LocId = @Training_Institute_LocId
							END
						
						
					--added on 19/05/2017-------(end)	
					end
				Else if  @Provider_TypeId = 1
					begin
						If Exists(select 1 From T0050_HRMS_Training_Provider_master  WITH (NOLOCK) Where (Provider_Emp_Id = @Provider_Emp_Id ) and Cmp_Id = @Cmp_Id
								AND Training_id = @Training_id AND Training_Pro_ID <> @Training_Pro_ID) -----training_ID Added By Ashwin 13102016
							begin 
								set @Training_Pro_ID = 0
								return 
							end
					end
			--Added By Ashwin 13102016(End)	
		
			--If Exists(select Training_Pro_ID From T0050_HRMS_Training_Provider_master  Where Provider_Name = @Provider_Name and Cmp_Id = @Cmp_Id 
			--								and Training_Pro_ID <> @Training_Pro_ID )
			--	begin
			--		set @Training_Pro_ID = 0
			--		return 
			--	end
			
		   --Added By Mukti 14082015(start)
				select @OldProvider_Name=Provider_Name,@OldProvider_contact_Name=Provider_contact_Name,
					   @OldProvider_Number=Provider_Number,@OldProvider_Detail=Provider_Detail,
					   @OldProvider_Email=Provider_Email,@OldProvider_Website=Provider_Website,
					   @OldTraining_id=Training_id,@OldProvider_Emp_Id=Provider_Emp_Id,
					   @OldProvider_TypeId=Provider_TypeId
				from T0050_HRMS_Training_Provider_master WITH (NOLOCK) where Training_Pro_ID = @Training_Pro_ID
	       --Added By Mukti 14082015(end)	
	       
				UPDATE    T0050_HRMS_Training_Provider_master
				SET          
							Provider_Name=@Provider_Name
							,Provider_contact_Name=@Provider_contact_Name
							,Provider_Number=@Provider_Number
							,Provider_Detail=@Provider_Detail
							,Provider_Email=@Provider_Email
							,Provider_Website=@Provider_Website
							,Training_id=@Training_id
							,Provider_Emp_Id=@Provider_Emp_Id--28 July 2015
							,Provider_TypeId=@Provider_TypeId--28 July 2015
							,Provider_FacultyId = @Provider_FacultyId --28/04/2017
							,Provider_InstituteId = @Provider_InstituteId --28/04/2017
							,Training_Institute_LocId = @Training_Institute_LocId --18/05/2017
				where Training_Pro_ID = @Training_Pro_ID
				
		--Added By Mukti 14082015(start)
				    set @OldValue = 'Old Value' + '#'+ 'Provider Name :' + cast(Isnull(@OldProvider_Name,'') as varchar(50)) + '#' + 
							'Provider contact Name :' + cast(Isnull(@OldProvider_contact_Name,'') as varchar(250)) + '#' + 
							'Provider Number :' + cast(Isnull(@OldProvider_Number,'')as varchar(50)) + '#' + 
							'Provider Detail :' + cast(Isnull(@OldProvider_Detail,'') as varchar(500)) + '#' + 
							'Email ID :' + cast(Isnull(@OldProvider_Email,'') as varchar(50)) + '#' + 
							'Website :' + cast(Isnull(@OldProvider_Website,'') as varchar(50)) + '#' + 
							'Training id :' + cast(Isnull(@OldTraining_id,'') as varchar(5)) + '#' + 
							'Company Id  :' + Cast(ISNULL(@Cmp_Id,0)as varchar(5)) + '#' +
							'Provider Emp Id :' + cast(Isnull(@OldProvider_Emp_Id,'') as varchar(5)) + '#' +
							'Provider Type Id :' + cast(Isnull(@OldProvider_TypeId,'') as varchar(5))+ '#' +
						'New Value' + '#'+ 'Provider Name :' + cast(Isnull(@Provider_Name,'') as varchar(50)) + '#' + 
							'Provider contact Name :' + cast(Isnull(@Provider_contact_Name,'') as varchar(250)) + '#' + 
							'Provider Number :' + cast(Isnull(@Provider_Number,0) as varchar(50)) + '#' + 
							'Provider Detail :' + cast(Isnull(@Provider_Detail,'') as varchar(500)) + '#' + 
							'Email ID :' + cast(Isnull(@Provider_Email,'') as varchar(50)) + '#' + 
							'Website :' + cast(Isnull(@Provider_Website,'') as varchar(50)) + '#' + 
							'Training id :' + cast(Isnull(@Training_id,0) as varchar(5)) + '#' + 
							'Company Id  :' + Cast(ISNULL(@Cmp_Id,0) as varchar(5)) + '#' +
							'Provider Emp Id :' + cast(Isnull(@Provider_Emp_Id,0) as varchar(5)) + '#' +
							'Provider Type Id :' + cast(Isnull(@Provider_TypeId,0) as varchar(5)) 
		--Added By Mukti 14082015(end)			
		end
	Else If @Trans_Type = 'D'
		begin
			--Added By Mukti 14082015(start)
				select @OldProvider_Name=Provider_Name,@OldProvider_contact_Name=Provider_contact_Name,
					   @OldProvider_Number=Provider_Number,@OldProvider_Detail=Provider_Detail,
					   @OldProvider_Email=Provider_Email,@OldProvider_Website=Provider_Website,
					   @OldTraining_id=Training_id,@OldProvider_Emp_Id=Provider_Emp_Id,
					   @OldProvider_TypeId=Provider_TypeId
				from T0050_HRMS_Training_Provider_master WITH (NOLOCK) where Training_Pro_ID = @Training_Pro_ID
	        --Added By Mukti 14082015(end)	
		
		------added on 19/05/2017 --start
				IF @Training_Institute_LocId is NULL
					DELETE FROM T0055_Training_Faculty WHERE Training_Institute_LocId is null and Training_InstituteId= @Provider_InstituteId and Training_Id = @Training_Id
				ELSE
					DELETE FROM T0055_Training_Faculty WHERE Training_Institute_LocId = @Training_Institute_LocId and Training_InstituteId= @Provider_InstituteId and Training_Id = @Training_Id
		------added on 19/05/2017 --end		
				Delete From T0050_HRMS_Training_Provider_master Where Training_Pro_ID = @Training_Pro_ID
				
			--Added By Mukti 14082015(start)
				    set @OldValue = 'Old Value' + '#'+ 'Provider Name :' + cast(Isnull(@OldProvider_Name,'') as varchar(50)) + '#' + 
							'Provider contact Name :' + cast(Isnull(@OldProvider_contact_Name,'') as varchar(250)) + '#' + 
							'Provider Number :' + cast(Isnull(@OldProvider_Number,'')as varchar(50)) + '#' + 
							'Provider Detail :' + cast(Isnull(@OldProvider_Detail,'') as varchar(500)) + '#' + 
							'Email ID :' + cast(Isnull(@OldProvider_Email,'') as varchar(50)) + '#' + 
							'Website :' + cast(Isnull(@OldProvider_Website,'') as varchar(50)) + '#' + 
							'Training id :' + cast(Isnull(@OldTraining_id,'') as varchar(5)) + '#' + 
							'Company Id  :' + Cast(ISNULL(@Cmp_Id,0)as varchar(5)) + '#' +
							'Provider Emp Id :' + cast(Isnull(@OldProvider_Emp_Id,'') as varchar(5)) + '#' +
							'Provider Type Id :' + cast(Isnull(@OldProvider_TypeId,'') as varchar(5))
			--Added By Mukti 14082015(end)		
		end
		
	exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Provider Master',@OldValue,@Training_Pro_ID,@User_Id,@IP_Address --Mukti 14082015
RETURN
	



