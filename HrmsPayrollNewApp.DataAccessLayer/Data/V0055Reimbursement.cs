using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055Reimbursement
{
    public decimal RimbId { get; set; }

    public decimal CmpId { get; set; }

    public string RimbName { get; set; } = null!;

    public string RimbFlag { get; set; } = null!;

    public decimal RimbLevel { get; set; }

    public decimal? AdId { get; set; }

    public string? AdName { get; set; }
}
