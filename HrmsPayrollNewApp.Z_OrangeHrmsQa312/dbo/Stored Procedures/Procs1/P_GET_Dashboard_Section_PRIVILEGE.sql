

/* This sp is used  for top bar checking PRIVILEGE for dashboard sections */
CREATE PROCEDURE  [dbo].[P_GET_Dashboard_Section_PRIVILEGE]
	@Cmp_ID			numeric,
	@Privilege_ID	numeric = 0,
	@Form_Name varchar(max)=''
	
	
AS
	BEGIN
		SET NOCOUNT ON;

		Create table #HomeSecPrivilage(
		Trans_Id	numeric,
		Privilage_ID	 numeric,
		Cmp_Id	numeric,
		Form_Id	numeric,
		Is_View	bit,
		Is_Edit	bit,
		Is_Save	bit,
		Is_Delete	bit,
		Is_Print	bit,
		Form_Name  varchar(1000)
		)
    
	--latest Latest Members             TD_Home_ESS_222
	--organization                      TD_Home_ESS_221
	--Post Request                      TD_Home_ESS_302
	--Birthday & Anniversary Reminder   TD_Home_ESS_303
	--Add & View Events                 TD_Home_ESS_304
	--Message Board                     TD_Home_ESS_305
	--Wall Of Fame                      TD_Home_ESS_306
    --Training Calender                 TD_Home_ESS_310

	 

	--Set @Form_Name =@Form_Name+' or D.Form_Name = ''TD_Home_ESS_302'' or D.Form_Name = ''TD_Home_ESS_303'''

	--Set @Form_Name =@Form_Name+' or D.Form_Name = ''TD_Home_ESS_304'' or D.Form_Name = ''TD_Home_ESS_305'''

	--Set @Form_Name =@Form_Name+' or D.Form_Name = ''TD_Home_ESS_306'' or D.Form_Name = ''TD_Home_ESS_310'''
	select	P.*,D.Form_Name
		from	T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
				inner JOIN T0050_PRIVILEGE_DETAILS P WITH (NOLOCK) On PM.Privilege_ID = p.Privilage_ID
				INNER JOIN T0000_DEFAULT_FORM D WITH (NOLOCK) on P.Form_Id = D.Form_ID
		where	P.Cmp_Id = @Cmp_ID  and  Privilage_ID = @Privilege_ID 
				and (Is_View=1 or Is_Edit=1 or Is_Save=1 or Is_Delete=1 or Is_Print=1)
				and (D.Form_Name in (Select data from dbo.Split(@Form_Name,',')))
				
				--'TD_Home_ESS_222','TD_Home_ESS_221','TD_Home_ESS_302','TD_Home_ESS_303','TD_Home_ESS_304','TD_Home_ESS_305','TD_Home_ESS_306','TD_Home_ESS_310'

	
			
	----organization
	--select	P.*,D.Form_Name
	--from	T0020_PRIVILEGE_MASTER PM
	--	inner JOIN T0050_PRIVILEGE_DETAILS P On PM.Privilege_ID = p.Privilage_ID
	--	INNER JOIN T0000_DEFAULT_FORM D on P.Form_Id = D.Form_ID
	--where	P.Cmp_Id = @Cmp_ID and D.Form_Name like 'TD_Home_ESS_221' and Privilage_ID=@Privilege_ID	

	----Post Request
	--select	P.*,D.Form_Name
	--from	T0020_PRIVILEGE_MASTER PM
	--	inner JOIN T0050_PRIVILEGE_DETAILS P On PM.Privilege_ID = p.Privilage_ID
	--	INNER JOIN T0000_DEFAULT_FORM D on P.Form_Id = D.Form_ID
	--where	P.Cmp_Id = @Cmp_ID and D.Form_Name like 'TD_Home_ESS_302' and Privilage_ID=@Privilege_ID	
	
	----Birthday & Anniversary Reminder
	--select	P.*,D.Form_Name
	--from	T0020_PRIVILEGE_MASTER PM
	--	inner JOIN T0050_PRIVILEGE_DETAILS P On PM.Privilege_ID = p.Privilage_ID
	--	INNER JOIN T0000_DEFAULT_FORM D on P.Form_Id = D.Form_ID
	--where	P.Cmp_Id = @Cmp_ID and D.Form_Name like 'TD_Home_ESS_303' and Privilage_ID=@Privilege_ID	
				
				
	----Add & View Events						
	--select	P.*,D.Form_Name
	--from	T0020_PRIVILEGE_MASTER PM
	--	inner JOIN T0050_PRIVILEGE_DETAILS P On PM.Privilege_ID = p.Privilage_ID
	--	INNER JOIN T0000_DEFAULT_FORM D on P.Form_Id = D.Form_ID
	--where	P.Cmp_Id = @Cmp_ID and D.Form_Name like 'TD_Home_ESS_304' and Privilage_ID=@Privilege_ID	 

	----Message Board
	--select	P.*,D.Form_Name
	--from	T0020_PRIVILEGE_MASTER PM
	--	inner JOIN T0050_PRIVILEGE_DETAILS P On PM.Privilege_ID = p.Privilage_ID
	--	INNER JOIN T0000_DEFAULT_FORM D on P.Form_Id = D.Form_ID
	--where	P.Cmp_Id = @Cmp_ID and D.Form_Name like 'TD_Home_ESS_305' and Privilage_ID=@Privilege_ID	 

	----Wall Of Fame
	--select	P.*,D.Form_Name
	--from	T0020_PRIVILEGE_MASTER PM
	--	inner JOIN T0050_PRIVILEGE_DETAILS P On PM.Privilege_ID = p.Privilage_ID
	--	INNER JOIN T0000_DEFAULT_FORM D on P.Form_Id = D.Form_ID
	--where	P.Cmp_Id = @Cmp_ID and D.Form_Name like 'TD_Home_ESS_306' and Privilage_ID=@Privilege_ID	
	
	----Training Calender
	 
	--select	P.*,D.Form_Name
	--from	T0020_PRIVILEGE_MASTER PM
	--	inner JOIN T0050_PRIVILEGE_DETAILS P On PM.Privilege_ID = p.Privilage_ID
	--	INNER JOIN T0000_DEFAULT_FORM D on P.Form_Id = D.Form_ID
	--where	P.Cmp_Id = @Cmp_ID and D.Form_Name like 'TD_Home_ESS_310' and Privilage_ID=@Privilege_ID	

END

