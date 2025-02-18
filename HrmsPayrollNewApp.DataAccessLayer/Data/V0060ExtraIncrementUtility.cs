using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0060ExtraIncrementUtility
{
    public DateTime EffectiveDate { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? AppraisalFrom { get; set; }

    public DateTime? AppraisalTo { get; set; }

    public byte EligibleType { get; set; }

    public string Eligibility { get; set; } = null!;

    public int ResId { get; set; }

    public string? ReasonName { get; set; }
}
