


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0040_SelfAppraisal_Master]
	@SApparisal_ID		numeric(18) output  
   ,@Cmp_ID				numeric(18)   
   ,@SApparisal_Content nvarchar(1000)  
   ,@SAppraisal_Sort	int
   ,@SDept_Id			varchar(800)--numeric(18)   	
   ,@SIsMandatory		int = null         --added on 19 Mar 2014	 
   ,@SType				int=null 
   ,@SWeight			int	=null
   ,@Effective_Date		datetime = null  --added on 25 Feb 2016
   ,@Ref_SID			numeric(18,0) --added on 1 Mar 2016
   ,@tran_type			varchar(1) 
   ,@User_Id			numeric(18,0) = 0
   ,@IP_Address			varchar(30)= '' 
   ,@SKPAWeight			int	= null	--added on 11 Mar 2016
   ,@SCategory			varchar(max)=''
   ,@SBranch			varchar(max)=''
   
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	 declare @OldValue as varchar(max)
	 declare @OldContent as varchar(1000)
	 declare @oldsort as varchar(18)
	 
	 declare @Type as varchar(50)
	 declare @IsMandatory as varchar(50)
	 declare @Capture_Weightage as varchar(50)
	 declare @OldType as varchar(50)
	 declare @OldIsMandatory as varchar(50)
	 declare @OldCapture_Weightage as varchar(50)
	 declare @OldEffective_Date as varchar(50)
	 declare @OldSKPAWeightage as varchar(50)
	 declare @OldDept_ID as varchar(500)
	 declare @OldSType as varchar(50)
	 declare @OldSIsMandatory as varchar(50)
	 declare @OldSWeight as varchar(50)
	 Declare @Cmp_name as Varchar(250)
	 	 
	  set @OldValue = ''
	  set @OldContent = ''
	  set @oldsort =''
	  
	 if @Ref_SID = 0
		set @Ref_SID =null--added on 1 Mar 2016
	 if @SKPAWeight	 = 0
		set @SKPAWeight	 =null--added on 11 Mar 2016
	 if @SCategory =''
		set @SCategory = NULL
	 if @SBranch =''
		set @SBranch = NULL
	
	----commented by  by aswini 01/06/2023
	 -- IF UPPER(@tran_type) ='I' OR UPPER(@tran_type) ='U'
		--  BEGIN 
		--	If @SApparisal_Content = ''
		--		BEGIN
		--			--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Content is not Properly Inserted',0,'Enter Proper Content',GetDate(),'Appraisal')						
		--			Return
		--		END
		--	--IF EXISTS(select 1 from T0040_SelfAppraisal_Master where SAppraisal_Sort=@SAppraisal_Sort and SApparisal_ID<>@SApparisal_ID and Cmp_ID=@Cmp_ID and SType=@SType)
		--	--	BEGIN 
		--	--		--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Duplicate entry of sorting number',0,'Duplicate Sorting',GetDate(),'Appraisal')
		--	--		SET @SApparisal_ID = 0 						
		--	--		Return
		--	--	END	
		--  END
		  
		 	 
	 --If Upper(@tran_type) ='I'
		--BEGIN		   
		--	select @SApparisal_ID = isnull(max(SApparisal_ID),0) + 1 from T0040_SelfAppraisal_Master WITH (NOLOCK)
			
		--	--print @Ref_SID
		--	--added on 1 Mar 2016
		--	if @Ref_SID = NULL
		--		BEGIN
		--			set @Ref_SID = @SApparisal_ID
		--		End
		--	---end
		--	PRINT 'm'
		--	INSERT INTO T0040_SelfAppraisal_Master
		--	(
		--		SApparisal_ID,Cmp_ID,SApparisal_Content,SAppraisal_Sort,SDept_Id,SIsMandatory,SType,SWeight,Effective_Date,Ref_SID,SKPAWeight,SCateg_Id,SBranch_Id
		--	)
		--	VAlUES
		--	(
		--		@SApparisal_ID,@Cmp_ID,@SApparisal_Content,@SAppraisal_Sort,@SDept_Id,@SIsMandatory,@SType,@SWeight,@Effective_Date,@Ref_SID,@SKPAWeight,@SCategory,@SBranch----added on 25 Feb 2016
		--	)		
				If Upper(@tran_type) ='I'  --added by aswini 01/06/2023
		BEGIN	
		
		if exists (select SApparisal_ID from T0040_SelfAppraisal_Master where  SApparisal_ID=@SApparisal_ID )   
    begin  
     set @SApparisal_ID = 0  
     Return  
    end  

	 if exists (select SApparisal_ID from T0040_SelfAppraisal_Master where SApparisal_Content =@SApparisal_Content    and Cmp_ID=@Cmp_ID )   
    begin  
     set @SApparisal_ID = 0  
     Return  
    end

			select @SApparisal_ID = isnull(max(SApparisal_ID),0) + 1 from T0040_SelfAppraisal_Master WITH (NOLOCK)
			
			--print @Ref_SID
			--added on 1 Mar 2016
			if @Ref_SID = NULL
				BEGIN
					set @Ref_SID = @SApparisal_ID
				End
			---end
	----		PRINT 'm'
			INSERT INTO T0040_SelfAppraisal_Master
			(
				SApparisal_ID,Cmp_ID,SApparisal_Content,SAppraisal_Sort,SDept_Id,SIsMandatory,SType,SWeight,Effective_Date,Ref_SID,SKPAWeight,SCateg_Id,SBranch_Id
			)
			VAlUES
			(
				@SApparisal_ID,@Cmp_ID,@SApparisal_Content,@SAppraisal_Sort,@SDept_Id,@SIsMandatory,@SType,@SWeight,@Effective_Date,@Ref_SID,@SKPAWeight,@SCategory,@SBranch----added on 25 Feb 2016
			)		  
				--Added By Mukti(start)08112016
				if @SType=1
					set @Type='Self Assessment'
				else if @SType=2
					set @Type='KPA'
				if @SIsMandatory=0
					set @IsMandatory='No'
				else if @SIsMandatory=1
					set @IsMandatory='Yes'
				if @SWeight=0
					set @Capture_Weightage='No'
				else if @SWeight=1
					set @Capture_Weightage='Yes'
					
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id	
			set @OldValue = 'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Content :' +ISNULL(@SApparisal_Content,'') 
										+ '#'+ 'Type :' +  ISNULL(@Type,'')
										+ '#'+ 'Effective Date :' +  CONVERT(nvarchar(35),isnull(@Effective_Date,''))																			
										+ '#'+ 'Is Mandatory :' +  ISNULL(@IsMandatory,'')										
										+ '#'+ 'Capture Weightage :' + isnull(@Capture_Weightage,'')										
										+ '#'+ 'KPA Weightage :' +  CONVERT(nvarchar(20),ISNULL(@SKPAWeight,''))
										+ '#'+ 'Sort :' +  CAST(ISNULL(@SAppraisal_Sort,'')AS varchar(18)) 
										+ '#'+ 'Department :' +  CONVERT(nvarchar(500),@SDept_Id)+ '#'											
										
			--Added By Mukti(end)08112016						
		END
	Else If  Upper(@tran_type) ='U' 
		BEGIN
			--Added By Mukti(start)08112016
				select @OldContent  =ISNULL(SApparisal_Content,''),@oldsort=CAST(ISNULL(SAppraisal_Sort,'')as varchar(18)),
					   @OldEffective_Date=isnull(Effective_Date,''),@OldSKPAWeightage=ISNULL(SKPAWeight,0),@OldDept_ID=ISNULL(SDept_Id,''),
					   @OldSType=SType,@OldSIsMandatory=SIsMandatory,@OldSWeight=SWeight
				From dbo.T0040_SelfAppraisal_Master  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SApparisal_ID = @SApparisal_ID		
				
				if @OldSType=1
					set @OldType='Self Assessment'
				else if @OldSType=2
					set @OldType='KPA'
				if @OldSIsMandatory=0
					set @OldIsMandatory='No'
				else if @OldSIsMandatory=1
					set @OldIsMandatory='Yes'
				if @OldSWeight=0
					set @OldCapture_Weightage='No'
				else if @OldSWeight=1
					set @OldCapture_Weightage='Yes'
			--Added By Mukti(start)08112016	
				if not exists (select SApparisal_ID from T0040_SelfAppraisal_Master where  SApparisal_ID=@SApparisal_ID )   
    begin  
     set @SApparisal_ID = 0  
     Return  
    end  

	 if exists (select SApparisal_ID from T0040_SelfAppraisal_Master where  SApparisal_ID<>@SApparisal_ID and SApparisal_Content=@SApparisal_Content  and Cmp_ID=@Cmp_ID )   
    begin  
     set @SApparisal_ID = 0  
     Return  
    end
			UPDATE    T0040_SelfAppraisal_Master
			SET       SApparisal_Content = @SApparisal_Content,
					  SAppraisal_Sort = @SAppraisal_Sort,
					  SDept_Id	= @SDept_Id,
					  SIsMandatory = @SIsMandatory,
					  SType=@SType,
					  SWeight=@SWeight,
					  Effective_Date = @Effective_Date,--added on 25 Feb 2016
					  Ref_SID = @Ref_SID, -- added on 1 mar 2016
					  SKPAWeight = @SKPAWeight, -- added on 11 mar 2016
					  SCateg_Id = @SCategory,
					  SBranch_Id = @SBranch
			WHERE     SApparisal_ID = @SApparisal_ID
			
			--set @OldValue = 'old Value' + '#'+ 'Content :' + @OldContent  + '#' +  'Sort :' + @oldsort  + '#' +
            --+ 'New Value' + '#'+ 'Content :' +ISNULL( @SApparisal_Content,'') + '#' + 'Sort :' + CAST(ISNULL( @SAppraisal_Sort,'')as varchar(18)) + '#'
            
            	--Added By Mukti(start)08112016
				if @SType=1
					set @Type='Self Assessment'
				else if @SType=2
					set @Type='KPA'
				if @SIsMandatory=0
					set @IsMandatory='No'
				else if @SIsMandatory=1
					set @IsMandatory='Yes'
				if @SWeight=0
					set @Capture_Weightage='No'
				else if @SWeight=1
					set @Capture_Weightage='Yes'
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id	
					
			set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Content :' +ISNULL(@OldContent,'') 
										+ '#'+ 'Type :' +  ISNULL(@OldType,'')
										+ '#'+ 'Effective Date :' +  CONVERT(nvarchar(35),isnull(@OldEffective_Date,''))																			
										+ '#'+ 'Is Mandatory :' +  ISNULL(@OldIsMandatory,'')										
										+ '#'+ 'Capture Weightage :' + isnull(@OldCapture_Weightage,'')										
										+ '#'+ 'KPA Weightage :' +  CONVERT(nvarchar(20),ISNULL(@OldSKPAWeightage,''))
										+ '#'+ 'Sort :' +  CAST(ISNULL(@oldsort,'')AS varchar(18)) 
										+ '#'+ 'Department :' +  CONVERT(nvarchar(500),@OldDept_ID)
					 + '#' +'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Content :' +ISNULL(@SApparisal_Content,'') 
										+ '#'+ 'Type :' +  ISNULL(@Type,'')
										+ '#'+ 'Effective Date :' +  CONVERT(nvarchar(35),isnull(@Effective_Date,''))																			
										+ '#'+ 'Is Mandatory :' +  ISNULL(@IsMandatory,'')										
										+ '#'+ 'Capture Weightage :' + isnull(@Capture_Weightage,'')										
										+ '#'+ 'KPA Weightage :' +  CONVERT(nvarchar(20),ISNULL(@SKPAWeight,''))
										+ '#'+ 'Sort :' +  CAST(ISNULL(@SAppraisal_Sort,'')AS varchar(18)) 
										+ '#'+ 'Department :' +  CONVERT(nvarchar(500),@SDept_Id)
			--Added By Mukti(end)08112016	
			
		END
	Else If  Upper(@tran_type) ='D'
		BEGIN
			 --select @OldContent  =ISNULL(@SApparisal_Content,''),@oldsort=CAST(ISNULL( @SAppraisal_Sort,'')as varchar(18))  From dbo.T0040_SelfAppraisal_Master Where Cmp_ID = @Cmp_ID and SApparisal_ID = @SApparisal_ID		
			 --Added By Mukti(start)08112016
				select @OldContent  =ISNULL(SApparisal_Content,''),@oldsort=CAST(ISNULL(SAppraisal_Sort,'')as varchar(18)),
					   @OldEffective_Date=isnull(Effective_Date,''),@OldSKPAWeightage=ISNULL(SKPAWeight,0),@OldDept_ID=ISNULL(SDept_Id,''),
				       @SType=SType,@SIsMandatory=SIsMandatory,@SWeight=SWeight
				From dbo.T0040_SelfAppraisal_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SApparisal_ID = @SApparisal_ID		
				
				if @SType=1
					set @OldType='Self Assessment'
				else if @SType=2
					set @OldType='KPA'
				if @SIsMandatory=0
					set @OldIsMandatory='No'
				else if @SIsMandatory=1
					set @OldIsMandatory='Yes'
				if @SWeight=0
					set @OldCapture_Weightage='No'
				else if @SWeight=1
					set @OldCapture_Weightage='Yes'
			--Added By Mukti(start)08112016	
			
				DELETE FROM T0050_SA_SubCriteria WHERE SApparisal_ID = @SApparisal_ID			
				DELETE FROM T0040_SelfAppraisal_Master WHERE SApparisal_ID = @SApparisal_ID					
			 
			 --set @OldValue = 'old Value' + '#'+ 'Content :' +ISNULL( @OldContent,'') + '#' 	+ 'Sort :' + CAST(ISNULL( @oldsort,'')as varchar(18)) + '#' 			 
			 set @OldValue = 'old Value'+ '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Content :' +ISNULL(@OldContent,'') 
										+ '#'+ 'Type :' +  ISNULL(@OldType,'')
										+ '#'+ 'Effective Date :' +  CONVERT(nvarchar(35),isnull(@OldEffective_Date,''))																			
										+ '#'+ 'Is Mandatory :' +  ISNULL(@OldIsMandatory,'')										
										+ '#'+ 'Capture Weightage :' + isnull(@OldCapture_Weightage,'')										
										+ '#'+ 'KPA Weightage :' +  CONVERT(nvarchar(20),ISNULL(@OldSKPAWeightage,''))
										+ '#'+ 'Sort :' +  CAST(ISNULL(@oldsort,'')AS varchar(18)) 
										+ '#'+ 'Department :' +  CONVERT(nvarchar(500),@OldDept_ID)
		END
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Self Assessment Master',@OldValue,@SApparisal_ID,@User_Id,@IP_Address
END

