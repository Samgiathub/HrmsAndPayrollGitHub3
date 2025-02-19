



-- exec P0040_KPI_Master @KPI_Id=0 ,@Cmp_ID=9,@Dept_Id='',@KPI='MANAGER FEEDBACK',@Weightage='15',@Effective_Date='2014-09-23 11:29:50.200',@Category_Id=0,@tran_type='Inse',@User_Id=1363,@IP_Address='127.0.0.1'
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0040_KPI_Master]
	 @KPI_Id	 numeric(18,0) OUTPUT
	,@Cmp_Id	 numeric(18,0)
	,@Branch_Id	 varchar(Max)--numeric(18,0)
	,@KPI		 varchar(500)
	,@Weightage	 numeric(18,2)
	,@Effective_Date datetime
	,@Category_Id	numeric(18,0)=null
	,@Designation_Id	varchar(Max)=null --added on 04072016
	,@Active		bit=1 --added on 04072016
	,@tran_type		 varchar(1) 
    ,@User_Id		 numeric(18,0) = 0
	,@IP_Address	 varchar(30)= '' 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 declare @OldValue as varchar(max)
	 declare @OldDept_Id as varchar(max)
	 declare @oldKPI as varchar(500)
	 declare @oldWeightage as  numeric(18,2)
	 declare @oldEffective_Date as datetime
	 	 
	 	if @Category_Id = 0
	 		set @Category_Id = null
	 	if @Designation_Id = ''--added on 04072016
	 		set @Designation_Id = null
	 		
 if @Branch_Id = ''
	 		set @Branch_Id = null
	 		
	 If Upper(@tran_type) ='I'
		Begin
			select @KPI_Id = isnull(max(KPI_Id),0) + 1 from T0040_KPI_Master WITH (NOLOCK)
			INSERT INTO T0040_KPI_Master
			(
				 KPI_Id
				,Cmp_id
				,Branch_Id
				,KPI
				,Weightage
				,Effective_Date
				,Category_Id
				,Designation_Id	--added on 04072016
				,Active	--added on 04072016
			)
			Values
			(
				 @KPI_Id
				,@Cmp_Id
				,@Branch_Id
				,@KPI
				,@Weightage
				,@Effective_Date
				,@Category_Id
				,@Designation_Id	--added on 04072016
				,@Active	--added on 04072016
			)
			
			set @OldValue = 'New Value' + '#'+ 'Dept :' + cast(ISNULL( @Branch_Id,0)as varchar(18)) + '#' + 'KPI :' +  CAST(ISNULL( @KPI,'')AS varchar(18)) + '#'
										+ 'Weightage :' +  CAST(ISNULL( @Weightage,0)AS varchar(18)) + '#' + 'Effective Date :' +   CONVERT(nvarchar(20),ISNULL(@Effective_Date,''))  + '#'
										
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
				--select @oldKPI  =ISNULL(KPI,''),@OldDept_Id=CAST(ISNULL(Dept_Id,0)as varchar(18)),@oldWeightage=CAST(ISNULL(Weightage,0)AS varchar(18)),
				--	   @oldEffective_Date  = CONVERT(nvarchar(20),ISNULL(Effective_Date,'')) 
				--From dbo.T0040_KPI_Master Where Cmp_ID = @Cmp_ID and KPI_Id = @KPI_Id
		
			UPDATE    T0040_KPI_Master
			SET     
				Branch_Id=@Branch_Id,
				KPI=@KPI,
				Weightage=@Weightage,
				Effective_Date=@Effective_Date,
				Category_Id=@Category_Id,		
				Designation_Id = @Designation_Id,--added on 04072016
				Active = @Active 	--added on 04072016
			WHERE KPI_Id = @KPI_Id and cmp_Id=@Cmp_ID
			
			set @OldValue = 'old Value'  + '#'+ 'Dept :' + cast(ISNULL( @OldDept_Id,0)as varchar(18)) + '#' + 'KPI :' +  CAST(ISNULL( @oldKPI,'')AS varchar(18)) + '#'
										+ 'Weightage :' +  CAST(ISNULL( @oldWeightage,0)AS varchar(18)) + '#' + 'Effective Date :' + CONVERT(nvarchar(20),ISNULL(@oldEffective_Date,'')) + '#'
										
            + 'New Value'  + '#'+ 'Dept :' + cast(ISNULL(@Branch_Id,0)as varchar(18)) + '#' + 'KPI :' +  CAST(ISNULL( @KPI,'')AS varchar(18)) + '#'
										+ 'Weightage :' +  CAST(ISNULL( @Weightage,0)AS varchar(18)) + '#' + 'Effective Date :' +   CONVERT(nvarchar(20),ISNULL(@Effective_Date,''))  + '#'
		End
	Else If  Upper(@tran_type) ='D'
		Begin
				select @oldKPI  =ISNULL(KPI,''),@OldDept_Id=CAST(ISNULL(Branch_Id,0)as varchar(18)),@oldWeightage=CAST(ISNULL(Weightage,0)AS varchar(18)),
					   @oldEffective_Date  =   CONVERT(nvarchar(20),ISNULL(Effective_Date,'')) 				   
				From dbo.T0040_KPI_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and KPI_Id = @KPI_Id
						
				DELETE FROM T0040_KPI_Master WHERE KPI_Id = @KPI_Id and  cmp_Id=@Cmp_ID
				--DELETE FROM T0080_SubKPI_Master WHERE KPI_Id = @KPI_Id and  cmp_Id=@Cmp_ID
				
				set @OldValue = 'old Value'  + '#'+ 'Dept :' + cast(ISNULL( @OldDept_Id,0)as varchar(18)) + '#' + 'KPI :' +  CAST(ISNULL( @oldKPI,'')AS varchar(18)) + '#'
										+ 'Weightage :' +  CAST(ISNULL( @oldWeightage,0)AS varchar(18)) + '#' + 'Effective Date :' + CONVERT(nvarchar(20),ISNULL(@oldEffective_Date,'')) + '#'
		End
		--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'KPI Master',@OldValue,@KPI_Id,@User_Id,@IP_Address
END



