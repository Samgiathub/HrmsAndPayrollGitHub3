using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100BonusSlabwise
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? WorkingDays { get; set; }

    public decimal? EligibleDay { get; set; }

    public decimal? PaidDay { get; set; }

    public decimal? LeaveSlab { get; set; }

    public decimal? BonusAmount { get; set; }

    public decimal? AdditionalAmount { get; set; }

    public decimal? TotalBonusAmount { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? BonusEffectOnSal { get; set; }

    public decimal? BonusEffectMonth { get; set; }

    public decimal? BonusEffectYear { get; set; }

    public string? BonusComments { get; set; }

    public decimal ExtraPaidDays { get; set; }
}
