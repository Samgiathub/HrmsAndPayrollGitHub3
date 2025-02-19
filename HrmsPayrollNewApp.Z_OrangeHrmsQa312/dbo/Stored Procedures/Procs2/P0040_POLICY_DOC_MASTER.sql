

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_POLICY_DOC_MASTER]
@Policy_Doc_ID NUMERIC OUTPUT
,@Cmp_ID		NUMERIC
,@Policy_Title	nvarchar(50)
,@Policy_Tooltip	nvarchar(30)
,@Policy_Upload_Doc	varchar(200)
,@Policy_From_Date	DateTime
,@Policy_To_Date	DateTime
,@Tran_type	CHAR(1)
,@Policy_Sorting  numeric = 0
,@Emp_ID nvarchar(MAX) = NULL
,@Dept_Id nvarchar(MAX) = NULL
,@Cmp_ID_Multi nvarchar(MAX) = NULL  --added by sneha 8 oct 2015
,@Policy_Type int = null		 --added by sneha 8 oct 2015
,@Document_Type int = 1
,@User_Id numeric(18,0) = 0
,@IP_Address varchar(30)= '' --Add By Paras 19-10-2012
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as  varchar(max)
declare @OldPolicy_Title as varchar(50)
declare @OldPolicy_Tooltip as varchar(30)
declare @OldPolicy_Upload_Doc as varchar(200)
declare  @OldPolicy_From_Date  as varchar(20)
declare  @OldPolicy_To_Date as  varchar(20)
declare  @OldPolicy_Sorting as 	varchar(3)

set @OldPolicy_Title = ''
set @OldPolicy_Tooltip = ''
set @OldPolicy_Upload_Doc =''
set  @OldPolicy_From_Date  = ''
set  @OldPolicy_To_Date =  ''
set  @OldPolicy_Sorting = ''



	if @Tran_type = 'I'
	
	begin
	
	if exists(select Policy_Doc_ID from T0040_POLICY_DOC_MASTER WITH (NOLOCK) where upper(Policy_Title) = upper(@Policy_Title) and Cmp_ID = @Cmp_ID	)
			Begin
				Set @Policy_Doc_ID = 0
			return
			End
			
		select @Policy_Doc_ID = isnull(max(Policy_Doc_ID),0) + 1  from T0040_POLICY_DOC_MASTER	WITH (NOLOCK)
	
		
		insert into T0040_POLICY_DOC_MASTER (Policy_Doc_ID,Cmp_ID,Policy_Title,Policy_Tooltip,Policy_Upload_Doc,Policy_From_Date,Policy_To_Date,Policy_Sorting,Emp_ID,Dept_Id,Cmp_ID_Multi,Policy_Type,DOC_TYPE)
				Values(@Policy_Doc_ID,@Cmp_ID,@Policy_Title,@Policy_Tooltip,@Policy_Upload_Doc,@Policy_From_Date,@Policy_To_Date,@Policy_Sorting,@Emp_ID,@Dept_Id,@Cmp_ID_Multi,@Policy_Type,@Document_Type)
				
				set @OldValue = 'New Value' + '#'+ 'Policy Title :' +ISNULL( @Policy_Title,'') + '#' + 'PolicyTooltip :' + ISNULL( @Policy_Tooltip,'') + '#' + 'Policy Upload Doc :' + ISNULL(@Policy_Upload_Doc,'') + '#' + 'Policy From Date :' +CAST( ISNULL( @Policy_From_Date,0)AS VARCHAR(20)) + '#' + 'Policy To Date:' +CAST(ISNULL( @Policy_To_Date,0)AS VARCHAR(20)) + ' #'+ 'Policy Sorting :' +CAST(ISNULL(@Policy_Sorting,0)AS VARCHAR(10)) 
	END
	else if @Tran_type = 'U'
	begin
	if exists(select Policy_Doc_ID from T0040_POLICY_DOC_MASTER WITH (NOLOCK) where upper(Policy_Title) = upper(@Policy_Title) and Cmp_ID = @Cmp_ID and Policy_Doc_ID <>@Policy_Doc_ID) 
			Begin
				Set @Policy_Doc_ID = 0
			return
			End
			
			select @OldPolicy_Title  =ISNULL(Policy_Title,'') ,@OldPolicy_Tooltip  =ISNULL(Policy_Tooltip,''),@OldPolicy_Upload_Doc  =isnull(Policy_Upload_Doc,''),@OldPolicy_From_Date =CAST(isnull(Policy_From_Date,0)as varchar(20)),@OldPolicy_To_Date =CAST(isnull(Policy_To_Date,0)as  varchar(20)),@OldPolicy_Sorting  =CAST(isnull(Policy_Sorting,0)as varchar(20)) From dbo.T0040_POLICY_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Policy_Doc_ID = @Policy_Doc_ID
			
			update T0040_POLICY_DOC_MASTER set 
			  Policy_Title=@Policy_Title,
			  Policy_Tooltip=@Policy_Tooltip,
			  Policy_Upload_Doc=@Policy_Upload_Doc,
			  Policy_From_Date=@Policy_From_Date,
			  Policy_To_Date=@Policy_To_Date,
			  Policy_Sorting=@Policy_Sorting,
			  Emp_ID = @Emp_ID,
			  Dept_Id = @Dept_Id,
			   Cmp_ID_Multi = @Cmp_ID_Multi,  --added by sneha 8 oct 2015
			  Policy_Type = @Policy_Type,  --added by sneha 8 oct 2015
			  DOC_TYPE = @Document_Type
			  where Policy_Doc_ID =@Policy_Doc_ID and Cmp_ID =@Cmp_ID
			  
			  set @OldValue = 'old Value' + '#'+ 'Policy Title :' +ISNULL( @Policy_Title,'') + '#' + 'PolicyTooltip :' + ISNULL( @Policy_Tooltip,'') + '#' + 'Policy Upload Doc :' + ISNULL(@Policy_Upload_Doc,'') + '#' + 'Policy From Date :' +CAST( ISNULL( @Policy_From_Date,0)AS VARCHAR(20)) + '#' + 'Policy To Date:' +CAST(ISNULL( @Policy_To_Date,0)AS VARCHAR(20)) + ' #'+ 'Policy Sorting :' +CAST(ISNULL(@Policy_Sorting,0)AS VARCHAR(10)) 
               + 'New Value' + '#'+ 'Policy Title :' +ISNULL( @Policy_Title,'') + '#' + 'PolicyTooltip :' + ISNULL( @Policy_Tooltip,'') + '#' + 'Policy Upload Doc :' + ISNULL(@Policy_Upload_Doc,'') + '#' + 'Policy From Date :' +CAST( ISNULL( @Policy_From_Date,0)AS VARCHAR(20)) + '#' + 'Policy To Date:' +CAST(ISNULL( @Policy_To_Date,0)AS VARCHAR(20)) + ' #'+ 'Policy Sorting :' +CAST(ISNULL(@Policy_Sorting,0)AS VARCHAR(10)) 
    
	end
	else if  @Tran_Type = 'D'
	begin
	select @OldPolicy_Title  =ISNULL(Policy_Title,'') ,@OldPolicy_Tooltip  =ISNULL(Policy_Tooltip,''),@OldPolicy_Upload_Doc  =isnull(Policy_Upload_Doc,''),@OldPolicy_From_Date =CAST(isnull(Policy_From_Date,0)as varchar(20)),@OldPolicy_To_Date =CAST(isnull(Policy_To_Date,0)as  varchar(20)),@OldPolicy_Sorting  =CAST(isnull(Policy_Sorting,0)as varchar(20)) From dbo.T0040_POLICY_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Policy_Doc_ID = @Policy_Doc_ID
	
	delete FROM  T0040_POLICY_DOC_MASTER WHERE  Policy_Doc_ID =@Policy_Doc_ID
	
	set @OldValue = 'old Value' + '#'+ 'Policy Title :' +ISNULL( @OldPolicy_Title,'') + '#' + 'PolicyTooltip :' + ISNULL( @OldPolicy_Tooltip,'') + '#' + 'Policy Upload Doc :' + ISNULL(@OldPolicy_Upload_Doc,'') + '#' + 'Policy From Date :' +CAST( ISNULL( @OldPolicy_From_Date,0)AS VARCHAR(20)) + '#' + 'Policy To Date:' +CAST(ISNULL( @OldPolicy_To_Date,0)AS VARCHAR(20)) + ' #'+ 'Policy Sorting :' +CAST(ISNULL(@OldPolicy_Sorting,0)AS VARCHAR(10)) 
	end
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Policy Master',@OldValue,@Policy_Doc_ID,@User_Id,@IP_Address
	
	
	
return



