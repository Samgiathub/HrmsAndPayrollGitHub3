
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Home_Thoughts_Detail] 
	@Cmp_ID numeric(18,0),
	@Type numeric(18,0),
	@Branch_ID numeric(18,0) = null,
	@For_Thought  bigint =0   --Added by Jaina 07-12-2016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Type =0  
	   SELECT COUNT(Leave_Application_ID) as Leave from V0110_Leave_Application_Detail where Application_status='P' and cmp_ID=@Cmp_ID      
	ELSE IF @Type =1
		 Select Count(Loan_App_ID) as Loan from V0100_LOAN_APPLICATION where Loan_status='N' and cmp_ID=@Cmp_ID	 
	ELSE IF  @Type =2	
		SELECT COUNT(claim_App_ID) as Claim from V0100_Claim_Application_New where Claim_App_Status='P' and cmp_ID=@Cmp_ID
	ELSE IF @Type =3
		BEGIN
			Declare @News as varchar(5000)
			Declare @News_Letter_ID numeric(18,0)
			Declare @News_Title varchar(50)
			Declare @News_Description varchar(1000)
			set @News=''

			--select * from T0040_NEWS_LETTER_MASTER where Cmp_ID=@Cmp_ID And Start_Date <= Getdate() And End_Date >= getdate() And Is_Visible=1

			--Declare Cur_News cursor for       
			--select News_Letter_ID,News_Title,News_Description  from  T0040_NEWS_LETTER_MASTER where Cmp_ID=@Cmp_ID And CONVERT(VARCHAR(10),Start_Date,120) <= CONVERT(VARCHAR(10),Getdate(),120) And CONVERT(VARCHAR(10),End_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) And Is_Visible=1  and Flag_T =1 Order by News_Letter_ID -- Alpesh 21-Jul-2011 date compare was not appropriate 
			--open Cur_News      
			--fetch next from Cur_News into  @News_Letter_ID,@News_Title,@News_Description
			--While @@Fetch_Status=0      
			--	begin      
			--		set @News =  @News_Description 
					
			--		fetch next from Cur_News into  @News_Letter_ID,@News_Title,@News_Description
			--	end      
			--close Cur_News      
			--Deallocate Cur_News  

			SELECT	@News = News_Description   --News_Letter_ID,News_Title,News_Description  
			FROM	T0040_NEWS_LETTER_MASTER WITH (NOLOCK)
			WHERE	Cmp_ID=@Cmp_ID And CONVERT(VARCHAR(10),Start_Date,120) <= CONVERT(VARCHAR(10),Getdate(),120) 
					And CONVERT(VARCHAR(10),End_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) And Is_Visible=1  
					AND Flag_T =1  and Flag_T=@For_Thought
			ORDER BY News_Letter_ID 
 
 
			if @News <> ''
				BEGIN
					IF @For_Thought = 0  --Added by Jaina 07-12-2016
						Begin
							set @News = '<Marquee scrollamount=2 width=210px >' + @News + '</Marquee>'	
							select @News as News
						End
					ELSE   --Added by Jaian 07-12-2016
						BEGIN
							select News_Title + ': ' + News_Description aS News  from  T0040_NEWS_LETTER_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And CONVERT(VARCHAR(10),Start_Date,120) <= CONVERT(VARCHAR(10),Getdate(),120) And CONVERT(VARCHAR(10),End_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) And Is_Visible=1  and Flag_T =1 Order by News_Letter_ID 
						END
				END
			ELSE
				SELECT top 0 '' AS News
		--set @News =  @News 
			

		End
	ELSE
		SELECT @News AS News
	 
		RETURN




