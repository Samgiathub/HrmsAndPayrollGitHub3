using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0011CompanyDetail
{
    public decimal CmpId { get; set; }

    public int? TranId { get; set; }

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string? LoginId { get; set; }

    public string? OldCmpName { get; set; }

    public string? OldCmpAddress { get; set; }

    public DateTime EffectDate { get; set; }

    public string? CmpHeader { get; set; }

    public string? CmpFooter { get; set; }
}
