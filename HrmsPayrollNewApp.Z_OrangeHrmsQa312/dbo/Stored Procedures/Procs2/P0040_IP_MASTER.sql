
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_IP_MASTER]
	@Ip_ID AS NUMERIC(18,0) output
	,@Ip_Address AS VARCHAR(100)
	,@Cmp_ID as numeric(18, 0)
	,@Branch_ID as numeric(18, 0)
	,@Device_No as numeric(18, 0)
	,@Device_Model as Varchar(10)
	,@Is_Active as numeric(18, 0)
	,@Baud_Rate as numeric(18, 0)
	,@Comm_Key as numeric(18, 0)
	,@Comm_Port as numeric(18, 0)
	,@Device_Name as varchar(50)
	,@tran_type varchar(1)
	,@Device_Type varchar(20)
	,@Is_Gate_Pass	tinyint = 0  -- Added by Gadriwala muslim 29122014
	,@Is_Training	tinyint = 0  -- Added by Sneha 20 July 2015
	,@Is_Canteen	tinyint = 0
	,@flag as Varchar(10)  --Mukti 17122015
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	if @Branch_ID = 0
		set @Branch_ID = null
		
	if @tran_type='I' or @tran_type='U'
	begin
	
	If Exists(Select Ip_ID From T0040_IP_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and device_name = @Device_Name and ISNULL(@Device_Name,'') <> '' and Ip_ID <> @Ip_ID)
					begin
						Raiserror('@@Device Name Already exists@@',16,2)
						return -1
					end
	
	end
	
	If @tran_type  = 'I'
		Begin
				If Exists(Select Ip_ID From T0040_IP_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Ip_Address = @Ip_Address)
					begin
						set @Ip_ID = 0
						Return 
					end
				
				select @Ip_ID = Isnull(max(Ip_ID),0) + 1 	From T0040_IP_Master WITH (NOLOCK) 
				
				INSERT INTO T0040_IP_Master
	(Ip_ID 
	,Ip_Address 
	,Cmp_ID 
	,Branch_ID 
	,Device_No 
	,Device_Model 
	,Is_Active 
	,Baud_Rate
	,Comm_Key 
	,Comm_Port 
	,Device_Name
	,Device_type
	,Is_Gate_Pass
	,Is_Training
	,Is_Canteen
	,flag)
				VALUES  
				  ( @Ip_ID 
	,@Ip_Address
	,@Cmp_ID 
	,@Branch_ID 
	,@Device_No 
	,@Device_Model 
	,@Is_Active 
	,@Baud_Rate
	,@Comm_Key 
	,@Comm_Port
	,@Device_Name
	,@Device_Type
	,@Is_Gate_Pass -- Added by Gadriwala Muslim 29122014
	,@Is_Training
	,@Is_Canteen -- added by sneha 20 july 2015
	,@flag)  --Mukti 17122015
		End
	Else if @Tran_Type = 'U'
		begin
		-- Girish 20-10-2008(Start)
		
				If Exists(Select Ip_ID From T0040_IP_Master WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Ip_Address = @Ip_Address and Ip_ID <> @Ip_ID)
					begin
						set @Ip_ID = 0
						Return 
					end
		-- Girish 20-10-2008(End)			
				

				Update T0040_IP_Master
				set    Ip_ID=@Ip_ID 
					,Ip_Address=@Ip_Address
					,Cmp_ID=@Cmp_ID 
					,Branch_ID=@Branch_ID 
					,Device_no=@Device_No 
					,Device_Model=@Device_Model 
					,Is_Active=@Is_Active 
					,Baud_Rate=@Baud_Rate
					,Comm_Key=@Comm_Key 
					,Comm_Port=@Comm_Port 
					,Device_Name = @Device_Name
					,Device_Type=@Device_Type
					,Is_Gate_Pass = @Is_Gate_Pass -- Added by Gadriwala Muslim 29122014
					,Is_Training = @Is_Training  --added by sneha 20 July 2015
					,Is_Canteen = @Is_Canteen
					,flag=@flag  --Mukti 17122015
				where Ip_ID = @Ip_ID
				
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0040_IP_Master Where IP_ID = @IP_ID
		end

	RETURN




