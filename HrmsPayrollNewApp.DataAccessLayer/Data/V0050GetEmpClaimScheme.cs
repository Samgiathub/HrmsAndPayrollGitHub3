using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050GetEmpClaimScheme
{
    public DateTime EffectiveDate { get; set; }

    public decimal SchemeId { get; set; }

    public byte IsFwdLeaveRej { get; set; }

    public decimal CmpId { get; set; }

    public string Type { get; set; } = null!;

    public decimal EmpId { get; set; }
}
