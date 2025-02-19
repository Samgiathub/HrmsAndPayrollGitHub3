

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0020_PRIVILEGE_MASTER]
	@Privilege_ID AS NUMERIC output,
	@CMP_ID AS NUMERIC,
	@Privilege_Name AS VARCHAR(100),
	@tran_type varchar(1),
	@Is_Active AS NUMERIC,
	@Privilege_Type AS NUMERIC,
	@Branch_id AS NUMERIC,

	@StateID as nvarchar(MAX),		--Added by ronakk 21022022
	@DistrictID as nvarchar(MAX),	--Added by ronakk 21022022
	@TehsilID as nvarchar(MAX),		--Added by ronakk 21022022

	@Branch_Id_Multi as nvarchar(MAX),
	@Vertical_Id_Multi as nvarchar(MAX) = null,
	@SubVertical_Id_Multi as nvarchar(MAx) = null,
	@Department_Id_Multi as nvarchar(MAX) = null, -- Added By Jaina 15-09-2015
	@Copy_From_PrivilegeID AS NUMERIC = 0,  --Mukti 27012016
	@Privilege_CopyCompany_Id as numeric = 0  --Added by Jaina 01-03-2018
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Changes by ronakk 21022022 in whole sp logic
	
	
	if @vertical_id_Multi = ''
		set @vertical_id_Multi = null		-- Added by Gadriwala Muslim 11102014
	if @SubVertical_Id_Multi = ''			-- Added by Gadriwala Muslim 11102014
		set @SubVertical_Id_Multi = null	
	
	IF @Department_Id_Multi = ''         --Added By Jaina 15-09-2015
		set @Department_Id_Multi = null
		
	if @Branch_Id_Multi = ''
		begin
			set @Branch_Id_Multi = 0
		end

		--Added by ronakk 21022022

		if @StateID = ''
		begin
			set @StateID = 0
		end
	

		if @DistrictID = ''
		begin
			set @DistrictID = 0
		end

		if @TehsilID = ''
		begin
			set @TehsilID = 0
		end
	
	--End by ronakk 21022022


	
	Declare @OldValue varchar(max)  = ''

	If @tran_type  = 'I'
		Begin
				if @Privilege_CopyCompany_Id = 0  --Added by Jaina 06-04-2018
				begin
					If Exists(Select Privilege_ID From T0020_PRIVILEGE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Privilege_Name) = upper(@Privilege_Name)) 
						begin
							set @Privilege_ID = 0
							Return 
						end
				end
				
				if @Privilege_CopyCompany_Id > 0  --Added by Jaina 06-04-2018
				begin
					If Exists(Select Privilege_ID From T0020_PRIVILEGE_MASTER WITH (NOLOCK) Where Cmp_ID = @Privilege_CopyCompany_Id and upper(Privilege_Name) = upper(@Privilege_Name)) 
						begin
							set @Privilege_ID = 0
							Return 
						end
				end
				
				select @Privilege_ID = Isnull(max(Privilege_ID),0) + 1 	From T0020_PRIVILEGE_MASTER WITH (NOLOCK)
				
				if (@Privilege_CopyCompany_Id > 0 and @Copy_From_PrivilegeID > 0 )  --Added by Jaina 01-03-2018
				BEGIN						
						
						INSERT INTO T0020_PRIVILEGE_MASTER(Privilege_ID,Cmp_Id,Privilege_Name,Is_Active,Privilege_Type,Branch_Id,
						     Branch_Id_Multi,Vertical_ID_Multi,SubVertical_ID_Multi,Department_Id_Multi,State_id_Multi,District_id_Multi,Tehsil_id_Multi,Old_Effect)
						select  @Privilege_ID,@Privilege_CopyCompany_Id,@Privilege_Name,1,@Privilege_Type,Branch_Id,0,0,0,0,0,0,0,1					
						from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where Privilege_ID = @Copy_From_PrivilegeID
				END				
				ELSE IF (@Copy_From_PrivilegeID > 0)--Mukti 27012016 (To copy details of existing Privilege)
					BEGIN
						INSERT INTO T0020_PRIVILEGE_MASTER(Privilege_ID,Cmp_Id,Privilege_Name,Is_Active,Privilege_Type,Branch_Id,
						     Branch_Id_Multi,Vertical_ID_Multi,SubVertical_ID_Multi,Department_Id_Multi,State_id_Multi,District_id_Multi,Tehsil_id_Multi,Old_Effect)
						select  @Privilege_ID,@cmp_id,@Privilege_Name,1,@Privilege_Type,Branch_Id,Branch_Id_Multi,Vertical_ID_Multi,
						SubVertical_ID_Multi,Department_Id_Multi,State_id_Multi,District_id_Multi,Tehsil_id_Multi,1
						from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where Privilege_ID = @Copy_From_PrivilegeID
					END
				ELSE
					BEGIN
						--INSERT INTO T0020_PRIVILEGE_MASTER
						--                      (Privilege_ID, Cmp_ID, Privilege_Name,Privilege_Type,Branch_Id,Branch_Id_Multi)
						--VALUES     (@Privilege_ID, @Cmp_ID, @Privilege_Name,@Privilege_Type,@Branch_id,isnull(@Branch_Id_Multi,0))
								
						--Change By Jaina 15-09-2015 (Department_Id_Multi)
						INSERT INTO T0020_PRIVILEGE_MASTER
											  (Privilege_ID, Cmp_ID, Privilege_Name,Privilege_Type,Branch_Id,Branch_Id_Multi,Vertical_ID_Multi,
											  SubVertical_ID_Multi,Department_Id_Multi,State_id_Multi,District_id_Multi,Tehsil_id_Multi,Old_Effect)
						VALUES     (@Privilege_ID, @Cmp_ID, @Privilege_Name,@Privilege_Type,@Branch_id,isnull(@Branch_Id_Multi,0),isnull(@Vertical_Id_Multi,0),
						isnull(@SubVertical_Id_Multi,0),ISNULL(@Department_Id_Multi,0),ISNULL(@StateID,0),ISNULL(@DistrictID,0),ISNULL(@TehsilID,0),1)
					END
				
		End
	Else if @Tran_Type = 'U'
		begin
				If Exists(Select Privilege_ID From T0020_PRIVILEGE_MASTER WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(Privilege_Name) = upper(@Privilege_Name) and Privilege_ID <> @Privilege_ID) 
					begin
						set @Privilege_ID = 0
						Return 
					end

				Update T0020_PRIVILEGE_MASTER
				set Privilege_Name = @Privilege_Name
				,Privilege_Type = @Privilege_Type
				,Branch_Id = @Branch_id
				,State_id_Multi = isnull(@StateID,0)	   
				,District_id_Multi = isnull(@DistrictID,0) 
				,Tehsil_id_Multi = isnull(@TehsilID,0)	   
				,Old_Effect =1
				,Branch_Id_Multi = isnull(@Branch_Id_Multi,0)
				,Vertical_ID_Multi = isnull(@Vertical_Id_Multi,0)
				,SubVertical_ID_Multi = isnull(@SubVertical_Id_Multi,0)
				,Department_Id_Multi = ISNULL(@Department_Id_Multi,0)  --Added By Jaina 15-09-2015
				where Privilege_ID = @Privilege_ID
				
				 set @OldValue = 'Old Value' + '#'+ 'Privilege_Name :' + cast(ISNULL(@Privilege_Name,0) as varchar(5)) 
					  + '#' + 'Privilege_Type :' + cast(ISNULL(@Privilege_Type,0) as varchar(5)) 
					  + '#' + 'Branch_id :' + cast(isnull(@Branch_id,0) as varchar(5))
					  + '#' + 'StateID :' + cast(isnull(@StateID,0) as varchar(5))  
					  + '#' + 'DistrictID  :' + isnull(@DistrictID,0)
					  + '#' + 'TehsilID :' + isnull(@TehsilID,0)
					  + '#' + 'Branch_Id_Multi :' + ISNULL(@Branch_Id_Multi,0)  
					  + '#' + 'Vertical_Id_Multi :' + ISNULL(@Vertical_Id_Multi,0)              
					  + '#' + 'SubVertical_Id_Multi :' + ISNULL(@SubVertical_Id_Multi,0) 
					  + '#' + 'Department_Id_Multi :' + ISNULL(@Department_Id_Multi,0)  
					
		end
	Else if @Tran_Type = 'D'
		begin
				If Not Exists(Select Trans_Id From T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK) Where Privilege_ID = @Privilege_ID) 
					begin
						Delete From T0050_PRIVILEGE_DETAILS Where Privilage_ID = @Privilege_ID
						Delete From T0020_PRIVILEGE_MASTER Where Privilege_ID = @Privilege_ID
					end
				Else
					begin
						Delete From T0020_PRIVILEGE_MASTER Where Privilege_ID = @Privilege_ID	
					end
		end
		
		   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Privilege Master',@OldValue,@Cmp_Id,0,0
          

	RETURN




