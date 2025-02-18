using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050IncentiveScheme
{
    public decimal SchemeId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public string? DesigId { get; set; }

    public string? BranchId { get; set; }
}
