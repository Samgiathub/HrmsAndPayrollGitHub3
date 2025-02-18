using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0301ProcessTypeMaster
{
    public decimal ProcessTypeId { get; set; }

    public decimal CmpId { get; set; }

    public string? ProcessType { get; set; }

    public string? AdIdMulti { get; set; }

    public DateTime ModifyDate { get; set; }

    public decimal SortId { get; set; }

    public string? AdNameMulti { get; set; }

    public string LoanIdMulti { get; set; } = null!;

    public string LoanNameMulti { get; set; } = null!;

    public string LeaveIdMulti { get; set; } = null!;

    public string LeaveNameMulti { get; set; } = null!;
}
