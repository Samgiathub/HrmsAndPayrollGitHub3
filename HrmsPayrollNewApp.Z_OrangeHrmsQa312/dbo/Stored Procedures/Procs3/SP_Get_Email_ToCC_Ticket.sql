
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Email_ToCC_Ticket] 
	 @Emp_ID				NUMERIC(18,0)
	,@Cmp_ID				NUMERIC(18,0)
	,@Module_Name			NVARCHAR(MAX)
	,@Flag					TinyInt = 1	
	,@Is_Mobile				TinyInt = 0 	-- Flag will be 1, IT
											-- Flag will be 2, HR
											-- Flag will be 3, Account
											-- Flag will be 4, Travel Help Desk							
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if Object_ID('tempdb..#Temp_CC') is not null
		Begin
			Drop TABLE #Temp_CC
		End
		
	CREATE TABLE #Temp_CC(Output_CC Varchar(max))
	
	if Object_ID('tempdb..#Temp_Emp') is not null
		Begin
			Drop TABLE #Temp_Emp
		End
	CREATE TABLE #Temp_Emp(Output_Emp Varchar(Max))
	
	if Object_ID('tempdb..#Temp_Other') is not null
		Begin
			Drop TABLE #Temp_Other
		End
	CREATE TABLE #Temp_Other(Other_Email Varchar(Max))
	
		
	if Object_ID('tempdb..#Email_Branch') is not null
		Begin
			Drop TABLE #Email_Branch
		End
		
	CREATE TABLE #Email_Branch
	(
		Login_ID numeric(18,0),
		Branch_Id numeric(18,0)
	 )
	 
	Declare @Branch_ID_Multi nvarchar(max)
	set @Branch_ID_Multi = ''
	Declare @Login_Id numeric(18,0)
	set @Login_Id = 0
		
	Declare @EMAIL_NTF_SENT AS Numeric(1,0)
	Set @EMAIL_NTF_SENT = 0
	
	Declare @emp_branch As Numeric(18,0)
	Set @emp_branch = 0

	Select @EMAIL_NTF_SENT = EMAIL_NTF_SENT From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = @Cmp_ID And EMAIL_TYPE_NAME = @Module_Name
	
	If @EMAIL_NTF_SENT = 1 and @Module_Name <> 'Ticket Close'
		Begin
			SELECT	@emp_branch = I1.BRANCH_ID
					FROM	T0095_INCREMENT I1 WITH (NOLOCK)
							INNER JOIN (
											SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
											FROM	T0095_INCREMENT I2 WITH (NOLOCK) 
												INNER JOIN (
																SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																WHERE	I3.Increment_Effective_Date <= GETDATE() and I3.Emp_ID = @Emp_ID
																GROUP BY I3.Emp_ID
															) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
											WHERE	I2.Cmp_ID = @Cmp_Id 
											GROUP BY I2.Emp_ID
										) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
					WHERE	I1.Cmp_ID=@Cmp_Id
					
				If @Flag = 1  -- For IT Department
					Begin
						Declare CurEmailHr cursor for 
						Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
						Where Cmp_ID = @Cmp_ID And IS_IT = 1 and Is_Active =1
								
						Open CurEmailHr
							fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
						 while @@fetch_status = 0
							begin	
									Insert into #Email_Branch
									 select @Login_ID,data
									 from dbo.Split(@Branch_ID_Multi,',')
									 where (data = @emp_branch or data = 0) 
									   
								fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
							end
						close CurEmailHr
						deallocate CurEmailHr
						
						IF @Is_Mobile = 0
							BEGIN
								INSERT INTO #Temp_CC
								SELECT (ISNULL(Email_ID_IT,'')) 
								FROM  T0011_LOGIN L WITH (NOLOCK)
								INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
								WHERE Cmp_ID = @Cmp_ID AND Is_IT = 1 AND Is_Active =1 AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) 
							END
						ELSE
							BEGIN
								Insert into #Temp_CC
								Select (ISNULL(IE.DeviceID,'')) 
								From  T0011_LOGIN L WITH (NOLOCK)
								INNER JOIN #Email_Branch EB on EB.Login_ID = L.Login_ID 
								INNER JOIN T0095_Emp_IMEI_Details IE WITH (NOLOCK) ON L.Emp_ID = IE.Emp_ID AND IE.Is_Active = 1
								WHERE L.Cmp_ID = @Cmp_ID AND Is_IT = 1 AND L.Is_Active = 1 AND(EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) 
							END 
					End
				Else if @Flag = 2 -- For HR Department
					Begin
						Declare CurEmailHr cursor for 
						Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
						Where Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active =1
								
						Open CurEmailHr
						fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
						while @@fetch_status = 0
							begin	
									Insert into #Email_Branch
									 select @Login_ID,data
									 from dbo.Split(@Branch_ID_Multi,',')
									 where (data = @emp_branch or data = 0) 
								fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
							end
						close CurEmailHr
						deallocate CurEmailHr
						
						IF @Is_Mobile = 0
							BEGIN
								INSERT INTO #Temp_CC
								SELECT (ISNULL(Email_ID,'')) 
								FROM T0011_LOGIN L WITH (NOLOCK)
								INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
								WHERE Cmp_ID = @Cmp_ID AND Is_HR = 1 AND Is_Active = 1 AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) 
							END
						ELSE
							BEGIN
								INSERT INTO #Temp_CC
								SELECT (ISNULL(IE.DeviceID,'')) 
								FROM T0011_LOGIN L WITH (NOLOCK)
								INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
								INNER JOIN T0095_Emp_IMEI_Details IE WITH (NOLOCK) ON L.Emp_ID = IE.Emp_ID AND IE.Is_Active = 1
								WHERE L.Cmp_ID = @Cmp_ID AND Is_HR = 1 AND L.Is_Active = 1 AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) 
							END
					End
				Else if @Flag = 3 -- For Account Department
					Begin	
						Declare CurEmailAcc cursor for 
						Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
						Where Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active =1
							
						Open CurEmailAcc
						fetch next from CurEmailAcc into @Branch_ID_Multi,@Login_Id
						while @@fetch_status = 0
							begin
									Insert into #Email_Branch
									select @Login_ID,data
									from dbo.Split(@Branch_ID_Multi,',')
									where (data = @emp_branch or data = 0)
								fetch next from CurEmailAcc into @Branch_ID_Multi,@Login_Id
							end
						close CurEmailAcc
						deallocate CurEmailAcc
						
						IF @Is_Mobile = 0
							BEGIN
								Insert into #Temp_CC
								Select Distinct(ISNULL(Email_ID_accou,'')) From T0011_LOGIN L WITH (NOLOCK)
								inner join
								#Email_Branch EB on EB.Login_ID = L.Login_ID 
								Where Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active=1
								and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
							END
						ELSE
							BEGIN
								INSERT INTO #Temp_CC
								SELECT DISTINCT(ISNULL(IE.DeviceID,'')) 
								FROM T0011_LOGIN L WITH (NOLOCK)
								INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
								INNER JOIN T0095_Emp_IMEI_Details IE WITH (NOLOCK) ON L.Emp_ID = IE.Emp_ID AND IE.Is_Active = 1
								WHERE L.Cmp_ID = @Cmp_ID AND Is_Accou = 1 AND L.Is_Active=1  AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) 
							END 
					End
				Else if @Flag = 4 -- For Travel Help Desk
					Begin
						Declare CurEmailHelpDesk cursor for 
						Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN  WITH (NOLOCK)
						Where Cmp_ID = @Cmp_ID And Travel_Help_Desk = 1 and Is_Active =1
								
						Open CurEmailHelpDesk
						fetch next from CurEmailHelpDesk into @Branch_ID_Multi,@Login_Id
						while @@fetch_status = 0
							begin
								Insert into #Email_Branch
								 select @Login_ID,data
								 from dbo.Split(@Branch_ID_Multi,',')
								 where (data = @emp_branch or data = 0)
								fetch next from CurEmailHelpDesk into @Branch_ID_Multi,@Login_Id
							end
						close CurEmailHelpDesk
						deallocate CurEmailHelpDesk
							
						IF @Is_Mobile = 0
							BEGIN
								Insert into #Temp_CC
								Select Distinct(ISNULL(Email_ID_HelpDesk,'')) From T0011_LOGIN L WITH (NOLOCK)
								inner join
								#Email_Branch EB on EB.Login_ID = L.Login_ID 
								Where Cmp_ID = @Cmp_ID And Travel_Help_Desk = 1 and Is_Active=1
								and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
							END
						ELSE
							BEGIN
								INSERT INTO #Temp_CC
								SELECT DISTINCT(ISNULL(IE.DeviceID,'')) 
								FROM T0011_LOGIN L WITH (NOLOCK)
								INNER JOIN #Email_Branch EB ON EB.Login_ID = L.Login_ID 
								INNER JOIN T0095_Emp_IMEI_Details IE WITH (NOLOCK) ON L.Emp_ID = IE.Emp_ID AND IE.Is_Active = 1
								WHERE L.Cmp_ID = @Cmp_ID AND Travel_Help_Desk = 1 AND L.Is_Active = 1 AND (EB.Branch_ID = @emp_branch OR EB.Branch_ID = 0) 
							END
					End
					
					
				
		END
			--Select distinct(Output_CC) + ',' From #Temp_CC where Output_CC <>  '' for xml path('') 
			--Select distinct(Output_Emp) + ',' From #Temp_Emp where Output_Emp<> '' for xml path('')
			if @Module_Name = 'Ticket Close' and @EMAIL_NTF_SENT = 1
				Begin

					Insert into #Temp_Other Select Other_Email From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = @Cmp_ID And EMAIL_TYPE_NAME = @Module_Name
					Select * From #Temp_Other

				End
			Else
				Begin
					Insert into #Temp_Emp Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()
					Select * From #Temp_CC
					
					Insert into #Temp_Emp Select Other_Email From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = @Cmp_ID And EMAIL_TYPE_NAME = @Module_Name
					--Declare @Email_List Varchar(500)
					--Set @Email_List = ''
					--Select @Email_List = COALESCE(@Email_List,';','') + Output_Emp From #Temp_Emp
					--Select @Email_List
					
					Select distinct(Output_Emp) + ','  From #Temp_Emp Where Output_Emp <> ''  for xml path('') 
				End
END


