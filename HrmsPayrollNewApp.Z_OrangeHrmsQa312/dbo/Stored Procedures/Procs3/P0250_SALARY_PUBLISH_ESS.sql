

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_SALARY_PUBLISH_ESS]
	 @Publish_ID  numeric output
	,@Cmp_Id numeric(18,0)
	,@Branch_ID  numeric(18,0)
	,@Month numeric(5,0)
	,@Year numeric(5,0)
	,@Is_Publish tinyint
	,@User_ID numeric(18,0) --its employee login id
	,@Emp_ID numeric(18,0)
	,@Comments as varchar(max) = ''
	,@Sal_Type as Varchar(12)  --Mukti(23062016)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


					if exists (select 1 from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where MONTH = @Month and YEAR = @Year and Cmp_ID = @Cmp_Id and Emp_ID = @Emp_ID and Sal_Type=@Sal_Type)
						begin	
						
							UPDATE    T0250_SALARY_PUBLISH_ESS
								SET Is_Publish = @Is_Publish, User_ID = @User_ID, System_Date = GETDATE()
								,Comments = @Comments,Sal_Type=@Sal_Type
								  where MONTH = @Month and YEAR = @Year and Cmp_ID = @Cmp_Id  and Emp_Id = @Emp_ID and Sal_Type=@Sal_Type
						end
					else
					begin
							select @Publish_ID = Isnull(max(Publish_ID),0) + 1 	From T0250_SALARY_PUBLISH_ESS WITH (NOLOCK)	
							INSERT INTO T0250_SALARY_PUBLISH_ESS
						(Publish_ID, Cmp_ID, Branch_ID,Emp_ID, Month,Year, Is_Publish, User_ID, System_Date,Comments,Sal_Type)
						VALUES  (@Publish_ID,@Cmp_ID,@Branch_ID,@Emp_ID,@Month,@Year,@Is_Publish,@User_ID,GETDATE(),@Comments,@Sal_Type)
						
					end

	RETURN




