

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_Emp_JD_Responsibilty]
	   @Emp_JD_Tran_ID			numeric(18,0) OUTPUT
      ,@Cmp_Id					numeric(18,0)
      ,@Emp_Id					numeric(18,0)
      ,@JDCode_Id				numeric(18,0)
      ,@EffectiveDate			datetime
      ,@Responsibilty			nvarchar(Max)
      ,@tran_type		varchar(1) 
	  ,@User_Id			numeric(18,0) = 0
	  ,@IP_Address		varchar(30)= '' 
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
	BEGIN
	-- --commented by mansi start
	--IF EXISTS(select 1 from T0090_Emp_JD_Responsibilty WITH (NOLOCK) where emp_id = @emp_id and EffectiveDate=@EffectiveDate and JDCode_Id <> @JDCode_Id)
	--		BEGIN
	--		SET @Emp_JD_Tran_ID =0
	--		RETURN 
	--			--delete from T0090_Emp_JD_Responsibilty where emp_id = @emp_id and EffectiveDate=@EffectiveDate
	--		END	
	--		 --commented by mansi end
	 --added by mansi start
		 IF EXISTS(SELECT 1 FROM T0090_Emp_JD_Responsibilty WITH (NOLOCK) WHERE emp_id = @emp_id and EffectiveDate=@EffectiveDate and JDCode_Id = @JDCode_Id and Responsibilty = @Responsibilty)	
			BEGIN
			--print 1
				SET @Emp_JD_Tran_ID =0
			RETURN 
		
			END
		ELSE IF EXISTS(select 1 from T0090_Emp_JD_Responsibilty WITH (NOLOCK) where emp_id = @emp_id and EffectiveDate=@EffectiveDate and JDCode_Id <> @JDCode_Id and Responsibilty <> @Responsibilty)
			BEGIN
			print 2
			
			--SET @Emp_JD_Tran_ID =0 
			
			--RETURN 
				--delete from T0090_Emp_JD_Responsibilty where emp_id = @emp_id and EffectiveDate=@EffectiveDate
				
			END	
		--added by mansi end
		ELSE IF EXISTS(SELECT 1 FROM T0090_Emp_JD_Responsibilty WITH (NOLOCK) WHERE emp_id = @emp_id and EffectiveDate=@EffectiveDate and JDCode_Id = @JDCode_Id and Responsibilty = @Responsibilty)	
			BEGIN
			--print 3
				SET @Emp_JD_Tran_ID =0
			RETURN 
		
			END
	
			select @Emp_JD_Tran_ID = isnull(max(Emp_JD_Tran_ID),0) + 1 from T0090_Emp_JD_Responsibilty	 WITH (NOLOCK)
		
		Insert into T0090_Emp_JD_Responsibilty
		(
			Emp_JD_Tran_ID
			  ,Cmp_Id
			  ,Emp_Id
			  ,JDCode_Id
			  ,EffectiveDate
			  ,Responsibilty
			  ,Create_Date
		)
		VALUES(
			   @Emp_JD_Tran_ID
			  ,@Cmp_Id
			  ,@Emp_Id
			  ,@JDCode_Id
			  ,@EffectiveDate
			  ,@Responsibilty
			  ,GETDATE()
		)
		
	END
	Else If  Upper(@tran_type) ='U' 
	BEGIN
		UPDATE  T0090_Emp_JD_Responsibilty
		SET		Responsibilty	=	@Responsibilty
		WHERE   Emp_JD_Tran_ID = @Emp_JD_Tran_ID 
	END
	Else If  Upper(@tran_type) ='D'
	BEGIN
		DELETE FROM T0090_Emp_JD_Responsibilty WHERE  Emp_Id = @Emp_Id and JDCode_Id =@JDCode_Id and EffectiveDate =@EffectiveDate
	END 
END
