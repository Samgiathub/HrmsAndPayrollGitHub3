
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_IMMIGRATION]
	
	 @Row_ID  NUMERIC(18,0) OUTPUT
	,@Cmp_ID  NUMERIC(18,0)
	,@Resume_ID NUMERIC(18,0)
	,@Loc_ID	numeric(18, 0)	
	,@Imm_Type	varchar(20)	
	,@Imm_No	varchar(20)	
	,@Imm_Issue_Date	datetime	
	,@Imm_Issue_Status	varchar(20)	
	,@Imm_Date_of_Expiry	datetime	
	,@Imm_Review_Date	datetime	
	,@Imm_Comments	varchar(250)	
	,@Trans_Type  char(1)
	,@Attach_docs varchar(max)=''
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF @Cmp_ID=0
		SET @Cmp_ID=NULL 
	IF @Loc_ID=0
		SET @Loc_ID=NULL 
	if @Imm_Issue_Date =''
	 set @Imm_Issue_Date=null
	if @Imm_Date_of_Expiry =''
	 set @Imm_Date_of_Expiry= null
	if @Imm_Review_Date = ''
		set @Imm_Review_Date=null
		  
	 if @Trans_Type = 'I'
	   Begin 	
			 if exists(Select Row_ID from T0090_HRMS_RESUME_IMMIGRATION WITH (NOLOCK)  where Resume_id= @Resume_id And Imm_Issue_Date = @Imm_Issue_DatE and Imm_TYpe = @Imm_type and cmp_id =@cmp_id)
					Begin
						set @Row_ID = 0
						return 
					End 
		 
		 
		 --if @Imm_type = 'Passport' -- Add on 13Aug2013
			--begin
			--	if exists(Select Row_ID from T0090_HRMS_RESUME_IMMIGRATION where Resume_id= @Resume_id and Imm_TYpe = @Imm_type and cmp_id =@cmp_id)
			--	Begin
			--		set @Row_ID = 0
			--		return 
			--	End 
			--end
			--else if @Imm_type = 'Visa' -- Add on 13Aug2013
			--begin
			--	if exists(Select Row_ID from T0090_HRMS_RESUME_IMMIGRATION where Resume_id= @Resume_id and Imm_TYpe = @Imm_type and ( Imm_No = @Imm_No OR Loc_ID = @Loc_ID ) and cmp_id =@cmp_id)
			--	Begin
			--		set @Row_ID = 0
			--		return 
			--	End 
			--end	
		 		
					select @Row_ID = isnull(max(Row_ID),0) + 1 from t0090_HRMS_RESUME_IMMIGRATION WITH (NOLOCK)
					
					Insert into T0090_HRMS_RESUME_IMMIGRATION
							(Row_ID
							,Cmp_ID
							,Resume_ID
							,Loc_ID
							,Imm_Type
							,Imm_No
							,Imm_Issue_Date
							,Imm_Issue_Status
							,Imm_Date_of_Expiry
							,Imm_Review_Date
							,Imm_Comments
							,attach_Documents
							)
					values	(@Row_ID
							,@Cmp_ID
							,@Resume_ID
							,@Loc_ID
							,@Imm_Type
							,@Imm_No
							,@Imm_Issue_Date
							,@Imm_Issue_Status
							,@Imm_Date_of_Expiry
							,@Imm_Review_Date
							,@Imm_Comments
							,@Attach_docs
							)
					
      End					
	    
	Else if @Trans_Type = 'U'
	
	  Begin 
	  
			if @Imm_type = 'Passport' -- Add  13Aug2013
			begin
				if exists(Select Row_ID from T0090_HRMS_RESUME_IMMIGRATION WITH (NOLOCK) where Resume_id= @Resume_id and Imm_TYpe = @Imm_type and cmp_id =@cmp_id and Row_ID <> @Row_ID)
				Begin
					set @Row_ID = 0
					return 
				End 
			end
			else if @Imm_type = 'Visa' -- Add  13Aug2013
			begin
				if exists(Select Row_ID from T0090_HRMS_RESUME_IMMIGRATION WITH (NOLOCK) where Resume_id= @Resume_id and Imm_TYpe = @Imm_type and ( Imm_No = @Imm_No OR Loc_ID = @Loc_ID ) and cmp_id =@cmp_id and Row_ID <> @Row_ID)
				Begin
					set @Row_ID = 0
					return 
				End 
			end	
	  
			  Update t0090_HRMS_RESUME_IMMIGRATION	        
	          set 
				Loc_ID=@Loc_ID
				,Imm_Type=@Imm_Type
				,Imm_No=@Imm_No
				,Imm_Issue_Date=@Imm_Issue_Date
				,Imm_Issue_Status=@Imm_Issue_Status
				,Imm_Date_of_Expiry=@Imm_Date_of_Expiry
				,Imm_Review_Date=@Imm_Review_Date
				,Imm_Comments=@Imm_Comments
				,attach_Documents=@Attach_docs
	        where Row_ID = @Row_ID
	  
	  
	  End
	
	    Else if  @Trans_Type = 'D'   
	      Begin 
	          
	           Delete from T0090_HRMS_RESUME_IMMIGRATION where Row_ID =@Row_ID
				
	      End
	 
	RETURN







