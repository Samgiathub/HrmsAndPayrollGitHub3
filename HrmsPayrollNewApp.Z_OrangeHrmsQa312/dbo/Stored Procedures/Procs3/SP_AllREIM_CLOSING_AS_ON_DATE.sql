

-- =============================================
-- Author:		Ripal Patel
-- Create date: 01-Aug-2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AllREIM_CLOSING_AS_ON_DATE]
	@CMP_ID				numeric(18,0),
	@EMP_ID				numeric(18,0),
	@FOR_DATE			DATETIME = null,
	@RC_ID				numeric(18,0) = 0,
	@NotEffectOnSalary	TInyInt = 0
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

CREATE table #Reim_AD
 (      
	  Reim_Tran_ID numeric(18,0) ,     
	  Emp_ID numeric(18,0),
	  AD_ID numeric(18,0),
	  AD_Name varchar(50),
	  Reim_Opening numeric(18,2),
	  Reim_Credit numeric(18,2),
	  Reim_Debit numeric(18,2),
	  Reim_Closing numeric(18,2),
	  For_Date	Datetime
 ) 
 
   ---Change the Select Query by Jimit as not Consdier Transfer case in Max Increment 05022018
	Declare Cur_AdID Cursor For
		Select	AD.AD_ID 
		From	T0100_EMP_EARN_DEDUCTION ED WITH (NOLOCK) inner join
				(
					SELECT I.INCREMENT_ID,I.EMP_ID
					FROM   T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
							(
								 SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
								 FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
									(
											SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM T0095_INCREMENT I3 WITH (NOLOCK)
											WHERE I3.Increment_effective_Date <= @FOR_DATE and I3.Emp_ID = @EMP_ID and I3.Increment_Type Not In ('Transfer','Deputation')
											GROUP BY I3.EMP_ID  
										) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID = I3.Emp_ID	
								   where I.INCREMENT_EFFECTIVE_DATE <= @FOR_DATE and I.Cmp_ID = @Cmp_ID and I.Increment_Type Not In ('Transfer','Deputation')
								   group by I.emp_ID  
							) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 
						WHERE I.EMP_ID = @Emp_ID --AND I.INCREMENT_EFFECTIVE_DATE <= @FOR_DATE						
					)Q On q.Emp_Id = Ed.EMP_ID and Q.Increment_Id = Ed.Increment_Id INNER JOIN
				T0050_AD_MASTER AD WITH (NOLOCK) on ED.AD_ID = AD.AD_ID --and ED.EMP_ID = @EMP_ID
		  Where isnull(AD_NOT_EFFECT_SALARY,0)= @NotEffectOnSalary			          
				And  AD.Allowance_Type = 'R' And isnull(AD.AD_ACTIVE,0) = 1 
	Open Cur_AdID
	Fetch next from Cur_AdID into @RC_ID
	WHILE @@FETCH_STATUS = 0
	Begin
			
			insert into #Reim_AD
			SELECT top 1 lt.Reim_Tran_ID,LT.Emp_ID,LM.AD_ID,aD_Name,Reim_Opening,
					(SELECT SUM(Reim_Credit) 
						FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
								(SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
								WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
								GROUP BY EMP_ID,RC_ID) Q 
								ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE
								where LT.RC_ID = @RC_ID) Reim_Credit,
					((SELECT SUM(Reim_Debit) 
						FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
								(SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
								WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
								GROUP BY EMP_ID,RC_ID) Q 
								ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE
								where LT.RC_ID=@RC_ID)) Reim_Debit,
								
					(Reim_Closing) Reim_Closing,lt.For_Date
					
					FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
							(SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK) 
							WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
							GROUP BY EMP_ID,RC_ID) Q 
							ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE INNER JOIN 
						T0050_AD_Master LM WITH (NOLOCK) ON LT.RC_ID = LM.AD_ID
					where LT.RC_ID=@RC_ID order by  lt.Reim_Tran_ID desc
	
		Fetch next from Cur_AdID into @RC_ID
	End
	Close Cur_AdID
	DeAllocate Cur_AdID

	select * from #Reim_AD
	Drop table #Reim_AD
END

