

-- Created By Mukti on 29032016 for Default_Entry of Perquisites.
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- ===============================================================
CREATE PROCEDURE [dbo].[InsertDefault_perquisites] 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @IT_Parent_ID as numeric     
Declare @Login_ID as numeric = 0
Declare @Company_ID as numeric     
Declare @IT_Level as numeric     
SET @IT_Parent_ID = NULL    
		
DECLARE perquisites CURSOR FOR
 select distinct Cmp_id from T0010_COMPANY_MASTER WITH (NOLOCK)
OPEN perquisites
fetch next from perquisites into @Company_ID
while @@fetch_status = 0
Begin
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Interest free or concessional Loans' and Cmp_ID=@Company_ID)
		BEGIN
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Interest free or concessional Loans', 'Loans' , 0 , 'I' ,@IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0, 0,1    
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Holiday expenses' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Holiday expenses', 'Holiday expenses' , 0 , 'I' ,@IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1  
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Free or concessional travel' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Free or concessional travel', 'concessional travel' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1   
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Free meals' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Free meals', 'Free meals' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0, 0,1    
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Free Education' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Free Education', 'Free Education' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1   
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Gifts, vouchers etc.' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Gifts, vouchers etc.', 'Gifts,vouchers' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1    
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Credit card expenses' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Credit card expenses', 'Credit card expenses' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID, 0, 0, 'I','',0,'', 0, 0,  0,1   
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Club expenses' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Club expenses', 'Club expenses' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1    
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Use of movable assets by employees' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Use of movable assets by employees', 'Use of movable assets' , 0 , 'I' ,@IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0, 0,1   
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Transfer of assets to employees' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK) 
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Transfer of assets to employees', 'Transfer of assets' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1    
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Value of any other benefit / amenity / service / privilege' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Value of any other benefit / amenity / service / privilege', 'Value other benefit' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1  
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Stock options (non-qualified options)' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Stock options (non-qualified options)', 'Stock options' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1    
		END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Other benefits or amenities' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Other benefits or amenities', 'Other benefits' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'',0, 0,  0,1    
		END
		
		--if not EXISTS(select * from T0070_IT_MASTER where IT_Name='Total value of perquisites' and Cmp_ID=@Company_ID)
		--BEGIN
		--	Set @IT_Level = NULL    
		--	select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER 
		--	EXEC P0070_IT_MASTER 0, @Company_ID, 'Total value of perquisites', 'value of perquisites' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1    
		--END
		
		if not EXISTS(select * from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Total value of profits in lieu of salary as per 17(3)' and Cmp_ID=@Company_ID)
		BEGIN
			Set @IT_Level = NULL    
			select @IT_Level = isnull(max(IT_Level),0) + 1  from T0070_IT_MASTER WITH (NOLOCK)
			EXEC P0070_IT_MASTER 0, @Company_ID, 'Total value of profits in lieu of salary as per 17(3)', 'Total profit' , 0 , 'I' , @IT_Level, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  0, 0, 'I','',0,'', 0, 0,  0,1    
		END

fetch next from perquisites into @Company_ID
End
close perquisites 
deallocate perquisites

