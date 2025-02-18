using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040AdFormulaEligibleSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public string AdFormulaEligible { get; set; } = null!;

    public string? ActualAdFormulaEligible { get; set; }
}
