using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011CompanyDetail
{
    public int TranId { get; set; }

    public decimal? CmpId { get; set; }

    public string? CmpName { get; set; }

    public string? CmpAddress { get; set; }

    public string? OldCmpName { get; set; }

    public string? OldCmpAddress { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? EffectDate { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? CmpHeader { get; set; }

    public string? CmpFooter { get; set; }
}
