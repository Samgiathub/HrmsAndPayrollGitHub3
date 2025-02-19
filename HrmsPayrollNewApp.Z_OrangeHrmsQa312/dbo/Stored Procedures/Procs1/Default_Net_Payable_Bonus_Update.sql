

-- Created By rohit for update net payble Bonus In the bonus table on 19052016
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Default_Net_Payable_Bonus_Update]        
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
SET ANSI_WARNINGS OFF; 
begin

update T0180_BONUS
set Net_Payable_Bonus = (isnull(Bonus_Amount,0) + isnull(Ex_Gratia_Bonus_Amount,0)) - (ISNULL(Punja_other_cust_bonus_paid,0) + isnull(Intrime_advance_bonus_paid,0) + ISNULL(Deduction_mis_Amount,0) + ISNULL(Income_Tax_on_Bonus,0))
from T0180_BONUS
where Net_Payable_Bonus = 0

return
end



