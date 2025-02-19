
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_HRMS_AttributeMaster]
	   @PA_ID					numeric(18) output
      ,@Cmp_ID					numeric(18)  
      ,@PA_Title				nvarchar(250)		
      ,@PA_Type					varchar(5)
      ,@PA_Weightage			numeric(18)			
      ,@PA_SortNo				integer
      ,@PA_Category				varchar(50)=null --added on 23 feb 2016
      ,@PA_EffectiveDate		datetime	    --added on 29 feb 2016
      ,@PA_DeptId				varchar(max)	--added on 29 feb 2016
      ,@Ref_PAID				numeric(18)		--added on 29 feb 2016
      ,@PA_Desc					nvarchar(200)	--added on 27 Sep 2016
      ,@Grade_Id				varchar(max)	--Mukti(20092018)
      ,@tran_type				varchar(1) 
	  ,@User_Id					numeric(18,0) = 0
	  ,@IP_Address				varchar(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 declare @OldValue as varchar(max)
	 declare @OldPA_Title as nvarchar(250)
	 declare @OldPA_Type as varchar(5)
	 declare @OldPA_Weightage as varchar(18)
	 declare @oldsort as varchar(18)
	 Declare @PA_Type_Name as varchar(50)
	 Declare @OldPA_EffectiveDate as varchar(50)
	 Declare @OldPA_Desc as nvarchar(500)
	 DECLARE @OldPA_Category as VARCHAR(50)
	 Declare @OldPA_Type_Name as varchar(50)
	 Declare @OldPA_DeptId as varchar(max)
	Declare @Cmp_name as Varchar(250)
	
	 if @PA_Category =''
		set @PA_Category =null--added on 23 feb 2016
	 if @PA_DeptId =''
		set @PA_DeptId =null--added on 29 feb 2016	
	if @Grade_Id =''
		set @Grade_Id =null
	if @Ref_PAID = 0
		set @Ref_PAID =null--added on 29 feb 2016
	 
	  set @OldValue = ''
	  set @OldPA_Title = ''
	  set @OldPA_Type = ''
	  set @OldPA_Weightage=''
	  set @oldsort =''
	  
	 -- If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U' commented by aswini 
		--BEGIN
		--	If @PA_Title = ''
		--		BEGIN
		--			SET @PA_ID= 0 -- Added by Gadriwala Muslim 14102016
		--			--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Title is not Properly Inserted',0,'Enter Proper Content',GetDate(),'Appraisal')						
		--			Return
		--		END
		--	--if exists(select 1 from T0040_HRMS_AttributeMaster where PA_SortNo=@PA_SortNo and PA_ID<>@PA_ID and Cmp_ID=@Cmp_ID and PA_Type=@PA_Type)
		--	--	begin
		--	--		--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Duplicate entry of sorting number',0,'Duplicate Sorting',GetDate(),'Appraisal')
		--	--		SET @PA_ID= 0 						
		--	--		Return
		--	--	End
		--END	
	 --If Upper(@tran_type) ='I'
		--begin
		--	select @PA_ID = isnull(max(PA_ID),0) + 1 from T0040_HRMS_AttributeMaster WITH (NOLOCK)
			
		--	--added on 29 Feb 2016
		--	if @Ref_PAID = NULL
		--		BEGIN
		--			set @Ref_PAID = @PA_ID
		--		End
		--	---end
		--	INSERT INTO T0040_HRMS_AttributeMaster
		--	(
		--		PA_ID,Cmp_ID,PA_Title,PA_Type,PA_Weightage,PA_SortNo,PA_Category,PA_EffectiveDate,PA_DeptId,Ref_PAID,PA_Desc,Grade_Id
		--	)
		--	VAlUES
		--	(
		--		@PA_ID,@Cmp_ID,@PA_Title,@PA_Type,@PA_Weightage,@PA_SortNo,@PA_Category,@PA_EffectiveDate,@PA_DeptId,@Ref_PAID,@PA_Desc,@Grade_Id
		--	)

		If @tran_type  = 'I'  ----added by Aswini 08.06.2023
  Begin  
  if exists (select PA_ID from T0040_HRMS_AttributeMaster where  PA_ID=@PA_ID)   
    begin  
     set @PA_ID = 0  
     Return  
    end  

	 if exists (select PA_ID from T0040_HRMS_AttributeMaster where   PA_Title=@PA_Title  and Cmp_ID=@Cmp_ID )   
    begin  
     set @PA_ID = 0  
     Return  
    end  

	
    select @PA_ID = isnull(max(PA_ID),0) + 1 from T0040_HRMS_AttributeMaster WITH (NOLOCK)

	if @Ref_PAID = NULL
				BEGIN
					set @Ref_PAID = @PA_ID
				End

	INSERT INTO T0040_HRMS_AttributeMaster
			(
				PA_ID,Cmp_ID,PA_Title,PA_Type,PA_Weightage,PA_SortNo,PA_Category,PA_EffectiveDate,PA_DeptId,Ref_PAID,PA_Desc,Grade_Id
			)
			VAlUES
			(
				@PA_ID,@Cmp_ID,@PA_Title,@PA_Type,@PA_Weightage,@PA_SortNo,@PA_Category,@PA_EffectiveDate,@PA_DeptId,@Ref_PAID,@PA_Desc,@Grade_Id
			)
			
			--Added By Mukti(start)09112016
			if @PA_Type='PA'
				set @PA_Type_Name='Perfomance Attribute'
			else if @PA_Type='PoA'
				set @PA_Type_Name='Potential Attribute'			
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id	
			SET @OldValue = 'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#' +  'EffectiveDate :' + CONVERT(nvarchar(35),isnull(@PA_EffectiveDate,''))
										+ '#' +  'Title :' + ISNULL(@PA_TITLE,'') 
										+ '#' +  'Description :' + ISNULL(@PA_Desc,'') 
										+ '#' +  'Type :' + ISNULL(@PA_Type_Name,'')
										+ '#' +  'Category :' + ISNULL(@PA_Category,'')
										+ '#' +  'Weightage :' +  CAST(ISNULL(@PA_WEIGHTAGE,'')AS VARCHAR(18))
										+ '#' +  'Department :' + ISNULL(@PA_DeptId,'')
										+ '#' +  'Sort :' +  CAST(ISNULL(@PA_SORTNO,'')AS VARCHAR(18)) + '#'
			--Added By Mukti(end)09112016
		End	
	Else If  Upper(@tran_type) ='U' 
		begin		
			select @OldPA_Title  =ISNULL(PA_Title,''),@OldPA_Type  =ISNULL(PA_Type,''),@OldPA_Weightage=CAST(ISNULL(PA_Weightage,'')as varchar(18)),
				   @oldsort=CAST(ISNULL(PA_SortNo,'')as varchar(18)),@OldPA_EffectiveDate=ISNULL(PA_EffectiveDate,''),@OldPA_Desc=ISNULL(PA_Desc,''),
				   @OldPA_Category=ISNULL(PA_Category,''),@OldPA_DeptId=ISNULL(PA_DeptId,'')
			From dbo.T0040_HRMS_AttributeMaster WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and PA_ID = @PA_ID		
	---added by aswini 08/6/2023 
  if Not Exists (select PA_ID from T0040_HRMS_AttributeMaster where  PA_ID=@PA_ID )   
    begin  
     set @PA_ID = 0  
     Return  
    end  

	 if exists (select PA_ID from T0040_HRMS_AttributeMaster where   PA_ID<>@PA_ID  and Cmp_ID=@Cmp_ID and PA_Title	= @PA_Title)   
    begin  
     set @PA_ID = 0  
     Return  
    end  
			UPDATE    T0040_HRMS_AttributeMaster
			SET       PA_Title		= @PA_Title,
					  PA_Type		= @PA_Type,
					  PA_Weightage	= @PA_Weightage,
					  PA_SortNo		= @PA_SortNo,
					  PA_Category	= @PA_Category, --added on 23 feb 2016
					  PA_EffectiveDate = @PA_EffectiveDate, --added on 29 feb 2016
					  PA_DeptId		= @PA_DeptId, --added on 29 feb 2016
					  Ref_PAID		= @Ref_PAID, --added on 29 feb 2016
					  PA_Desc		= @PA_Desc,	 --added on 27 Sep 2016
					  Grade_Id		= @Grade_Id
			WHERE     PA_ID			= @PA_ID
			
			--Added By Mukti(start)09112016
				if @OldPA_Type='PA'
					set @OldPA_Type_Name='Perfomance Attribute'
				else if @OldPA_Type='PoA'
					set @OldPA_Type_Name='Potential Attribute'
				if @PA_Type='PA'
					set @PA_Type_Name='Perfomance Attribute'
				else if @PA_Type='PoA'
					set @PA_Type_Name='Potential Attribute'	
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
				set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'EffectiveDate :' + CONVERT(nvarchar(35),isnull(@OldPA_EffectiveDate,''))
											+ '#' +  'Title :' + ISNULL(@OldPA_Title,'') 
											+ '#' +  'Description :' + ISNULL(@OldPA_Desc,'') 
											+ '#' +  'Type :' + ISNULL(@OldPA_Type_Name,'')
											+ '#' +  'Category :' + ISNULL(@OldPA_Category,'')
											+ '#' +  'Weightage :' +  CAST(ISNULL(@OldPA_Weightage,'')AS VARCHAR(18))
											+ '#' +  'Department :' + ISNULL(@OldPA_DeptId,'')
											+ '#' +  'Sort :' +  CAST(ISNULL(@oldsort,'')AS VARCHAR(18)) 
					     + '#' +'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'EffectiveDate :' + CONVERT(nvarchar(35),isnull(@PA_EffectiveDate,''))
											+ '#' +  'Title :' + ISNULL(@PA_TITLE,'') 
											+ '#' +  'Description :' + ISNULL(@PA_Desc,'') 
											+ '#' +  'Type :' + ISNULL(@PA_Type_Name,'')
											+ '#' +  'Category :' + ISNULL(@PA_Category,'')
											+ '#' +  'Weightage :' +  CAST(ISNULL(@PA_WEIGHTAGE,'')AS VARCHAR(18))
											+ '#' +  'Department :' + ISNULL(@PA_DeptId,'')
											+ '#' +  'Sort :' +  CAST(ISNULL(@PA_SORTNO,'')AS VARCHAR(18)) + '#'
			--Added By Mukti(end)09112016
		End	
	Else If  Upper(@tran_type) ='D'
		Begin
			select @OldPA_Title  =ISNULL(PA_Title,''),@OldPA_Type  =ISNULL(PA_Type,''),@OldPA_Weightage=CAST(ISNULL(PA_Weightage,'')as varchar(18)),
				   @oldsort=CAST(ISNULL(PA_SortNo,'')as varchar(18)),@OldPA_EffectiveDate=ISNULL(PA_EffectiveDate,''),@OldPA_Desc=ISNULL(PA_Desc,''),
				   @OldPA_Category=ISNULL(PA_Category,''),@OldPA_DeptId=ISNULL(PA_DeptId,'')
			From dbo.T0040_HRMS_AttributeMaster WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and PA_ID = @PA_ID	
	
				DELETE FROM T0040_HRMS_AttributeMaster WHERE PA_ID = @PA_ID	
								
				--Added By Mukti(start)09112016
				if @OldPA_Type='PA'
					set @OldPA_Type_Name='Perfomance Attribute'
				else if @OldPA_Type='PoA'
					set @OldPA_Type_Name='Potential Attribute'
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
				set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'EffectiveDate :' + CONVERT(nvarchar(35),isnull(@OldPA_EffectiveDate,''))
											+ '#' +  'Title :' + ISNULL(@OldPA_Title,'') 
											+ '#' +  'Description :' + ISNULL(@OldPA_Desc,'') 
											+ '#' +  'Type :' + ISNULL(@OldPA_Type_Name,'')
											+ '#' +  'Category :' + ISNULL(@OldPA_Category,'')
											+ '#' +  'Weightage :' +  CAST(ISNULL(@OldPA_Weightage,'')AS VARCHAR(18))
											+ '#' +  'Department :' + ISNULL(@OldPA_DeptId,'')
											+ '#' +  'Sort :' +  CAST(ISNULL(@oldsort,'')AS VARCHAR(18))
				--Added By Mukti(end)09112016
		End
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Performance Attribute Master',@OldValue,@PA_ID,@User_Id,@IP_Address
		
END
------------------



