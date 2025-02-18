using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050GetSubBranch
{
    public int TranId { get; set; }

    public int? CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? SubBranchId { get; set; }

    public string? Subbranch { get; set; }
}
