using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190BonusDetail
{
    public decimal BonusTranId { get; set; }

    public decimal BonusId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BonusCalculatedAmount { get; set; }

    public decimal BonusAmount { get; set; }

    public DateTime MonthDate { get; set; }

    public decimal PresentDays { get; set; }

    public decimal WorkingDays { get; set; }

    public decimal? MonthlyExGratiaCalculatedAmt { get; set; }

    public virtual T0180Bonu Bonus { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
